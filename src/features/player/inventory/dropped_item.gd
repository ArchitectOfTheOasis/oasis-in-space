## The Items in the world and the pickup detection.
extends Area2D
class_name DroppedItem

var dropped_item = preload("res://features/player/inventory/dropped_item.tscn")

# DEBUG
var test_item_data : ItemResource = load("res://features/items/coal.tres")
var test_amount : int = 48

var item_data : ItemResource
var amount : int 
@onready var item_texture: Sprite2D = %Item
@onready var item_shadow: Sprite2D = %"Item Shadow"



func _ready() -> void:
	update_visuals()



# The PickUP-System (Add to Inventory)
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	
	if body.has_method("get_inv_manager"):
		var inv_manager = body.inv_manager
		if inv_manager == null:
			push_error("'inv_manager' not found in player")
			return
	
		if item_data == null:
			push_error("item_data is <null>")
			return 

		if inv_manager.add_item(item_data, amount):
			queue_free()
		else:
			printerr("add_item to inv_manager failed. Maybe item_data not set correctly or inventory is full.")





func update_visuals():
	if item_data and item_texture:
		item_texture.texture = item_data.texture
