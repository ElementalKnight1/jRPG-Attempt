extends Node

const SAVE_PATH = "user://save.json"

static var player_inventory: PlayerInventory = PlayerInventory.new():
	get: return player_inventory

func _ready():
	SignalBus.connect("save_game", save)
	SignalBus.connect("load_game", load)

static func save():
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data = {
		"inventory": {
			"gold": var_to_str( player_inventory.gold ),
		}
	}
	file.store_line( JSON.stringify(data) )

static func load():
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json := JSON.new()
	json.parse(file.get_line())
	var data := json.get_data() as Dictionary
	player_inventory.gold = str_to_var(data.inventory.gold)
	SignalBus.emit_signal("successful_load")
