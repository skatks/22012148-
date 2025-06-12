extends Node

# 서브시스템 클래스들을 미리 로드
var story_engine_script = preload("res://scripts/StoryEngine.gd")
var choice_evaluator_script = preload("res://scripts/ChoiceEvaluator.gd")
var dice_service_script = preload("res://scripts/DiceService.gd")
var save_load_manager_script = preload("res://scripts/SaveLoadManager.gd")
var inventory_script = preload("res://scripts/Inventory.gd")
var companion_script = preload("res://scripts/Companion.gd")

signal story_node_changed(node_data: Dictionary)
signal stat_check_result(success: bool, roll_result: Dictionary, required: int, stat_info: Dictionary)
signal initialization_completed

# 게임 상태 변수들
var current_story_node: Dictionary = {}
var player_stats: Dictionary = {}
var inventory: Array = []
var companions: Dictionary = {}
var flags: Dictionary = {}

# 서브시스템 참조
@onready var story_engine: Node
@onready var choice_evaluator: Node
@onready var dice_service: Node
@onready var save_load_manager: Node
@onready var inventory_system: Node
@onready var companion_system: Node

var _initialized: bool = false

func _enter_tree():
	# 서브시스템 초기화
	_initialize_subsystems()

func _ready():
	print("GameManager ready")
	initialize_game()
	_initialized = true
	emit_signal("initialization_completed")

func _initialize_subsystems():
	print("Initializing subsystems")
	story_engine = story_engine_script.new()
	choice_evaluator = choice_evaluator_script.new()
	dice_service = dice_service_script.new()
	save_load_manager = save_load_manager_script.new()
	inventory_system = inventory_script.new()
	companion_system = companion_script.new()
	
	# 서브시스템들을 GameManager의 자식으로 추가
	add_child(story_engine)
	add_child(choice_evaluator)
	add_child(dice_service)
	add_child(save_load_manager)
	add_child(inventory_system)
	add_child(companion_system)
	
	# 스토리 엔진 시그널 연결
	story_engine.connect("story_node_changed", _on_story_node_changed)

func _on_story_node_changed(node_data: Dictionary):
	current_story_node = node_data
	emit_signal("story_node_changed", node_data)

func initialize_game():
	print("Initializing game")
	# 기본 플레이어 스탯 초기화
	player_stats = {
		"intelligence": 10,
		"strength": 10,
		"charisma": 10,
		"luck": 10
	}
	
	# 시스템 초기화
	inventory_system.clear()
	companion_system.clear()
	flags.clear()
	
	# 첫 스토리 노드 로드
	if story_engine:
		story_engine.load_story_node("start")
	else:
		push_error("Story engine not initialized!")

# 초기화 완료 여부 확인
func is_initialized() -> bool:
	return _initialized

# D&D 스타일의 능력치 수정치 계산
func calculate_stat_modifier(stat_value: int) -> int:
	return floori((stat_value - 10) / 2.0)

func evaluate_choice(choice_id: String) -> bool:
	return choice_evaluator.evaluate_choice(choice_id, current_story_node)

func check_conditions(conditions: Dictionary) -> Dictionary:
	return choice_evaluator.check_conditions(conditions, player_stats)

func attempt_stat_check(stat_type: String, required_value: int, stat_value: int) -> bool:
	var stat_modifier = calculate_stat_modifier(stat_value)
	var roll_result = dice_service.roll_dice(1, 20, stat_modifier)
	var success = roll_result.total >= required_value
	
	var stat_info = {
		"type": stat_type,
		"value": stat_value,
		"modifier": stat_modifier
	}
	
	emit_signal("stat_check_result", success, roll_result, required_value, stat_info)
	return success

func save_game():
	save_load_manager.save_game({
		"player_stats": player_stats,
		"inventory": inventory_system.get_items(),
		"companions": companion_system.get_companions(),
		"flags": flags,
		"current_node": current_story_node.id if current_story_node.has("id") else "start"
	})

func load_game():
	var save_data = save_load_manager.load_game()
	if save_data.is_empty():
		return
		
	player_stats = save_data.player_stats
	inventory_system.set_items(save_data.inventory)
	companion_system.set_companions(save_data.companions)
	flags = save_data.flags
	story_engine.load_story_node(save_data.current_node) 
