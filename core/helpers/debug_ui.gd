## Used to show a debug layer with valuable informations like in Minecraft. [br]
## add_debug_property(debug_type: DebugType, property_id : StringName, value):
extends Node
class_name DebugLayer
#region === DECLARATION ===
@onready var tab_container: TabContainer = $Control/TabContainer

enum DebugType {PLAYER, WORLD}
var debug_type_map: Dictionary = {
	DebugType.PLAYER : "Player",
	DebugType.WORLD : "World"
}

var properties : Array[StringName] = []
#endregion



#region === PROCESSING ===
func _ready() -> void:
	self.visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		self.visible = not self.visible
#endregion



## Every value can be added in every script
func add_debug_property(debug_type: DebugType, property_id : StringName, value):
	var type_key : String
	if debug_type_map.has(debug_type):
		type_key = debug_type_map[debug_type]
		var target_container = tab_container.get_node_or_null(type_key)

		if target_container:
			if properties.has(property_id):
				if target_container.find_child(property_id, true, false):
					var target_label = target_container.find_child(property_id, true, false)
					target_label.text = property_id + " : " + str(value)
			else:
				var property = Label.new()
				target_container.add_child(property)
				property.name = property_id
				property.text = property_id + " : " + str(value)
				property.add_theme_font_size_override("font_size", 6)
				properties.append(property_id)
		else:
			var type = VBoxContainer.new()
			tab_container.add_child(type)
			type.name = type_key
	else:
			printerr("DebugType '%s' not found in base 'debug_type_map'.
			Please check spelling or add type if necessary." % str(debug_type))
