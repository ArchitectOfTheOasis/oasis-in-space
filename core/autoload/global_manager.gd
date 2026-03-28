## Manages the GameState and holds Data
extends Node
class_name GlobalManager


@export var world_data : WorldData

func _ready() -> void:
	world_data = WorldData.new()
	save_manager.request_save_data.connect(_on_request_save_data)

# DEBUG: SaveSystem Testing Dependency
func _process(_delta: float) -> void:
	debug_ui.add_debug_property(debug_ui.DebugType.PLAYER, 
		"Loop Nr", world_data.loop_nr)
	if Input.is_action_just_pressed("chat"):
		world_data.loop_nr += 1

func _on_request_save_data():
	#set_save_data()
	save_manager.register("world_data", self, world_data, "world_data")
