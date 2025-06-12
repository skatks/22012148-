extends Control

@onready var story_text = %StoryText
@onready var choices_container = %ChoicesContainer
@onready var settings_menu = %SettingsMenu
@onready var save_load_menu = $SaveLoadMenu
@onready var dice_result_label = %DiceResultLabel
@onready var inventory_ui = %InventorySystem
@onready var companion_ui = %CompanionSystem
@onready var inventory_button = %InventoryButton
@onready var companion_button = %CompanionButton
@onready var menu_button = %MenuButton

var game_manager: Node

func _ready():
	print("Main game scene ready")
	print("Checking nodes...")
	print("Story text: ", story_text)
	print("Choices container: ", choices_container)
	print("Settings menu: ", settings_menu)
	print("Dice result label: ", dice_result_label)
	print("Inventory UI: ", inventory_ui)
	print("Companion UI: ", companion_ui)
	print("Inventory button: ", inventory_button)
	print("Companion button: ", companion_button)
	print("Menu button: ", menu_button)
	
	# 노드들이 제대로 로드되었는지 확인
	if not settings_menu:
		push_error("Settings menu not found!")
		settings_menu = get_node_or_null("%SettingsMenu")
		print("Trying to find settings menu again: ", settings_menu)
	
	story_text.text = "게임을 초기화하는 중..."
	await get_tree().create_timer(0.1).timeout
	_initialize_game_manager()
	_connect_button_signals()

func _connect_button_signals():
	print("Connecting button signals...")
	if inventory_button:
		print("Inventory button found")
		inventory_button.pressed.connect(_on_inventory_button_pressed)
	if companion_button:
		print("Companion button found")
		companion_button.pressed.connect(_on_companion_button_pressed)
	if menu_button:
		print("Menu button found")
		menu_button.pressed.connect(_on_menu_button_pressed)
	else:
		print("Menu button not found!")
		# 버튼을 다시 찾아보기
		menu_button = get_node_or_null("%MenuButton")
		if menu_button:
			print("Found menu button on second try")
			menu_button.pressed.connect(_on_menu_button_pressed)

func _initialize_game_manager():
	game_manager = get_node("/root/GameManager")
	if not game_manager:
		push_error("GameManager not found!")
		story_text.text = "오류: 게임 매니저를 찾을 수 없습니다."
		return
		
	print("Found GameManager:", game_manager)
	
	# 스토리 노드 변경 시그널 연결
	if not game_manager.is_connected("story_node_changed", _on_story_node_changed):
		game_manager.connect("story_node_changed", _on_story_node_changed)
	if not game_manager.is_connected("stat_check_result", _on_stat_check_result):
		game_manager.connect("stat_check_result", _on_stat_check_result)
	print("Connected to GameManager signals")
	
	# 현재 스토리 노드가 있다면 표시
	if not game_manager.current_story_node.is_empty():
		_on_story_node_changed(game_manager.current_story_node)
	else:
		story_text.text = "스토리를 로드하는 중..."
		game_manager.story_engine.load_story_node("start")
	
	# 주사위 결과 레이블 초기화
	if dice_result_label:
		dice_result_label.hide()

func _input(event):
	if event.is_action_pressed("save"):
		save_load_menu.show_save_menu()
	elif event.is_action_pressed("ui_cancel"):  # ESC 키
		if settings_menu:
			settings_menu.visible = !settings_menu.visible
	elif event.is_action_pressed("inventory"):
		_on_inventory_button_pressed()
	elif event.is_action_pressed("companions"):
		_on_companion_button_pressed()

func _on_story_node_changed(node_data: Dictionary):
	if story_text and node_data.has("text"):
		story_text.text = node_data.text
	else:
		if story_text:
			story_text.text = "텍스트를 찾을 수 없습니다."
	
	# 기존 선택지 제거
	if choices_container:
		for child in choices_container.get_children():
			child.queue_free()
	
		# 새 선택지 추가
		if node_data.has("choices"):
			for choice in node_data.choices:
				var button = Button.new()
				button.text = choice.text
				button.pressed.connect(func(): _on_choice_button_pressed(choice))
				choices_container.add_child(button)

func _on_choice_button_pressed(choice: Dictionary):
	if not game_manager:
		push_error("GameManager not found in _on_choice_button_pressed!")
		return
		
	print("Choice button pressed: ", choice)
	
	# 조건 체크가 있는 경우
	if choice.has("conditions") and choice.conditions.has("stat_check"):
		var stat_check = choice.conditions.stat_check
		var stat_value = game_manager.player_stats.get(stat_check.type, 0)
		
		if game_manager.attempt_stat_check(stat_check.type, stat_check.value, stat_value):
			if choice.has("next"):
				game_manager.story_engine.load_story_node(choice.next)
		else:
			if story_text:
				story_text.text = "능력치 체크 실패! 다른 선택지를 골라주세요."
	else:
		# 조건이 없는 경우 바로 다음 노드로 이동
		if choice.has("next"):
			game_manager.story_engine.load_story_node(choice.next)

func _on_stat_check_result(success: bool, roll_result: Dictionary, required: int, stat_info: Dictionary):
	if not dice_result_label:
		return
		
	var result_text = "주사위 굴림 결과:\n"
	result_text += "필요 값: %d\n" % required
	result_text += "굴림 결과: %d + %d = %d\n" % [roll_result.results[0], roll_result.modifier, roll_result.total]
	result_text += "결과: " + ("성공!" if success else "실패...")
	
	dice_result_label.text = result_text
	dice_result_label.show()

func _on_settings_button_pressed():
	settings_menu.visible = !settings_menu.visible

func _on_save_button_pressed():
	save_load_menu.show_save_menu()

func _on_load_button_pressed():
	save_load_menu.show_load_menu()

func _on_inventory_button_pressed():
	if inventory_ui:
		inventory_ui.visible = !inventory_ui.visible

func _on_companion_button_pressed():
	if companion_ui:
		companion_ui.visible = !companion_ui.visible

func _on_menu_button_pressed():
	print("Menu button pressed")
	if settings_menu:
		print("Settings menu found, current visibility: ", settings_menu.visible)
		settings_menu.visible = !settings_menu.visible
		print("Settings menu new visibility: ", settings_menu.visible)
	else:
		print("Settings menu not found!")
		# 메뉴를 다시 찾아보기
		settings_menu = get_node_or_null("%SettingsMenu")
		if settings_menu:
			print("Found settings menu on second try")
			settings_menu.visible = true 
