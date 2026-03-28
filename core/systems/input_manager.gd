## Centralized processing of input.
##
## USAGE:
## [code]
## input_manager = $InputManager
## 
## func _process(_delta) -> void:
##    var input_misc = input_manager.collect_misc()
##    if input[InputManager.Action.INTERACT]:
##        pass  #returns true or false based on the key
##
## func _physics_process(_delta) -> void:
##    var input_movement = input_manager.collect_movement()
##        if input_movement[InputManager.Action.MOVE]: 
##            pass #returns Vector2 values based on input
## [/code]
#
#
# TODO:
#  
# IMPORTANT:
# • Instead of Dictionarys and standard input observing use 'unhandled_input' instead
#   and make 'InputManager' to the SSOT
# • Some UI Elements allow "click-througs" due to Mouse Settings on Control-Nodes.
#   Currently 'Control' in 'Player_UI' and 'Main Inventory' -> Filter == 'Pass'.
#   Block the mouse when UI Elements are dominant.
extends Node
class_name InputManager

signal inventory
signal left_mouse
signal right_mouse
signal middle_mouse



enum Action {
	MOVE,
	SNEAK,
	
	ACTION,
	INTERACT,
	
	INVENTORY,
	PAUSE,
	
	ZOOM_IN,
	ZOOM_OUT
}


"""---FUNCTIONS---"""
func collect_movement() -> Dictionary[Action, Variant]:
	return {
		Action.MOVE : Input.get_vector("move_left", "move_right", "move_up", "move_down"),
		Action.SNEAK : Input.is_action_pressed("sneak"),
	 }

func collect_misc() -> Dictionary[Action, Variant]:
	return {
		Action.INVENTORY : Input.is_action_just_pressed("inventory"),
		Action.PAUSE : Input.is_action_just_pressed("pause"),
		Action.ZOOM_IN : Input.is_action_just_pressed("zoom_in"),
		Action.ZOOM_OUT : Input.is_action_just_pressed("zoom_out"),
		Action.INTERACT : Input.is_action_just_pressed("mouse_right")
	}
