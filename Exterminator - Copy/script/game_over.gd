extends Node



func _ready():
	$score.text = "Your final Score: " + str(Global.total_enemies_removed)
	$Label/AnimationPlayer.play("fade")

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
