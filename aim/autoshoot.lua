if not _fps_aim_assist then -- When sharpshooter is off: enable both
	_fps_aim_assist = true
	_fps_aim_assist_autoshoot = true
else -- When sharpshooter is on: toggle autoshoot
	_fps_aim_assist_autoshoot = not _fps_aim_assist_autoshoot
end
--managers.chat:_receive_message(1, 'Sharpshooter', _fps_aim_assist and (_fps_aim_assist_autoshoot and 'AUTOSHOOT' or 'AUTOAIM') or 'OFF', tweak_data.system_chat_color)
managers.hud:show_hint({text = 'Sharpshooter: ' .. (_fps_aim_assist and (_fps_aim_assist_autoshoot and 'AUTOSHOOT' or 'AUTOAIM') or 'OFF')})
