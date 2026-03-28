extends Node
class_name WeatherSystem

var current_weather : GlobalEnums.Weather


"""---PROCESSING---"""




"""---FUNCTIONS---"""
func set_weather() -> GlobalEnums.Weather:
	current_weather = GlobalEnums.Weather.values().pick_random()
	return current_weather



"""---SIGNALS---"""
