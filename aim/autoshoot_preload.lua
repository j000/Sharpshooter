
local org_check_action_primary_attack = PlayerStandard._check_action_primary_attack
function PlayerStandard:_check_action_primary_attack(t, input)
	if _fps_aim_assist then
		local feedback
		if managers then
			if managers.player then
				if managers.player:player_unit() then
					if managers.player:player_unit():camera() then
						if managers.player:player_unit():camera():camera_unit() then
							feedback = managers.player:player_unit():camera():camera_unit():base():chk_autoaim()
						end
					end
				end
			end
		end
		if not _fps_aim_assist_autoshoot then
		elseif not feedback then
		elseif not feedback.error_dot or not feedback.dis then
		elseif feedback.error_dot > 0.99 then
			local error_dis = math.sin(math.acos(feedback.error_dot)) * feedback.dis
			if feedback.dis < 500 and error_dis < 20.0 then --Near distance in cm
				input.btn_primary_attack_state = true
				input.btn_primary_attack_press = true
			else
				if (feedback.dis > feedback.effective_dis) and (not feedback.is_sniper) then
				elseif error_dis <= 11.0 or (feedback.is_running and error_dis <= 17.5) then
					input.btn_primary_attack_state = true
					input.btn_primary_attack_press = true
				else
				end
			end
		else
		end
	end
	return org_check_action_primary_attack(self, t, input)
end

_fps_aim_assist_autoshoot = false

local org_start_action_steelsight = PlayerStandard._start_action_steelsight
function PlayerStandard:_start_action_steelsight(t)
	if managers.player:player_unit():inventory():equipped_unit():base():weapon_tweak_data().category == 'grenade_launcher' then --Auto correct pitch angle Disable it if you don't like it.
		local from_pos = managers.player:player_unit():camera():position()
		local tar_vec = Vector3()
		mvector3.set(tar_vec, managers.player:player_unit():camera():forward())
		mvector3.multiply(tar_vec, 40000)
		mvector3.add(tar_vec, from_pos)
		local vis_ray = World:raycast('ray', from_pos, tar_vec, 'slot_mask', managers.slot:get_mask( 'bullet_impact_targets' ))
		if vis_ray then
			managers.player:player_unit():camera():camera_unit():base():clbk_aim_assist(vis_ray)
		end
	end
	return org_start_action_steelsight(self, t)
end

local org_end_action_steelsight = PlayerStandard._end_action_steelsight
function PlayerStandard:_end_action_steelsight(t)
	local result = org_end_action_steelsight(self, t)
	managers.player:player_unit():camera():camera_unit():base()._gl_aiming = nil
	return result
end

