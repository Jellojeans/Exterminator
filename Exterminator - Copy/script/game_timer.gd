extends Node

@export var game_duration: float = 120.0  # Game lasts 120 seconds

var game_over: bool = false

func _ready():
	%GameTimer.wait_time = game_duration
	%GameTimer.start()
	%GameTimer.timeout.connect(_on_level_up)

func _on_level_up():
	pass
