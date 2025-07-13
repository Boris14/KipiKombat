class_name SquatState
extends State

func _ready():
	character.velocity = Vector2(0, 0)
	anim_player.play(animations[EAnimation.SQUAT])

func _physics_process(delta):
	if is_queued_for_deletion():
		return
	if not Input.is_action_pressed(character._squat_input):
		change_state.call(EState.IDLE)
