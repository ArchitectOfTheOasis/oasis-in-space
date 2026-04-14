## Resolves and plays animations based on 'state' and 'direction'
## Uses a mapping system to auto-generate the animation names.
## Adding a new state entry will automatically create all four directions
## for the state. [br][New Entry -> {State.ATTACK : "attack"} -> "attack_right"][br]
## States get updated by signals on 'state_change' in the 'StateManager' and 
## 'direction_change' in the 'Player'
## 
##
## USAGE:[br]
## 1. Add animation using the format "state_direction".[br]
## 2. Add the <state> prefix to 'state_map'[br]
## 3. Emit the signals 'direction_change' in the 'Player'.[br]
## 4. Emit the signal 'state_change' in the 'StateManager'.[br]
#
#
# TODO:
# • If state changes, the animation gets interrupted.
# • Link player speed with animation (especially space movement)
# 
# ARCHITECTURE DEBT:
# • Currently tied to 'Player'
#     Make system generic 
# • Adding 'Sneak' doesn't work, because its an intern modifier of state 'Move' 
extends Node
class_name AnimationManager
#region === DECLARATION ===

@export var anim_player_path : NodePath
@onready var anim_player := get_node(anim_player_path)

@export var anim_shadow_path : NodePath
@onready var anim_shadow := get_node(anim_shadow_path)


@export var player_path : NodePath
@onready var player := get_node(player_path)

@export var state_manager_path : NodePath
@onready var state_manager := get_node(state_manager_path)



const State = GlobalEnums.States
const Direction = GlobalEnums.Direction

const str_connector = "_"
const SHADOW_KEY : String = "shadow"
const PLAYER_KEY : String = "player"



var direction_map : Dictionary[Direction, String] = {
	Direction.UP : "up",
	Direction.DOWN : "down",
	Direction.LEFT : "left",
	Direction.RIGHT : "right"
}


var state_map : Dictionary[GlobalEnums.States, String] = {

	State.IDLE : "idle",
	State.MOVE : "move",
	#State.SNEAK : "sneak"
}
#endregion



#region === PROCESSING ===
func _ready() -> void:
	state_manager.state_change.connect(on_state_change)
	player.direction_change.connect(on_direction_change)
	play_animation()
#endregion



#region === PLAY ANIMATION === 
func play_animation():
	var anim_names = get_anim_names()

	anim_player.play(anim_names[PLAYER_KEY])
	anim_shadow.play(anim_names[SHADOW_KEY])
#endregion



#region === PROPERTY UPDATE ===
func on_state_change():
	play_animation()


func on_direction_change():
	play_animation()
#endregion



#region === MAPPING SYSTEM ===
## Pipeline function converting the state and direction.
## Returns a structured dict to handle object animations differently.[br]
## Return example:  [code]{PLAYER_KEY : "move_right', SHADOW_KEY : "move"}[/code]
func get_anim_names() -> Dictionary:
	var state = state_manager.current_state
	var direction = player.last_direction

	var anim_names : Dictionary = map_animation(state, direction)

	return anim_names

## Converts the incoming enums to string values so 'build_anim_name' can join them.
func map_animation(state : GlobalEnums.States, direction : GlobalEnums.Direction) -> Dictionary:
	if not state_map.has(state):
		push_error("'%s' not found in base 'state_map'" % State.keys()[state])
		return {}

	if not direction_map.has(direction):
		push_error("'%s' not found in base 'direction_map'" % State.keys()[direction])
		return {}

	var state_name = state_map[state]
	var direction_name : String = direction_map[direction]
	return  build_anim_name(state_name, direction_name)

## Returns a structured dictionary to address animation seperatly.
func build_anim_name(state_key : String, direction_key: String) -> Dictionary:
	return {
		PLAYER_KEY : state_key + str_connector + direction_key,
		SHADOW_KEY : state_key
		}
