extends Spatial

const INFO_TEXT = """Jog in place to move in this demo.

Based on your head movement it will simulate
moving forard.
You can also climb everything in this demo."""

func _ready():
	$OQ_UILabel.set_text(INFO_TEXT)
