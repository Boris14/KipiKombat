class_name State
extends Node

var change_state : Callable
var anim_player : AnimationPlayer
var character : Player
var area : Area2D
var collisions
var animations = {
	EAnimation.IDLE : "Idle",
	EAnimation.WALK_FORWARD : "Walk Forward",
	EAnimation.WALK_BACKWARDS: "Walk Backwards",
	EAnimation.PUNCH : "Punch",
	EAnimation.LOW_KICK : "Low Kick",
	EAnimation.HIGH_KNOCKBACK : "High Knockback",
	EAnimation.BLOCK : "Block",
	EAnimation.IDLE_TO_SQUAT : "Idle to Squat",
	EAnimation.SQUAT : "Squat",
	EAnimation.SQUAT_BLOCK : "Squat Block",
}

func setup(change_state, character, anim_player, area):
	self.change_state = change_state
	self.anim_player = anim_player
	self.character = character
	self.area = area
	character.connect("health_changed", _on_character_health_changed)
	if area != null:
		area.connect("body_entered", _on_area_body_entered)
		area.monitoring = false

func _exit_tree():
	if area != null:
		area.monitoring = false

func _activate_area(duration):
	if area == null:
		return
	area.monitoring = true
	await get_tree().create_timer(duration).timeout
	area.monitoring = false

# The methods below correspond to the players input
# Each state can override a method to react properly
func move_left():
	pass

func move_right():
	pass
	
func idle_to_squat():
	pass
	
func squat():
	pass
	
func punch():
	pass
	
func low_kick():
	pass
	
func block():
	pass
	
func squat_block():
	pass

# Signal handlers	
func _on_area_body_entered(body : Node2D):
	pass
	
func _on_character_health_changed(old_health : float, new_health : float):
	pass
