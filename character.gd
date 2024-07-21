extends Node2D
@export var is_active = false
@export var stats: Resource
@export var isMoving = false
@export var facing = "d"
@export var is_protagonist = true
@export var cheat_walk_through_walls = false
@export var cheat_move_faster = false
@export var movementSpeedFactor = 4.0

#var save_path = "res://test_char.tres"


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("start_next_turn", start_turn)
	$CharacterSpritesBase.modulate = Color(1,1,1)
	#if stats:
	#	print("HP: "+str(stats.HP))
	
	pass # Replace with function body.
	#load_character(save_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#If we were walking, but now we've stopped, let's look like we've stopped.
	if self.isMoving == false and $CharacterSpritesBase.get_animation().begins_with("walk_"):
		play_anim("idle_"+facing,false)

func set_up_character():
	pass
	#CharacterStats = load_character_data()
func activate_cheat_move_faster(onOrOff:bool):
	self.cheat_move_faster = onOrOff
	if onOrOff:
		self.movementSpeedFactor = 8
	else:
		self.movementSpeedFactor = 4

func move(dir):
	#change direction (internally)
	if dir.x < 0:
		facing = "l"
	elif dir.x > 0:
		facing = "r"
	elif dir.y < 0:
		facing = "u"
	else:
		facing = "d"
	
	#check if we're going to walk into something
	$RayCast2D.target_position = dir * (16)
	$RayCast2D.force_raycast_update()
	
	#if we're not going to walk into something,
	#then start moving that way
	if (not $RayCast2D.is_colliding()) or cheat_walk_through_walls:
		var tween = create_tween()
		tween.tween_property(self, "position",
			position + dir * 16, 1.0/self.movementSpeedFactor).set_trans(Tween.TRANS_LINEAR)
		self.isMoving = true
		if is_protagonist:
			SignalBus.increment_encounter_step_counter()
		#if we aren't playing the animation already, start it.
		if $CharacterSpritesBase.get_animation() != "walk_"+facing:
			play_anim("walk_"+facing,false)
		await tween.finished
		self.isMoving = false
	else:
		play_anim("idle_"+facing) #change facing
		


func get_character_size():
	pass
	var temp = $CharacterSpritesBase.get_sprite_frames()
	var current_anim = $CharacterSpritesBase.get_animation()
	var temp_size = temp.get_frame_texture(current_anim,0).get_size()
	return temp_size
	
	
func load_stats(filepath):
	if ResourceLoader.exists(filepath):
		stats = ResourceLoader.load(filepath).duplicate()

func get_stat(statistic):
	#print(stats)
	return stats.get(statistic)
	#return $CharacterStatistics.get(statistic)

func get_Area2D():
	return $Area2D

func start_turn(character):
	#print(character) #test
	if character == self:
		pass
		#print(get_stat("character_name")+"'s turn!")

func alter_HP(amount):
	stats.HP -= amount
	#print(get_stat("character_name") + " took " + str(amount) + " damage!")
	#print(get_stat("character_name") + " has " + str(get_stat("HP")) + " HP left.")
	if stats.HP <= 0 and stats.character_type == "enemy":
		#We're a bad guy who died!
		$CharacterSpritesBase.modulate = Color(.796,.349,.831) #RGB: 203,89,212
		$AnimationPlayer.play("death_default")

func really_remove_from_fight():
	SignalBus.combatants_dict["enemy"].erase(self)
	self.queue_free()

func remove_character_from_fight():
	SignalBus.emit_signal("character_died",self)
	really_remove_from_fight()

func set_stat(statistic, new_value):
	stats.set(statistic,new_value)
	#$CharacterStatistics.set(statistic,new_value)

func calculate_stat_from_growth_rate(statistic):
	
	if statistic != "HPmax" and statistic != "MPmax":
		statistic = statistic.to_lower()
		var temp_growth_stat = "growth_"+str(statistic)
		var temp_growth_stat_value = stats.get(temp_growth_stat)
		var temp_stat = StatGrowth.level_table[temp_growth_stat_value][stats.get("level")-1]
		stats.set(statistic,temp_stat)
	elif statistic == "HPmax":
		var temp_max_HP = round((3.0 * (stats.get("level") ** 1.2)) + (6.5 * stats.get("vitality") ** 1.32))
		stats.set(statistic, temp_max_HP)
	elif statistic == "MPmax":
		var temp_max_MP = round((0.5 * (stats.get("level") ** 1.2)) + (2.0 * stats.get("willpower") ** 1.1))
		stats.set(statistic, temp_max_MP)

func calculate_all_stats():
	calculate_stat_from_growth_rate("Agility")
	calculate_stat_from_growth_rate("Knowledge")
	calculate_stat_from_growth_rate("Strength")
	calculate_stat_from_growth_rate("Vitality")
	calculate_stat_from_growth_rate("Willpower")
	
	calculate_stat_from_growth_rate("HPmax")
	calculate_stat_from_growth_rate("MPmax")

func print_character_stats():
	print(stats.get("character_name")+" stats: ")
	print("  LEVEL: "+str(stats.get("level")))
	print("  HP: "+str(stats.get("HP"))+" / "+str(stats.get("HPmax")))
	print("  MP: "+str(stats.get("MP"))+" / "+str(stats.get("MPmax")))
	print("  Agility: "+str(stats.get("agility"))+" ("+str(stats.get("growth_agility"))+" / 5)")
	print("  Knowledge: "+str(stats.get("knowledge"))+" ("+str(stats.get("growth_knowledge"))+" / 5)")
	print("  Strength: "+str(stats.get("strength"))+" ("+str(stats.get("growth_strength"))+" / 5)")
	print("  Vitality: "+str(stats.get("vitality"))+" ("+str(stats.get("growth_vitality"))+" / 5)")
	print("  Willpower: "+str(stats.get("willpower"))+" ("+str(stats.get("growth_willpower"))+" / 5)")

	##Check if this character has the animation in question.
func has_anim(desired_anim):
	if get_stat("character_type") == "enemy":
		return false #good enough for now, enemies might never get animations.
	var has_anim = true
	for obj in [$CharacterSpritesBase,$CharacterSpritesHair,$CharacterSpritesClothes]:
		has_anim = has_anim and obj.get_sprite_frames().has_animation(desired_anim)
	return has_anim
	
##Plays the given animation.
func play_anim(desired_anim,start_from_zero=true):
	$CharacterSpritesBase.play(desired_anim)
	$CharacterSpritesHair.play(desired_anim)
	$CharacterSpritesClothes.play(desired_anim)
	if start_from_zero:
		$CharacterSpritesBase.set_frame(0)
		$CharacterSpritesHair.set_frame(0)
		$CharacterSpritesClothes.set_frame(0)
	$AnimationPlayer.play(desired_anim)	
	pass

func override_sprite(new_sprite_path=""):
	if new_sprite_path == "":
		new_sprite_path = get_stat("sprite_override")
	if not new_sprite_path.begins_with("res://"):
		new_sprite_path = "res://sprites/enemies/"+new_sprite_path
	#var image = Image.load_from_file(new_sprite_path)
	#var texture = ImageTexture.create_from_image(image)
	var frameset = SpriteFrames.new()
	var frame1
	frameset.add_animation("default")
	frame1 = load(new_sprite_path) 
	frameset.add_frame("default", frame1)
	$CharacterSpritesBase.set_sprite_frames(frameset)
	$CharacterSpritesBase.play("default")
	#$CharacterSpritesBase.texture = texture
	#$CharacterSpritesBase/SpriteFrames.set_frame("default", 0, texture)
	
	
func flash_sprite():
	var flashes = 0
	
	while flashes <= 5:
		if flashes in [0,2,4]:
			$CharacterSpritesBase.modulate = Color(10,10,10)
			if get_stat("character_type") == "hero":
				$CharacterSpritesHair.modulate = Color(10,10,10)
				$CharacterSpritesClothes.modulate = Color(10,10,10)
		else:
			$CharacterSpritesBase.modulate = Color(1,1,1)
			if get_stat("character_type") == "hero":
				$CharacterSpritesHair.modulate = Color(1,1,1)
				$CharacterSpritesClothes.modulate = Color(1,1,1)
		
		await get_tree().create_timer(0.1).timeout
		flashes += 1
		
	#$CharacterSpritesBase.modulate = Color(1,1,1)
	#$characterSpritesHair.modulate = Color(1,1,1)
	#$characterSpritesClothes.modulate = Color(1,1,1)

func _on_character_base_sprites_animation_finished():
	$AnimationPlayer.stop()
	play_anim("idle_sword_l_1",false)
	#$CharacterSpritesBase.play("idle_sword_l_1")
	#$CharacterSpritesBase/AnimationPlayer.play("idle_sword_l_1")
	#$CharacterSpritesBase.set_frame(0)
	#pass # Replace with function body.


