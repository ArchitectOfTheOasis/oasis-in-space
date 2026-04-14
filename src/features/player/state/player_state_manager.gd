## Directs the state switching and handles the processing.
## Automatically registers new states added as child node. 
## Signal driven state changes, triggered by the children connected to the
## specific trigger signals.
##
## USAGE: [br]
## 1. Add new child Node below 'StateManager' that enherits from 'PlayerState'
##    and select the 'state_id' in the inspector.[br]
## 2. Connect new state to the signals that trigger a state switch.[br]
## 3. Call the 'request_change(target_state)' function to  request state switch.
#
#
# TODO:
#
# ARCHITECTURE DEBT:
# • Currently concipated on 'Player' only. 
# • Signal based state switching will be redundant with more states
extends Node
class_name StateManager
#region === DECLARATION ===

signal state_change


# --- The states use these references as reference
@export var player_path : NodePath
@onready var player : Player = get_node(player_path)


@export var anim_manager_path : NodePath
@onready var anim_manager : AnimationManager = get_node(anim_manager_path)
# ---

var current_state : GlobalEnums.States = GlobalEnums.States.IDLE
var new_state : GlobalEnums.States

## Stores the Node references to the registered states.
var state_objects : Dictionary[GlobalEnums.States, PlayerState] = {}
#endregion


#region === PROCESSING ===
func _ready() -> void:
	link_states()

	state_objects[current_state].enter(self)


func _process(delta: float) -> void:
	state_objects[current_state].handle_process(delta)


func _physics_process(delta: float) -> void:
	state_objects[current_state].handle_physics_process(delta)
#endregion



#region === STATE SWITCH ===
func switch_state():
	if current_state == new_state:
		return 
	
	if not state_objects.has(current_state):
		printerr("State '%s' not in Dictionary 'state_objects." % current_state)
		return 
	
	state_objects[current_state].exit()
	
	state_change.emit()
	current_state = new_state
	
	state_objects[current_state].enter(self)



func _on_request_state_change(state_id : GlobalEnums.States):
	if current_state != state_id:
		new_state = state_id
		switch_state()
#endregion 


#region === STATE REGISTRY === 
func link_states():
	for child in get_children():
		if not child is PlayerState:
			push_error("Child '%s' is not enheriting from 'PlayerState'" % child.name)
			continue
	
		var state_id = child.state_id
		if state_objects.has(state_id):
			push_error("Duplicated key '%s' in base 'state_objects'." % GlobalEnums.States.keys()[state_id])
			continue 
	
		state_objects.set(state_id, child)
		child.request_state_change.connect(_on_request_state_change)
#endregion
