--managers.hud:show_hint({text = 'MSG'})
managers.chat:_receive_message(1, 'Sharpshooter', (managers.player:player_unit():movement():current_state() == 'tased') and 'TASED' or (managers.player:player_unit():movement():tased() and 'TASED2' or 'FAIL'), tweak_data.system_chat_color)
