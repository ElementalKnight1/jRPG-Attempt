extends HBoxContainer



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_text(new_text):
	$Label.text = new_text

func get_text():
	return $Label.text

##Highlights a row (mostly to make it obvious whose turn it is now)
func highlight():
	$Label.set("theme_override_font_sizes/font_size",24)
