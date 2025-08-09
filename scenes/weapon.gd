class_name Weapon extends Node3D

@onready var weapon_sound: AudioStreamPlayer = $WeaponSound
@onready var animation_tree: AnimationTree = $AnimationTree

@export var clip_size: int = 9

@onready var ammo_pool = clip_size + 20 #TODO: change to clip_size once ammo pickups are invented
@onready var ammo_clip = clip_size

signal update_ammo_label(ammo_clip, ammo_pool)

func can_fire():
	return ammo_clip > 0

func fire():
	if not can_fire():
		return
	
	weapon_sound.play()
	switch_to_animation("attack")
	
	ammo_clip -= 1
	update_ammo_label.emit(ammo_clip, ammo_pool)

func switch_to_animation(animation_name: String):
	animation_tree["parameters/conditions/" + animation_name] = true

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack" || anim_name == "Fire":
		animation_tree["parameters/conditions/attack"] = false
	elif anim_name == "Reload":
		animation_tree["parameters/conditions/reload"] = false
