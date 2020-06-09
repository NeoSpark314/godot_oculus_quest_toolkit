extends TextureButton


var id
var Name

signal pressed_id(id)

func _ready():
	$Label.text = Name


func _on_DifficultyButton_pressed():
	emit_signal("pressed_id", id)
