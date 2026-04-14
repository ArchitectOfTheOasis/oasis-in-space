extends Node
class_name ItemSpawner

var dropped_item = preload("res://features/player/inventory/dropped_item.tscn")

# DEBUG
var test_item_data : ItemResource = load("res://features/items/coal.tres")



func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Q"):
		rand_spawn()
	


func spawn_item(pos : Vector2, _item_data : ItemResource, _amount : int) -> bool:
	if _item_data == null:
		return false
	
	if _amount <= 0:
		return false

	var world_item = dropped_item.instantiate()
	
	world_item.item_data = _item_data
	world_item.amount = _amount
	world_item.position = pos
	
	get_tree().current_scene.add_child(world_item)
	return true






# DEBUG FUNCTION
func rand_spawn():
	var pos = Vector2(randf_range(-50, 50),randf_range(-50, 50))
	var amount = randi_range(1, 39)
	if spawn_item(pos, test_item_data, amount):
		pass
