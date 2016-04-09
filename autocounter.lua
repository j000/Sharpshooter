
--[[
File name : autocounter.lua

PostRequireScripts:
  - [lib/units/beings/player/playerdamage, aim\autocounter.lua]
  
Current v1.0

Change log :
	v1.0
		Initial release.
--]]

local _damage_bullet = PlayerDamage.damage_bullet
function PlayerDamage:damage_bullet(attack_data)
	if attack_data.attacker_unit then managers.player:player_unit():inventory():equipped_unit():base():check_autoaim2_no_angle_check_enemies_insert(attack_data.attacker_unit:key()) end
	return _damage_bullet(self, attack_data)
end

