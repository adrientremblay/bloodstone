extends Node3D

@onready var player = $Player
@onready var hud = $HUD

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inspect") and player.book != null:
		hud.display_book(player.book.description, player.book.contents)
