# Simple visibility toggle on button press
extends Spatial

export(vr.BUTTON) var toggle_button = vr.BUTTON.Y;

# we have this separate to see it in the editor but
# have it hidden on actual start
export var invisible_on_start = false;

var cycle_through_children = false; #Not yet implemented

func _process(dt):
	if (vr.button_just_pressed(toggle_button)):
		if (!cycle_through_children):
			visible = !visible;
		else:
			print("TODO: non global visibility toggle not yet implemented");

func _ready():
	if (invisible_on_start): visible = false;
