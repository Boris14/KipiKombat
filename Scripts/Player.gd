class_name Player
extends CharacterBody2D

const SPEED = 300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var _is_player_1 = true if get_meta("is_player_1") else false
@onready var _left_input = "player1left" if _is_player_1 else "player2left"
@onready var _right_input = "player1right" if _is_player_1 else "player2right"
@onready var _punch_input = "player1punch" if _is_player_1 else "player2punch"

func _ready():
	# Save layer 1 for the ground
	set_collision_layer_value(2, _is_player_1)
	set_collision_layer_value(3, not _is_player_1)
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis(_left_input, _right_input)
	if direction:
		velocity.x = direction * SPEED
		if (direction > 0):
			$AnimatedSprite2D.play("Walk")
		else:
			$AnimatedSprite2D.play_backwards("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$AnimatedSprite2D.play("Idle")

	move_and_slide()
