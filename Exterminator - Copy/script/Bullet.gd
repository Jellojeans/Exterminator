extends Area2D
signal hit
signal killed  # Declare the signal


var speed = 4000

func _physics_process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed * delta
	
	
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("mobs"):
		emit_signal("hit", body)
		body.destroy()
		#body.queue_free()
		queue_free()
	else:
		if body.is_in_group("WorldItem"):
			queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
