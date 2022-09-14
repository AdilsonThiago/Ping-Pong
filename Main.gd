extends Control

func _on_StartButton_pressed():
	get_tree().change_scene("res://Assets/World.tscn")
	pass

func _on_QuitButton_pressed():
	get_tree().quit()
	pass
