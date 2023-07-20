class_name HealthBar
extends ProgressBar

var max_health = 1

func set_max_health(in_max_health):
	max_health = in_max_health

func _on_player_health_changed(old_health, new_health):
	value = new_health / max_health

