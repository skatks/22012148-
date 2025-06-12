extends Node

class_name Companion

signal companion_changed

var companions: Dictionary = {}

func _ready():
	# 예시 동료 추가
	add_companion({
		"id": "engineer",
		"name": "엔지니어 사라",
		"description": "우주선의 수석 엔지니어입니다. 기계를 다루는 데 전문가입니다.",
		"stats": {
			"intelligence": 14,
			"strength": 10,
			"charisma": 12,
			"luck": 8
		},
		"skills": ["repair", "computer", "electronics"]
	})
	
	add_companion({
		"id": "medic",
		"name": "의료관 마이클",
		"description": "우주선의 의료 책임자입니다. 부상과 질병 치료를 담당합니다.",
		"stats": {
			"intelligence": 13,
			"strength": 9,
			"charisma": 14,
			"luck": 10
		},
		"skills": ["medicine", "biology", "chemistry"]
	})
	
	add_companion({
		"id": "security",
		"name": "보안관 알렉스",
		"description": "우주선의 보안 책임자입니다. 전투와 방어 전문가입니다.",
		"stats": {
			"intelligence": 11,
			"strength": 15,
			"charisma": 10,
			"luck": 12
		},
		"skills": ["combat", "security", "tactics"]
	})

func add_companion(companion_data: Dictionary) -> bool:
	if not companion_data.has("id") or not companion_data.has("name"):
		push_error("Invalid companion data format")
		return false
		
	companions[companion_data.id] = companion_data
	emit_signal("companion_changed")
	return true

func remove_companion(companion_id: String) -> bool:
	if companions.has(companion_id):
		companions.erase(companion_id)
		emit_signal("companion_changed")
		return true
	return false

func has_companion(companion_id: String) -> bool:
	return companions.has(companion_id)

func get_companion(companion_id: String) -> Dictionary:
	if companions.has(companion_id):
		return companions[companion_id]
	return {}

func get_companions() -> Dictionary:
	return companions.duplicate()

func set_companions(new_companions: Dictionary):
	companions = new_companions.duplicate()
	emit_signal("companion_changed")

func clear():
	companions.clear()
	emit_signal("companion_changed") 