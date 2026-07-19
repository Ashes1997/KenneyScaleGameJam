extends Control

const PLAY_SCENE := "res://levels/test_level/SlingshotLevelTest.tscn"


func _ready() -> void:
	$BoxContainer/Play.pressed.connect(_on_play_pressed)
	$BoxContainer/Quit.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(PLAY_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()
