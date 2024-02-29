extends Control
var skill_info_holder = {}
var character_array = []
var enemy_array = []
var hero_array = []
var current_user = null
#var combatants_dict = {}
const TargetSelectionResource = preload("res://sprites/UI/cursor_hand.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Button1.grab_focus()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func receive_current_user(temp_user):
	current_user = temp_user

func feed_button_attack_data(button="",attack_data=[]):
	skill_info_holder[button] = attack_data

#func receive_character_array(temp_combatants_dict):
#	combatants_dict = temp_combatants_dict

func fire_off_skill(user,target,instruction_list):
	SignalBus.emit_signal("do_attack_from_instruction_list",user,target,instruction_list)
	queue_free() #get rid of the menu entirely


func _on_button_1_pressed():
	var testAttackArgs=[]
	testAttackArgs = AttackDatabase.get_attack("Fire 1")
	#testAttackArgs.append({"type":"definitions","name":"Fire 1","default_target":"enemy","target":"single","description":"A simple fire spell."})
	#testAttackArgs.append({"type":"dialogue","text":"Fire 1","timer":2.0})
	#testAttackArgs.append({"type":"animation","animation":"attack_sword_l_2","position":"user","timer":0.4})
	#testAttackArgs.append({"type":"FX","position":"target","path":"fx_fire_01","flip":true}) #fx_impact_01
	#testAttackArgs.append({"type":"damage","damage_stat":"knowledge","defense_stat":"spirit",
							#"damage_stat_multiplier":1,"element":"none"})
	#fire_off_skill(combatants_dict["heroes"][0],combatants_dict["enemies"][0],testAttackArgs)
	select_target_with_cursor(testAttackArgs[0]["default_target"],$VBoxContainer/Button1,testAttackArgs)


func _on_button_2_pressed():
	var testAttackArgs=[]
	testAttackArgs = AttackDatabase.get_attack("Ice 2")
	#testAttackArgs.append({"type":"definitions","name":"Ice 2","target":"all enemies","default_target":"enemy","description":"A journeyman ice spell. Hits all foes on the field."})
	#testAttackArgs.append({"type":"dialogue","text":"Ice 2","timer":2.0})
	#testAttackArgs.append({"type":"animation","animation":"attack_sword_l_2","position":"user","timer":0.4})
	#testAttackArgs.append({"type":"FX","position":"target","path":"fx_ice_02","flip":true}) #fx_impact_01
	#testAttackArgs.append({"type":"damage","damage_stat":"knowledge","defense_stat":"spirit",
							#"damage_stat_multiplier":6,"element":"ice"})
	#fire_off_skill(combatants_dict["heroes"][0],combatants_dict["enemies"][0],testAttackArgs)
	select_target_with_cursor(testAttackArgs[0]["default_target"],$VBoxContainer/Button2,testAttackArgs)


func _on_button_3_pressed():
	
	var testAttackArgs=[]
	testAttackArgs = AttackDatabase.get_attack("Mega Impact Hammer")
	
	#testAttackArgs.append({"type":"definitions","name":"Mega Impact Hammer","default_target":"enemy","target":"single","description":"A powerful hammer blow."})
	#testAttackArgs.append({"type":"dialogue","text":"Mega Impact Hammer","timer":2.0})
	#testAttackArgs.append({"type":"animation","animation":"attack_sword_l_2","position":"user","timer":0.4})
	#testAttackArgs.append({"type":"FX","position":"target","path":"fx_impact_01","flip":true}) #fx_impact_01
	#testAttackArgs.append({"type":"damage","damage_stat":"strength","defense_stat":"vitality",
							#"damage_stat_multiplier":3,"element":"none"})
	#release_focus()
	
	#Let's figure out who we should start the targeting on by default.
	select_target_with_cursor(testAttackArgs[0]["default_target"],$VBoxContainer/Button3,testAttackArgs)
	#var temp_default_target = null
	#if testAttackArgs[0]["default_target"] == "enemy":
		#temp_default_target = combatants_dict["enemy"][0]
	#elif testAttackArgs[0]["default_target"] == "friend":
		#temp_default_target = combatants_dict["hero"][0]
	#elif testAttackArgs[0]["default_target"] == "self":
		#temp_default_target = current_user
	#
	##Actually start up the targeting cursor
	#var temp_target_cursor = TargetSelectionResource.instantiate()
	#temp_target_cursor.initiate(combatants_dict,temp_default_target)
	#add_child(temp_target_cursor)
	#
	##Now, let's wait and see who the player selects using the targeting cursor.
	#var temp_target 
	#temp_target = await temp_target_cursor.target_selected
	#if temp_target != null:
		#fire_off_skill(current_user,temp_target,testAttackArgs)
	#else: #if it IS null, then we backed out of selecting the attack
		#$VBoxContainer/Button3.grab_focus()
	
	#fire_off_skill(character_array[0],character_array[1],testAttackArgs)

func select_target_with_cursor(default_target,original_button,testAttackArgs):
	var temp_default_target = null
	if default_target == "enemy":
		temp_default_target = SignalBus.combatants_dict["enemy"][0]
	elif default_target == "friend":
		temp_default_target = SignalBus.combatants_dict["hero"][0]
	elif default_target == "self":
		temp_default_target = current_user
	
	#Actually start up the targeting cursor
	var temp_target_cursor = TargetSelectionResource.instantiate()
	temp_target_cursor.initiate(temp_default_target)
	add_child(temp_target_cursor)
	
	#Now, let's wait and see who the player selects using the targeting cursor.
	var temp_target 
	temp_target = await temp_target_cursor.target_selected
	if temp_target != null:
		fire_off_skill(current_user,temp_target,testAttackArgs)
	else: #if it IS null, then we backed out of selecting the attack
		original_button.grab_focus()
