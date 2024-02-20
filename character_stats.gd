extends Resource

##The character's type (hero or enemy)
@export var character_type = "enemy"

##The character's name.
@export var character_name = ""

##The character's class (TBD how this works later)
@export var character_class_name = ""

##The character's level.
@export var level = 1

##The character's Experience Points.
@export var experience = 0

##How often you dodge attacks and effects.
@export var agility = 0

##Affects the power of your social attacks / abilities.
@export var charisma = 0

##How fast you move in combat. Higher Initiative = maybe getting more turns
@export var initiative = 0 

##How much damage you deal with magical attacks.
@export var knowledge = 0 

##How often you land your attacks.
@export var perception = 0
 
##Affects the range on normal and critical damage, and how often you apply status effects.
@export var skill = 0 

##Affects how much damage you receive from magical attacks.
@export var spirit = 0 

##How much damage you deal with physical attacks.
@export var strength = 0 

##Affects how much damage you receive from physical attacks.
@export var vitality = 0 

##Affects how much damage you receive from social attacks.
@export var willpower = 0 





@export var HP = 100
@export var HPmax = 100
@export var MP = 100
@export var MPmax = 100
@export var SP = 100
@export var SPmax = 100

@export var Equipment = {}
#@export var EquipHandL = []
#@export var EquipHandR = []
#@export var EquipHead = []
#@export var EquipBody = []
#@export var EquipLegs = []
#@export var EquipAccessory1 = []
#@export var EquipAccessory2 = []

@export var Personality = ""
@export var Gender = ""

@export var sprite_override=""

@export var StyleHair = []
@export var StyleSkin = []
@export var StyleBody = []

@export var ElementalAttributes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

