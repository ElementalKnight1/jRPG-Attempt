extends Node2D

class_name Tile

var tileLinks = [[null,null,null],[null,null,null],[null,null,null]]
var edgesArray = [[0,0,0],[0,0,0],[0,0,0]]

enum TileType {
	SEA,
	LAND,
	FOREST
}

@export var tile_type: TileType
@export var group: int

@onready var sprite := $Sprite2D

func _ready():
	#sprite.modulate = Color(0, 1, 1, 1) if tile_type == TileType.SEA else Color.WHITE
	if tile_type == TileType.SEA:
		sprite.texture = load("res://sprites/world/sea_000000000.png")
	elif tile_type == TileType.LAND:
		sprite.texture = load("res://sprites/world/grass_5.png")
		$Area2D/CollisionShape2D.set_deferred("disabled",true)
	else:
		sprite.texture = load("res://sprites/world/forest_5.png")
		$Area2D/CollisionShape2D.set_deferred("disabled",true) #you can walk through it

func set_tile_type(newTileType:int):
	self.tile_type = newTileType
	if tile_type == TileType.SEA:
		sprite.texture = load("res://sprites/world/sea_000000000.png")
	elif tile_type == TileType.LAND:
		sprite.texture = load("res://sprites/world/grass_5.png")
		$Area2D/CollisionShape2D.set_deferred("disabled",true)
	else:
		sprite.texture = load("res://sprites/world/forest_5.png")
		$Area2D/CollisionShape2D.set_deferred("disabled",true) #you can walk through it

func set_group(newGroup:int):
	self.group = newGroup
	$Label.text = str(self.group)
	$Label.visible = true

func set_edges():
	var edgeString = ""
	
	for j in 3:
		for i in 3:
			if tileLinks[j][i]:
				if tileLinks[j][i].tile_type != tile_type: #if it's not the same as myself...
					edgeString += "1"
				else: edgeString += "0"
			else: edgeString += "0"
	
	if tile_type == TileType.LAND: #TEST temp
		#print("Checking a Land tile...") #TEST
		if edgeString == "000000000":# and SignalBus.map_starting_location == Vector2.ONE:
			SignalBus.map_starting_location = self.position
			#print("Found a good starting position!")
	
	if tile_type == TileType.SEA:
		
		var fullFileName = "res://sprites/world/sea_"+edgeString+".png"
		if FileAccess.file_exists(fullFileName):
			sprite.texture = load(fullFileName)
		else:
			if edgeString in SignalBus.tileEdgeSubstitutionDictionary:
				edgeString = SignalBus.tileEdgeSubstitutionDictionary[edgeString]
				fullFileName = "res://sprites/world/sea_"+edgeString+".png" #try again
				if FileAccess.file_exists(fullFileName):
					sprite.texture = load(fullFileName)
				else:
					print("I was told I could use "+edgeString+", but I can't find it!")
			else:
				print("Missing: "+edgeString)
				fullFileName = "res://sprites/world/error.png"
				sprite.texture = load(fullFileName)

				

	
