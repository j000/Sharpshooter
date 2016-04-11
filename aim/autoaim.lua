--[[
File name : autoaim.lua

KeyBindings:
  - [B, aim/autoaim.lua]
  
Current v1.2

Change log :
	v1.2
		Remove patch to GameSetup, since it is done in 'autoshoot_preload.lua'.
	v1.1
		Merged with the toggle script.
	v1.0
		Initial release.
--]]

--Turn it off when it bugs
_fps_aim_assist = not _fps_aim_assist
if not _fps_aim_assist and _fps_aim_assist_autoshoot then
	_fps_aim_assist_autoshoot = false
end
--managers.hud:show_hint({text = 'Auto aim ('.. tostring(_fps_aim_assist) ..')'})
--managers.chat:_receive_message(1, 'AUTOAIM', _fps_aim_assist and 'ON' or 'OFF', tweak_data.system_chat_color)
--managers.chat:_receive_message(1, 'Sharpshooter', _fps_aim_assist and (_fps_aim_assist_autoshoot and 'AUTOSHOOT' or 'AUTOAIM') or 'OFF', tweak_data.system_chat_color)
managers.hud:show_hint({text = 'Sharpshooter: ' .. (_fps_aim_assist and (_fps_aim_assist_autoshoot and 'AUTOSHOOT' or 'AUTOAIM') or 'OFF')})
