local _damage_bullet = PlayerDamage.damage_bullet
function PlayerDamage:damage_bullet(attack_data)
	if _fps_aim_assist_autocounter and attack_data.attacker_unit then
		managers.player:player_unit():inventory():equipped_unit():base():check_autoaim2_no_angle_check_enemies_insert(attack_data.attacker_unit:key())
	end
	return _damage_bullet(self, attack_data)
end
