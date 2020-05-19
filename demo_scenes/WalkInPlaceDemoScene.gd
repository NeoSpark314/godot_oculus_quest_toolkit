extends Spatial

const INFO_TEXT = """Jog in place to move in this demo.

Based on your head movement it will simulate
moving forard.
You can also climb everything in this demo."""

func _physics_process(_dt):
	if (vr.button_just_pressed(vr.BUTTON.ENTER)): # switch back to main menu
		vr.switch_scene("res://demo_scenes/UIDemoScene.tscn");


func _ready():
	$OQ_UILabel.set_label_text(INFO_TEXT)
