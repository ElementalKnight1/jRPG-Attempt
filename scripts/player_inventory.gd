class_name PlayerInventory
extends Resource

@export var gold: int = 0:
	get: return gold

func give_gold( amount: int ):
	request_gold( -1 * amount )

func request_gold( amount: int ) -> bool:
	if amount > gold: return false
	gold -= amount
	SignalBus.emit_signal("gold_changed")
	return true

func set_gold( amount: int ):
	if amount <= 0: return
	gold = amount
	SignalBus.emit_signal("gold_changed")
