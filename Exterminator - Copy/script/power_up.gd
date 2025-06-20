extends Area2D
@export var bullet_index: int = 0
#var current_bullet_index: int = 0  # Index to track which bullet is selected
func _ready():
	$AutoDespawnTimer.start() #starting despawn timer, this will make the item dissapear after a certain amount of time if not picked up

func _on_body_entered(body: Node2D) -> void: #when the body enters
	$CPUParticles2D.emitting = true # turning on partical emitter
	if body.is_in_group("player"): # if the entered body is the player and...
		if body.has_method("switch_bullet"): #if the player has the method "switch bullet"
			if "switch_bullet" in body:
				body.switch_bullet() #then run the switch bullet function
				
				$ohyeah.play() #play sound
				await get_tree().create_timer(1.0).timeout #wait for one second
		queue_free() #remove asset
		

	


func _on_auto_despawn_timer_timeout() -> void:
	print("Power-up disappearing...")
	%AnimationPlayer.play("new_animation")
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
