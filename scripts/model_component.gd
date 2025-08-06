class_name ModelComponent extends Node3D

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	assert(animation_player != null)

func play_animation(name: String):
	if animation_player.has_animation(name):
		animation_player.play(name)
