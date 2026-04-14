## Responsible for the fade to black effect at scene transition. 
## Gets triggered with 'transition_finished' by the 'SceneManager'
extends CanvasLayer
class_name TransitionScreen


signal transition_finished

@export var anim_player_path : NodePath
@onready var anim_player : Node = get_node(anim_player_path)




func _ready() -> void:
	anim_player.play("idle")
	self.visible = false
	anim_player.animation_finished.connect(_on_animation_finished)



func fade_scene_out():
	anim_player.play("fade_to_black")
	self.visible = true



func fade_scene_in():
	self.visible = true
	anim_player.play("fade_to_normal")



## [param anim_name]: The animation name in child 'anim_player'
func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		transition_finished.emit("fade_out_completed")
	elif anim_name == "fade_to_normal":
		self.visible = false
		transition_finished.emit("fade_in_completed")
