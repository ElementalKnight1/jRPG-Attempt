extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func determine_next_action(character):
	print(character.get_stat("BattleAI"))
	print(character.get_stat("BattleAIMemory"))
	
	
func evaluate_BattleAI(character):
	var currTarget = null
	var currAttack = ""
	for curr_row in character.get_stat("BattleAI"):
		print(str(curr_row))
		if curr_row[0] == "Attack":
			currAttack = curr_row[1]
		elif curr_row[0] == "Target":
			currTarget = determine_target(curr_row[1])
	if not currTarget:
		currTarget = determine_target("hero") #default
	
	return {"Target":currTarget,"Attack":currAttack} 
	#could eventually have it be able to return a custom script, too.

func determine_target(args):
	var temp_target_array = []
	var comparison_result = false
	var value_to_check = null
	
	for character in SignalBus.combatants_dict[args["side"]]:
		if args.has("stat_to_check"):
			if args["stat_to_check"] != "":
				value_to_check = character.get_stat(args["stat_to_check"])
				if args["check_operand"] == "==":
					if value_to_check == args["check_value"]: comparison_result = true
				elif args["check_operand"] == "!=":
					if value_to_check != args["check_value"]: comparison_result = true
				elif args["check_operand"] == ">=":
					if value_to_check >= args["check_value"]: comparison_result = true
				elif args["check_operand"] == "<=":
					if value_to_check <= args["check_value"]: comparison_result = true
				elif args["check_operand"] == ">":
					if value_to_check > args["check_value"]: comparison_result = true
				elif args["check_operand"] == "<":
					if value_to_check < args["check_value"]: comparison_result = true
				
				if comparison_result == true:
					temp_target_array.append(character)
		else: #we just need anyone
			temp_target_array.append(character)
	
	if args["one_or_all"] == "one":
		temp_target_array = [temp_target_array.pick_random()]
	
	return temp_target_array
