extends Panel

@onready var stats_container = $StatsContainer
var game_manager: Node

func _ready():
	call_deferred("_initialize_game_manager")

func _initialize_game_manager():
	game_manager = get_node_or_null("/root/GameManager")
	if not game_manager:
		push_error("GameManager not found!")
		return
		
	update_stats_display()
	# GameManager의 스탯 변경 시그널 연결 (나중에 구현)
	# game_manager.connect("stats_changed", _on_stat_changed)

func update_stats_display():
	if not game_manager:
		push_error("GameManager not found in update_stats_display!")
		return
		
	# 기존 스탯 표시 제거
	for child in stats_container.get_children():
		child.queue_free()
	
	# 스탯 표시 업데이트
	for stat_name in game_manager.player_stats:
		var stat_value = game_manager.player_stats[stat_name]
		var modifier = game_manager.calculate_stat_modifier(stat_value)
		
		var stat_label = Label.new()
		stat_label.text = "%s: %d [%+d]" % [stat_name.capitalize(), stat_value, modifier]
		stats_container.add_child(stat_label)

func _on_stat_changed():
	update_stats_display() 
