extends Area2D

var speed = 5000

signal killed  # Declare the signal
signal hit     #set signal

func _ready() -> void:
	$AnimationPlayer.play("fire")
func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta    #setting the move direction, and speed for bullet (position equals transform.x * speed* delta + position
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("mobs"):               #if body is in mobs group
		emit_signal("hit", body)                #emit the signal called hit
		#body.queue_free()
		body.destroy()
		queue_free()
	else:
		if body.is_in_group("WorldItem"):
			queue_free()
func _on_VisibleOnScreenNotifier2D_screen_exited() -> void:
	queue_free()
