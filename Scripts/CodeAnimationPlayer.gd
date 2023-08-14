class_name CodeAnimationPlayer
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
@onready var _knockback_input = "player1knockback" if _is_player_1 else "player2knockback"

var _curr_health : float = max_health
var _is_uninterruptible_animation_active:bool = false

func _ready():
	pass
	
	
func _physics_process(delta):
	# Add the gravity.
#	if not is_on_floor():
#		velocity.y += gravity * delta
		
	if Input.is_action_just_pressed(_knockback_input):
		_play_uninterruptible_animation("Hit Body")
		return
		
	if _is_uninterruptible_animation_active:
		return

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis(_left_input, _right_input)
	if direction:
		velocity.x = direction * SPEED
		if (direction > 0):
			$AnimationPlayer.play("Walk Forward")
		else:
			$AnimationPlayer.play("Walk Backward")
		move_and_slide()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$AnimationPlayer.play("Idle")
		
	if Input.is_action_just_pressed(_punch_input):
		_play_uninterruptible_animation("Jab")
#		_curr_health -= 10
#		health_changed.emit(_curr_health + 10, _curr_health)
	if Input.is_action_just_pressed(_kick_input):
		_play_uninterruptible_animation("Forward Kick")


func _play_uninterruptible_animation(name: StringName):
	_is_uninterruptible_animation_active = true
	if ($AnimationPlayer.current_animation == name):
		$AnimationPlayer.stop()
	$AnimationPlayer.play(name)	
	$AnimationPlayer.connect("animation_finished", _play_uninterruptible_animation_finished_handler)

	
func _play_uninterruptible_animation_finished_handler(anim_name: StringName):
	_is_uninterruptible_animation_active = false
	$AnimationPlayer.disconnect("animation_finished", _play_uninterruptible_animation_finished_handler)
