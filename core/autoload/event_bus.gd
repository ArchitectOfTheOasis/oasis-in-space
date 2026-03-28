## Centralized signal hub to decouple systems and prevent hard referencing.
extends Node
class_name EventBus

#region === SETTINGS ===
## Used for all menu button interactions. See also 'MenuButtonWrapper'.
signal menu_button_pressed(action: MenuButtonWrapper.ACTION)
#endregion



#region === SCENE TRANSITION ===
## Spawnpoints emits their availability so 'SpawnpointRegistry' and 'SceneManager'
## can determine valid spawn locations.
signal spawnpoint_available(spawnpoint_id : String, position: Vector2)

## Emitted by the 'SceneManager' when the new Scene is loaded. 
## Sets the players direction and position.
signal scene_initiated(spawnpoint_position : Vector2, direction : GlobalEnums.Direction)

## Emitted when scene is ready. 'SceneManager' awaits this signal.
signal world_scene_initialized

## Emitted when player is ready. 'SceneManager' awaits this signal.
signal player_initialized
#endregion
