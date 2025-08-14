extends Node3D

@onready var player: Player = $Player
@onready var hud = $HUD

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inspect"):
		if player.book != null:
			hud.toggle_book(player.book.description, player.book.get_pages())
			player.frozen = not player.frozen
			if player.frozen:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
		var talkable = player.return_talkable()
		if talkable:
			print("Dialog")
