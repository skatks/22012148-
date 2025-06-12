extends Control

func _ready():
	# 버튼에 시그널 연결
	$MarginContainer/VBoxContainer/ButtonsContainer/StartButton.pressed.connect(_on_start_button_pressed)
	$MarginContainer/VBoxContainer/ButtonsContainer/LoadButton.pressed.connect(_on_load_button_pressed)
	
	# 초기 상태에서는 로드 버튼 비활성화
	$MarginContainer/VBoxContainer/ButtonsContainer/LoadButton.disabled = true
	
	# GameManager 초기화 확인
	call_deferred("_check_save_files")

func _check_save_files():
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.save_load_manager:
		if game_manager.save_load_manager.has_save_file(0):
			$MarginContainer/VBoxContainer/ButtonsContainer/LoadButton.disabled = false

func _on_start_button_pressed():
	# 새 게임 시작
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_load_button_pressed():
	# 저장된 게임 불러오기
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")
	# 씬이 변경된 후 GameManager의 load_game() 호출
	await get_tree().create_timer(0.1).timeout
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.save_load_manager:
		game_manager.save_load_manager.load_game(0) 
