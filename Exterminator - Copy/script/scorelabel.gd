extends Label

func _process(delta):
	text = "Enemies Defeated: " + str(Global.total_enemies_removed)
