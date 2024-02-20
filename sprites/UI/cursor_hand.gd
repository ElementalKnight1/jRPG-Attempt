extends Control

#var combatants_dict = {}
var curr_target_side = ""
var current_target
var current_target_side_index = 0
var can_target_all = true
var current_flicker_index = 0

signal target_selected(target)

# Called when the node enters the scene tree for the first time.
func _ready():
	grab_focus()
	#print("Cursor online!")
	pass # Replace with function body.

func initiate(default_target):
	#set_combatants_dict(temp_combatants_dict)
	move_cursor_to_character(default_target)
	if typeof(current_target) != TYPE_STRING:
		curr_target_side = default_target.get_stat("character_type")
		current_target = default_target
	elif default_target == "all enemies":
		curr_target_side = "enemy"
	elif default_target == "all heroes":
		curr_target_side = "hero"
	elif default_target == "all combatants":
		curr_target_side = "all"
		current_target = "all combatants"
	#print("Cursor initiated!")

#func set_combatants_dict(temp_combatants_dict):
#	combatants_dict = temp_combatants_dict
#	print("Cursor's Combatants dictionary set!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move_cursor(location):
	$CursorSprite.position = location
	#print("Cursor is now at "+str($CursorSprite.position))

func move_cursor_to_character(character):
	if typeof(character) != TYPE_STRING:
		$MultiTargetFlickerTimer.stop()
		current_flicker_index = 0
		position_cursor(character)
	else:
		if character == "all enemies":
			position_cursor(SignalBus.combatants_dict["enemy"][0])
		else: #all heroes or all combatants
			position_cursor(SignalBus.combatants_dict["hero"][0])
		$MultiTargetFlickerTimer.start() #and this should handle the flickering
	

func position_cursor(character):
	var temp_pos = Vector2.ZERO
	var character_size = character.get_character_size()
	#print("Character Size (X): "+str(character_size.x))
	temp_pos = Vector2(character.position.x - (character_size.x / 2.0),character.position.y )
	#move_cursor(character.position)
	move_cursor(temp_pos)

func _gui_input(event):
	#print("Cursor received GUI Input Event!")
	if event.is_action_pressed("ui_accept"):
		target_selected.emit(current_target)
		#get_tree().set_input_as_handled()
		queue_free()
		#return current_target #this might need to be a signal.
	elif event.is_action_pressed("ui_cancel"):
		target_selected.emit(null)
		#get_tree().set_input_as_handled()
		queue_free()
	if typeof(current_target) != TYPE_STRING or current_target != "all combatants":
		if event.is_action_pressed("ui_down"):
			current_target_side_index += 1
			if current_target_side_index > (len(SignalBus.combatants_dict[curr_target_side]) - 1):
				current_target_side_index = 0 #loop back around
			current_target = SignalBus.combatants_dict[curr_target_side][current_target_side_index]
		if event.is_action_pressed("ui_up"):
			current_target_side_index -= 1
			if current_target_side_index < 0:
				current_target_side_index = len(SignalBus.combatants_dict[curr_target_side]) - 1
			current_target = SignalBus.combatants_dict[curr_target_side][current_target_side_index]
		if event.is_action_pressed("ui_left"):
			if curr_target_side == "hero" and typeof(current_target) != TYPE_STRING:
				curr_target_side = "enemy"
				if current_target_side_index > (len(SignalBus.combatants_dict[curr_target_side]) - 1):
					current_target_side_index = 0
				current_target = SignalBus.combatants_dict[curr_target_side][current_target_side_index]
			elif curr_target_side == "hero" and typeof(current_target) == TYPE_STRING:
				current_target_side_index = 0
				current_target = SignalBus.combatants_dict[curr_target_side][current_target_side_index]
			elif curr_target_side == "enemy" and can_target_all and len(SignalBus.combatants_dict["enemy"]) > 1:
				current_target = "all enemies"
		if event.is_action_pressed("ui_right"):
			if curr_target_side == "enemy" and typeof(current_target) != TYPE_STRING:
				curr_target_side = "hero"
				if current_target_side_index > (len(SignalBus.combatants_dict[curr_target_side]) - 1):
					current_target_side_index = 0
				current_target = SignalBus.combatants_dict[curr_target_side][current_target_side_index]
			elif curr_target_side == "enemy" and typeof(current_target) == TYPE_STRING:
				current_target_side_index = 0
				current_target = SignalBus.combatants_dict[curr_target_side][current_target_side_index]
			elif curr_target_side == "hero" and can_target_all and len(SignalBus.combatants_dict["hero"]) > 1:
				current_target = "all heroes"
		
		
		move_cursor_to_character(current_target)
	
	
	#move to the position of the chosen target
	


func _on_multi_target_flicker_timer_timeout():
	pass # Replace with function body.
	current_flicker_index += 1
	var temp_target = null
	if current_target == "all enemies":
		if current_flicker_index > len(SignalBus.combatants_dict["enemy"]) - 1:
			current_flicker_index = 0
		temp_target = SignalBus.combatants_dict["enemy"][current_flicker_index]
	elif current_target == "all heroes":
		if current_flicker_index > len(SignalBus.combatants_dict["hero"]) - 1:
			current_flicker_index = 0
		temp_target = SignalBus.combatants_dict["hero"][current_flicker_index]
	else: #all combatants
		var temp_array = SignalBus.combatants_dict["hero"]
		temp_array.append_array(SignalBus.combatants_dict["enemy"])
		if current_flicker_index > len(temp_array) - 1:
			current_flicker_index = 0
		temp_target = temp_array[current_flicker_index]
	position_cursor(temp_target)
	$MultiTargetFlickerTimer.start()
