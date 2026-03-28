## Stores global world data.
extends Resource
class_name WorldData

@export var world_name : String = "Planet_B"
@export var loop_nr : int = 1

## Serves as persistent storage of scene data.
var scene_data : Dictionary[GlobalEnums.Scene, Dictionary] = {}
