extends Control

func _on_new_game_pressed():
	SignalBus.emit_signal("scene_change", SceneManager.SceneOption.DUMMY_SCENE_1)

func _on_load_game_pressed():
	SignalBus.emit_signal("load_game")
	SignalBus.emit_signal("scene_change", SceneManager.SceneOption.DUMMY_SCENE_1)
