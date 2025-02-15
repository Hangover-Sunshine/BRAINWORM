extends Node

const SAVE_LOCATION = "user://game_settings.config"

var config:ConfigFile

var MasterVolume:float = 1

var MusicVolume:float = 1.0

var MasterSFXVolume:float = 1.0
var UiSFXVolume:float = 1.0
var GameSFXVolume:float = 1.0

var FullScreen:bool = false

var os_type:String

func _ready():
	# get all native data
	os_type = OS.get_name()
	# get all native data
	
	# NOTE: Remove this if you don't plan on making a web build...
	if os_type == "Web":
		var p = InputEventKey.new()
		p.physical_keycode = KEY_P
		InputMap.action_erase_events("pause")
		InputMap.action_add_event("pause", p)
	##
	
	config = ConfigFile.new()
	
	# if it exists, load whatever we haved saved
	if FileAccess.file_exists(SAVE_LOCATION):
		config.load(SAVE_LOCATION)
		
		MasterVolume = config.get_value("volume", "master")
		
		MusicVolume = config.get_value("volume", "music")
		
		MasterSFXVolume = config.get_value("volume", "sfx_master")
		UiSFXVolume = config.get_value("volume", "ui_sfx")
		GameSFXVolume = config.get_value("volume", "game_sfx")
		
		FullScreen = config.get_value("screen", "fullscreen")
		
		var bus = AudioServer.get_bus_index("Music")
		AudioServer.set_bus_volume_db(bus, linear_to_db(MusicVolume))
		
		bus = AudioServer.get_bus_index("SFX")
		AudioServer.set_bus_volume_db(bus, linear_to_db(MasterSFXVolume))
		
		bus = AudioServer.get_bus_index("GameSFX")
		AudioServer.set_bus_volume_db(bus, linear_to_db(GameSFXVolume))
		
		bus = AudioServer.get_bus_index("UISFX")
		AudioServer.set_bus_volume_db(bus, linear_to_db(UiSFXVolume))
		
		bus = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_volume_db(bus, linear_to_db(GlobalSettings.MasterVolume))
		
		return
	##
	
	save_settings()
##

func save_settings():
	# otherwise, save a new config file with our defaults in place
	config.set_value("volume", "master", MasterVolume)
	config.set_value("volume", "sfx_master", MasterSFXVolume)
	config.set_value("volume", "ui_sfx", UiSFXVolume)
	config.set_value("volume", "game_sfx", GameSFXVolume)
	config.set_value("volume", "music", MusicVolume)
	
	config.set_value("screen", "fullscreen", FullScreen)
	
	config.save(SAVE_LOCATION)
##
