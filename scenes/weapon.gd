class_name Weapon extends Node3D

@onready var weapon_sound: AudioStreamPlayer = $WeaponSound

@export var animation_name: String

func fire():
	weapon_sound.play()
