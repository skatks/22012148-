extends Node

class_name SaveLoadManager

const SAVE_FILE = "user://savegame.json"

func save_game(save_data: Dictionary) -> bool:
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file == null:
		push_error("Error: Could not open save file for writing")
		return false
		
	var json_string = JSON.stringify(save_data)
	file.store_string(json_string)
	file.close()
	print("Game saved successfully")
	return true

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_FILE):
		print("No save file found")
		return {}
		
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file == null:
		push_error("Error: Could not open save file for reading")
		return {}
		
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		print("Game loaded successfully")
		return json.data
	else:
		push_error("JSON Parse Error: " + json.get_error_message())
		return {}

func get_save_info(slot: int) -> Dictionary:
	var save_data = load_game()
	if save_data.is_empty():
		return {}
		
	return {
		"slot": slot,
		"save_date": save_data.get("save_date", 0),
		"location": save_data.get("location", "알 수 없는 위치")
	}

func has_save_file(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_FILE) 