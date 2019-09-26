extends Spatial

func _ready():
	#$"Racket/Racket-col".mass = 1.0;
	#$"Racket/Racket-col".continuous_cd = true;
	#$"Racket/Racket-col/shape0".shape.set_margin(0.001);
	#$"Racket/Racket-col/shape1".shape.set_margin(0.001);
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
