## Detects player interaction and initiates scene transition on 'right click'.
#
# TODO:
# • Remove Input collection
# • Remove "Floor Area2D" detection when "interactible Range" is implemented
extends SceneTransitionTrigger
class_name TransitionDoor


@export var input_manager_path : NodePath
@onready var input_manager : Node = get_node(input_manager_path)



var clickable : bool = false
var player_in_enter_area : bool = false
var input : Dictionary



func _ready() -> void:
	super._ready()
	input = input_manager.collect_misc()
# Only gets active if all conditions are fulfilled
	set_process(false)


func _process(_delta: float) -> void:
	interact()



# FIXME: Collects Input -> Remove when InputManager is ready
func interact():
	if clickable and player_in_enter_area:
		input = input_manager.collect_misc()
		if input[InputManager.Action.INTERACT]:
			initiate_scene_transition()





#region === SIGNALS/TRIGGER ===
func _on_mouse_entered() -> void:
	clickable = true
	set_process(true)

func _on_mouse_exited() -> void:
	clickable = false
	set_process(false)


func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_enter_area = true

func _on_player_detection_body_exited(_body: Node2D) -> void:
	player_in_enter_area = false
#endregion
