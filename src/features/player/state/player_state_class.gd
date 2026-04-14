## Provides centralized state logic and provides inspector driven 'ID' selection.
##
## USAGE:[br][br]
## 
## ADD NEW STATE: [br]
## 1. Extend state script from PlayerState[br]
## 2. Select the 'state_id' in the Inspector[br]
## 3. Implement following actions:[br][br]
## [code]
## enter():  
##     super.enter(sm) # To ensure references are initialized
##     player.move_started.connect(_on_move_started) # State switching trigger
##
##
## exit():
##     player.move_started.disconnect(_on_move_started) # Avoid unwanted behaviour
##
##  To request the state change:
##      request_state(GlobalEnums.States.MOVE)
##[/code]
extends Node
class_name PlayerState
#region === DECLARATION ===
signal request_state_change(state_id : GlobalEnums.States)

@export var state_id := GlobalEnums.States.IDLE

var sm : StateManager
var player : Player
var anim_manager : AnimationManager
#endregion



#region === PROCESS HANDLING ===

## Called by 'StateManager' when this state becomes active. Used for initialisation.
func enter(state_manager : StateManager) -> void:
	sm = state_manager
	player = sm.player
	anim_manager = sm.anim_manager
	
	if anim_manager:
		# 'anim_manager' pulls the current state and direction itself
		anim_manager.play_animation()


## Cleanup before leaving state (e.g. disconnect signals)
func exit() -> void:
	pass


## Alias for '_process()'. Handled by 'StateManager' on the active state. 
func handle_process(_delta : float) -> void:
	pass


## Alias for '_physics_process()'. Handled by 'StateManager' on the active state. 
func handle_physics_process(_delta : float) -> void:
	pass
#endregion



#region === HELPER === 
## Used to update dependent scripts (e.g. 'anim_manager')
func request_state(target_state : GlobalEnums.States) -> void:
	request_state_change.emit(target_state)
#endregion
