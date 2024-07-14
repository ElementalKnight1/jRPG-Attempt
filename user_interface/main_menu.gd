extends Control

var active = false
var open = false

func _ready():
	update_display()
	SignalBus.connect("scene_change", scene_change)

func update_display():
	if !active || !open:
		hide()
		Engine.time_scale = 1.0
	else:
		var current = get_tree().current_scene
		# remove focus
		current.hide()
		current.show()
		# get menu on top
		if get_index() < current.get_index():
			get_tree().root.move_child( self, current.get_index() )
		#get_tree().current_scene.add_sibling( self )
		show()
		Engine.time_scale = 0.0

func _input(event):
	if !active: return
	if event.is_action_pressed("escape"):
		open = !open
		update_display()

func scene_change(scene: SceneManager.SceneOption):
	match scene:
		SceneManager.SceneOption.HOME_SCREEN:
			active = false
		_:
			active = true
			open = false
	update_display()

func _on_save_game_pressed():
	print("save pressed")
	SignalBus.emit_signal("save_game")

func _on_load_game_pressed():
	print("load pressed")
	SignalBus.emit_signal("load_game")

func _on_resume_pressed():
	open = false
	update_display()
