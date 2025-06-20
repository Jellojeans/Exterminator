extends Control


func _on_start_pressed() -> void:
	change_scene()

	
	
func change_scene():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_touchstart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_touchquit_pressed() -> void:
	get_tree().quit()
