## A library of helper functions
extends Node
class_name GlobalFunctions



#region === GET NODE ===
## [param node]: Where to search the children
## [param group_name]: 
func get_child_by_group(node: Node, group_name : String) -> Node2D:
	if node:
		for child in node.get_children():
			if child.is_in_group(group_name):
				return child
	return null
#endregion



#region === DEBUGGING ===
# prints a pretty array
func print_array(array : Array):
	for i in range(array.size()):
		var eintrag = array[i]
		print(str(i + 1) + ": " + str(eintrag))
#endregion
