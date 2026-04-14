## Serves as a Blueprint for the saveable Player values. Gets called by
## SaveManager which uses this blueprint to create the SaveFile
extends Resource
class_name PlayerData

@export var player_id : String = ""
@export var current_stats : Dictionary = {}
@export var inv_data : Array[Dictionary] = []
@export var current_spawnpoint : String



func set_player_data(_player_id : String, _current_stats : Dictionary, 
_inv_data : Array, _current_spawnpoint : String) -> void:
		player_id = _player_id
		current_stats = _current_stats
		inv_data = _inv_data
		current_spawnpoint = current_spawnpoint
		# NOTE: current_spawnpoint MUSS die current_scene ableiten!


func get_player_data():
	pass
