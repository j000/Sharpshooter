if _fps_aim_assist then -- When sharpshooter is on: disable both
	_fps_aim_assist = false
	_fps_aim_assist_autoshoot = false
else -- When sharpshooter is off: enable
	_fps_aim_assist = true
end
--managers.chat:_receive_message(1, 'Sharpshooter', _fps_aim_assist and (_fps_aim_assist_autoshoot and 'AUTOSHOOT' or 'AUTOAIM') or 'OFF', tweak_data.system_chat_color)
managers.hud:show_hint({text = 'Sharpshooter: ' .. (_fps_aim_assist and (_fps_aim_assist_autoshoot and 'AUTOSHOOT' or 'AUTOAIM') or 'OFF')})
