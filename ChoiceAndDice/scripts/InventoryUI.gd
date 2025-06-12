extends Control

@onready var close_button = $Panel/VBoxContainer/CloseButton

func _ready():
	close_button.pressed.connect(_on_close_button_pressed)

func _on_close_button_pressed():
	visible = false 