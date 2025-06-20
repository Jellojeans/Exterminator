extends Area2D
@export var bullet_index: int = 0
#var current_bullet_index: int = 0  # Index to track which bullet is selected
func _ready():
	$DespawnTimer.start() #start despawn timer

func _on_body_entered(body: Node2D) -> void: # when entering body
	if body.is_in_group("player"): # if body is in group player
		HealthManager.increase_health(10) # update health manager script with 10 additional points
		
		$CPUParticles2D.emitting = true # emit particles 
		
		print("Health increased",(HealthManager.current_health))
		print("Trying to play sound. Node: ", $HeartHappy)
		$HeartHappy.play() #play sound
		await get_tree().create_timer(0.5).timeout # wait
		queue_free() #release asset
	
		


func _on_despawn_timer_timeout() -> void:
	print("heart go bye bye")
	$AnimationPlayer.play("HeartDissolve")
	
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
