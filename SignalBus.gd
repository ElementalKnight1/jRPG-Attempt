extends Node

signal start_next_turn(character)
signal end_of_round()
signal end_of_turn()
signal do_attack_from_instruction_list(user,target,instruction_list)
signal character_died(character)

@export var combatants_dict = {"hero":[],"enemy":[]}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
