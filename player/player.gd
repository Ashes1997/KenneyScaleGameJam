extends Node2D

@onready var blob: Blob = $CharacterBody2D
@onready var hand: Hand = $Hand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hand.slingshot_requested.connect(_on_slingshot_requested)
	hand.grabbed.connect(_on_grabbed)
	hand.released.connect(_on_released)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_slingshot_requested(anchor_position:Vector2) -> void:
	blob.slingshot_to(anchor_position)

func _on_grabbed(anchor_position: Vector2) -> void:
	blob.on_grabbed(anchor_position, hand.arm_radius)

func _on_released() -> void:
	blob.on_released()
