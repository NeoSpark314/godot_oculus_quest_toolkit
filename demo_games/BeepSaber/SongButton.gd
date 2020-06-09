extends TextureButton


var id
var info

signal pressed_id(id)

func _ready():
	if info:
		$Label.text = "%s - %s"%[info._songAuthorName, info._songName]
	else:
		$Label.text = "Fail!!"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SongButton_pressed():
	emit_signal("pressed_id", id)
