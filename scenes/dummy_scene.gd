extends Control

@onready var display_gold = %DisplayGold

func _ready():
	SignalBus.connect("gold_changed", gold_changed)
	SignalBus.connect("successful_load", gold_changed)

func gold_changed():
	display_gold.text = "%d gp" % PersistentData.player_inventory.gold

func _on_gain_gold_pressed():
	PersistentData.player_inventory.give_gold( 100 )

func _on_spent_gold_pressed():
	if !PersistentData.player_inventory.request_gold( 95 ):
		print( "not enough gold" )

func _on_move_room_pressed():
	SignalBus.emit_signal("scene_change", SceneManager.SceneOption.DUMMY_SCENE_2)
