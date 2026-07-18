extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0
@export var death_y: float = 1000.0

@export var scale_speed: float = 2.0
@export var max_scale: float = 4.0
@export var min_scale: float = 0.25
var target:float=1.0

@onready var face=$face 
@export var face_strength = 0.1
@export var max_face = 14.0
@export var follow_speed = 8.0



func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_W):
		target+=scale_speed*delta
	if Input.is_key_pressed(KEY_S):
		target-=scale_speed*delta
	
	target= clamp(target,min_scale,max_scale)
	scale = Vector2(target,target)
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * target

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	var offset = velocity*face_strength
	offset= offset.limit_length(max_face)
	face.position = face.position.lerp(offset,follow_speed*delta)
	
	move_and_slide()
	
	if global_position.y>death_y:
		get_tree().reload_current_scene()
