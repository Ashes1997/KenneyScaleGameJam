extends Node2D

@onready var blob: Blob = $CharacterBody2D
@onready var hand: Hand = $Hand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hand.slingshot_requested.connect(_on_slingshot_requested)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_slingshot_requested(anchor_position:Vector2) -> void:
	blob.slingshot_to(anchor_position)
