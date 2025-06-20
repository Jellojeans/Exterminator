extends Node

var max_health := 100 # variable for max health set to 100
var current_health: int #variable to store the players current health

signal Health_Change # signal to emit when an action occurs, in this case the change of health state

@export var damage_amount: int = 2 #setting up a damage amount

func _ready() -> void:
	current_health = max_health #giving the current health the value of the variable max health

func decrease_health(health_amount: int): # when health is decreased
	current_health -= health_amount #subtract health amount from current health
	if current_health < 0: # if health is less than zero
		current_health = 0 #health is then equal to zero
	Health_Change.emit(current_health)# emit the health change signal.
	print("Health decreased:", current_health)

func increase_health(health_amount: int): #function to increase health
	current_health += health_amount #Set current health to health amount + current health
	if current_health > max_health: # if health is greater than max health
		current_health = max_health #current health will equal max health
	Health_Change.emit(current_health) #emit the health change signal
	print("Health increased:", current_health)
