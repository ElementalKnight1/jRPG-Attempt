extends Node
const DamagePopupResource = preload("res://damage_popup.tscn")
const DialogueWindowResource = preload("res://dialogue_window.tscn")
signal end_of_attack

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("do_attack_from_instruction_list",do_attack_from_instruction_list)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func determine_damage(attacker,target,apply_damage = true, args={}):
	#print("Attempting to do damage...")
	var temp_damage = 0
	var temp_stat = 0
	
	#deal with attack and multipliers
	if "damage_stat" in args:
		temp_stat = attacker.get_stat(args["damage_stat"])
	else:
		temp_stat = attacker.get_stat("strength")
	
	if "damage_stat_multiplier" in args:
		temp_stat *= args["damage_stat_multiplier"]
		
	
	temp_damage += temp_stat
	temp_stat = 0
	
	#Deal with defense and multipliers
	if "defense_stat" in args:
		temp_stat = target.get_stat(args["defense_stat"])
	else:
		temp_stat = target.get_stat("vitality")
	
	if "defense_stat_multiplier" in args:
		temp_stat *= args["defense_stat_multiplier"]
	
	temp_damage -= temp_stat
	temp_stat = 0
	
	#clamp the damage, it's gotta be between 0 and 9,999
	if temp_damage < 0:
		temp_damage = 0 #clamp it!
	elif temp_damage > 9999:
		temp_damage = 9999
	
	temp_damage = snappedi(temp_damage,1) #round it to the nearest integer
	#print("Temp Damage: "+str(temp_damage))
	if not apply_damage:
		return temp_damage
	else:
		display_damage_popup(target,temp_damage)
		target.alter_HP(temp_damage)
		#print("Doing damage!") #TEST
		
		return temp_damage #in case we need to do math on it afterwards

func roll_CoS(chance,isTrueHit=false):
	var roll1 = -1
	var roll2 = -1
	var real_roll = -1
	chance *= 100
	#print("Chance: "+str(chance)+" out of 10,000")
	roll1 = randi_range(0,10000)
	roll2 = randi_range(0,10000)
	if isTrueHit:
		real_roll = (roll1 + roll2) / 2
	else:
		real_roll = roll1
	if chance >= real_roll:
		#print("Success! Rolled a "+str(real_roll))
		return true
	else:
		#print("Failure... Rolled a "+str(real_roll))
		return false
	pass

##Displays the bouncing damage numbers.
func display_damage_popup(which_character,how_much_damage):
	#print("Damage label on "+str(which_character))
	var damage_label_instance = DamagePopupResource.instantiate()
	self.add_child(damage_label_instance)
	#print("Damage Label Instance: " + str(damage_label_instance))
	damage_label_instance.change_text(str(how_much_damage))
	#print("Damage popup on "+ which_character.get_stat("character_name")+" with "+str(damage_label_instance.get_node("LifetimeTimer").time_left)+" seconds left.")
	#self.print_tree_pretty()
	#damage_label_instance.position(get_node(which_character+"/Area2D"))
	var new_pos = which_character.get_Area2D().get_global_transform_with_canvas()
	#print(new_pos)
	#var new_pos = get_node(which_character+"/Area2D").get_global_transform_with_canvas()
	#print(new_pos)
	#damage_label_instance.position = new_pos[2]
	damage_label_instance.go_to_location(new_pos[2])
	#print("Done setting up the damage popup.")
	
func do_attack(attacker,target):
	#print("Attack!")
	
	
	
	#print(attacker.get_stat("character_name") +" takes a swing at "+target.get_stat("character_name"))
	var tempDamage = 0
	if attacker.get_stat("character_type") == "hero":
		attacker.play_anim("attack_sword_l_2") #heroes get animations, enemies don't
	if see_if_attack_hit(attacker,target):
		#print("A direct hit!")
		determine_damage(attacker,target)
	else:
		#print("They missed!")
		display_damage_popup(target,"Miss!")
	
	$InitiativeBox.next_turn()

func play_character_anim(character,anim_string,start_from_zero=true):
	if character.has_anim(anim_string):
		character.play_anim(anim_string,true)
	else:
		character.flash_sprite()
	
func spell_fire(attacker,target):
	var tempDamage = 0
	play_character_anim(attacker,"attack_sword_l_2")
	#if attacker.get_stat("character_type") == "hero":
		#attacker.play_anim("attack_sword_l_2") #heroes get animations, enemies don't
	var tempFX = load_scene("res://sprites/effects/fx_fire_01.tscn",self)
	#var tempFX = load_scene("res://fx_slash_01.tscn",self)
	tempFX.position = target.get_Area2D().get_global_transform_with_canvas()[2]
	await tempFX.animation_finished
	#print("Done Waiting on the fire! 🔥")
	determine_damage(attacker,target,{"element":"fire"})
	await get_tree().create_timer(1.0).timeout
	#print("Done Waiting on the fire! 🔥")
	SignalBus.emit_signal("end_of_turn")
	
func do_attack_from_instruction_list(user,target,instruction_list = []):
	if typeof(target) == TYPE_STRING:
		if target == "all enemies":
			target = SignalBus.combatants_dict["enemy"]
		elif target == "all heroes":
			target = SignalBus.combatants_dict["hero"]
		elif target == "all combatants":
			target = SignalBus.combatants_dict["hero"]
			target.append_array(SignalBus.combatants_dict["enemy"])
	elif typeof(target) != TYPE_ARRAY: 
		#It wasn't a string, and it wasn't a predetermined array, 
		#so it's probably just one character.
		target = [target]
	
	var i = 0
	var is_last_combatant_in_loop = false
	for entry in instruction_list:
		i = 0
		is_last_combatant_in_loop = false
		for individual_target in target:
			if i == len(target) - 1: is_last_combatant_in_loop = true
			#print(str(entry) + " "+ str(individual_target))
			if entry["type"] == "FX":
				#get the scene
				
				#where's it going?
				var tempFXposition = Vector2.ZERO
				var tempFXside = null
				if entry["position"] == "target":
					tempFXposition = individual_target.get_Area2D().get_global_transform_with_canvas()[2]
					tempFXside = individual_target.get_stat("character_type")
				elif entry["position"] == "user":
					tempFXposition = user.get_Area2D().get_global_transform_with_canvas()[2]
					tempFXside = user.get_stat("character_type")
				
				#Okay, NOW start playing it.
				var tempFX = load_scene("res://sprites/effects/"+entry["path"]+".tscn",self)
				tempFX.position = tempFXposition
				#self.add_child(tempFX)
				
				
				
				#Do we need to flip it?
				if "flip" in entry: #If it's in there at all.
					if entry["flip"]: #If it's not null.
						if (entry["flip"] == true and tempFXside == "enemy") or (entry["flip"] == false and tempFXside == "hero"):
							tempFX.flip_h = true
				
				#wait for the FX to finish - will want to make this an option
				#Right now we only care about it if it's the last one in the group
				if is_last_combatant_in_loop:
					if "timer" in entry:
						if typeof(entry["timer"]) == TYPE_FLOAT:
							await get_tree().create_timer(entry["timer"]).timeout #give it a little time
						elif typeof(entry["timer"]) == TYPE_STRING:
							#TEMP - This is a place for edge cases.
							await tempFX.animation_finished
							tempFX.queue_free()
					else:
						await tempFX.animation_finished
						tempFX.queue_free()
				else:
					tempFX.animation_finished.connect(tempFX.queue_free)
				
				
				
				#await tempFX.animation_finished
				#tempFX.queue_free() #gotta remember to get rid of it when we're done!
			if entry["type"] == "dialogue":
				if is_last_combatant_in_loop: #for a multi-target attack, we only display the dialogue once.
					var dialogue_instance = DialogueWindowResource.instantiate()
					self.add_child(dialogue_instance)
					dialogue_instance.change_text(str(entry["text"]),true)
					#damage_label_instance.position(get_node(which_character+"/Area2D"))
					
					#position it on the screen
					#var new_pos = Vector2.ZERO
					#new_pos.x = 100 #TEST
					#dialogue_instance.position = new_pos
					
					if "timer" in entry:
						if typeof(entry["timer"]) == TYPE_FLOAT:
							#I'm positive there are better ways to do this, but meh.
							#I can always do it the Right Way later.
							dialogue_instance.start_lifetime_timer(entry["timer"])
							await get_tree().create_timer(entry["timer"]).timeout
							#yield(dialogue_instance,"tree_exited")
							#await get_tree().create_timer(entry["timer"]).timeout #give it a little time
						#elif typeof(entry["timer"]) == TYPE_STRING:
						#	await temp_animated.animation_finished
			
			
			if entry["type"] == "damage":
				determine_damage(user,individual_target,true,entry)
				#await get_tree().create_timer(0.1).timeout
				if is_last_combatant_in_loop:
					
					#print("Waiting on the last guy's damage...")
					#print(individual_target)
					#print_tree_pretty()
					await get_tree().create_timer(1.0).timeout
					#print("---Done waiting on the last guy's damage...")
				
			if entry["type"] == "animation":
				
				#What animation are we playing?
				var tempAnimation = ""
				if "animation" in entry:
					tempAnimation = entry["animation"]
				#Who's playing it?
				var temp_animated = user
				if entry["position"] == "target":
					temp_animated = individual_target
					#play_character_anim(target,tempAnimation)
				elif entry["position"] == "user":
					temp_animated = user
					#play_character_anim(user,tempAnimation)
				
				#Okay, now kick the animation off.
				play_character_anim(temp_animated,tempAnimation)
					
				#animation timing
				if "timer" in entry:
					if individual_target == target.back():
						if typeof(entry["timer"]) == TYPE_FLOAT:
							await get_tree().create_timer(entry["timer"]).timeout #give it a little time
						elif typeof(entry["timer"]) == TYPE_STRING:
							await temp_animated.animation_finished
			i += 1
	#We finished the attack, so the turn is done (this can probably be done better)
	#print("Finished the attack.")
	#print_tree_pretty()
	SignalBus.emit_signal("end_of_turn")
	
func load_scene(path, parent : Node) -> Node:
	var result : Node = null
	if ResourceLoader.exists(path):
		result = ResourceLoader.load(path).instantiate()
	if result:
		parent.add_child(result)
	return result
	
func see_if_attack_hit(attacker,target):
	var chance_to_hit = 85 #baseline chance to hit, if everyone's stats are equal
	var did_it_hit = true
	var tempDamage = 0	
	chance_to_hit += attacker.get_stat("perception")
	chance_to_hit += attacker.get_stat("level")
	chance_to_hit -= target.get_stat("level")
	chance_to_hit -= target.get_stat("agility")
	
	did_it_hit = roll_CoS(chance_to_hit,false)
	if did_it_hit:
		return true
	else:
		return false
		
func get_stat(which_character,which_stat,new_value = null):
	if new_value == null: #we're just getting the reference.
		return get_node(which_character+"/CharacterStatistics").get(which_stat)
	else: #we're tryign to set the stat.
		get_node(which_character+"/CharacterStatistics").set(which_stat,new_value)
