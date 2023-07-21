class_name HealthBar
extends ProgressBar

const MAX_VALUE = 100

var max_health : float

func set_max_health(in_max_health):
	max_health = in_max_health
	value = MAX_VALUE

func _on_player_health_changed(old_health, new_health):
	value = new_health / max_health * MAX_VALUE

