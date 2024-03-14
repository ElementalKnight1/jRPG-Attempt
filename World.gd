extends Node2D

const TileSize = 16
const SeaLevel = 0.1
const ForestLevel = 0.3
const RENDER_DISTANCE = 28.0 #48 right now for a full screen's map

var tileArray = []
var currTileArrayX = -1
var currTileArrayY = -1

var currentCharacter

var inputs = {"move_right": Vector2.RIGHT,
			"move_left": Vector2.LEFT,
			"move_up": Vector2.UP,
			"move_down": Vector2.DOWN}

const CharacterResource = preload("res://character.tscn")

@export var altitude_noise: FastNoiseLite
@export var tile: PackedScene
#@export var character: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	altitude_noise.seed = randi()
	#self.material.get_shader_param("noiseTexture").seed = randi()
	pass # Replace with function body.
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
	#for tile in tileArray.get_items():
		#tile.set_edges()
	#print(SignalBus.combatants_dict["hero"][0])
	
	#TEMPORARY TEST just getting a character in on the world map
	var tempChar = CharacterResource.instantiate()
	tempChar.load_stats("res://test_char_30.tres")
	$Characters.add_child(tempChar)
	currentCharacter = tempChar
	SignalBus.combatants_dict["hero"].append(tempChar)
	
	#And trying to place 'em somewhere
	var tempPosition = position.snapped(Vector2.ONE * TileSize)
	tempPosition += Vector2.ONE * TileSize/2
	currentCharacter.position = tempPosition
	
func _unhandled_input(event):
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			move(currentCharacter, dir)

func move(character, dir):
	var tween = create_tween()
	tween.tween_property(character, "position",
		character.position + inputs[dir] * TileSize, 1.0/3).set_trans(Tween.TRANS_SINE)
	character.isMoving = true
	await tween.finished
	character.isMoving = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
