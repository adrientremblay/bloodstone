extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var particle_emitter: GPUParticles3D = $GPUParticles3D
var active = false

func _ready() -> void:
	release()

func activate():
	active = true
	animation_player.play("Activate")
	particle_emitter.emitting = true

func release():
	active = false
	animation_player.play("Release")
	particle_emitter.restart()
	particle_emitter.emitting = false
