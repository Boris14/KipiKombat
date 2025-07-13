class_name BlockState
extends State

var anim_name : String

func _ready():
	anim_name = animations[EAnimation.BLOCK]
	character.velocity = Vector2(0, 0)
	anim_player.connect("animation_finished", _on_animation_finished)
	anim_player.play(anim_name)

func _physics_process(delta):
	if is_queued_for_deletion():
		return
	if not Input.is_action_pressed(character._block_input):
		change_state.call(EState.IDLE)
	
func _exit_tree():
	super._exit_tree()
	character.is_blocking = false
	
func _on_animation_finished(finished_anim_name : String):
	if finished_anim_name == anim_name:
		character.is_blocking = true
		
