extends Node

class_name ChoiceEvaluator

func evaluate_choice(choice_id: String, current_node: Dictionary) -> bool:
	if current_node.has("choices"):
		for choice in current_node.choices:
			if choice.id == choice_id:
				if choice.has("conditions"):
					return check_conditions(choice.conditions, get_parent().player_stats).can_try
				return true
	return false

func check_conditions(conditions: Dictionary, player_stats: Dictionary) -> Dictionary:
	var result = {
		"can_try": true,
		"type": "",
		"current": 0,
		"required": 0,
		"modifier": 0
	}
	
	if conditions.has("stat_check"):
		var stat_type = conditions.stat_check.type
		var required = conditions.stat_check.value
		
		if player_stats.has(stat_type):
			var current = player_stats[stat_type]
			var modifier = get_parent().calculate_stat_modifier(current)
			
			result.type = stat_type
			result.current = current
			result.required = required
			result.modifier = modifier
			
			# 시도 가능 여부 확인 (예: 최소 요구치)
			result.can_try = current >= (required - 10)  # 기본적으로 -10까지는 시도 가능
		else:
			result.can_try = false
	
	return result

func calculate_stat_modifier(stat_value: int) -> int:
	return floori((stat_value - 10) / 2.0) 