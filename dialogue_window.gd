extends Control


# Called when the node enters the scene tree for the first time.
func _ready(lifetime=0.0):
	if lifetime > 0.0:
		$LifetimeTimer.start(lifetime)
	reposition()
	pass # Replace with function body.

func reposition(type="announce"):
	pass
	if type == "announce":
		
		#size.x = get_viewport_rect().size.x
		#$NinePatchRect.size.x = get_viewport_rect().size.x - 16
		position = get_viewport_rect().size / 2
		
		position.y = $NinePatchRect.size.y / 2 + 16
		#position.y = get_viewport_rect().size.y / 2
		#position.x = 0
		#print(str(get_viewport_rect().size / 2))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_lifetime_timer(lifetime=2.0):
	$LifetimeTimer.start(lifetime)

func _on_lifetime_timer_timeout():
	queue_free()

func change_text(new_text, is_centered=false):
	if is_centered:
		$NinePatchRect/DialogueText.text = "[center]"+str(new_text)+"[/center]"
	else:
		$NinePatchRect/DialogueText.text = str(new_text)
