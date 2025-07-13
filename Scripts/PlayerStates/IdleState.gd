class_name IdleState
extends State

func _ready():
	anim_player.play(animations[EAnimation.IDLE])

func move_left():
	change_state.call(EState.WALK)

func move_right():
	change_state.call(EState.WALK)
	
func squat():
	change_state.call(EState.SQUAT)
	
func punch():
	change_state.call(EState.PUNCH)

func low_kick():
	change_state.call(EState.LOW_KICK)
	
func block():
	change_state.call(EState.BLOCK)
	
func squat_block():
	change_state.call(EState.SQUAT_BLOCK)
