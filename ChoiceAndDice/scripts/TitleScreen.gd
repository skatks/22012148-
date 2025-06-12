extends Control

@onready var new_game_button = $Panel/VBoxContainer/NewGameButton
@onready var load_game_button = $Panel/VBoxContainer/LoadGameButton
@onready var quit_button = $Panel/VBoxContainer/QuitButton

func _ready():
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_new_game_pressed():
	# 메인 게임 씬으로 전환
	get_tree().change_scene_to_file("res://scenes/MainGame.tscn")

func _on_load_game_pressed():
	var game_manager = get_node("/root/GameManager")
	if game_manager:
		game_manager.load_game()
		get_tree().change_scene_to_file("res://scenes/MainGame.tscn")
	else:
		var popup = AcceptDialog.new()
		popup.dialog_text = "저장된 게임을 찾을 수 없습니다."
		add_child(popup)
		popup.popup_centered()

func _on_quit_pressed():
	get_tree().quit() 