extends Node

class_name StoryEngine

signal story_node_changed(node_data: Dictionary)

var current_node: Dictionary = {}
var story_data: Dictionary = {}

func _ready():
    print("StoryEngine ready")
    _load_story_data()

func _load_story_data():
    var story_files = [
        "res://data/story/start.json",
        "res://data/story/engine_room.json",
        "res://data/story/cooling_fix.json",
        "res://data/story/status_report.json",
        "res://data/story/sleep_consequence.json",
        "res://data/story/continue_route.json",
        "res://data/story/distress_signal.json"
    ]
    
    for file_path in story_files:
        var file = FileAccess.open(file_path, FileAccess.READ)
        if file:
            var json_text = file.get_as_text()
            var json = JSON.new()
            var parse_result = json.parse(json_text)
            if parse_result == OK:
                var data = json.get_data()
                if data is Dictionary and data.has("id"):
                    story_data[data.id] = data
                else:
                    push_error("Invalid story node format in " + file_path)
            else:
                push_error("JSON Parse Error: " + json.get_error_message() + " in " + file_path + " at line " + str(json.get_error_line()))
        else:
            push_error("Failed to open story file: " + file_path)

func load_story_node(node_id: String) -> void:
    print("Loading story node: ", node_id)
    if story_data.has(node_id):
        current_node = story_data[node_id]
        emit_signal("story_node_changed", current_node)
    else:
        push_error("Story node not found: " + node_id)
        # 노드를 찾을 수 없는 경우 에러 노드를 생성
        current_node = {
            "id": "error",
            "text": "오류: 스토리 노드를 찾을 수 없습니다. (ID: " + node_id + ")",
            "choices": []
        }
        emit_signal("story_node_changed", current_node)

func get_current_node() -> Dictionary:
    return current_node

func get_story_data() -> Dictionary:
    return story_data 