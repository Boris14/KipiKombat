class_name Player
extends CharacterBody2D

signal health_changed(old_health, new_health)

const SPEED = 300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var max_health := 100.0

@onready var _is_player_1 = true if has_meta("is_player_1") else false
@onready var _left_input = "player1left" if _is_player_1 else "player2left"
@onready var _right_input = "player1right" if _is_player_1 else "player2right"
@onready var _punch_input = "player1punch" if _is_player_1 else "player2punch"
@onready var _kick_input = "player1kick" if _is_player_1 else "player2kick"

var _curr_health : float = max_health

func _ready():
	pass
	
var is_action_playing = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if is_action_playing == true:
		return

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis(_left_input, _right_input)
	if direction != 0:
		velocity.x = direction * SPEED
		if (direction > 0):
			$AnimatedSprite2D.play("Walk Forward")
		else:
			$AnimatedSprite2D.play("Walk Backward")
	else:
		velocity.x = 0
		$AnimatedSprite2D.play("Idle")
				
	if Input.is_action_just_pressed(_punch_input):
		is_action_playing = true
		$AnimatedSprite2D.connect("animation_looped", _on_animated_sprite_animation_looped)
		$AnimatedSprite2D.play("Jab")
		#_curr_health -= 10
		#health_changed.emit(_curr_health + 10, _curr_health)
	if Input.is_action_just_pressed(_kick_input):
		is_action_playing = true
		$AnimatedSprite2D.connect("animation_looped", _on_animated_sprite_animation_looped)
		$AnimatedSprite2D.play("Forward Kick")

	move_and_slide()

func _on_animated_sprite_animation_looped():
	is_action_playing = false
