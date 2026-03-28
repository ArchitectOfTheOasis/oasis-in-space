## Handles the players movement logic including different modes based on gravitation.
## Gravity values move from 0.1 (very floaty) to 1.0 (instant) in a steep curve.
#
#
# TODO:
# • Link player speed with animation
# • Connect InputManager instead of 'input_movement'
extends PlayerState

const STOP_THRESHOLD : float = 0.1

var input_movement : Dictionary
var move_speed : float
var sneak_strength : float

var gravity : float



#region === PROCESSING === 
func enter(state_manager):
	super.enter(state_manager)

	player.move_ended.connect(_on_move_ended)
	
# Won't get updates on runtime changes
	var stats_data = player.player_stats.stats
	move_speed = stats_data[PlayerStats.Stat.MOVE_SPEED]
	sneak_strength = stats_data[PlayerStats.Stat.SNEAK_STRENGTH]
	gravity = player.gravity_strength


func handle_physics_process(delta : float):
	input_movement = player.input_movement
	calculate_movement(delta)

	if player.velocity.length() <= STOP_THRESHOLD:
		request_state(GlobalEnums.States.IDLE)


func exit():
	player.move_ended.disconnect(_on_move_ended)



## 
func _on_move_ended():
	pass
#endregion



#region === MOVEMENT CALCULATION === 
## Calculates movement based on the gravity to reduce to one movement logic.
func calculate_movement(delta):
	var input = input_movement[InputManager.Action.MOVE]
	var target_speed : Vector2
	var ease_strength : float

	if input != Vector2.ZERO:
		# Acceleration
		ease_strength = 1.3 

		if input_movement[InputManager.Action.SNEAK]:
			target_speed = input.normalized() * move_speed / sneak_strength
		else: 
			target_speed = input.normalized() * move_speed

	else:
		# Decceleration
		ease_strength = 1.1 
		target_speed = Vector2.ZERO
	
	apply_movement(delta, target_speed, ease_strength)

## [param target_speed]: Abosolute speed at 100%
## [param ease_strength]: Acceleration duration (low values = fast, high values = slow)
func apply_movement(delta : float, target_speed : Vector2, ease_strength : float):
	player.velocity = player.velocity.lerp(
	target_speed, ease(gravity * delta * Constants.delta_normalizer, ease_strength))
#endregion
