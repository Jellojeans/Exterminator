extends CharacterBody2D

const BASE_SPEED = 100
const SCUTTLE_SPEED = 450  # Speed when scuttling
const PAUSE_TIME = 1  # Duration of pause
#const speed = 200
signal OOB
signal killed



@export var target_to_chase: CharacterBody2D    #setting up chase target
@export var direction_change_interval: float = 0.2  #making a floating number ie. percentage to dictate direction later
@export var max_angle_variation: float = 30.0  #max angle the bug can change to
@export var scuttle_chance: float = 0.2  # 20% chance to scuttle
@export var pause_chance: float = 0.1  # 10% chance to pause

@export var health_amount : int = 100 # setting the bats health?

@export var damage_amount: int = 2 # damage that the enemy does?

enum State { CHASING, SCUTTLING }    #enum is a list of constants i.e. they don't change.
var state = State.CHASING     #setting the beginning state
var scuttle_timer = 0.0       #setting the scuttle timer
var power_ups = [preload("res://scenes/PowerUp.tscn"),  #loading power ups scene in case of drop
preload("res://scenes/health_up.tscn")]  # same with the health scene
var move_direction: Vector2  # setting the enemy to move
var current_speed: float = BASE_SPEED # setting current_speed's value to that of the float Base_speed
var noise = FastNoiseLite.new()
var noise_offset = randf() * 1000.0
var Player: CharacterBody2D

func _ready() -> void:
	$Sprite2D.visible = false # make enemy sprite invisible 
	noise.seed = randi()
	noise.frequency = 0.5
	#move_direction = Vector2.DOWN.rotated(deg_to_rad(randf_range(-max_angle_variation, max_angle_variation)))
	$ChangeDirectionTimer.wait_time = direction_change_interval #setting the value of direction change to the direction timers value
	$ChangeDirectionTimer.start() #starting the timer
	#Start speed variation timer
	$SpeedVariationTimer.wait_time = randf_range(1.0, 3.0)  # Random interval
	$SpeedVariationTimer.start()
	$WallDetector.enabled = true #enabling the texture rect
	print("timer started")

func _process(delta: float) -> void:
	#velocity = move_direction * current_speed
	#move_and_slide()
	
	move(delta)

func move(delta):
	Player = Global.PlayerBody
	if not Player:
		return

	match state:            #calling match on the enum state. asking for only one state
		State.CHASING:       #this is the state being called.
			var desired_direction = (Player.global_position - global_position).normalized() 
			$WallDetector.force_raycast_update()  #making sure raycast is awake

			if $WallDetector.is_colliding():  #is the raycast touching anything?
				var collider = $WallDetector.get_collider() 
				if collider != Player: # if the variable collider is not the player
					# Enter scuttle mode
					state = State.SCUTTLING  #set the state to scuttling
					scuttle_timer = 0.8  # Move for 0.5 seconds before resuming chase
					var turn_angle = PI / 4  # 45 degrees
					if randf() < 0.5:  #if random number is less than .5
						turn_angle *= -1  # Randomly choose left or right
					move_direction = desired_direction.rotated(turn_angle).normalized()
					current_speed = BASE_SPEED  #set current_speed to Base_speed
				else:
					move_direction = desired_direction #if raycast isn't colliding
			else:
				move_direction = desired_direction 

		State.SCUTTLING:
			scuttle_timer -= delta #set timer minus delta
			if scuttle_timer <= 0: #if timer is less than zero
				state = State.CHASING  # Go back to chasing
				return  # Skip movement this frame so we don't double-process

	velocity = move_direction * current_speed  # set velocity to movedirection x current speed
	move_and_slide()
	look_at(Player.global_position)  #make enemy face player

		

#func _change_appearance():
	#$Sprite2D/splatter.play("splat")
	#queue_free()
	

func _on_speed_variation_timer_timeout() -> void: #when the speed timer times out
	var rand_val = randf() #variable with a random number
	if rand_val < pause_chance: # if random number is less than the pause chance value
		current_speed = 0  # Pause movement
		$AnimatedSprite2D.pause() #play pause animation
		print("pausebug")
		await get_tree().create_timer(PAUSE_TIME).timeout #wait for the timer
		$AnimatedSprite2D.play() #play move animation
		current_speed = BASE_SPEED  # Resume normal speed
	elif rand_val < pause_chance + scuttle_chance: #else if the random value is less than pause chance + scuttle chance
		current_speed = SCUTTLE_SPEED  # Scuttle faster
		print("scuttlebug")
		await get_tree().create_timer(randf_range(0.3, 1.0)).timeout #await a timer that was created with a random number for wait time
		current_speed = BASE_SPEED  # Back to normal

	# Restart timer with a new random interval
	$SpeedVariationTimer.wait_time = randf_range(1.0, 3.0)  #another random timer
	$SpeedVariationTimer.start()  #start the timer



func _on_change_direction_timer_timeout() -> void:     #when the change direction timer times out
	var noise_value = noise.get_noise_1d(noise_offset)
	var angle_variation = deg_to_rad(noise_value * max_angle_variation)
	#move_direction = Vector2.DOWN.rotated(angle_variation).normalized()
	noise_offset += 0.1

func destroy():
	emit_signal("killed")  # Notify the spawner before removal / sending out signal
	$AnimatedSprite2D.visible = false  #hiding the move animation
	$CollisionShape2D.set_deferred("disabled", true)  # Prevent physics errors
	current_speed = 0  # Pause movement
	$CPUParticles2D.emitting = true #makes partical emitter turn on
	$LightOccluder2D.visible = false #makes shadow go away
	$Sprite2D.visible = true # turning on sprite that depicts death
	%SplatNoise.play() #playing death sound
	$Sprite2D/splatter.play("splat") #showing dead bug sprite
	await $Sprite2D/splatter.animation_finished  #waiting until the animation has finished playing.
	on_death()  #go to on death function
	queue_free()  # Remove the object from the scene
	

func on_death():
	var drop_chance: float = 0.1  #Setting a variable to represent the chance of the enemy dropping an item
	if randf() < drop_chance: #if random number is less than drop chance
		var power_up_index = randi() % power_ups.size() 
		var power_up_instance = power_ups[power_up_index].instantiate()
		power_up_instance.global_position = global_position
		get_parent().add_child(power_up_instance)
		#queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("OOB")
	#queue_free() removes bugs when off screen



	



	
