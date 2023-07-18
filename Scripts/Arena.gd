extends Node2D

@export var player_scene : PackedScene

var _player_1
var _player_2

# Called when the node enters the scene tree for the first time.
func _ready():
	if $Player1Start != null and player_scene != null:
		_player_1 = player_scene.instantiate() as Player
		_player_1.position = $Player1Start.position
		_player_1.set_meta("is_player_1", true)
		add_child(_player_1)
		
# Ctrl + K for multiple line comment
	if $Player2Start != null and player_scene != null:
		_player_2 = player_scene.instantiate() as Player
		_player_2.position = $Player2Start.position
		add_child(_player_2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
