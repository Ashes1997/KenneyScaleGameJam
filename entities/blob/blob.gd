class_name Blob
extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0
@export var scale_speed: float = 2.0
@export var max_scale: float = 4.0
@export var min_scale: float = 0.25
@export var min_scale_gravity: float = 0.5
@export var max_scale_gravity: float = 2
@export var slingshot_strength: float = 750
var target:float=1.0
var target_gravity:float=1.0

func _process(delta: float) -> void:
	if Input.is_action_pressed("scale_up"):
		target+=scale_speed*delta
	if Input.is_action_pressed("scale_down"):
		target-=scale_speed*delta

	target= clamp(target,min_scale,max_scale)
	target_gravity= clamp(target,min_scale_gravity,max_scale_gravity)
	scale = Vector2(target,target)
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * target_gravity

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()

func slingshot_to(anchor_position:Vector2):
	print("anchor: ", anchor_position, "  blob: ", global_position)
	var direction: Vector2 = (anchor_position - global_position).normalized()
	velocity += direction*slingshot_strength
	
