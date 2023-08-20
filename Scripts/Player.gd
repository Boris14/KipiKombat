class_name Player
extends CharacterBody2D

signal health_changed(old_health, new_health)

const SPEED = 300.0

enum PlayerState
{
	IDLE,
	WALK_FORWARD,
	WALK_BACKWARDS,
	PUNCH,
	KICK,
	KNOCKBACK
}

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var max_health := 100.0

@onready var _is_player_1 = true if has_meta("is_player_1") else false
@onready var _left_input = "player1left" if _is_player_1 else "player2left"
@onready var _right_input = "player1right" if _is_player_1 else "player2right"
@onready var _punch_input = "player1punch" if _is_player_1 else "player2punch"
@onready var _state_machine : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")

var _state: PlayerState
var _curr_health : float = max_health

func _ready():
	change_state(PlayerState.IDLE)
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis(_left_input, _right_input)
	if direction:
		change_state(PlayerState.WALK_FORWARD if direction > 0 else PlayerState.WALK_BACKWARDS)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		change_state(PlayerState.IDLE)
	
	if Input.is_action_just_pressed(_punch_input):
		change_state(PlayerState.PUNCH)
		_curr_health -= 10
		health_changed.emit(_curr_health + 10, _curr_health)

	match _state_machine.get_current_node():
		"Idle":
			velocity.x = move_toward(velocity.x, 0, SPEED)
		"Walk Forward":
			velocity.x = SPEED
		"Walk Backwards":
			velocity.x = -SPEED
		["Punch", "Kick"]:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		"Knockback":
			velocity.x = -SPEED
		_:
			print("Wow")

	move_and_slide()


func change_state(new_state : PlayerState) -> void:
	match(new_state):
		_state:
			return
		PlayerState.IDLE:
			_state_machine.travel("Idle")
		PlayerState.WALK_FORWARD:
			_state_machine.travel("Walk Forward")
		PlayerState.WALK_BACKWARDS:
			_state_machine.travel("Walk Backwards")
		PlayerState.PUNCH:
			_state_machine.travel("Punch")
		PlayerState.KICK:
			_state_machine.travel("Kick")
		PlayerState.KNOCKBACK:
			_state_machine.travel("Knockback")
			
