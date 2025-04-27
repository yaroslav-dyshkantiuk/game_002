extends Node

@onready var pause_menu: Control = $"../CanvasLayer/PauseMenu"

var game_paused: bool = false
var save_path = "user://savegame.save"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		game_paused = !game_paused
	
	if game_paused == true:
		get_tree().paused = true
		pause_menu.show()
	else:
		get_tree().paused = false
		pause_menu.hide()

func _on_resume_pressed() -> void:
	game_paused = !game_paused

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_menu_button_pressed() -> void:
	game_paused = !game_paused

func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(Global.gold)

func load_game():
	var file = FileAccess.open(save_path, FileAccess.READ)
	Global.gold = file.get_var(Global.gold)

func _on_save_pressed() -> void:
	save_game()
	game_paused = !game_paused

func _on_load_pressed() -> void:
	load_game()
	game_paused = !game_paused
