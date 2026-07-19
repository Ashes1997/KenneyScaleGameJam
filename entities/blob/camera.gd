extends Camera2D

@export var min_zoom = 0.5
@export var max_zoom = 2.0
@export var zoom_follow_speed = 5.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var blob = get_parent()
	var target_zoom = clamp(blob.target, min_zoom, max_zoom)
	zoom = zoom.lerp(Vector2(1.0/target_zoom, 1.0/target_zoom), zoom_follow_speed * delta)
