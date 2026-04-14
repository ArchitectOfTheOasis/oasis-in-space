## Holds the inventory data and maintains the item order.
## Acts as the SSOT for the inventory System
##
## Usage:[br]
## • Use 'add_item' to add items to the inventory.[br]
## • Use 'remove_item' to remove items from the inventory.[br][br]
##
## Signals:[br]
## • 'inventory_changed' is emitted whenever the inventory data changes. 
##    UI Systems should listen to this signal to update their visual representation.[br]
## • 'inventory_full' is emitted when no additional items can be added
#
# TODO:
#
# IMPORTANT:
# • Player looses Inventory at scene transition.
#
# • May be convert 'InventoryManager' into a 'Resource' so it's pure Data instead 
#   of amscene Node.
# • Replace placeholder 'MAX_STACK' with 'item_data.max_stack'
# • Implement adjustable inventory size logic.
# • Implement stack splitting and re-ordering.
# • Handle partial pickups and full inventory.
#     • Disable pickup when no slots are available
#     • If a stack can partially accept items, only pick up the valid amount
#       and leave remaining items in the world
# • Replace while loop in 'add_item' with substraction logic.
#
# NOTE: 
# Previously this required 'await get_tree().process_frame'.
# After refactoring the logic no longer needs it.
extends Node
class_name InventoryManager
#region === DECLARATION ===


signal inventory_full
signal inventory_changed

## Used to navigate through the inventory. See also 'inventory'.
enum SlotKey {
	ITEM_DATA,
	AMOUNT
}

## Holds the inventory slots. 
## Each slot is stored as a Dictionary: [br]
## [code]{SlotKey.ITEM_DATA : ItemResource}, {SlotKey.AMOUNT : int}[/code]
var inventory : Array [Dictionary] = [] 

## Placeholder till item_data.MAX_STACK implemented
const MAX_STACK : int = 99
const MAX_SLOTS : int = 40
var current_slots : int = 30

var test_item : ItemResource = ResourceLoader.load("res://features/items/copper_axe.tres")
#endregion



# NOTICE: Delete PROCESSING // Just for DEBUG
#region === PROCESSING ===
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("I"):
		add_item(test_item, 64)


	if Input.is_action_just_pressed("O"):
		remove_item(test_item, 64)
#endregion



#region === ADD LOGIC ===
func add_item(item_data : ItemResource, amount : int) -> bool:
	if item_data == null:
		return false

	if find_matching_item(item_data) < 0:
		if inventory.size() >= current_slots:
			inventory_full.emit()
			print("Inventory Full")
			return false


	while amount > 0:
		var index = find_matching_item(item_data)
		if index > -1: 
			amount = add_to_stack(index, amount)
			if amount <= 0:
				return true
			else:
				continue 

		else:
			if amount <= 0:
				return true
			else: 
				if create_new_stack(item_data):
					continue
				else:
					break

	push_error("An unexpected error occurred")
	return false



func add_to_stack(index : int, amount : int) -> int:
	if index < 0:
		push_error("Index not found")
		return amount
	
	if amount > 0 and inventory[index][SlotKey.AMOUNT] < MAX_STACK:
		var remaining_space = MAX_STACK - inventory[index][SlotKey.AMOUNT]
		if amount < remaining_space:
			inventory[index][SlotKey.AMOUNT] += amount
			inventory_changed.emit()
			return 0
		else:
			inventory[index][SlotKey.AMOUNT] += remaining_space
			amount -= remaining_space
			inventory_changed.emit()
	return amount
#endregion



#region === REMOVE LOGIC ===
## Substracts the amount of the given items in the inventory.
func remove_item(item_data : ItemResource, amount : int) -> bool:
	if item_data == null or amount <= 0:
		return false


	while amount > 0:
		var index = find_matching_item_backwards(item_data)

		if index < 0:
			return false

		if inventory[index][SlotKey.AMOUNT] > amount:
			inventory[index][SlotKey.AMOUNT] -= amount
			amount = 0
		else:
			amount -= inventory[index][SlotKey.AMOUNT]
			inventory.remove_at(index)
	inventory_changed.emit()
	return true
	#endregion



#region === SLOT HELPERS === Find and create
# Returns the index of the first matching item with available stack capacity.
func find_matching_item(item_data : ItemResource) -> int:
	for index in range(inventory.size()):
		if inventory[index][SlotKey.ITEM_DATA] == item_data and inventory[index][SlotKey.AMOUNT] < MAX_STACK:
			return index
	return -1

# Returns the index of the last matching item.
func find_matching_item_backwards(item_data : ItemResource) -> int:
	for index in range(inventory.size() -1, -1, -1):
		if inventory[index][SlotKey.ITEM_DATA] == item_data:
			return index
	return -1


## Currently returns the index of the last free slot or -1 if the inv is full. 
# Refactor when you implement re-ordering
func find_empty_slot() -> int:
	if inventory.size() < current_slots:
		return inventory.size()

	return -1 


func create_new_stack(item_data : ItemResource) -> bool:
	if find_empty_slot() <0 :
		return false

	inventory.append({SlotKey.ITEM_DATA : item_data, SlotKey.AMOUNT : 0})
	return true
#endregion
