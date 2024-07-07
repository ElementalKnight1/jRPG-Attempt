extends Node2D

const TileSize = 16
const SeaLevel = 0.001 #0.1 for a few more islands; 0.01 for 2 continents; 0.001 for a big single continent
const ForestLevel = 0.3
const MountainLevel = 0.7

const MAP_SIZE_X = 64
const MAP_SIZE_Y = 48
const screen_width = ((TileSize * MAP_SIZE_X) / 2) - (TileSize / 2)
const screen_height = ((TileSize * MAP_SIZE_Y) / 2) - (TileSize / 2)

var tileArray = []
var currTileArrayX = -1
var currTileArrayY = -1

var tileGroups = {}

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
	await generate_map()
	
	
	#TEMPORARY TEST just getting a character in on the world map
	var tempChar = CharacterResource.instantiate()
	tempChar.load_stats("res://test_char_30.tres")
	$Characters.add_child(tempChar)
	currentCharacter = tempChar
	SignalBus.combatants_dict["hero"].append(tempChar)
	
	#And trying to place 'em somewhere
	place_character()
	
	#set up camera
	$Camera2D.make_current()
	$Camera2D.position = currentCharacter.position
	$Camera2D.set_limit(SIDE_RIGHT,screen_width)
	$Camera2D.set_limit(SIDE_LEFT,(-1 * screen_width) - 16)
	$Camera2D.set_limit(SIDE_BOTTOM,screen_height)
	$Camera2D.set_limit(SIDE_TOP,(-1 * screen_height) - 16)

func place_character():
	var randomTile = tileGroups.keys().pick_random()
	#print("Placing character in TileGroup "+str(randomTile))
	randomTile = tileGroups[randomTile]["list"].pick_random()
	var tempPosition = randomTile.position
	#var tempPosition = position.snapped(Vector2.ONE * TileSize)
	tempPosition += Vector2.ONE * TileSize/2
	if SignalBus.map_starting_location != Vector2.ONE:
		tempPosition = SignalBus.map_starting_location
		
	currentCharacter.position = tempPosition
	#print(currentCharacter.position) #TEST
	#currentCharacter.play_anim("idle_sword_l") #for starting

func clear_map():
	for line in tileArray:
		for tile in line:
			if is_instance_valid(tile):
				tile.queue_free()
	
	tileGroups.clear()
	tileArray.clear()
	currTileArrayX = -1
	currTileArrayY = -1

func generate_map():
	#Make map
	altitude_noise.seed = randi()
	for n in MAP_SIZE_Y:
		# We divide by two so that half the tiles
		# generate left/above center and half right/below
		var y = n - MAP_SIZE_Y / 2.0
		
		currTileArrayY += 1
		tileArray.append([])
		for m in MAP_SIZE_X:
			var x = m - MAP_SIZE_X / 2.0
			
			currTileArrayX += 1
			
			generate_terrain_tile(x, y)
		currTileArrayX = -1
		
		#await get_tree().create_timer(0.2).timeout #TEST
	
	map_smoother() #smooth out shapes' edges
	
	determine_tile_groups() #determine the continents
	
	print_tilegroups()
	
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
	if event.is_action_pressed("cheat_move_faster"):
		currentCharacter.activate_cheat_move_faster(!currentCharacter.cheat_move_faster)
		if currentCharacter.cheat_move_faster:
			#var tempResource = load("res://initiative_list_item.tscn")
			add_cheat_label("Move Faster")
		else:
			remove_cheat_label("Move Faster")
			
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
	if character.isMoving or dir == Vector2.ZERO:
		$Camera2D.position = currentCharacter.position
		##print($Camera2D.position) #TEST
		return #don't need to do anything
	
	character.move(dir)
	

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
	link_tile_to_neighbors(currTileArrayX,currTileArrayY)
#
	
func link_tile_to_neighbors(tileArrayX,tileArrayY):
	var tile = tileArray[tileArrayY][tileArrayX]
	if tileArrayX > 0 and tileArrayY > 0: #if it's not in the top row nor left column, link to what's up and left of it.
		tile.tileLinks[0][0] = tileArray[tileArrayY - 1][tileArrayX - 1]
		tileArray[tileArrayY - 1][tileArrayX - 1].tileLinks[2][2] = tile
	if tileArrayY > 0:
		tile.tileLinks[0][1] = tileArray[tileArrayY - 1][tileArrayX]
		tileArray[tileArrayY - 1][tileArrayX].tileLinks[2][1] = tile
		if tileArrayX < (int(MAP_SIZE_X) - 1):
			tile.tileLinks[0][2] = tileArray[tileArrayY - 1][tileArrayX + 1]
			tileArray[tileArrayY - 1][tileArrayX + 1].tileLinks[2][0] = tile
	if tileArrayX > 0:
		tile.tileLinks[1][0] = tileArray[tileArrayY][tileArrayX - 1]
		tileArray[tileArrayY][tileArrayX - 1].tileLinks[1][2] = tile

func determine_tile_groups():
	#basically determines what island a given tile belongs to.
	#also gathers data in the tileGroups dictionary that will prove useful later.
	var tileGrouperY = -1
	var tileGrouperX = -1
	var tempTileGroup = 999999
	for row in tileArray:
		tileGrouperY += 1
		for tile in row:
			tempTileGroup = 999999
			tileGrouperX += 1
			if tile.tile_type != tile.TileType.SEA:
				#check if any of the previous tiles it's connected to are part of a group. If they are, this one is too.
				if tile.tileLinks[0][0].group > 0:
					tempTileGroup = tile.tileLinks[0][0].group
				if tile.tileLinks[0][1].group > 0 and tile.tileLinks[0][1].group != tempTileGroup:
					if tile.tileLinks[0][1].group > tempTileGroup:
						await combine_tilegroups(tempTileGroup,tile.tileLinks[0][1].group)
					tempTileGroup = tile.tileLinks[0][1].group
				if tile.tileLinks[0][2].group > 0 and tile.tileLinks[0][2].group != tempTileGroup:
					if tile.tileLinks[0][2].group > tempTileGroup:
						await combine_tilegroups(tempTileGroup,tile.tileLinks[0][2].group)
					tempTileGroup = tile.tileLinks[0][2].group
				if tile.tileLinks[1][0].group > 0 and tile.tileLinks[1][0].group != tempTileGroup:
					if tile.tileLinks[1][0].group > tempTileGroup:
						await combine_tilegroups(tempTileGroup,tile.tileLinks[1][0].group)
					elif tempTileGroup != 999999:
						await combine_tilegroups(tile.tileLinks[1][0].group, tempTileGroup)
						#This is dumb, but it seems to work, so... good enough for me.
					tempTileGroup = tile.tileLinks[1][0].group
				
				if tempTileGroup == 999999: #we didn't find an existing group so let's make a new one
					tempTileGroup = add_new_tilegroup()
				
				tile.set_group(tempTileGroup)
				add_tile_to_tilegroups(tile,tile.group)
		tileGrouperX = -1
	#a little cleanup afterwards
	for entry in tileGroups.keys():
		if tileGroups[entry].is_empty():
			tileGroups.erase(entry)
		elif tileGroups[entry].count <= 6: #it only has 6 or fewer tiles? Too small, let's remove it.
			for tile in tileGroups[entry]["list"]:
				tile.set_tile_type(0)
				#tile.$Label.visible = false
				tile.set_group(0)
		else:
			tileGroups[entry]["centerpoint"] /= tileGroups[entry]["count"]

func remove_too_small_tilegroups(numTileLimit:int):
	for entry in tileGroups.keys():
		if tileGroups[entry]["count"] <= numTileLimit:
			for tile in tileGroups[entry]["list"]:
				tile.set_tile_type(0) #set each tile in the group to water
			tileGroups.erase(entry) #and remove the tileGroup entirely

func add_tile_to_tilegroups(tile,tileGroup:int):
	tileGroups[tileGroup]["count"] += 1
	tileGroups[tileGroup]["list"].append(tile)
	tileGroups[tileGroup]["centerpoint"] += tile.position

func combine_tilegroups(oldTileGroupToKeep:int,oldTileGroupToRemove:int):
	#for key in tileGroups[oldTileGroupToRemove]:
	tileGroups[oldTileGroupToKeep]["count"] += tileGroups[oldTileGroupToRemove]["count"]
	tileGroups[oldTileGroupToKeep]["list"].append_array(tileGroups[oldTileGroupToRemove]["list"])
	tileGroups[oldTileGroupToKeep]["centerpoint"] += tileGroups[oldTileGroupToRemove]["centerpoint"]
	for tile in tileGroups[oldTileGroupToRemove]["list"]: #make sure those tiles get the message!
		tile.set_group(oldTileGroupToKeep)
	tileGroups[oldTileGroupToRemove].clear()
		

func add_new_tilegroup():
	#make a blank tileGroup!
	var newTileGroup = tileGroups.size() + 1
	tileGroups[newTileGroup] = {}
	tileGroups[newTileGroup]["count"] = 0
	tileGroups[newTileGroup]["list"] = []
	
	tileGroups[newTileGroup]["centerpoint"] = Vector2.ZERO
	
	var randomVector = Vector2.ZERO
	randomVector.x = randf_range(-1,1)
	randomVector.y = randf_range(-1,1)
	tileGroups[newTileGroup]["vector"] = randomVector
	return newTileGroup

func print_tilegroups():
	var tempString = ""
	for group in tileGroups.keys():
		tempString = ""
		tempString = "Tile Group "+str(group)+":\n"
		tempString += "    Count: "+str(tileGroups[group]["count"])+"\n"
		tempString += "    Vector: "+str(tileGroups[group]["vector"].x)+", "+str(tileGroups[group]["vector"].x)+"\n"
		tempString += "    Centerpoint: "+str(tileGroups[group]["centerpoint"])
		print(tempString)

func map_smoother():
	#if two tiles of the same type are bookending something that isn't of that type,
	#smooth that out.
	var smoothingY = -1
	var smoothingX = -1
	for row in tileArray:
		smoothingY += 1
		for tile in row:
			smoothingX += 1
			if smoothingY == 0 or smoothingY == len(tileArray) - 1: #if it's the top or bottom row,
				tile.set_tile_type(tile.TileType.SEA) #make it water.
				#print("Row " + str(smoothingY) + ", Col "+ str(smoothingX) + ": forcing water.")
			elif smoothingX > 0 and smoothingX < len(row) - 1: #if it's in the middle somewhere,
				if tileArray[smoothingY][smoothingX - 1].tile_type == tileArray[smoothingY][smoothingX + 1].tile_type and tileArray[smoothingY][smoothingX - 1].tile_type != tileArray[smoothingY][smoothingX].tile_type: 
					#and the tiles to the left and right are the same,
					#TEST print("Row " + str(smoothingY) + ", Col "+ str(smoothingX) + ": was "+ str(tile.tile_type) +", forcing " + str(tileArray[smoothingY][smoothingX - 1].tile_type) + ".")
					tile.set_tile_type(tileArray[smoothingY][smoothingX - 1].tile_type) #smooth it out and make this tile those tile-types too
				elif tileArray[smoothingY - 1][smoothingX].tile_type == tileArray[smoothingY + 1][smoothingX].tile_type and tileArray[smoothingY - 1][smoothingX].tile_type != tileArray[smoothingY][smoothingX].tile_type: 
					#and the tiles above and below are the same,
					#TEST print("Row " + str(smoothingY) + ", Col "+ str(smoothingX) + ": was "+ str(tile.tile_type) +", forcing " + str(tileArray[smoothingY - 1][smoothingX].tile_type) + ".")
					tile.set_tile_type(tileArray[smoothingY - 1][smoothingX].tile_type) #smooth it out and make this tile those tile-types too
					
			else: #it's on the left or right edge, let's make it just water.
				tile.set_tile_type(tile.TileType.SEA)
				#print("Row " + str(smoothingY) + ", Col "+ str(smoothingX) + ": forcing water.")
		smoothingX = -1
		

func altitude_value(x: int, y: int) -> Tile.TileType:
	var value = altitude_noise.get_noise_2d(x, y)
	
	if value >= ForestLevel:
		return Tile.TileType.FOREST
	
	if value >= SeaLevel:
		return Tile.TileType.LAND
		
	return Tile.TileType.SEA


