extends Control

@onready var volume_slider = $Panel/VBoxContainer/SettingsContainer/VolumeControl/VolumeSlider
@onready var text_speed_slider = $Panel/VBoxContainer/SettingsContainer/TextSpeedControl/TextSpeedSlider
@onready var save_button = $Panel/VBoxContainer/SaveButton
@onready var load_button = $Panel/VBoxContainer/LoadButton
@onready var close_button = $Panel/VBoxContainer/CloseButton

var game_manager: Node

func _ready():
	call_deferred("_initialize_game_manager")
	_connect_signals()
	_load_settings()

func _connect_signals():
	volume_slider.value_changed.connect(_on_volume_changed)
	text_speed_slider.value_changed.connect(_on_text_speed_changed)
	save_button.pressed.connect(_on_save_pressed)
	load_button.pressed.connect(_on_load_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _initialize_game_manager():
	game_manager = get_node("/root/GameManager")
	if not game_manager:
		push_error("GameManager not found!")

func _load_settings():
	# 설정 파일에서 값을 로드하거나 기본값 사용
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	
	if err == OK:
		volume_slider.value = config.get_value("audio", "volume", 1.0)
		text_speed_slider.value = config.get_value("text", "speed", 1.0)
	else:
		volume_slider.value = 1.0
		text_speed_slider.value = 1.0

func _save_settings():
	var config = ConfigFile.new()
	
	config.set_value("audio", "volume", volume_slider.value)
	config.set_value("text", "speed", text_speed_slider.value)
	
	config.save("user://settings.cfg")

func _on_volume_changed(value: float):
	# 오디오 버스의 볼륨 조절
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	_save_settings()

func _on_text_speed_changed(value: float):
	# 텍스트 속도 설정
	if game_manager:
		game_manager.text_speed = value
	_save_settings()

func _on_save_pressed():
	if game_manager:
		game_manager.save_game()
		var popup = AcceptDialog.new()
		popup.dialog_text = "게임이 저장되었습니다."
		add_child(popup)
		popup.popup_centered()

func _on_load_pressed():
	if game_manager:
		game_manager.load_game()
		var popup = AcceptDialog.new()
		popup.dialog_text = "게임을 불러왔습니다."
		add_child(popup)
		popup.popup_centered()

func _on_close_pressed():
	visible = false 
