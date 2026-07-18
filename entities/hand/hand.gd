class_name Hand
extends Node2D

signal grabbed(anchor_position: Vector2)
signal released
signal slingshot_requested(anchor_position: Vector2)

@export var arm_radius: float = 150.0
@export var reach_radius: float = 40.0
@export var body_path: NodePath
@export var open_texture: Texture2D
@export var closed_texture: Texture2D

var is_grabbing: bool = false
var anchor_position: Vector2 = Vector2.ZERO

@onready var reach_ray: RayCast2D = $ReachRay
@onready var hand_line: Line2D = $HandLine
@onready var body: Node2D = get_node(body_path)
@onready var grab_area: Area2D = $GrabArea
@onready var hand_sprite: Sprite2D = $HandSprite

func _ready() -> void:
	hand_sprite.texture = open_texture

func _physics_process(delta: float) -> void:
	if not is_grabbing:
		var offset: Vector2 = (get_global_mouse_position() - body.global_position).limit_length(arm_radius)
		global_position = body.global_position + offset
		hand_sprite.rotation = offset.angle() + 90

func _process(delta: float) -> void:
	hand_line.points = [Vector2.ZERO, to_local(body.global_position)]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("grab"):
		_try_grab()
	elif event.is_action_released("grab"):
		_try_release()
	elif event.is_action_pressed("slingshot") and is_grabbing:
		slingshot_requested.emit(anchor_position)
		_try_release()

func  _try_grab() -> void:
	var candidates := grab_area.get_overlapping_bodies()
	if !candidates.is_empty():
		var target: Node2D = candidates[0]
		anchor_position = global_position
		is_grabbing = true
		hand_sprite.texture = closed_texture
		grabbed.emit(anchor_position)

func _try_release() -> void:
	if is_grabbing:
		is_grabbing = false
		hand_sprite.texture = open_texture
		released.emit()
