class_name IdleToSquatState
extends State

var anim_name : String

func _ready():
	anim_name = animations[EAnimation.IDLE_TO_SQUAT]
	character.velocity = Vector2(0, 0)
	anim_player.connect("animation_finished", _on_animation_finished)
	anim_player.play(anim_name)

func _physics_process(delta):
	if is_queued_for_deletion():
		return
	if not Input.is_action_pressed(character._squat_input):
		change_state.call(EState.IDLE)

func _on_animation_finished(finished_anim_name : String):
	if finished_anim_name == anim_name:
		change_state.call(EState.SQUAT)
