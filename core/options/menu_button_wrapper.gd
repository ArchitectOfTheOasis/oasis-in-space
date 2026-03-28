## Inspector-driven menu button wrapper.
## Emits the menu action through event_bus ([code]event_bus.menu_button_pressed(action)[/code])
## Allows listening to a single signal instead of connecting to every button.[br]
## USAGE:
## • Add a new action by creating a new entry in the 'ACTION' enum[br]
## • Attach Script to TextureButton, select action and add your 'label_texture'[br]
## • Connect to 'event_bus.menu_button_pressed'
extends Node
class_name MenuButtonWrapper

@export var action := ACTION.SAVE
@export var label_texture : Texture
@onready var label: TextureRect = %label

enum ACTION {
	SAVE,
	LOAD,
	OPTIONS
}

func _ready() -> void:
	# can be replaced with a map for auto label
	label.texture = label_texture


func _on_pressed() -> void:
	event_bus.menu_button_pressed.emit(action)
