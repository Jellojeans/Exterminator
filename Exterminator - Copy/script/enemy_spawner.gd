extends Node2D

@export var enemy_scene: PackedScene  # Assign your enemy scene in the inspector

@export var enemy_two: PackedScene   #may not need.

@export var spawn_rate: float = 4.0   # Time between spawns (lower = faster)
@export var spawn_positions: Array[Node2D]  # List of spawn points
@export var max_enemies: int = 7  # Max enemies allowed on screen at once


var current_enemy_count: int = 0  # Track the number of enemies
var spawn_timer: Timer  # Timer to control enemy spawn rate

func _ready():
	start_spawning() #run the start spawning function

func start_spawning():
	# Set up the enemy spawn timer
	spawn_timer = Timer.new() #set a new timer
	spawn_timer.name = "SpawnTimer" #name it
	spawn_timer.wait_time = spawn_rate #set it's wait time to the spawn rate variable
	spawn_timer.autostart = true #autostart timer
	spawn_timer.one_shot = false #not one shot
	spawn_timer.timeout.connect(spawn_enemy) #
	add_child(spawn_timer)

	# Start difficulty increase timer
	%DifficultyIncrease.start() #start timer to time when difficulty will increase
	print("difficulty increase started")

func spawn_enemy():
	if current_enemy_count >= max_enemies or spawn_positions.size() == 0: #if enemy count is greater than max enemies
		return
	
	var spawn_point = spawn_positions[randi() % spawn_positions.size()] #spawn point is set to a random spawn position
	var enemy_instance # setting a variable
	
	if Global.enemy_kill_ratio > 40 and enemy_two:      # if enemies killed is more than 40, and enemy scene 2 exists
		enemy_instance = enemy_two.instantiate()         #instantiate enemy two
	else:
		if not enemy_scene:                              #if not enemy scene, must be enemy 2                                                 
			return
		enemy_instance = enemy_scene.instantiate()        #instantiate an enemy

	enemy_instance.global_position = spawn_point.global_position   #
	enemy_instance.OOB.connect(On_screen_exit)   # 
	enemy_instance.killed.connect(_on_enemy_removed)  #When killed, connect to on enemy removed function
	get_parent().add_child(enemy_instance)             #making a copy of the enemy scene and adding it
	current_enemy_count += 1                            #update enemy counter variable
	
	
func _on_enemy_removed():  #when an enemy is removed.
	current_enemy_count = max(0, current_enemy_count - 1)   #remove one enemy from the count
	Global.total_enemies_removed += 1                       #add one to overall score of enemies removed
	

func On_screen_exit():
	current_enemy_count = max(0, current_enemy_count - 1)    #if the enemy leaves the screen.
	

func _on_difficulty_increase_timeout() -> void:             #when the difficulty timer times out
	# Make enemies spawn faster by decreasing spawn_rate
	var totalEnemy = max_enemies 
	if totalEnemy <= 30:              #the maximum number that max enemies can be when increaseddddddddddddd
			spawn_rate = max(.5, spawn_rate - 0.5)    #increase the spawn rate but don't let it drop below 2.2
			max_enemies += 1                           #allow an additional enemy in the scene for max enemies.
			print("spawn rate increased (faster), new rate:", spawn_rate)
	

	# Update the existing spawn timer d
			spawn_timer.stop()
			spawn_timer.wait_time = spawn_rate
			spawn_timer.start()

	# Restart the difficulty increase timer if needed
			%DifficultyIncrease.stop()
			%DifficultyIncrease.wait_time = 10.0  # Optional: how often to increase difficulty
			%DifficultyIncrease.start()

	
