extends Node2D

@export var player1_scene : PackedScene
@export var player2_scene : PackedScene

@onready var _hud = $HUD as HUD

var _player_1
var _player_2

# Called when the node enters the scene tree for the first time.
func _ready():
	if $Player1Start != null and player1_scene != null:
		_player_1 = player1_scene.instantiate() as Player
		_player_1.position = $Player1Start.position
		_player_1.set_meta("is_player_1", true)
		_hud.get_healthbar_1().set_max_health(_player_1.max_health)
		_player_1.connect("health_changed", _hud.get_healthbar_1()._on_player_health_changed)
		add_child(_player_1)
		
# Ctrl + K for multiple line comment
	if $Player2Start != null and player2_scene != null:
		_player_2 = player2_scene.instantiate() as Player
		_player_2.position = $Player2Start.position
		_player_2.scale = Vector2(-1, 1)
		_hud.get_healthbar_2().set_max_health(_player_2.max_health)
		_player_2.connect("health_changed", _hud.get_healthbar_2()._on_player_health_changed)
		add_child(_player_2)
		
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
