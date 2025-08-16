extends Node3D

@onready var player: Player = $Player
@onready var hud = $HUD

@export var game_over_scene: PackedScene

func _ready() -> void:
	Dialogic.timeline_ended.connect(on_timeline_finished)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inspect"):
		var talkable = player.return_talkable()
		if not (talkable or player.book):
			return
			
		player.frozen = not player.frozen
		
		if player.book != null:
			hud.toggle_book(player.book.description, player.book.get_pages())
			
		if player.frozen:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if talkable:
				Dialogic.start("father")
				player.return_talkable().start_speaking()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			if talkable:
				Dialogic.end_timeline()
				player.return_talkable().stop_speaking()

func on_timeline_finished():
	player.frozen = false
	player.return_talkable().stop_speaking()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func game_over():
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")

func _on_death_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		game_over()
