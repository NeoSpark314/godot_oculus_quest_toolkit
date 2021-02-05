extends Spatial

#constants
MENU_PRESSED = -.001
X_PRESSED = -.002
Y_PRESSED = -.002

func _process(_delta):
	update_buttons();

# updates the positions of the buttons based on what is currently pressed
#  ideally the digital buttons would be updated on a signal rather than every delta
#  but in the interest of not modifying existing architecture it is done this way
func update_buttons():
	pass
