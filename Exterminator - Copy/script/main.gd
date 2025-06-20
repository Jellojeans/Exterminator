extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	HealthManager.Health_Change.connect(_on_health_changed) #connect to health manager script
	$Player/CanvasLayer/HealthBar.min_value = 0 #setting the minimum value for the health bar
	$Player/CanvasLayer/HealthBar.max_value = HealthManager.max_health # setting the max value
	$Player/CanvasLayer/HealthBar.value = HealthManager.current_health # assigning the current health value

func _on_health_changed(new_health: int):
	$Player/CanvasLayer/HealthBar.value = HealthManager.current_health
