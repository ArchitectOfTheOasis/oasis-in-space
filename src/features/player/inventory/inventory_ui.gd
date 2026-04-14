## Responsible for displaying inventory items and all visual Inv-UI elements.
## Separates UI presentation from inventory logic.
## InventoryManager handles inventory data while this script handles 
## UI rendering and interaction.
##
## Usage: 
## • Add/Delete slots by adding/removing slots from container nodes
## • For special slots add container with slot as child, reference it and
##   register slots in the register_slots function. 
## • To update changes in the InventoryManager.inventory make sure
##   'inventory_changed' is emitted. 
## • Connect to 'inventory_opened'/'inventory_closed' to react to UI events.
#
# TODO:
# • Replace shared slots to the first ROW_SIZE in main slots.
# • implement Sounds (Different Manager)
# • Visualize Selected Slot and add Shortcuts + Scroll
#
# IMPORTANT:
# • Not handled Edge Case - Inventory slot is empty between filled ones.
extends Node
class_name InventoryUI
#region === DECLARATIONS ===

# For Ui-interaction
signal inventory_opened
signal inventory_closed

# The containers that hold the "physical" slots. 
@onready var main_slots_container: GridContainer = %"Main Slots"
@onready var shared_slots_container: HBoxContainer = %"Shared Slots"
@onready var hotbar_slots_container: HBoxContainer = %hotbar_slots

@onready var inv_manager: InventoryManager = %"Inventory Manager"

@onready var hotbar: TextureRect = %Hotbar
@onready var main_inventory: Control = %"Main Inventory"


var main_slots : Array[InventorySlot] = []
var hotbar_slots : Array[InventorySlot] = []

## Determines how many slots are at the horizontal axis.
const ROW_SIZE : int = 10

var inventory_snapshot : Array = []

var is_inv_opened : bool = false
#endregion



#region === PROCESSING ===
func _ready() -> void:
	main_inventory.visible = false
	hotbar.visible = true
	
	register_slots()
	inv_manager.inventory_changed.connect(_on_inventory_changed)




func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory()

## Öffnet Main-Inventory und blendet dabei die Hotbar aus oder umgekehrt. 
func toggle_inventory():
	is_inv_opened = not is_inv_opened
	main_inventory.visible = is_inv_opened
	hotbar.visible = not is_inv_opened
	
	if is_inv_opened:
		inventory_opened.emit()
	else:
		inventory_closed.emit()
#endregion 



#region === SLOT LOGIC ===
## Handles slot registration and synchronization between main/hotbar/shared slots.

## Stores slots in different Arrays to support shared slots (hotbar/main_inv)
func register_slots():
	resolve_slots(shared_slots_container, main_slots)
	resolve_slots(main_slots_container, main_slots)
	resolve_slots(hotbar_slots_container, hotbar_slots)


## Pulls slots from containers for Flexible Slot adding (Need reference)
## [param container] The "physical" container based in the Hierarchy.
## [param coontainer_slots] A Array based in the 'InvUI' to hold the slots.
func resolve_slots(container : Node, container_slots : Array):
	if container:
		for child in container.get_children():
			if child is InventorySlot:
				container_slots.append(child)


func synchronize_main_slots():
	for index in ROW_SIZE:
		var shared_slot = main_slots[index]
		var hotbar_slot = hotbar_slots[index]
		if shared_slot.item_data != null:
			hotbar_slot.set_item(shared_slot.item_data, shared_slot.amount)
		else:
			hotbar_slot.remove_item()
#endregion



#region === APPLY INVENTORY DATA ===w
## Mirrors the inventory data from the inv_manager, assigns the matching slot,
## displays the item_data including the amount.
## Stores a snapshot of the current inventory state to avoid rebuilding the whole inv.
func _on_inventory_changed():
	var inventory_data = inv_manager.inventory
	if not main_slots:
		return false
	
	if not inventory_data and not inventory_snapshot:
		return false
	
	for index in range(max(inventory_snapshot.size(), inventory_data.size())):
		var ui_slot = main_slots[index]
		if index >= inventory_data.size():
			ui_slot.remove_item()
			continue

		var data_slot = inventory_data[index]
		if ui_slot.item_data != data_slot[inv_manager.SlotKey.ITEM_DATA]:
			ui_slot.set_item(data_slot[inv_manager.SlotKey.ITEM_DATA], data_slot[inv_manager.SlotKey.AMOUNT])

		if ui_slot.amount != data_slot[inv_manager.SlotKey.AMOUNT]:
			ui_slot.change_amount(data_slot[inv_manager.SlotKey.AMOUNT])


	update_snapshot()
	synchronize_main_slots()


## 
func update_snapshot() -> void:
	inventory_snapshot = inv_manager.inventory.duplicate()
#endregion
