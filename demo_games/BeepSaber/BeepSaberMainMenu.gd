# The main menu is shown at game start or pause on an OQ_UI2DCanvas
# some logic is in the BeepSaber_Game.gd to set the correct state
#
# This file also contains the logic to load a beatmap in the format that
# normal Beat Saber uses. So you can load here custom beat saber songs too
extends Panel

# we need the main game class here to trigger game start/restart/continue
var _beepsaber = null;

func initialize(beepsaber_game):
	_beepsaber = beepsaber_game;


func set_mode_game_start():
	$Play_Button.visible = true;
	$Continue_Button.visible = false;
	$Restart_Button.visible = false;


func set_mode_continue():
	$Play_Button.visible = false;
	$Continue_Button.visible = true;
	$Restart_Button.visible = true;

# a loaded beat map will have an info dictionary; this is a global variable here
# to later extend it to load different maps
var _map_info = null;

func _load_and_show_song_info(path):
	_map_info = vr.load_json_file(path + "info.dat");
	if (!_map_info):
		vr.log_error("No info.dat found in " + path);
		return false;
		
	if (_map_info._difficultyBeatmapSets.size() == 0):
		vr.log_error("No _difficultyBeatmapSets in info.dat");
		return false;
		
	$SongInfo_Label.text = """Song Author: %s
Song Title: %s
Beatmap Author: %s""" %[_map_info._songAuthorName, _map_info._songName, _map_info._levelAuthorName]

	$cover.texture = load(path + _map_info._coverImageFilename);


func _load_map_and_start(path, info):
	if (info == null): return;
		
	var set0 = info._difficultyBeatmapSets[0];
	if (set0._difficultyBeatmaps.size() == 0):
		vr.log_error("No _difficultyBeatmaps in set");
		return false;
		
	var map_info = set0._difficultyBeatmaps[0];
	var map_filename = path + map_info._beatmapFilename;
	var map_data = vr.load_json_file(map_filename);
	
	if (map_data == null):
		vr.log_error("Could not read map data from " + map_filename);
	
	#print(info);

	_beepsaber.start_map(path, info, map_data);
	
	return true;


var path = "res://demo_games/BeepSaber/data/maps/TheFatRat_Timelapse/";


func _ready():
	_load_and_show_song_info(path)
	pass # Replace with function body.


func _on_Play_Button_pressed():
	#_load_map_and_start("res://demo_games/BeepSaber/data/maps/Monplaisir_Level2/");
	#_load_map_and_start("res://demo_games/BeepSaber/data/maps/test/");
	_load_map_and_start(path, _map_info);
	pass # Replace with function body.


func _on_Exit_Button_pressed():
	# switch back to the main menu area of the OQ_Toolkit demo scenes
	vr.switch_scene("res://demo_scenes/UIDemoScene.tscn");


func _on_Restart_Button_pressed():
	_beepsaber.restart_map();


func _on_Continue_Button_pressed():
	_beepsaber.continue_map();
