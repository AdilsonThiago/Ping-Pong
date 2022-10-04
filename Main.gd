extends Control

func _process(delta):
	if Networking._is_running_multiplayer() and Networking._is_server() and Networking.players.size() == 2:
		Networking._start_game()
	pass

func _on_StartButton_pressed():
	get_tree().change_scene("res://Assets/World.tscn")
	pass

func _on_QuitButton_pressed():
	get_tree().quit()
	pass

func _on_MultiplayerLan_pressed():
	$Panel.show()
	pass

func _on_Close_pressed():
	$Panel.hide()
	pass

func _on_Create_pressed():
	if not Networking._is_server():
		Networking._create_server()
	pass

func _on_Connect_pressed():
	if not Networking._is_server():
		Networking._update_ip($Panel/LineEdit.text)
		Networking._enter_server()
	pass
