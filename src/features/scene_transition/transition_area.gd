## Detects player and initiates a scene transition
extends SceneTransitionTrigger
class_name TransitionArea



func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if body.is_in_group("Player"):
			initiate_scene_transition()
