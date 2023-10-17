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

func kick():
	change_state.call(EState.KICK)

func block():
	change_state.call(EState.BLOCK)
