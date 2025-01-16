class_name IdleState
extends State

func _ready():
	anim_player.play(animations[EAnimation.IDLE])

func move_left():
	change_state.call(EState.WALK)

func move_right():
	change_state.call(EState.WALK)
	
func punch():
	change_state.call(EState.PUNCH)

func mid_kick():
	change_state.call(EState.MID_KICK)
	
func low_kick():
	change_state.call(EState.LOW_KICK)
	
func block():
	change_state.call(EState.BLOCK)
