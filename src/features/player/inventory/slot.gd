## Reusable slot for every UI inventory element. Used for visual representation.
extends TextureButton
class_name InventorySlot
#region === DECLARATION ===
@onready var item_display: TextureRect = %ItemDisplay
@onready var amount_label: Label = %AmountLabel


var item_data : ItemResource 
var amount : int = 0 
#endregion



#region === DISPLAY ITEMS ===
func set_item(new_item : ItemResource, new_amount : int) -> bool:
	if new_item == null:
		return false
	
	if item_data == new_item:
		amount = new_amount
	else:
		item_data = new_item
		amount = new_amount
	update_display()
	return true


func change_amount(new_amount : int) -> void:
	amount = new_amount
	update_display()


func remove_item() -> void:
	item_data = null
	amount = 0
	update_display()


func update_display() -> void:
	if item_data:
		item_display.texture = item_data.texture
	else:
		item_display.texture = null
	
	amount_label.text = str(amount)
	amount_label.visible = amount > 1
	return
#endregion



#region === EYE CANDY ===
func _on_mouse_entered() -> void:
	if item_data:
		item_display.scale = Vector2(2, 2)


func _on_mouse_exited() -> void:
	item_display.scale = Vector2(1.0,1.0)
