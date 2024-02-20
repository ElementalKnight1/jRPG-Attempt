extends Control

#const InitiativeTextLabelResource = preload("res://initiative_list_label.tscn")
const InitiativeTextLabelResource = preload("res://initiative_list_item.tscn")
var initiative_row_holder = []
var initiative_array = []
var characters_to_remove = []

signal your_turn(character)
#const font = preload("res://fonts/ManaSeedTitle.ttf")
# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("end_of_turn", end_of_turn)
	SignalBus.connect("character_died", character_died)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_new_round():
	initiative_array = create_initiative_list()
	populate_list(initiative_array)
	highlight_next_up()

func end_of_turn():
	if not characters_to_remove.is_empty():
		print("Time to clean the initiative!")
		clean_initiative_array()
	
	next_turn()

func next_turn():
	#visible = false
	var entry_to_remove = initiative_row_holder.pop_front() #pop the old one
	entry_to_remove.queue_free() #and delete it from the initiative listing.
	initiative_array.pop_front()
	if initiative_row_holder.size() > 0 and initiative_array[0][0] != null: #we still have turns in this round.
		highlight_next_up()
		
		#your_turn.emit(initiative_array[0])
		#initiative_row_holder[0].highlight() #highlight the new current turn
	elif initiative_row_holder.size() > 0 and initiative_array[0][0] == null:
		end_of_turn()
	else:
		#print("That's the end of the round...")
		SignalBus.emit_signal("end_of_round")
	#visible = true
		
		

func create_initiative_list():
	var temp_initiative_array = []
	var temp_array = []
	for side in ["hero","enemy"]:
		for character in SignalBus.combatants_dict[side]:
			temp_array = []
			temp_array.append(character)
			temp_array.append(character.get_stat("initiative")) #this can be more dynamic and interesting later.
			temp_initiative_array.append(temp_array)
	temp_initiative_array.sort_custom(func(a, b): return a[1] > b[1])
	return temp_initiative_array

func character_died(character):
	characters_to_remove.append(character)
	#print("Characters to remove:")
	#print(characters_to_remove)
	#print(character.get_stat("character_name")+" has died!")
	#print(initiative_array)
	#var i = 0
	#var indices_to_remove = []
	#while i < len(initiative_array) - 1:
		##print("Trying to find them...")
		#if initiative_array[i][0] == character:
			#print("FOUND 'EM in the Initiative Array, at position "+str(i))
			#indices_to_remove.append(i)
			#
		#i += 1
	#for index in indices_to_remove:
		#initiative_row_holder[i].queue_free()
		#initiative_row_holder.remove_at(i) #remove it from the UI elements too, which actually controls things.
		#initiative_array.remove_at(i)

func clean_initiative_array():
	var i = 0
	var indices_to_remove = []
	for character in characters_to_remove:
		i = 0
		while i < len(initiative_array) - 1:
			#print("Trying to find them...")
			if initiative_array[i][0] == character:
				#print("FOUND 'EM in the Initiative Array, at position "+str(i))
				indices_to_remove.append(i)
				
			i += 1
		#character.really_remove_from_fight()
	indices_to_remove.sort_custom(sort_ascending)
	for index in indices_to_remove:
		initiative_row_holder[i].queue_free()
		initiative_row_holder.remove_at(i) #remove it from the UI elements too, which actually controls things.
		initiative_array.remove_at(i)
	
	characters_to_remove = []

func sort_ascending(a,b):
	if a < b:
		return true
	return false

func populate_list(initiative_array):	
	for entry in initiative_array:
		var entry_row = InitiativeTextLabelResource.instantiate()
		entry_row.set_text(entry[0].get_stat("character_name"))
		$VBoxContainer.add_child(entry_row)
		#var entry_row = HBoxContainer.new()#Label.new()
		#var entry_name = InitiativeTextLabelResource.instantiate()
		#entry_name.set_text(entry[0].get_stat("character_name"))
		#entry_row.add_child(entry_name)
		#$VBoxContainer.add_child(entry_row)
		initiative_row_holder.append(entry_row)
	
func highlight_next_up():
	initiative_row_holder[0].highlight()
	SignalBus.emit_signal("start_next_turn", initiative_array[0][0])
	pass
	
