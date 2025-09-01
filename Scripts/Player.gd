class_name Player
extends CharacterBody2D

signal health_changed(old_health, new_health)

@export var max_health := 100.0
@export var punch_damage := 10.0
@export var kick_damage := 20.0
@export var speed = 250.0

@onready var _is_player_1 = true if has_meta("is_player_1") else false
@onready var _left_input = "player_1_left" if _is_player_1 else "player_2_left"
@onready var _right_input = "player_1_right" if _is_player_1 else "player_2_right"
@onready var _squat_input = "player_1_squat" if _is_player_1 else "player_2_squat"
@onready var _punch_input = "player_1_punch" if _is_player_1 else "player_2_punch"
@onready var _low_kick_input = "player_1_low_kick" if _is_player_1 else "player_2_low_kick"
@onready var _block_input = "player_1_block" if _is_player_1 else "player_2_block"
@onready var _squat_block_input = "player_1_squat_block" if _is_player_1 else "player_2_squat_block"
@onready var _curr_health : float = max_health

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var class_per_state
var area_per_state
var state : State
var is_blocking := false

# Input (currently not used)
var input_buffer : Array[String] = []
var input_buffer_max_size := 10
var input_last_key_pressed := "N"
#var input_has_combo_timed_out := true

func _init():
	class_per_state = {
		EState.IDLE : IdleState,
		EState.WALK : WalkState,
		EState.SQUAT : SquatState,
		EState.IDLE_TO_SQUAT : IdleToSquatState,
		EState.PUNCH : PunchState,
		EState.LOW_KICK : LowKickState,
		EState.HIGH_KNOCKBACK : HighKnockbackState,
		EState.BLOCK : BlockState,
		EState.SQUAT_BLOCK : SquatBlockState,
	}

func _ready():
	area_per_state = {
		EState.IDLE : null,
		EState.WALK : null,
		EState.SQUAT : null,
		EState.PUNCH : $PunchArea,
		EState.LOW_KICK : $KickArea,
		EState.HIGH_KNOCKBACK : null,
		EState.BLOCK : null,
		EState.SQUAT_BLOCK : null,
		EState.IDLE_TO_SQUAT : null,
	}
	change_state(EState.IDLE)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis(_left_input, _right_input)
	if direction:
		state.move_left() if direction < 0 else state.move_right()

	move_and_slide()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if InputMap.action_has_event(_punch_input, event):
				state.punch()
			elif InputMap.action_has_event(_low_kick_input, event):
				state.low_kick()
			elif InputMap.action_has_event(_block_input, event):
				state.block()
			elif InputMap.action_has_event(_squat_block_input, event):
				state.squat_block()
			elif InputMap.action_has_event(_squat_input, event):
				state.idle_to_squat()

func change_state(new_state):
	if not class_per_state.has(new_state):
		printerr("Invalid state given")
		return
	if state != null:
		state.queue_free()
	state = class_per_state.get(new_state).new()
	state.setup(change_state, self, $AnimationPlayer, area_per_state[new_state])
	add_child(state)


func take_damage(damage):
	if is_blocking:
		return
	var old_health = _curr_health
	_curr_health -= damage
	if not state is HighKnockbackState:
		change_state(EState.HIGH_KNOCKBACK)
	# Important to call health_changed at the end 
	# because the state in connected to it
	health_changed.emit(old_health, _curr_health)


# Used to capture the input of the player in a buffer
# as a combination of direction + action
func _register_input():
# The direction matrix:
# 1 2 3
# 4 N 6
# 7 8 9
# N - neutral; 8 - down; 2 - up; 6 - right; etc. 
	var input_key = "N"
	if Input.get_axis(_left_input, _right_input) > 0:
		input_key = "6"
	elif Input.get_axis(_left_input, _right_input) < 0:
		input_key = "4"
	elif _is_player_1:
		input_key = "6"
	else:
		input_key = "4"
	
	if Input.is_action_just_pressed(_punch_input):
		input_key += "p"
	if Input.is_action_just_pressed(_low_kick_input):
		input_key += "lk"
	
	if input_key != input_last_key_pressed:
		if input_buffer.size() >= input_buffer_max_size:
			input_buffer.pop_front()
		input_buffer.push_back(input_key)
		input_last_key_pressed = input_key
		print(input_buffer)
	
