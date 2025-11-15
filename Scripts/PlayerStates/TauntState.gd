class_name TauntState
extends State

var duration : float

func _ready():
	var anim_name : String = animations[EAnimation.TAUNT]
	duration = anim_player.get_animation(anim_name).length
	character.velocity = Vector2(0, 0)
	anim_player.play(anim_name)

func _physics_process(delta):
	duration -= delta
	if duration <= 0:
		change_state.call(EState.IDLE)
