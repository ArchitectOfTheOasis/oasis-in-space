## Containing relevant player data and acts as physical entity in the world.
## Dependent scripts rely on the inspector driven referencing and variables.
## The Camera currently gets attached to the player in the Scene.
#
#
# TODO:
# • Facing direction on diagonal movement should be either left or right (space movement)
# • Facing direction based on velocity -> No facing updates when hitting walla
# • Abstract saving logic to external script
# • Implement applying more save data
# • Create a clean reference to the 'InventoryManager'
# • Attach Camera to player directly
extends CharacterBody2D
class_name Player
#region === DECLARATION ===
## Used to update 'AnimManager'
signal direction_change
## Used to switch to move state. Listened by idle state.
signal move_started
## Used to switch to idle state. Listened by move state.
signal move_ended


const MOVE_THRESHOLD : float = 1.0
const AXIS_THRESHOLD : float = 0.1


@export var player_name : String = ""
## Stores the player data. Used as a save-container.
var player_data : PlayerData
## Holds the entire PlayerStat-logic. Access stats via [player_stats.stats]
var player_stats : PlayerStats


var input : Dictionary
@export var input_path : NodePath
@onready var input_manager : InputManager = get_node(input_path)


var inv_manager : InventoryManager
@export var inv_ui_path : NodePath
@onready var inv_ui : InventoryUI= get_node(inv_ui_path)

@export var camera_path : NodePath
@onready var camera : Camera2D = get_node(camera_path)

# ATTENTION: Temporary solution
@onready var player_ui : CanvasLayer = %"Player UI"


const Direction = GlobalEnums.Direction
var new_direction : GlobalEnums.Direction
var last_direction : GlobalEnums.Direction = GlobalEnums.Direction.DOWN
var input_movement : Dictionary


## Not implemented yet. Maybe unnecessary because 'SaveManager' spawns the player
## directly at the respawnpoint. A bed mapping system and across script system is needed.
var respawnpoint : String

var move_mode : MoveMode = MoveMode.IDLE
enum MoveMode {IDLE, MOVE}

var gravity_strength : float
var spacesuit_duty : bool

#endregion


#region === PROCESSING ===
func _ready() -> void:
	player_stats = PlayerStats.new()
	
	get_inv_manager()
	
	save_manager.request_save_data.connect(_on_request_save_data)
	save_manager.game_loaded.connect(_on_game_loaded)
	#save_manager.object_data_injected.connect()
	
	# SceneManager dependencies
	event_bus.scene_initiated.connect(_on_scene_initiated)
	event_bus.player_initialized.emit()


func _process(_delta: float) -> void:
	input = input_manager.collect_misc()
	handle_zoom()


func _physics_process(_delta: float) -> void:
	debug_ui.add_debug_property(DebugLayer.DebugType.PLAYER, "Position", self.global_position)
	debug_ui.add_debug_property(DebugLayer.DebugType.PLAYER, "Facing Direction", GlobalEnums.Direction.keys()[new_direction])
	input_movement = input_manager.collect_movement()
	resolve_move_mode()
	move_and_slide()
	update_facing_direction()
#endregion



#region === SAVESYSTEM ===
## Saves all valuable stats and hands it to the save_manager
func _on_request_save_data() -> void:
	set_player_data()
	save_manager.register(player_name, self, player_data, "player_data")


func set_player_data() -> void:
	player_data = PlayerData.new()
	player_data.set_player_data(
		player_name,
		player_stats.stats,
		inv_manager.inventory,
		respawnpoint
	)


## Applies the saved data
func _on_game_loaded() -> void:
	if not inv_manager:
		push_error("'inv_manager' doesn't exist")
		return 
	
	inv_manager.set("inventory", player_data.inv_data)
	inv_manager.inventory = player_data.inv_data
	inv_manager.inventory_changed.emit()
#endregion



#region === WORLD INTERACTION ===
## Pulls environment properties (gravity, spacesuit rules) from the active 'WorldScene'
func get_zone_properties() -> void:
	var current_zone = get_tree().get_first_node_in_group("Zone")
	assert(current_zone != null, "Zone node not found. Maybe it's a timing problem")
	
	if not current_zone is WorldScene:
		push_error("Current zone '%s' is not 'WorldScene'" % current_zone.name)
		return
	
	assert(current_zone.gravity_strength != null, 
	"Either gravity_strength not set in '%s' or it's a timing Problem" %current_zone.name )
	
	spacesuit_duty = current_zone.spacesuit_duty
	gravity_strength = current_zone.gravity_strength


# WARNING: In multiplayer, one player can trigger this in every player
## Player initialisation at scene change triggered by 'SceneManager'
func _on_scene_initiated(spawnpoint, facing_direction) -> void:
	get_zone_properties()
	self.set_global_position(spawnpoint)
	last_direction = facing_direction
	direction_change.emit()
#endregion



#region === MOVEMENT/INPUT ===
func handle_zoom() -> void:
	if input[InputManager.Action.ZOOM_IN]:
		if camera.zoom <= Vector2( 2.5, 2.5):
			camera.zoom += Vector2(1, 1)
	
	if input[InputManager.Action.ZOOM_OUT]:
		if camera.zoom >= Vector2( 1.5, 1.5):
			camera.zoom -= Vector2( 1, 1) 


# Gate to ensure 'move_mode' is set once instead of every frame
func resolve_move_mode() -> void:
	if input_movement[InputManager.Action.MOVE]: 
		if move_mode != MoveMode.MOVE: #Switch
			move_mode = MoveMode.MOVE
			move_started.emit() #Change MoveMode, when input
	else:
		if move_mode != MoveMode.IDLE:
			move_mode = MoveMode.IDLE
			move_ended.emit() #switch back if no input


func update_facing_direction() -> void:	
	if velocity.length() >= MOVE_THRESHOLD:
	
		if abs(velocity.x) >= abs(velocity.y):
			if velocity.x >= AXIS_THRESHOLD:
				new_direction = Direction.RIGHT
			else:
				new_direction = Direction.LEFT
	
		else:
			if velocity.y >= AXIS_THRESHOLD:
				new_direction = Direction.DOWN
			else:
				new_direction = Direction.UP
	
	
		if last_direction != new_direction:
			last_direction = new_direction
			direction_change.emit()
#endregion



#region === HELPER === 
# NOTE: Dirty Solution because 'inv_manager' instance is nested
func get_inv_manager() -> void:
	for child in inv_ui.get_children():
		if child is InventoryManager:
			inv_manager = child
	assert(inv_manager != null, "'InventoryManager' not found in base 'InventoryUI'. Major saving issue!")
	#endregion
