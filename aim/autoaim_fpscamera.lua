--[[
File name : autoaim_fpscamera.lua

PostRequireScripts:
  - [lib/units/cameras/fpcameraplayerbase, aim/autoaim_fpscamera.lua]
  
Current v1.6.1

Change log :
	v1.6.1
		Fix a bug that it suddenly stop aiming while in steelsight, but it seems to be normal after re-entering steelsight again.
	v1.6
		Add aim support when charging melee weapons
	v1.5
		Add support for auto-shoot.
	v1.4
		It will not aim the target out of range when using grenade launchers .
	v1.3
		Add aim support for grenade launchers.
	v1.2
		Fix the problem that it aims an invalid target.
	v1.1
		Improve the accuracy while carrying / bleeding out.
	v1.0
		Initial release.
--]]
local org_get_aim_assist = FPCameraPlayerBase._get_aim_assist
function FPCameraPlayerBase:_get_aim_assist(t, dt)
	if self._aim_assisting then
		local r_value_x, r_value_y = org_get_aim_assist(self, t, dt)
		return r_value_x, r_value_y
	else
		return 0, 0
	end
end

local org_clbk_stop_aim_assist = FPCameraPlayerBase.clbk_stop_aim_assist
function FPCameraPlayerBase:clbk_stop_aim_assist()
	self._aim_assisting = nil
	org_clbk_stop_aim_assist(self)
end

function FPCameraPlayerBase:chk_autoaim()
	if _fps_aim_assist then
		if not self._aim_assisting then
			if managers.player:player_unit():movement():tased() then
				managers.chat:_receive_message(1, 'Sharpshooter', '/!\\ Tased /!\\', tweak_data.system_chat_color)
			end
			if managers.player:player_unit():movement():current_state():in_steelsight() or managers.player:player_unit():movement():current_state():_is_meleeing() or managers.player:player_unit():movement():tased() then
				local dir = managers.player:player_unit():camera():forward()
				if managers.player:player_unit():inventory():equipped_unit():base():weapon_tweak_data().category == 'grenade_launcher' and self._gl_aiming then dir = self._gl_aiming end
				local closest_ray, feedback = managers.player:player_unit():inventory():equipped_unit():base():check_autoaim2(managers.player:player_unit():camera():position(), dir, managers.player:player_unit():movement():current_state():_is_meleeing())
				if closest_ray then
					local chase_running_target = false
					if feedback.is_running then
						if feedback.error_dot then
							if feedback.error_dot > 0.99 then
								chase_running_target = true
							end
						end
					end
					self:clbk_aim_assist(closest_ray, chase_running_target)
				end
				return feedback
			end
		end
	end
end

function FPCameraPlayerBase:clbk_aim_assist(col_ray, chase_running_target)
	if col_ray then
		if self._aim_assisting then self._aim_assisting = false end
		local ray = col_ray.ray
		local r1 = self._parent_unit:camera():rotation()
		local r2 = self._aim_assist.mrotation or Rotation()
		mrotation.set_look_at(r2, ray, math.UP)
		local target_yaw = mrotation.yaw(r2)
		local target_pitch = mrotation.pitch(r2)
		if managers.player:player_unit():inventory():equipped_unit():base():weapon_tweak_data().category == 'grenade_launcher' then --Grenade launchers supported!
			local mypos = managers.player:player_unit():camera():position()
			local target_pos = col_ray.position
			if target_pos then 
				local tar_vec = Vector3()
				mvector3.set(tar_vec, target_pos)
				mvector3.subtract(tar_vec, mypos)
				local dis = mvector3.normalize(tar_vec)
				local target_angle, correct_angle
				target_angle = -target_pitch
				local arcsin = (2 * dis * 981 * math.cos(target_angle)) / 16000000
				if arcsin > 0 and arcsin < 1 then
					correct_angle = math.asin(arcsin) * 0.5 - target_angle
					target_pitch = correct_angle
					self._gl_aiming = Vector3()
					mvector3.set(self._gl_aiming, tar_vec)
				else
					return --Too far
				end
			end
		elseif self._camera_properties.current_tilt ~= 0 then --Carry and shoot? No problem!
			if target_pitch ~= 0 then
				local a = target_pitch
				local b = self._camera_properties.current_tilt
				target_pitch = math.atan(math.tan(a) * math.cos(b) * math.cos(b))
				local correct_angle_yaw = math.atan(math.tan(a) * math.cos(b) * math.sin(b))
				target_yaw = target_yaw + correct_angle_yaw
			end
		end
		local yaw = mrotation.yaw(r1) - target_yaw
		local pitch = mrotation.pitch(r1) - target_pitch
		if yaw > 180 then
			yaw = yaw - 360
		elseif yaw < -180 then
			yaw = yaw + 360
		end
		if pitch > 180 then
			pitch = pitch - 360
		elseif pitch < -180 then
			pitch = 360 + pitch
		end
		mvector3.set_static(self._aim_assist.direction, yaw, -pitch, 0)
		self._aim_assist.distance = mvector3.normalize(self._aim_assist.direction)
		if self._aim_assist.distance > 0 then
			self._tweak_data.aim_assist_speed = self._aim_assist.distance * 5 + 200
			if chase_running_target then self._tweak_data.aim_assist_speed = 4000 end
			self._aim_assisting = true
		else
			self._aim_assist.distance = 0
			mvector3.set_static(self._aim_assist.direction, 0, 0, 0)
		end
	end
end

_fps_aim_assist = false

