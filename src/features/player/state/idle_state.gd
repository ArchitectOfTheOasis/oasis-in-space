extends PlayerState



func enter(state_manager):
	super.enter(state_manager)
	
	player.move_started.connect(_on_move_started)

	player.velocity = Vector2.ZERO


func exit():
	player.move_started.disconnect(_on_move_started)

func _on_move_started():
	request_state(GlobalEnums.States.MOVE)
