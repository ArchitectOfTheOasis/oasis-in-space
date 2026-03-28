## Coordinates the scene transition between world scenes.
## when triggered by 'SceneTransitionTrigger'.
## 
## 'SceneTransitionTrigger' objects register at _ready() at 'SpawnpointRegistry'.
## When scene switch get's triggered the screen fades to black using the 
## 'Transition Screen'. The transition gets finished when registration is completed..
## 
## Trigger
## • fade_out
## • change_scene
## • await:
##       player_initialized
##       spawnpoints_registered
## • emit scene_initiated
## • fade_in
##
## 
## USAGE:[br][br]
## 
## ADD SCENE:[br]
## • Add entry to 'GlobalEnums.Scene'[br]
## • Drag the scene in the 'Value' slot in the inspector and pick the name as 'Key'[br][br]
##
## SWITCH SCENE:[br]
## • Call 'initiate_scene_transition(scene, spawnpoint, direction[br]
## • Usually triggered via. 'SceneTransitionTrigger'[br]
#
#
# TODO:
# IMPORTANT:
# • Player looses Inventory at scene transition. Probably save properties and
#   instantiate/infuse at scene loaded.
#
# ARCHITECTURE DEBT:
# • Static scene referencing is incompatible with dynamic base building.
#   A hybrid runtime registry may be required.
# • In multiplayer every player would be teleported. 
extends Node
class_name SceneManager
#region ===DECLARATIONS===
@onready var transition_screen: CanvasLayer = %transition_screen
@onready var spawnpoint_registry: SpawnpointRegistry = $"Spawnpoint Registry"


## Stores references to the scenes referenced in the Inspector
@export var scenes : Dictionary [GlobalEnums.Scene, PackedScene] = {}

#to make sure it's finished before triggered again
var transition_status : bool = false

var target_scene : GlobalEnums.Scene
var target_spawnpoint : GlobalEnums.Spawnpoint
var target_spawnpoint_position : Vector2
var player_direction : GlobalEnums.Direction

# Race condition gate to finish the scene
var player_initialized : bool = false
var spawnpoints_registered : bool = false
#endregion 



#region === PROCESSING ===
func _ready() -> void:
	transition_screen.connect("transition_finished", _on_transition_finished)
	event_bus.player_initialized.connect(_on_player_initialized)
	spawnpoint_registry.spawnpoint_registration_completed.connect(_on_spawnpoint_registration_completed)
#endregion



#region === SCENE TRANSITION ===
## [param scene]: The scene you want to transition to
## [param spawnpoint]: The unique id of the target spawnpoint
## [param direction]: The direction the 'Player' is facing when spawning
func initiate_scene_transition(scene : GlobalEnums.Scene, spawnpoint : GlobalEnums.Spawnpoint, facing_direction : GlobalEnums.Direction):
	if transition_status:
		return

	# Declaring parameters for usage throughout functions
	target_scene = scene
	target_spawnpoint = spawnpoint
	player_direction = facing_direction

	if not scenes.has(target_scene):
		printerr("invalid key '%s' in Dictionary 'scenes'. Please check spelling, or incorrect set Key/Value Pair" % target_scene)
		return false

	if scenes[target_scene] == null:
		printerr("invalid PackedScene in Dictionary 'scenes'. Should be '%s', but is <null>" % target_scene)
		return false

	transition_status = true
	transition_screen.fade_scene_out()
	return true


## Triggered by 'TransitionScreen' when transition animation is done
func _on_transition_finished(status : String):
	match status:
		"fade_out_completed":
			get_tree().change_scene_to_packed(scenes[target_scene])
		"fade_in_completed":
			transition_status = false

#Waits for Signals/Gate -> Gives the Player the Spawnpoint Data and Direction
func finish_scene_transition():
	if not transition_ready():
		return false

	if not spawnpoint_registry.spawnpoints.has(target_spawnpoint):
		push_error("Target Spawnpoint '%s' not found in spawnpoint_registry.spawnpoints." %target_spawnpoint)
		return false

	target_spawnpoint_position = get_target_spawnpoint_position()
	event_bus.scene_initiated.emit(target_spawnpoint_position, player_direction)
	transition_screen.fade_scene_in()
	return true
#endregion



#region === HELPERS ===
## Returns the 'target_spawnpoint' position or a fallback position 'Vector2.ZERO'
func get_target_spawnpoint_position() -> Vector2:
	if spawnpoint_registry.spawnpoints.has(target_spawnpoint):
		return spawnpoint_registry.spawnpoints[target_spawnpoint]

	push_error("Target Spawnpoint '%s' not found in base spawnpoint_registry.spawnpoints" %target_spawnpoint)
	return Vector2.ZERO


## To avoid race conditions
func transition_ready() -> bool:
	if player_initialized and spawnpoints_registered:
		player_initialized = false
		spawnpoints_registered = false
		return true
	return false
#endregion



#region === SIGNALS ===
#is emitted when player is _ready to receive
func _on_player_initialized():
	player_initialized = true
	finish_scene_transition()

#is emitted when the spawnpoint_registration is completed and all data is there
func _on_spawnpoint_registration_completed():
	spawnpoints_registered = true
	finish_scene_transition()
#endregion === 
