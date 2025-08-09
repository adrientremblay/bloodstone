class_name Weapon extends Node3D

@onready var weapon_sound: AudioStreamPlayer = $WeaponSound
@onready var animation_tree: AnimationTree = $AnimationTree

@export var animation_name: String

func fire():
	weapon_sound.play()

func switch_to_animation(animation_name: String):
	animation_tree["parameters/conditions/" + animation_name] = true

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack" || anim_name == "Fire":
		animation_tree["parameters/conditions/attack"] = false
	elif anim_name == "Reload":
		animation_tree["parameters/conditions/reload"] = false
