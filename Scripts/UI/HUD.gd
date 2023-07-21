class_name HUD
extends Control

@onready var player_1_healthbar = $Player1HealthBar: get = get_healthbar_1 
@onready var player_2_healthbar = $Player2HealthBar: get = get_healthbar_2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func get_healthbar_1() -> HealthBar:
	return player_1_healthbar

func get_healthbar_2() -> HealthBar:
	return player_2_healthbar
