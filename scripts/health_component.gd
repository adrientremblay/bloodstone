class_name HealthComponent extends Node3D

var alive = true
var blood = 10

# Children
@onready var death_sound: AudioStreamPlayer3D = $DeathSound
@onready var particle_emitter: GPUParticles3D = $GPUParticles3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ambient_sound: AudioStreamPlayer3D = $AmbientSound
@onready var eat_rat_sound = $EatRat

func bleed():
	animation_player.play("bleed")

func _ready() -> void:
	$GPUParticles3D.emitting = false

func die():
	alive = false
	death_sound.play()
	#animation_player.play("die")
	ambient_sound.stop()

func handle_attack(player: Player) -> int: # returns the blood consumed
	if player.current_weapon == player.hand:
		var blood_available = min(blood, player.blood_drain)
		if blood_available == 0:
			return 0
				
		eat_rat_sound.play()
		blood -= blood_available
		bleed()
		
		return blood_available
	
	if alive:
		die()
	
	return 0
