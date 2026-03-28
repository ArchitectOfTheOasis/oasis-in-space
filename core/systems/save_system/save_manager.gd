## Creates dynamically directories and saves the object data inside.
## Objects with saveable data have to register manually
## Current Directory structure: 
## [code]'user://saves/world_name/loop_nr/players'[/code]
## 
## USAGE EXAMPLE: [br]
## 1. Connect to 'request_save_data' signal in the saveable object[br]
## 2. In the connected handler, call save_manager.register()[br]
## 3. Connect to 'game_loaded' to apply loaded data [br][br]
## [code]
## class_name Player
## 
## func _ready(): 
## save_manager.request_save_data.connect(_on_request_save_data)
## save_manager.game_loaded.connect(_on_game_loaded)
##
## func _on_request_save_data():
## save_manager.register("player_1", self, player_data, "player_data")
## [/code]
#
#
# TODO
#
# IMPORTANT:
# • Implement saving the old 'saved_data' with the new 'active_data'.
#   You have to overwrite the matching keys in 'saved_data'
# • At Scene queue free the data has to be saved, otherwise at scene switch/
#   queue free the data is lost. Maybe signal at Scene Transition?
#
# ARCHITECTURE DEBT:
# • SaveManager has too many responsibilities
#       - Split into DirectoryManager, DataSerializer, SaveRegistry
# • Saving the Resources as Single files is unnecessary because you have
#   to load it and save it again.
#       - Save all the Resources in one 'Saves.tres'
# • Objects have to implement Save-Logic themselves
#       - SaveableObject Class as an attachment Node
# • Registry pattern not Bug-Safe (e.g. Object doesn't registrate)
# • Setting the data directly in the Objects
#       - Request pattern
# • Not generic. Saves only known Types (PlayerData, WorldData)
#
# LONG TERM:
# • Implement manual saving to the slots instead of auto rotate
# • Set all loading dependencies correctly (e.g. Spawnpoint)
# • Slot selection from main menu
# • Remove multiple save slots by default 
#   Make option in the settings to enable multiple slots for Sandbox player
#   With option off - No save selection.
extends Node
class_name SaveManager
#region === DECLARATIONS ===

## Emitted when all data has been written to disk successfully.
signal game_saved

## Emitted after all active objects received their loaded data.
signal game_loaded

## Emitted to request saved data from all registered objects.
## Connect to this signal and call register() in the handler.
signal request_save_data

## Emitted internally when all objects have registered.
signal registration_finished

## To fix timing issues with data initialisation and updates
signal object_data_injected


const SAVE_DIR : String = "user://saves/"
const LOOP_DIR : String = "/loop_nr_"
const PLAYER_DIR : String = "/players"

const FILE_EXTENSION : String = ".tres"
const SAVE_SLOTS : int = 3

enum PROCESSING_MODE {SAVE, LOAD}
var current_mode : PROCESSING_MODE = PROCESSING_MODE.SAVE

## Internal keys to navigate through the active_data dictionary entries.
enum ENTRY_TYPE {
	REFERENCE,
	DATA,
	DATA_INDEX
	}


## Example: user://saves/world_1
var world_save_dir : String 
## Example: user://saves/world_1/loop_nr_1
var loop_save_dir : String
## Example: user://saves/world_1/loop_nr_1/players
var player_save_dir : String 


## Navigation example: [code]active_data[key][ENTRY_TYPE.Data][/code]
var active_data : Dictionary[String, Dictionary] = {}


var saved_data : Dictionary[String, String] = {}
#endregion



#region === PROCESSING ===
func _ready() -> void:
	event_bus.menu_button_pressed.connect(_on_menu_button_pressed)
	
	# To ensure that the paths exist before first save for loading
	build_save_paths()
	
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_absolute(SAVE_DIR)
#endregion



#region === SIGNALS/TRIGGER ===
## [param action]: The Action chosen in the Inspector at the Button with
## 'MenuButton' script attached.
func _on_menu_button_pressed(action : MenuButtonWrapper.ACTION):
	match action:
		MenuButtonWrapper.ACTION.SAVE:
			current_mode = PROCESSING_MODE.SAVE
			initiate_process()
		MenuButtonWrapper.ACTION.LOAD:
			current_mode = PROCESSING_MODE.LOAD
			initiate_process()
#endregion



#region === DIRECTORY MANAGEMENT ===
## Requires global_manager.world_data.world_name to construct save_paths.
func build_save_paths():
	if not global_manager:
		push_error("'global_manager' is <null>.")
		return false
	
	if not global_manager.world_data:
		push_error("'global_manager.world_data' not found.")
		return false
	
	var world_data = global_manager.world_data
	var world_name = world_data.world_name
	var loop_nr = world_data.loop_nr
	
	world_save_dir = SAVE_DIR + world_name.to_lower()
	loop_save_dir = world_save_dir + LOOP_DIR + str(loop_nr)
	player_save_dir = loop_save_dir + PLAYER_DIR


# NOTE: Can overwrite the oldest save if SAVE_SLOTS limit is reached!
## Example path: ("user://saves/world_name/loop_nr_x/players)
func create_save_dirs():
	build_save_paths()
	if not DirAccess.dir_exists_absolute(world_save_dir):
		create_dir(world_save_dir)
	
	if not create_sub_dirs():
		overwrite_oldest_save()


# NOTE: Make this recursive? / return bool or error?
func create_dir(path : String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_absolute(path)


func get_first_or_last_dir(target_mode : PROCESSING_MODE) -> String:
	var loop_nrs = get_save_file_loop_nrs()
	var target_loop_count
	match target_mode:
		PROCESSING_MODE.SAVE:
			target_loop_count = loop_nrs.min()
		PROCESSING_MODE.LOAD:
			target_loop_count = loop_nrs.max()
	var target_dir_name = LOOP_DIR + str(target_loop_count)
	var target_dir_path = world_save_dir + target_dir_name
	return target_dir_path


## Returns an Array of ints representing the loop numbers in saved slots.
func get_save_file_loop_nrs() -> Array:
	var dir = DirAccess.open(world_save_dir)
	assert(dir, "Can't open Directory '%s'. Unable to get dir count." % world_save_dir)
	
	var dirs = dir.get_directories()
	var loop_nrs : Array = []
	for save_dir in dirs:
		var i = str(save_dir).remove_chars(LOOP_DIR)
		loop_nrs.append(int(i))
	return loop_nrs


## Returns the number of save directories in the current world_save_dir, or
## -1 if inaccessible
func get_save_file_count() -> int:
	var dir = DirAccess.open(world_save_dir)
	if dir:
		var dir_size = dir.get_directories().size()
		return dir_size
	
	return -1


# NOTE: Gets only called 3 times.
## The Dirs created: [code] user://saves/world_1/[b]loop_nr_1/players[/b]
func create_sub_dirs() -> bool:
	if DirAccess.dir_exists_absolute(loop_save_dir):
		if DirAccess.dir_exists_absolute(player_save_dir):
			return true
		else:
			create_dir(player_save_dir)
			return true
	
	var dir_size =  get_save_file_count()
	
	assert(dir_size >= 0 and dir_size <= SAVE_SLOTS, 
	"Math error. Either no world_save folder has been created or too many 
	directories found in '%s'. Check get_save_file_count." % world_save_dir)
	
	if dir_size < 0 or dir_size > SAVE_SLOTS:
		push_error("Saving interrupted. Invalid Directory Status")
		# returns true so the overwrite_oldest_save() functions can't overwrite!
		return true
	
	if dir_size >= SAVE_SLOTS:
		return false
	
	if DirAccess.dir_exists_absolute(loop_save_dir):
		return true

# NOTE: Necessary to create the dir's here? Why not create_sub_dirs? 
# - Check flow and fix!
	create_dir(loop_save_dir)
	create_dir(player_save_dir)
	return true


func overwrite_oldest_save() -> bool:
	var oldest_dir_path = get_first_or_last_dir(PROCESSING_MODE.SAVE)
	
	if oldest_dir_path == loop_save_dir:
		return true
	
	if not DirAccess.dir_exists_absolute(oldest_dir_path):
		return false
	
	remove_dir_recursive(oldest_dir_path)
	
	if not DirAccess.dir_exists_absolute(oldest_dir_path):
		create_dir(loop_save_dir)
		create_dir(player_save_dir)
		return true
	
	return false


# Will delete everything in the Folder permanently!
## [param path]: The absolute path to the folder you want to delete.
func remove_dir_recursive(path : String):
	var dir = DirAccess.open(path)
	if dir:
		# NOTE: I paid 3 hours of debugging for dir.include_hidden.
		dir.include_hidden = true
		dir.list_dir_begin()
		var file_name = dir.get_next()
	
		while file_name != "":
			if file_name == "." or file_name == "..":
				file_name = dir.get_next()
				continue
	
			var sub_path = path.path_join(file_name)
			if dir.current_is_dir():
				remove_dir_recursive(sub_path)
			else:
				var err = DirAccess.remove_absolute(sub_path)
				if err != OK:
					printerr("couldn't delete '%s'" % file_name)
					break
			file_name = dir.get_next()
		dir.list_dir_end()

	var error = DirAccess.remove_absolute(path)
	assert(error == OK, "Couldn't delete Directory at path: '%s'" % path)
#endregion



#region === DATA REGISTRATION === 
## [param id]: Unique string identifier (e.g. "Player_1")[br]
## [param reference]: Node Reference, usually self[br]
## [param data]: Resource instance containing saveable data (e.g. PlayerData)[br]
## [param data_index]: Name of the variable holding the resource (e.g. "player_data")[br][br]
## Example: [code]register("Player_1", self, player_data, "player_data")[/code]
func register(id : String, reference : Node, data : Resource, data_index : String) -> bool:
	if data == null:
		return false
	
	active_data[id] = {
		ENTRY_TYPE.REFERENCE : reference, 
		ENTRY_TYPE.DATA : data, 
		ENTRY_TYPE.DATA_INDEX : data_index}



	if check_registry_finished():
		return true

	return false


func check_registry_finished():
	var connections = get_signal_connection_list("request_save_data").size()
	if connections != active_data.size():
		return false
	registration_finished.emit()
	return true
#endregion



#region === SAVING LOGIC ===
# Clear previous registration to ensure new objects can register correctly.
func initiate_process():
	active_data.clear()
	
	registration_finished.connect(_on_registration_finished, CONNECT_ONE_SHOT)
	
	if get_signal_connection_list("request_save_data").size() < 0:
		push_error("No objects are connected to 'request_save_data'. 
		Can't register Data to 'active_data'")
		return false
	
	request_save_data.emit()



func _on_registration_finished():
	match current_mode:
		PROCESSING_MODE.SAVE:
			save_game()
		PROCESSING_MODE.LOAD:
			load_game()



## Directs where the File gets stored based on the Type and determines the 
## filename. [br]
func save_game():
	create_save_dirs()
	
	if active_data.size() <= 0:
		push_error("Abort Saving. No objects registered in base 'active_data'.")
		return false
	
	for key in active_data:
		var data = active_data[key][ENTRY_TYPE.DATA]
		if not data:
			push_error("invalid data in base 'active_data[%s]'." % key)
			return false
	
		if data is PlayerData:
			write_data_to_disk(str(key), data, player_save_dir)
	
		elif data is WorldData:
			write_data_to_disk(str(key), data, loop_save_dir)
	
		else:
			push_error("unknown Object '%s' in base 'active_data' registered." % 
			key)
	return true



## Saves a duplicate of the Resource 'data' with the name 'key' at 'save_dir_path'.[br]
## [param key] 'Unique ID' as file name[br]
## [param data] The 'Resource' to save[br]
## [param save_dir_path] 'Absolute path' of the destination Directory[br]
func write_data_to_disk(key : String, data : Resource, save_dir_path : String):
	var temp_data : Resource = data.duplicate(true)
	
	var path = save_dir_path.path_join(key + FILE_EXTENSION)
	ResourceSaver.save(temp_data, path)
#endregion



#region === LOADING LOGIC ===
# Loads the latest save to restore the latest game state
func load_game():
	var latest_save_path = get_first_or_last_dir(PROCESSING_MODE.LOAD)
	get_save_data(latest_save_path)
	active_match_save_data()
	game_loaded.emit()



## WARNING: Overwrites the Data directly in the Objects! Request pattern recommended
func active_match_save_data():
	for key in active_data:
		if saved_data.has(key):
			var resource_path = saved_data[key]
			var loaded_resource = ResourceLoader.load(resource_path)
			var object = active_data[key][ENTRY_TYPE.REFERENCE]
			var object_data_var = active_data[key][ENTRY_TYPE.DATA_INDEX]
			object.set(object_data_var, loaded_resource.duplicate(true))



# NOTE: Maybe put together with remove_dir_recursive to reduce redundancy.
## Saves the saved data in the dictionary 'saved_data'.
## [param path]: the absolute Path to the latest save.
func get_save_data(path: String) -> void:
	saved_data.clear()
	
	var dir = DirAccess.open(path)
	if not dir:
		assert(dir,"Dir at path '%s' doesn't exist. Interrupted loading process." % path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
	
		if dir.current_is_dir():
			var recursive_path = path.path_join(file_name)
			get_save_data(recursive_path)
	
		if file_name.ends_with(".tres"):
			var resource_path = path.path_join(file_name)
			var clean_file_name = file_name.get_basename()
			saved_data[clean_file_name] = resource_path
		file_name = dir.get_next()
#endregion
