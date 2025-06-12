extends Node

class_name Inventory

signal inventory_changed

var items: Array = []

func _ready():
	# 예시 아이템 추가
	add_item({
		"id": "medkit",
		"name": "응급 키트",
		"description": "체력을 회복할 수 있는 의료 키트입니다.",
		"type": "consumable",
		"effect": {
			"type": "heal",
			"value": 20
		}
	})
	
	add_item({
		"id": "repair_tool",
		"name": "수리 도구",
		"description": "기계를 수리할 때 사용하는 도구입니다.",
		"type": "tool",
		"effect": {
			"type": "repair",
			"value": 1
		}
	})
	
	add_item({
		"id": "energy_cell",
		"name": "에너지 셀",
		"description": "우주선의 보조 동력원으로 사용됩니다.",
		"type": "resource",
		"effect": {
			"type": "power",
			"value": 50
		}
	})

func add_item(item: Dictionary) -> bool:
	if not item.has("id") or not item.has("name"):
		push_error("Invalid item format")
		return false
		
	items.append(item)
	emit_signal("inventory_changed")
	return true

func remove_item(item_id: String) -> bool:
	for i in range(items.size()):
		if items[i].id == item_id:
			items.remove_at(i)
			emit_signal("inventory_changed")
			return true
	return false

func has_item(item_id: String) -> bool:
	for item in items:
		if item.id == item_id:
			return true
	return false

func get_item(item_id: String) -> Dictionary:
	for item in items:
		if item.id == item_id:
			return item
	return {}

func get_items() -> Array:
	return items.duplicate()

func set_items(new_items: Array):
	items = new_items.duplicate()
	emit_signal("inventory_changed")

func clear():
	items.clear()
	emit_signal("inventory_changed") 