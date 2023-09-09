class_name State
extends Node

var change_state : Callable
var anim_player : AnimationPlayer
var character : Player
var animations = {
	EAnimation.IDLE : "Idle",
	EAnimation.WALK_FORWARD : "Walk Forward",
	EAnimation.WALK_BACKWARDS: "Walk Backwards",
	EAnimation.PUNCH : "Punch",
	EAnimation.KICK : "Kick",
}

func setup(change_state, anim_player, character):
	self.change_state = change_state
	self.anim_player = anim_player
	self.character = character


# The methods below correspond to the players input
# Each state can override a method and react properly

func move_left():
	pass

func move_right():
	pass
	
func punch():
	pass
	
func kick():
	pass
