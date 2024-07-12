extends Node

const DamagePopupResource = preload("res://damage_popup.tscn")
const SkillSelectMenuResource = preload("res://skill_select_menu.tscn")
const BattleEnemyResource = preload("res://battle_enemy.tscn")
const CharacterResource = preload("res://character.tscn")
#var character_array = []
#var enemy_array = []
#var hero_array = []
#var combatants_dict = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("end_of_round", top_of_round)
	SignalBus.connect("start_next_turn", start_next_turn)
	#TEST Need to set up the fight in a more generic way
	add_character("res://test_char_30.tres")
	add_character("res://test_char_10.tres")
	#add_character("res://blue_slime.tres")
	add_character("res://data/enemies/red_dragon.tres")
	add_character("res://data/enemies/test_snake.tres")
	add_character("res://data/enemies/blue_slime.tres")

	#$Character01.load_stats("res://test_char_30.tres")
	#$Enemy01.load_stats("res://test_dragon.tres")
	#$Enemy02.load_stats("res://test_dragon.tres")
	#print(str($Character01.position)) #TEST
	#print($Enemy01.get_stat("character_type"))
	#print($Character01.get_stat("character_type"))
	
	#TEST need to set up color modulation in a more generic (and remembered) way, too
	#get_node("Character01/CharacterSpritesHair").modulate = Color (randf(),randf(),randf())
	
	#Set up the initiative box
	
	
	#character_array = [$Character01,$Enemy01,$Enemy02]
	#SignalBus.combatants_dict["hero"] = [$Character01]
	#SignalBus.combatants_dict["enemy"] = [$Enemy01,$Enemy02]
	$InitiativeBox.start_new_round()
	#$InitiativeBox.print_tree_pretty() #test

func add_character(resource_string = ""):
	var tempChar = CharacterResource.instantiate()
	tempChar.load_stats(resource_string)
	if tempChar.get_stat("character_type") == "enemy":
		tempChar = BattleEnemyResource.instantiate()
		tempChar.load_stats(resource_string)
		#print("Adding: "+tempChar.get_stat("character_name")+" as an Enemy.")
		tempChar.override_sprite()
		print(tempChar.get_stat("character_name"), " AI: ", tempChar.get_stat("BattleAI"))
		
	#print("Adding: "+tempChar.get_stat("character_name"))
	$Combatants.add_child(tempChar) #probably wanna organize this a bit more, 
						#so the tree is pretty and heroes / enemies are organized properly.
	
	#Alright, put them in the useful arrays
	#character_array.append(tempChar)
	if tempChar.get_stat("character_type") == "hero":
		#hero_array.append(tempChar)
		SignalBus.combatants_dict["hero"].append(tempChar)
		
	elif tempChar.get_stat("character_type") == "enemy":
		#enemy_array.append(tempChar)
		SignalBus.combatants_dict["enemy"].append(tempChar)
	tempChar.position = determine_combatant_starting_position(tempChar)
	pass # Replace with function body.

func determine_combatant_starting_position(tempChar):
	var temp_position = Vector2.ZERO
	if tempChar.get_stat("character_type") == "hero":
		var num_heroes = len(SignalBus.combatants_dict["hero"]) - 1
		
		temp_position.x = 630 + ((num_heroes % 2) * 48) + floor((num_heroes / 5) * 48)
		temp_position.y = 176 + ((num_heroes % 5) * 48)
		
	elif tempChar.get_stat("character_type") == "enemy":
		var num_enemies = len(SignalBus.combatants_dict["enemy"]) - 1
		temp_position.x = 96 + (floor(num_enemies / 3) * 64)
		temp_position.y = 160 + ((num_enemies % 3) * 64)
	return temp_position

func top_of_round():
	$InitiativeBox.start_new_round()
	pass

func start_next_turn(character):
	#print(character.get_stat("character_type"))
	if character.get_stat("character_type") == "enemy":
		#print(character.get_stat("character_name")) #TEST
		pass
		if character.get_stat("BattleAI") == []: #default for now
			$AttackHelper.spell_fire(character,SignalBus.combatants_dict["hero"][0])
		else: #we have an AI script to work with, yay!
			var enemyTurnOutput = $EnemyAIHelper.evaluate_BattleAI(character)
			var enemyAttack = AttackDatabase.get_attack(enemyTurnOutput["Attack"])
			print(enemyTurnOutput)
			#print(enemyAttack)
			$AttackHelper.do_attack_from_instruction_list(character,enemyTurnOutput["Target"],enemyAttack)
			#$AttackHelper.spell_fire(character,SignalBus.combatants_dict["hero"][0])
		#
		#do_attack(character,$Character01) #hard-coding the target for the moment.
	elif character.get_stat("character_type") == "hero":
		var skillMenu = SkillSelectMenuResource.instantiate()
		add_child(skillMenu)
		#skillMenu.receive_character_array(SignalBus.combatants_dict)
		skillMenu.receive_current_user(character)
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




#func _on_attack_test_button_3_pressed():
	##Currently unused, but I might make a button again to test things in the future.
	#$AttackHelper.spell_fire($Character01,$Enemy01)
	#pass # Replace with function body.
#
#
#func _on_attack_test_button_4_pressed():
	##Currently unused, but I might make a button again to test things in the future.
	#var testAttackArgs=[]
	#testAttackArgs.append({"type":"dialogue","text":"Mega Impact Hammer","timer":2.0})
	#testAttackArgs.append({"type":"animation","animation":"attack_sword_l_2","position":"user","timer":0.4})
	#testAttackArgs.append({"type":"FX","position":"target","path":"fx_ice_01","flip":true}) #fx_impact_01
	#testAttackArgs.append({"type":"damage","damage_stat":"strength","defense_stat":"vitality",
							#"damage_stat_multiplier":3,"element":"fire"})
	#$AttackHelper.do_attack_from_instruction_list($Character01,$Enemy01,testAttackArgs)
	#pass # Replace with function body.
