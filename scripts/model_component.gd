class_name ModelComponent extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready() -> void:
	animation_tree.active = true

func switch_to_animation(animation_name: String):
	animation_tree["parameters/conditions/attack"] = false
	animation_tree["parameters/conditions/die"] = false
	
	animation_tree["parameters/conditions/" + animation_name] = true
	print("Switching to :" + animation_name)
