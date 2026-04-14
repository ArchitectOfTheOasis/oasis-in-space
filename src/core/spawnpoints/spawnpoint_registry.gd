## Transmits spawnpoint data to 'SceneManager' and informs when all spawnpoints initialized
## Obtains the spawnpoint data by 'SceneTransitionTrigger'
#
# TODO:
# • Save spawnpoints by Scene. Only take changes when new spawnpoint is placed or changed.
# • 'child_count' pattern not Bug-Safe. 
extends Node
class_name SpawnpointRegistry

## 'SceneManager' awaits this signal in order to continue scene transition process.
signal spawnpoint_registration_completed

## Saves the identifier and the position of the Spawnpoint. E.g.: 
## {
var spawnpoints : Dictionary[GlobalEnums.Spawnpoint, Vector2]= {}

var child_count : int

func _ready() -> void:
	event_bus.spawnpoint_available.connect(_on_spawnpoint_available)


## Emits a signal when all spawnpoints are available 
func _on_spawnpoint_available(spawnpoint_id : GlobalEnums.Spawnpoint, position : Vector2):
	if child_count == 0:
		child_count = get_tree().get_node_count_in_group("Spawnpoint")
	if spawnpoints.has(spawnpoint_id):
		if spawnpoints[spawnpoint_id] != position:
			spawnpoints[spawnpoint_id] = position
	else:
		spawnpoints[spawnpoint_id] = position
	child_count -= 1
	if child_count == 0:
		spawnpoint_registration_completed.emit()
	
