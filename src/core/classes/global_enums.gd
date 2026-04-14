## Base class to share Enums across Scripts for type safety.
#
# TODO: 
# • For easier accessibility rename 'GlobalEnums' to something like 'Voc'.
# • Move 'Vocabulary' to this script
extends Node
class_name GlobalEnums

## Can be used for any state - for mobs and player.
enum States {
	IDLE,
	MOVE,
	SNEAK
	}

enum Direction {
	RIGHT,
	LEFT,
	DOWN,
	UP
	}

## Used for static scenes by the 'SceneManager' & 'SceneTransitionTrigger'
enum Scene {
	MAIN_ZONE,
	INDOOR_ZONE
	}

## Used for static spawnpoint by the 'SceneManager' & 'SceneTransitionTrigger'
enum Spawnpoint {
	BUILDING_ONE,
	INDOOR_ONE
}


enum Weather {
	CLEAR,
	WINDY,
	RAIN,
	STORM
}
