extends Node

signal start_next_turn(character)
signal end_of_round()
signal end_of_turn()
signal do_attack_from_instruction_list(user,target,instruction_list)
signal character_died(character)



@export var combatants_dict = {"hero":[],"enemy":[]}

var tileEdgeSubstitutionDictionary = {
	"000001001":"000001000",
	"001001001":"000001000",
	"000000011":"000000010",
	"000000111":"000000010",
	"111000000":"010000000",
	"110000000":"010000000",
	"011000000":"010000000",
	"000001011":"000001111",
	"010001000":"011001000",
	"100100000":"000100000",
	"110001001":"011001000",
	"110100010":"110100000",
	"000100010":"000100000",
	"010001001":"110100000"
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
