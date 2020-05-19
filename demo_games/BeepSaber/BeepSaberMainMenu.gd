extends Panel

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


var info = null;

func _load_and_show_song_info(path):
	info = vr.load_json_file(path + "info.dat");
	if (!info):
		vr.log_error("No info.dat found in " + path);
		return false;
		
	if (info._difficultyBeatmapSets.size() == 0):
		vr.log_error("No _difficultyBeatmapSets in info.dat");
		return false;
		
	$SongInfo_Label.text = """Song Author: %s
Song Title: %s
Beatmap Author: %s""" %[info._songAuthorName, info._songName, info._levelAuthorName]

	$cover.texture = load(path + info._coverImageFilename);


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
	_load_map_and_start(path, info);
	pass # Replace with function body.


func _on_Exit_Button_pressed():
	vr.switch_scene("res://demo_scenes/UIDemoScene.tscn");


func _on_Restart_Button_pressed():
	_beepsaber.restart_map();


func _on_Continue_Button_pressed():
	_beepsaber.continue_map();
