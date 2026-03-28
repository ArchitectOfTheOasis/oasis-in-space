## Manages the visual appearance of the player ui.
#
#
# TODO:
# 
# • Menu buttons exists only for debugging saving currently. Outsource saving buttons 
#   and create real menu buttons
extends CanvasLayer
class_name PlayerUI

## currently gets only turned visible in the 'Bed' script
@onready var menu_buttons: VBoxContainer = %MenuButtons


func _ready() -> void:
	menu_buttons.visible = false
