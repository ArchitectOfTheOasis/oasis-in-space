## Lets the player save and initiates new loop. Saves the current_scene for
## spawning reasons. [br]
## WARNING: Currently toggles player_ui_button visibility directly!
#
#
# TODO:
# • Change 'bed_id' from String to int
# • Signal based UI event instead of direct access (_on_body_entered)
# • "Click" player in place
# • If Game played in Multiplayer wait for all players in Bed.
#   If save slots option is enabled the host decides where to save.
extends Area2D
class_name Bed
#region === DECLARATION ===

@export var bed_id : String 
var current_scene 

var player : Node

#endregion



func _ready() -> void:
	current_scene = get_tree().get_first_node_in_group("Zone")

# Turns on/off the UI Buttons for saving -> Replace through signals
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		player.player_ui.menu_buttons.visible = true



func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player.player_ui.menu_buttons.visible = false
