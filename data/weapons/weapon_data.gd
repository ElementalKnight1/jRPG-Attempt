extends Resource

enum weapon_type {
	AXE,
	BOOK,
	BOW,
	CARDS,
	DAGGER,
	DICE,
	GREATSWORD,
	INSTRUMENT,
	KNUCKLE,
	MACE,
	NUNCHUK,
	ROD,
	SHIELD,
	SHURIKEN,
	SPEAR,
	STAFF, 
	SWORD,
	WHIP
}

@export var type:weapon_type
@export var rarity:float
@export var level:int
@export var attack_power:int
@export var additional_effects = []
@export var cost:int
@export var icon = ""
@export var color:Color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func make_weapon(new_type:int=0,new_level:int=1,new_rarity:float=0):#WeaponData.weapon_type):
	#weapons_list.append(temp_weapon)
	type = new_type
	level = new_level
	rarity = new_rarity
	attack_power = StatGrowth.level_table[rarity][level]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
