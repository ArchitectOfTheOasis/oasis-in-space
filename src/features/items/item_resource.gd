extends Resource
class_name ItemResource

enum ItemType {
	EMPTY,
	TOOL,
	CONSUMABLE,
	RESOURCE,
	CRAFTING
}

enum StackSize {
	SINGLE = 1,
	SMALL = 16,
	MEDIUM = 32,
	LARGE = 64,
	MASSIVE = 128
}


@export var item_name : String 
@export var item_id : int
@export var type : ItemType = ItemType.EMPTY
@export var stack_limit : StackSize = StackSize.SINGLE
@export var texture : Texture
@export var item_shadow : Texture = load("res://assets/items/item_shadow.png")
@export var flavor_text : String
