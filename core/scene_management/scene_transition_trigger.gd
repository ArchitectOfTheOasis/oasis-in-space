## Base class for scene transition triggers. 
## Stores spawnpoint data and provides functions to initiate scene transitions.
## When new scene is loaded every object with this script attached emits its 
## spawnpoint data to the 'SpawnpointRegistry' 
##
## USAGE:[br]
## • Attach this script to a scene transition node (e.g. Area2D)[br]
## • Add a 'spawnpoint' as child (use 'spawnpoint.tscn' or make sure Marker2D is 
##   in Group "Spawnpoint")[br]
## • Add properties in the Inspector[br]
##   [code]spawnpoint_id, target_scene_id, target_spawnpoint, target_direction[/code][br]
## • Child scripts with own '_ready()' function must call 'super()'
#
#
# TODO:
#
# ARCHITECTURE DEBT:
# • Spawnpoint position depends on _ready()
#      Refreshing system on re-placing a 'SceneTransitionTrigger'-area 
# • Static spawnpoint id system is incompatible with dynamic base building.
#   A hybrid runtime declaration may be required.
#
# NOTE:
# • Refactored the 'spawnpoint_id' to 'GlobalEnums.Spawnpoint' instead of string.
#   Fixed all obvious dependencies but not tested it yet.
# • Sideeffect: Even on first load the 'finish_scene_transition()' in the
#   'SceneManager' gets called due to the registration process. (Fade in at start)
extends Node
class_name SceneTransitionTrigger

@export var spawnpoint_id := GlobalEnums.Spawnpoint.BUILDING_ONE
@export var target_scene_id := GlobalEnums.Scene.MAIN_ZONE
@export var target_spawnpoint := GlobalEnums.Spawnpoint.INDOOR_ONE
@export var target_direction := GlobalEnums.Direction.UP

var spawnpoint : Node
var spawnpoint_position : Vector2

func _ready() -> void:
	emit_spawnpoint_data()

#region === REGISTER SPAWNPOINT TO SCENE MANAGER ===
## Pulls child below the Node this script is attached based on the Group "Spawnpoint"
## for reusability.
func get_spawnpoint() -> Node2D:
	spawnpoint = global_functions.get_child_by_group(self, "Spawnpoint")
	if not spawnpoint:
		push_error("Spawnpoint '%s' == null." % spawnpoint_id)
		return 

	return spawnpoint



func emit_spawnpoint_data() -> void:
	spawnpoint = get_spawnpoint()
	if not spawnpoint:
		push_error("Unable to emit spawnpoint data.")
		return

	spawnpoint_position = spawnpoint.global_position
	#emits the spawnpoint data with key at init
	event_bus.spawnpoint_available.emit(spawnpoint_id, spawnpoint_position)
#endregion

## Initiates the scene transition process in the 'SceneManager'.
## Gets called by Nodes that extend from 'SceneTransitionTrigger'.
func initiate_scene_transition():
	scene_manager.initiate_scene_transition(target_scene_id, target_spawnpoint, target_direction)
