
--[[
File name : autoshoot.lua

KeyBindings:
  - [Z, aim/autoshoot.lua]
  
Current v1.0

Change log :
	v1.0
		Initial release.
--]]

--Turn it off when it bugs
if not _fps_aim_assist then return end
_fps_aim_assist_autoshoot = not _fps_aim_assist_autoshoot
managers.hud:show_hint({text = "Auto shoot (".. tostring(_fps_aim_assist_autoshoot) ..")"})

