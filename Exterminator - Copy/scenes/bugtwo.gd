extends CharacterBody2D

const BASE_SPEED = 200
const SCUTTLE_SPEED = 550  # Speed when scuttling
const PAUSE_TIME = 2  # Duration of pause
#const speed = 200
signal OOB
signal killed



@export var target_to_chase: CharacterBody2D
@export var direction_change_interval: float = 0.2
@export var max_angle_variation: float = 30.0
@export var scuttle_chance: float = 0.3  # 20% chance to scuttle
@export var pause_chance: float = 0.2  # 10% chance to pause

@export var health_amount : int = 100

@export var damage_amount: int = 5

enum State { CHASING, SCUTTLING }
var state = State.CHASING
var scuttle_timer = 0.0
var power_ups = [preload("res://scenes/PowerUp.tscn"),
preload("res://scenes/health_up.tscn")]
var move_direction: Vector2
var current_speed: float = BASE_SPEED
var noise = FastNoiseLite.new()
var noise_offset = randf() * 1000.0
var Player: CharacterBody2D

func _ready() -> void:
	$Sprite2D.visible = false
	noise.seed = randi()
	noise.frequency = 0.5
	#move_direction = Vector2.DOWN.rotated(deg_to_rad(randf_range(-max_angle_variation, max_angle_variation)))
	$ChangeDirectionTimer.wait_time = direction_change_interval
	$ChangeDirectionTimer.start()
	#Start speed variation timer
	$SpeedVariationTimer.wait_time = randf_range(1.0, 3.0)  # Random interval
	$SpeedVariationTimer.start()
	$WallDetector.enabled = true
	print("timer started")

func _process(delta: float) -> void:
	#velocity = move_direction * current_speed
	#move_and_slide()
	
	move(delta)

func move(delta):
	Player = Global.PlayerBody
	if not Player:
		return

	match state:
		State.CHASING:
			var desired_direction = (Player.global_position - global_position).normalized()
			$WallDetector.force_raycast_update()

			if $WallDetector.is_colliding():
				var collider = $WallDetector.get_collider()
				if collider != Player:
					# Enter scuttle mode
					state = State.SCUTTLING
					scuttle_timer = 0.8  # Move for 0.5 seconds before resuming chase
					var turn_angle = PI / 4  # 45 degrees
					if randf() < 0.5:
						turn_angle *= -1  # Randomly choose left or right
					move_direction = desired_direction.rotated(turn_angle).normalized()
					current_speed = BASE_SPEED
				else:
					move_direction = desired_direction
			else:
				move_direction = desired_direction

		State.SCUTTLING:
			scuttle_timer -= delta
			if scuttle_timer <= 0:
				state = State.CHASING  # Go back to chasing
				return  # Skip movement this frame so we don't double-process

	velocity = move_direction * current_speed
	move_and_slide()
	look_at(Player.global_position)

		

#func _change_appearance():
	#$Sprite2D/splatter.play("splat")
	#queue_free()
	

func _on_speed_variation_timer_timeout() -> void:
	var rand_val = randf()
	if rand_val < pause_chance:
		current_speed = 0  # Pause movement
		$AnimatedSprite2D.pause()
		print("pausebug")
		await get_tree().create_timer(PAUSE_TIME).timeout
		$AnimatedSprite2D.play()
		current_speed = BASE_SPEED  # Resume normal speed
	elif rand_val < pause_chance + scuttle_chance:
		current_speed = SCUTTLE_SPEED  # Scuttle faster
		print("scuttlebug")
		await get_tree().create_timer(randf_range(0.3, 1.0)).timeout
		current_speed = BASE_SPEED  # Back to normal

	# Restart timer with a new random interval
	$SpeedVariationTimer.wait_time = randf_range(1.0, 3.0)
	$SpeedVariationTimer.start()



func _on_change_direction_timer_timeout() -> void:
	var noise_value = noise.get_noise_1d(noise_offset)
	var angle_variation = deg_to_rad(noise_value * max_angle_variation)
	#move_direction = Vector2.DOWN.rotated(angle_variation).normalized()
	noise_offset += 0.1

func destroy():
	emit_signal("killed")  # Notify the spawner before removal
	$AnimatedSprite2D.visible = false
	$CollisionPolygon2D.set_deferred("disabled", true)  # Prevent physics errors
	current_speed = 0  # Pause movement
	$CPUParticles2D.emitting = true
	$LightOccluder2D.visible = false
	$Sprite2D.visible = true
	%SplatNoise.play()
	$Sprite2D/splatter.play("splat")
	await $Sprite2D/splatter.animation_finished
	on_death()  
	queue_free()  # Remove the object from the scene
	

func on_death():
	var drop_chance: float = 0.1
	if randf() < drop_chance:
		var power_up_index = randi() % power_ups.size()
		var power_up_instance = power_ups[power_up_index].instantiate()
		power_up_instance.global_position = global_position
		get_parent().add_child(power_up_instance)
		#queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("OOB")
	#queue_free()
