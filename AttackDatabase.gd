extends Node #Resource

@export var data = {"Mega Impact Hammer":[
		{"type":"definitions","name":"Mega Impact Hammer","default_target":"enemy","target":"single","description":"A powerful hammer blow."},
		{"type":"dialogue","text":"Mega Impact Hammer","timer":2.0},
		{"type":"animation","animation":"attack_sword_l_2","position":"user","timer":0.4},
		{"type":"FX","position":"target","path":"fx_impact_01","flip":true},
		{"type":"damage","damage_stat":"strength","defense_stat":"vitality",
								"damage_stat_multiplier":3,"element":"none"}
	],
	"Ice 2":[
		{"type":"definitions","name":"Ice 2","target":"all enemies","default_target":"enemy","description":"A journeyman ice spell. Hits all foes on the field."},
		{"type":"dialogue","text":"Ice 2","timer":2.0},
		{"type":"animation","animation":"attack_sword_l_2","position":"user","timer":0.4},
		{"type":"FX","position":"target","path":"fx_ice_02","flip":null},
		{"type":"damage","damage_stat":"knowledge","defense_stat":"spirit",
							"damage_stat_multiplier":6,"element":"ice"}
	],
	"Fire 1":[
		{"type":"definitions","name":"Fire 1","default_target":"enemy","target":"single","description":"A simple fire spell."},
		{"type":"dialogue","text":"Fire 1","timer":2.0},
		{"type":"animation","animation":"attack_sword_l_2","position":"user","timer":0.4},
		{"type":"FX","position":"target","path":"fx_fire_01","flip":true},
		{"type":"damage","damage_stat":"knowledge","defense_stat":"spirit",
							"damage_stat_multiplier":1,"element":"none"}
	]
}

func get_attack(attack_name):
	return data[attack_name]
	
func get_attack_targetting_default_side(attack_name):
	return data[attack_name][0]["default_target"]

func get_attack_targetting_type(attack_name):
	return data[attack_name][0]["target"]

func get_attack_description(attack_name):
	return data[attack_name][0]["description"]
