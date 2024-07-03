extends Node2D

const TileSize = 16
const SeaLevel = 0.1
const ForestLevel = 0.3
const RENDER_DISTANCE = 48.0 #48 right now for a full screen's map
const screen_width = ((TileSize * RENDER_DISTANCE) / 2) - (TileSize / 2)
const screen_height = ((TileSize * RENDER_DISTANCE) / 2) - (TileSize / 2)

var tileArray = []
var currTileArrayX = -1
var currTileArrayY = -1

var currentCharacter

var inputs = {"move_right": Vector2.RIGHT,
			"move_left": Vector2.LEFT,
			"move_up": Vector2.UP,
			"move_down": Vector2.DOWN}
var pressed_direction = Vector2.ZERO

const CharacterResource = preload("res://character.tscn")

@export var altitude_noise: FastNoiseLite
@export var tile: PackedScene
#@export var character: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_map()
	
	
	#TEMPORARY TEST just getting a character in on the world map
	var tempChar = CharacterResource.instantiate()
	tempChar.load_stats("res://test_char_30.tres")
	$Characters.add_child(tempChar)
	currentCharacter = tempChar
	SignalBus.combatants_dict["hero"].append(tempChar)
	
	#And trying to place 'em somewhere
	var tempPosition = position.snapped(Vector2.ONE * TileSize)
	tempPosition += Vector2.ONE * TileSize/2
	if SignalBus.map_starting_location != Vector2.ONE:
		tempPosition = SignalBus.map_starting_location
		
	currentCharacter.position = tempPosition
	currentCharacter.play_anim("idle_sword_l") #for starting
	
	#set up camera
	$Camera2D.make_current()
	$Camera2D.position = currentCharacter.position
	$Camera2D.set_limit(SIDE_RIGHT,screen_width)
	$Camera2D.set_limit(SIDE_LEFT,(-1 * screen_width) - 16)
	$Camera2D.set_limit(SIDE_BOTTOM,screen_height)
	$Camera2D.set_limit(SIDE_TOP,(-1 * screen_height) - 16)
	
func clear_map():
	for line in tileArray:
		for tile in line:
			if is_instance_valid(tile):
				tile.queue_free()
	
	tileArray.clear()
	currTileArrayX = -1
	currTileArrayY = -1

func generate_map():
	altitude_noise.seed = randi()
	for n in RENDER_DISTANCE:
		# We divide by two so that half the tiles
		# generate left/above center and half right/below
		var y = n - RENDER_DISTANCE / 2.0
		
		currTileArrayY += 1
		tileArray.append([])
		for m in RENDER_DISTANCE:
			var x = m - RENDER_DISTANCE / 2.0
			
			currTileArrayX += 1
			
			generate_terrain_tile(x, y)
		currTileArrayX = -1
		
		#await get_tree().create_timer(0.2).timeout #TEST
	
	for tileRow in tileArray:
		for tile in tileRow:
			tile.set_edges()
			
func _unhandled_input(event):
	pressed_direction = Vector2.ZERO
	if event.is_action("move_up") or event.is_action("move_down"):
		#pressed_direction = Vector2.ZERO
		pressed_direction.y = Input.get_axis("move_up","move_down")
		if pressed_direction.y == 0.0:
			pressed_direction.x = Input.get_axis("move_left","move_right")
	elif event.is_action("move_left") or event.is_action("move_right"):
		#pressed_direction = Vector2.ZERO
		pressed_direction.x = Input.get_axis("move_left","move_right")
		if pressed_direction.x == 0.0:
			pressed_direction.y = Input.get_axis("move_down","move_up")
	#OLD INPUT
	#for dir in inputs.keys():
		#if event.is_action_pressed(dir):
			#move(currentCharacter, dir)
	if event.is_action_pressed("debug_refresh"): #F5, of course
		print("Regenerating map...")
		add_cheat_label("Regenerating Map...")
		await clear_map()
		await generate_map()
		remove_cheat_label("Regenerating Map...")
	if event.is_action_pressed("cheat_walk_through_walls"):
		#toggle walk through walls on or off.
		currentCharacter.cheat_walk_through_walls = not currentCharacter.cheat_walk_through_walls
		if currentCharacter.cheat_walk_through_walls:
			#var tempResource = load("res://initiative_list_item.tscn")
			add_cheat_label("Walk Through Walls")
		else:
			remove_cheat_label("Walk Through Walls")
			
			
func add_cheat_label(text):
	print("Adding cheat label: " + text)
	var tempLabel = load("res://initiative_list_item.tscn").instantiate()
	tempLabel.set_text(text)
	$CanvasLayer/"Cheat Text Overlay Manager".add_child(tempLabel)
	$CanvasLayer/"Cheat Text Overlay Manager".queue_redraw()

func remove_cheat_label(text):
	print("Removing cheat label: " + text)
	for label in $CanvasLayer/"Cheat Text Overlay Manager".get_children():
		if label.get_text() == text:
			label.queue_free()


func move(character, dir):
	#if (not character.isMoving) and dir != Vector2.ZERO:
		##we aren't moving but we're about to start moving.
		#character.play_anim("walk_d")
		#
	#elif character.isMoving:
		#$Camera2D.position = currentCharacter.position
		#return
	if character.isMoving or dir == Vector2.ZERO:
		$Camera2D.position = currentCharacter.position
		##print($Camera2D.position) #TEST
		return #don't need to do anything
	
	character.move(dir)
	
	
	
	
	
	#var ray = character.get_node("RayCast2D")
	#ray.target_position = dir * (TileSize)
	#ray.force_raycast_update()
	#
	#if not ray.is_colliding():
		#
		#var anim_to_play = ""
		#
		#if dir.x != 0 or dir.y != 0:
			#anim_to_play = "walk"
		#else:
			#anim_to_play = "idle"
		#if dir.x < 0:
			#character.facing = "l"
		#elif dir.x > 0:
			#character.facing = "r"
		#elif dir.y < 0:
			#character.facing = "u"
		#else:
			#character.facing = "d"
		#
		#anim_to_play += "_" + character.facing
		#character.play_anim(anim_to_play)
		#
		#var tween = create_tween()
		#tween.tween_property(character, "position",
			#character.position + dir * TileSize, 1.0/4).set_trans(Tween.TRANS_LINEAR)
		#character.isMoving = true
		#await tween.finished
		#character.isMoving = false
		
		
		
	#OLD INPUT
	#var ray = character.get_node("RayCast2D")
	##print(ray)
	#ray.target_position = inputs[dir] * (TileSize)
	#print(ray.target_position)
	#ray.force_raycast_update()
	#if ray.is_colliding():
		##print(ray.get_collider().get_parent())
		##print(ray.get_collider())
		#print("Ray collision! No moving for you.")
	#else:
		#var tween = create_tween()
		#tween.tween_property(character, "position",
			#character.position + inputs[dir] * TileSize, 1.0/3).set_trans(Tween.TRANS_SINE)
		#character.isMoving = true
		#await tween.finished
		#character.isMoving = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move(currentCharacter,pressed_direction)
	#OLD INPUT
	#pass

func generate_terrain_tile(x: int, y: int):
	var tile = tile.instantiate()
	tile.tile_type = altitude_value(x, y)
	tile.position = Vector2(x, y) * TileSize
	$Tiles.add_child(tile)
	tileArray[currTileArrayY].append(tile)
	
	#Link to other tiles
	if currTileArrayX > 0 and currTileArrayY > 0:
		tile.tileLinks[0][0] = tileArray[currTileArrayY - 1][currTileArrayX - 1]
		tileArray[currTileArrayY - 1][currTileArrayX - 1].tileLinks[2][2] = tile
	if currTileArrayY > 0:
		tile.tileLinks[0][1] = tileArray[currTileArrayY - 1][currTileArrayX]
		tileArray[currTileArrayY - 1][currTileArrayX].tileLinks[2][1] = tile
		if currTileArrayX < (int(RENDER_DISTANCE) - 1):
			tile.tileLinks[0][2] = tileArray[currTileArrayY - 1][currTileArrayX + 1]
			tileArray[currTileArrayY - 1][currTileArrayX + 1].tileLinks[2][0] = tile
	if currTileArrayX > 0:
		tile.tileLinks[1][0] = tileArray[currTileArrayY][currTileArrayX - 1]
		tileArray[currTileArrayY][currTileArrayX - 1].tileLinks[1][2] = tile
	
	
	
	#if currTileArrayX > 0:
		#tile.tileLinks[1][0] = tileArray[currTileArrayY - 1][currTileArrayX]

func altitude_value(x: int, y: int) -> Tile.TileType:
	var value = altitude_noise.get_noise_2d(x, y)
	
	if value >= ForestLevel:
		return Tile.TileType.FOREST
	
	if value >= SeaLevel:
		return Tile.TileType.LAND
		
	return Tile.TileType.SEA
