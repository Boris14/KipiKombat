class_name KickState
extends State

var duration : float
var area_activation_time : float
var area_active_duration : float

func _ready():
	var animation_id = animations[EAnimation.KICK]
	duration = anim_player.get_animation(animation_id).length
	area_activation_time = duration / 2
	area_active_duration = duration / 3
	character.velocity = Vector2(0, 0)
	anim_player.play(animation_id)

func _physics_process(delta):
	duration -= delta
	if duration <= 0:
		change_state.call(EState.IDLE)
	elif duration <= area_activation_time:
		_activate_area(area_active_duration)
		
func _on_area_body_entered(body : Node2D):
	super._on_area_body_entered(body)
	if body != character:
		body.take_damage(character.kick_damage)
