extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var active = false

func _ready() -> void:
	release()

func activate():
	active = true
	animation_player.play("Activate")

func release():
	active = false
	animation_player.play("Release")
