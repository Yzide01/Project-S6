extends Control

func _ready():
	$VBoxContainer/Header/MarginContainer/BackButton.pressed.connect(_on_back_pressed)

func _on_back_pressed():
	queue_free()
