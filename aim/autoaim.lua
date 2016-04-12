_fps_aim_assist = not _fps_aim_assist
if not _fps_aim_assist and _fps_aim_assist_autoshoot then
	_fps_aim_assist_autoshoot = false
end
--managers.hud:show_hint({text = 'Auto aim ('.. tostring(_fps_aim_assist) ..')'})
--managers.chat:_receive_message(1, 'AUTOAIM', _fps_aim_assist and 'ON' or 'OFF', tweak_data.system_chat_color)
--managers.chat:_receive_message(1, 'Sharpshooter', _fps_aim_assist and (_fps_aim_assist_autoshoot and 'AUTOSHOOT' or 'AUTOAIM') or 'OFF', tweak_data.system_chat_color)
managers.hud:show_hint({text = 'Sharpshooter: ' .. (_fps_aim_assist and (_fps_aim_assist_autoshoot and 'AUTOSHOOT' or 'AUTOAIM') or 'OFF')})
