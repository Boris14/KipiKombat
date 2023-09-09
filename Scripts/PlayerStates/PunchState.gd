class_name PunchState
extends State

var duration

func _ready():
	duration = anim_player.get_animation(animations[EAnimation.PUNCH]).length
	character.velocity = Vector2(0, 0)
	anim_player.play(animations[EAnimation.PUNCH])

func _physics_process(delta):
	duration -= delta
	if(duration <= 0):
		change_state.call(EState.IDLE)
