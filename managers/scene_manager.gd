class_name SceneManager
extends Node

func _ready():
	SignalBus.connect("scene_change", scene_change)

enum SceneOption {
	HOME_SCREEN,
	DUMMY_SCENE_1,
	DUMMY_SCENE_2,
}

func scene_change(scene: SceneOption):
	var scene_path = null
	match scene:
		SceneOption.HOME_SCREEN:
			scene_path = "res://scenes/home_screen.tscn"
		SceneOption.DUMMY_SCENE_1:
			scene_path = "res://scenes/dummy_scene.tscn"
		_:
			print( "Unable to find scene" ); return
	get_tree().change_scene_to_file(scene_path)
