## Inspector driven base class for world scenes.  Stores a reference of the 'WorldData'.
## 'Player' behaviour change based on the inspector variables. 
extends Node
class_name WorldScene


@export var scene_id := GlobalEnums.Scene.MAIN_ZONE
@export var gravity_strength : float = 1.0
## true = spacesuite on | false = spacesuit off
@export var spacesuit_duty : bool = false

var world_data : WorldData


func _ready():
	if not world_data:
		assert(global_manager, "'global_manager' not found")
		world_data = global_manager.world_data
