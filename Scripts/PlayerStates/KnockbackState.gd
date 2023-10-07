class_name KnockbackState
extends State

var duration : float
var direction : int
var knockback_force_multiplier := 50.0
var friction := 0.85

func _ready():
	var animation_id = animations[EAnimation.KNOCKBACK]
	duration = anim_player.get_animation(animation_id).length
	anim_player.play(animation_id)
	direction = -1 if character.has_meta("is_player_1") else 1

func _physics_process(delta):
	character.velocity.x *= friction
	duration -= delta
	if duration <= 0:
		character.velocity = Vector2(0, 0)
		change_state.call(EState.IDLE)
	
func _on_character_health_changed(old_health : float, new_health : float):
	super._on_character_health_changed(old_health, new_health)
	var damage = old_health - new_health
	if damage <= 0:
		return
	character.velocity.x += direction * damage * knockback_force_multiplier
