--[[
File name : check_autoaim2.lua

PostRequireScripts:
  - [lib/units/weapons/RaycastWeaponBase, aim/check_autoaim2.lua]
  
Current v1.5.1

Change log :
	v1.5.1
		Fixed a crash when playing as a client.
	v1.5
		Add counter attack funtionality.
		It now decides the effective distance depending on the weapon's accuracy.
			When the target is out of the effective distance, it will auto-aim but NOT auto-shoot EVEN IF you have auto-shoot toggle on(except for snipers).
		
	v1.4
		Add aim support when charging melee weapons.
		Improve the mechanism of finding the best target.
	v1.3
		Add support for auto-shoot.
	v1.2
		Add aim support for grenade launchers.
	v1.1
		It won't aim enemies that have been dominated / converted.
	v1.0
		Initial release.
--]]

local org_init = RaycastWeaponBase.init
function RaycastWeaponBase:init(unit)
	self._no_angle_check_enemies = {}
	return org_init(self, unit)
end

function RaycastWeaponBase:check_autoaim2(from_pos, direction, melee)
	local closest_ray
	local tar_vec = Vector3()
	local com = Vector3()
	local ignore_units = self._setup.ignore_units
	local slotmask = self._bullet_slotmask
	local enemies = managers.enemy:all_enemies()
	local can_engage_shield = ((self._can_shoot_through_shield or self._bullet_class ~= InstantBulletBase or self:weapon_tweak_data().category == 'grenade_launcher') and not melee) or (managers.player:has_category_upgrade('player', 'shield_knock') and melee)
	local largest_error_dot
	local best_target
	local target_weight
	local max_dis = 40000
	local target_dis
	local error_dot
	local max_error_dis = 12.0 -- cm
	if self._bullet_class == InstantExplosiveBulletBase then max_error_dis = 17.5 end --cm
	local max_error_dis_shield_explosive = 35.0 --cm
	local hit_chance = 0.6 --60 percent
	local effective_dis = (max_error_dis * math.sqrt(1.0 / hit_chance) / math.sin(self:_get_spread(managers.player:player_unit()))) * math.cos(self:_get_spread(managers.player:player_unit()))
	local effective_dis_shield_explosive = (max_error_dis_shield_explosive * math.sqrt(1.0 / hit_chance) / math.sin(self:_get_spread(managers.player:player_unit()))) * math.cos(self:_get_spread(managers.player:player_unit()))
	local feedback_eff_dis = effective_dis
	local feedback_target_running = false
	local target_running = false
	local last_cmp_eff_dis = effective_dis_shield_explosive + 1
	local need_angle_check = true
	local is_sniper = false
	if melee then max_dis = tweak_data.blackmarket.melee_weapons[managers.blackmarket:equipped_melee_weapon()].stats.range or 175 end
	for u_key, enemy_data in pairs(enemies) do
		local enemy = enemy_data.unit
		local no_angle_check_enemy_idx
		need_angle_check = true
		for idx, data in pairs(self._no_angle_check_enemies) do --Counter attack
			if not enemies[data] then
				table.remove(self._no_angle_check_enemies, idx) --The enemy is dead
			elseif data == enemy:key() then
				need_angle_check = false --The enemy attacked you before.
				no_angle_check_enemy_idx = idx
			end
		end
		target_weight = 0 --The less weight a target is, the more threatening it is
		if not alive(enemy_data.unit) then 
		elseif enemy:base():lod_stage() ~= 1 then 
		elseif enemy:base():char_tweak().access == 'teamAI4' then 
		elseif enemy:movement():team() == managers.player:player_unit():movement():team() or enemy:anim_data().hands_tied then
		else
			if self._bullet_class ~= InstantBulletBase and not melee then
				mvector3.set(com, enemy:movement():m_com()) --Center of body
			else
				if enemy:anim_data().run then
					mvector3.set(com, enemy:movement():m_head_pos())
					target_running = true
				else
					mvector3.set(com, enemy:body(enemy:character_damage()._head_body_name):position())
					target_running = false
				end
			end
			mvector3.set(tar_vec, com)
			mvector3.subtract(tar_vec, from_pos)
			local dis = mvector3.normalize(tar_vec)
			local finding_angle = 15 --degree
			if dis < 750 then
				finding_angle = 90 --cm / degree
			elseif dis < 2000 then
				finding_angle = 30
			end
			error_dot = mvector3.dot(direction, tar_vec)
			if error_dot > 1 then error_dot = 1 end
			if ((not need_angle_check) or (math.cos(finding_angle) < error_dot)) then
				mvector3.multiply(tar_vec, max_dis)
				mvector3.add(tar_vec, from_pos)
				local vis_ray = World:raycast('ray', from_pos, tar_vec, 'slot_mask', slotmask, 'ignore_unit', ignore_units)
				if vis_ray then
					if vis_ray.unit:in_slot(8) then --Shield
						if not alive(vis_ray.unit:parent()) then
						elseif not can_engage_shield then
						elseif vis_ray.unit:parent():key() ~= u_key then
						else
							local test_eff_dis = effective_dis
							if self._bullet_class == InstantExplosiveBulletBase then test_eff_dis = effective_dis_shield_explosive end
							target_weight = math.sin((math.acos(error_dot) * 0.5) * 2) * dis
							target_weight = target_weight * target_weight
							if (not best_target or best_target > target_weight) or (target_dis > last_cmp_eff_dis and dis <= test_eff_dis) then
								if self:weapon_tweak_data().category == 'grenade_launcher' and not melee then
									mvector3.set(vis_ray.ray, enemy:position())
									mvector3.subtract(vis_ray.ray, from_pos)
									mvector3.normalize(vis_ray.ray)
								else
									largest_error_dot = error_dot
								end
								closest_ray = vis_ray
								best_target = target_weight
								target_dis = dis
								feedback_eff_dis = test_eff_dis
								feedback_target_running = target_running
								last_cmp_eff_dis = test_eff_dis
								is_sniper = false
							end
						end
					elseif vis_ray.unit:key() == u_key then
						target_weight = math.sin((math.acos(error_dot) * 0.5) * 2) * dis
						target_weight = target_weight * target_weight
						if (not best_target or best_target > target_weight) or (target_dis > effective_dis and dis <= effective_dis and vis_ray.unit:base()._tweak_table ~= 'sniper') then --Aiming snipers is not affected by 'effective distance'
							if self:weapon_tweak_data().category == 'grenade_launcher' and not melee then
								mvector3.set(vis_ray.ray, enemy:position())
								mvector3.subtract(vis_ray.ray, from_pos)
								mvector3.normalize(vis_ray.ray)
							else
								largest_error_dot = error_dot
							end
							closest_ray = vis_ray
							best_target = target_weight
							target_dis = dis
							feedback_eff_dis = effective_dis
							feedback_target_running = target_running
							is_sniper = vis_ray.unit:base()._tweak_table == 'sniper'
						end
					end
				end
			end
		end
		if (not target_weight) and (not need_angle_check) then --Can not aim the enemy, remove it.
			table.remove(self._no_angle_check_enemies, no_angle_check_enemy_idx)
		end
	end
	return closest_ray, { error_dot = largest_error_dot, dis = target_dis, effective_dis = feedback_eff_dis, is_running = feedback_target_running, is_sniper = is_sniper }
end

function RaycastWeaponBase:check_autoaim2_no_angle_check_enemies_insert(enemy_key)
	table.insert(self._no_angle_check_enemies, enemy_key)
end
