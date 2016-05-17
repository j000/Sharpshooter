if not _fps_aim_assist then -- When sharpshooter is off: enable both
	_fps_aim_assist = true
	_fps_aim_assist_autocounter = true
else -- When sharpshooter is on: toggle autocounter
	_fps_aim_assist_autocounter = not _fps_aim_assist_autocounter
end
managers.hud:show_hint({text = 'Sharpshooter: AUTOCOUNTER ' .. (_fps_aim_assist_autocounter and 'ENABLED' or 'DISABLED')})
