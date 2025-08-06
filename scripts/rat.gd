extends CharacterBody3D

@onready var death_sound: AudioStreamPlayer3D = $DeathSound
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var alive = true
var blood = 10

func _ready() -> void:
	$GPUParticles3D.emitting = false

func die():
	alive = false
	death_sound.play()
	animation_player.play("die")
	$AudioStreamPlayer3D.stop()

func _on_death_sound_finished() -> void:
	pass

func bleed():
	animation_player.play("bleed")
