## Stores the stats of the 'Player' and handles stat adjustment logic.
##
## USAGE:
## 1. Reference and instantiate this Resource. [br]
##    [code] player_stats = PlayerStats.new() [/code][br]
## 2. If saved data exists duplicate the saved data.[br]
##    [code] player_stats = 'saved_player_stats'.duplicate() [/code][br]
## 3. Read the stats stored in the 'stats' Dictionary using the 'Stat' enum. [br]
##    [code] player_stats.Stat.MAX_HP [/code][br]
## 4. Manipulate stats using 'adjust_stat'.
#
#
# TODO:
#
# • Maybe rename to 'PlayerStatsManager' if logic runs here instead of pure data design.
#
# ARCHITECTURE DEBT:
# • Resource design acts as pure data. For effects over time 'extends Node' or
#   logic seperation needed.
extends Resource
class_name PlayerStats
#region === DECLARATION ===

## Used to update UI 
signal update_stat

## Stores all player stats.
## Navigation example: [code] player_stats.Stat.MAX_HP [/code]
var stats : Dictionary[Stat, float] = {
	Stat.MAX_HP : 100.0,
	Stat.HP : 100.0,
	
	Stat.MAX_OXYGEN : 100.0,
	Stat.OXYGEN : 100.0,
	
	Stat.MAX_STAMINA : 100.0,
	Stat.STAMINA : 100.0,
	
	Stat.MAX_MOVE_SPEED : 70.0,
	Stat.MOVE_SPEED : 70.0,
	Stat.SNEAK_STRENGTH : 2
}

enum Stat {
	MAX_HP,
	HP,
	
	MAX_OXYGEN,
	OXYGEN,
	
	MAX_STAMINA,
	STAMINA,
	
	MAX_MOVE_SPEED,
	MOVE_SPEED,
	SNEAK_STRENGTH
}
#endregion


# FIXME: Edge Case handling like overflow is missing.
## Accepts positive and negative values. 
func adjust_stat(stat: Stat, value: float):
	if stat in stats.keys():
		stats[stat] += value
		update_stat.emit()
