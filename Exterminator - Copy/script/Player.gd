extends CharacterBody2D

@export var bullet_types: Array[PackedScene]  # Array to store bullet scenes
@export var movespeed := int(350)   #exporting the movespeed variable to game studio
@export var cursor_texture: Texture2D    # allowing a texture to be added for the cross hair


var current_bullet_index: int = 0  # Index to track which bullet is selected



@onready var shoot_timer = $Timer  # Get the Timer node
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("level")  #Adding to group level
	Global.PlayerBody = self
	print("Health change signal connected!")  # Debug





# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	look_at(get_global_mouse_position())
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2(16, 16)) #setting the size of the curser to 16x16 pixals
	
	


	
	if Input.is_action_just_pressed("shoot") and shoot_timer.is_stopped(): #if button is pressed, and it's the shoot button, and the timer is not on, go to shoot function
		shoot()
		
func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left","right","forward","back").normalized() #set up variable for input direction, get vector(direction)
	
	
		
	Move(input_dir) #run the move script below.

func Move(input_dir : Vector2):
	velocity = input_dir * movespeed #setting velocity to input_dir x movespeed.
	
	#check to see if player is moving, to play an animation.
	if input_dir != Vector2.ZERO:      #if input_dir is not equal to vector2.zero (zero) then it's walking, not zero
		$AnimationPlayer.play("walk")
	else:  # else means if is zero
		$AnimationPlayer.play("idle") #player is not moving when zero
	move_and_slide()  #built in move function
	


		
		
func shoot():
	if bullet_types.size() > 0:         
		var bullet_scene = bullet_types[current_bullet_index]   #setting up a bullet_scene variable array
		if bullet_scene:
			var b = bullet_scene.instantiate()       #making a variable called "b" and assigning it the value of bullet_scen, and instantiating the scene
			get_tree().current_scene.add_child(b)  #calling this location, making a child scene from variable b
			b.global_position = %Muzzle.global_position   #setting the bullet start position at the marker2D named muzzle
			b.rotation = %Muzzle.global_rotation #setting the bullets rotation the same
			#b.look_at(get_global_mouse_position())
			

			match current_bullet_index:  #setting up the bullet index array each is a bullet scene.
				0:
					%spitwad.play()
				1:
					%fire.play()
			
			shoot_timer.start()





func switch_bullet():
	if bullet_types.size() == 0:  #if bullet_types size is zero / this is like a pre checked criteria to run the following code
		return
	
	# Only switch if we're currently using the default bullet (index 0)
	if current_bullet_index == 0:
		current_bullet_index = 1  # Or any specific upgraded index if more are added later
		shoot_timer.wait_time = 0.055  #adding the time between shots allowed
		print("Player switched to upgraded bullet:", current_bullet_index)
		$PowerUpTimer.start() #starting a 10 second timer that the new bullet will be active for
	if $PowerUpTimer.time_left > 20: #limit the power up time
		print("power up max time reached")
		pass
	
	else:
		var remaining = $PowerUpTimer.time_left
		$PowerUpTimer.stop()
		$PowerUpTimer.wait_time = remaining + 10.0
		$PowerUpTimer.start()
		print("Extended power-up time. New time:", $PowerUpTimer.wait_time)
		
	
	
	
	
	


func _on_hurtbox_body_entered(body: Node2D) -> void:  #defining hurtbox (area2d) parameters
	if body.is_in_group("mobs"):                     # if the colliding body is in the group "mobs"
		print("enemy hit player", body.damage_amount)
		HealthManager.decrease_health(5)       #decrease health from the health manager script
		if HealthManager.current_health == 0:   # if health is already at zero
			get_tree().change_scene_to_file("res://scenes/game_over.tscn")  # Load Game Over screen


func _on_power_up_timer_timeout() -> void:  #called when the PowerUpTimer times out
	$PowerUpTimer.stop()   #stop the timer
	current_bullet_index = 0  #change bullet scene back to zero
	shoot_timer.wait_time = .082 #back to previous wait time between bullets.
