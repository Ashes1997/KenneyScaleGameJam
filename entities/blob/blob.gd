class_name Blob
extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0
@export var death_y: float = 100000.0
@export var scale_speed: float = 2.0
@export var max_scale: float = 4.0
@export var min_scale: float = 0.25
@export var min_scale_gravity: float = 0.5
@export var max_scale_gravity: float = 2
@export var slingshot_strength: float = 750
@export var face_strength = 0.1
@export var max_face = 14.0
@export var follow_speed = 8.0
var target:float=1.0
var target_gravity:float=1.0
var is_hanging: bool = false
var grab_anchor: Vector2 = Vector2.ZERO
var base_arm_length: float = 0.0

@onready var face=$face

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
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
	var offset = velocity*face_strength
	offset= offset.limit_length(max_face)
	face.position = face.position.lerp(offset,follow_speed*delta)

	move_and_slide()

	if is_hanging:
		var max_len := base_arm_length * target
		var to_blob := global_position - grab_anchor
		if to_blob.length() > max_len:
			var dir := to_blob.normalized()
			global_position = grab_anchor + dir * max_len
			var radial := velocity.dot(dir)
			if radial > 0.0:
				velocity -= dir * radial

	if global_position.y>death_y:
		get_tree().reload_current_scene()

func slingshot_to(anchor_position:Vector2):
	var direction: Vector2 = (anchor_position - global_position).normalized()
	velocity += direction*slingshot_strength

func on_grabbed(anchor_position: Vector2, arm_length: float) -> void:
	is_hanging = true
	grab_anchor = anchor_position
	base_arm_length = arm_length

func on_released() -> void:
	is_hanging = false
