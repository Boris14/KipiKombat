class_name WalkState
extends State

var min_move_speed = 0.005
var friction = 0.32
var walk_left_anim : String
var walk_right_anim : String

func setup(change_state, character, anim_player, area):
	super.setup(change_state, character, anim_player, area)
	if character.has_meta("is_player_1"):
		walk_left_anim = animations.get(EAnimation.WALK_BACKWARDS)
		walk_right_anim = animations.get(EAnimation.WALK_FORWARD)
	else:
		walk_left_anim = animations.get(EAnimation.WALK_FORWARD)
		walk_right_anim = animations.get(EAnimation.WALK_BACKWARDS)

func _physics_process(_delta):
	if is_queued_for_deletion():
		return
	if abs(character.velocity.x) < min_move_speed:
		change_state.call(EState.IDLE)
	character.velocity.x *= friction

func move_left():
	anim_player.play(walk_left_anim)
	character.velocity.x -= character.speed

func move_right():
	anim_player.play(walk_right_anim)
	character.velocity.x += character.speed
	
func punch():
	change_state.call(EState.PUNCH)
	
func kick():
	change_state.call(EState.KICK)

