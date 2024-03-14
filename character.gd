extends Node2D
@export var is_active = false
@export var stats: Resource
@export var isMoving = false

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
	pass

func set_up_character():
	pass
	#CharacterStats = load_character_data()

func get_character_size():
	pass
	var temp = $CharacterSpritesBase.get_sprite_frames()
	var current_anim = $CharacterSpritesBase.get_animation()
	var temp_size = temp.get_frame_texture(current_anim,0).get_size()
	return temp_size
	
	
func load_stats(filepath):
	if ResourceLoader.exists(filepath):
		stats = ResourceLoader.load(filepath)

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


