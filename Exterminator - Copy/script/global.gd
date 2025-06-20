extends Node

var PlayerBody: CharacterBody2D
var total_enemies_removed: int = 0
var enemy_kill_ratio: int:
	get:
		return total_enemies_removed
