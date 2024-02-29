extends Node2D
@export var movement_plan = [-8,8,-4,4,0,0]
var movement_plan_index = 0
var velocity = Vector2.ZERO
var origin_location = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	velocity.y = movement_plan[movement_plan_index]
	#print("Damage popup ready!")
	$BounceTimer.start()
	pass # Replace with function body.

func change_text(new_text):
	$DamageText.text = "[center]"+str(new_text)+"[/center]"
	#$DamageText.text = str(new_text)
	

func go_to_location(location):
	#print(position)
	position = location
	

func do_damage_popup(location,amount):
	#print(location)
	position = location
	$DamageText.text = str(amount)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(Engine.get_frames_drawn())
	translate(velocity)
	pass


func _on_timer_timeout():
	queue_free()
	pass # Replace with function body.


func _on_bounce_timer_timeout():
	#print("Bounce Timer timed out!")
	movement_plan_index += 1
	if movement_plan_index < movement_plan.size():
		#print("Movement Plan Index: "+str(movement_plan_index))
		velocity.y = movement_plan[movement_plan_index]
		#print("Velocity: "+str(velocity))
		$BounceTimer.start()
	else:
		queue_free()
