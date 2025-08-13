extends Node3D

@onready var player = $Player
@onready var hud = $HUD

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inspect") and player.book != null:
		hud.toggle_book(player.book.description, player.book.get_pages())
		player.frozen = not player.frozen
