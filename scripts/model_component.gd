class_name ModelComponent extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree

@export var walk_enabled: bool = true

func _ready() -> void:
	animation_tree.active = true

func switch_to_animation(animation_name: String):	
	if !walk_enabled && (animation_name == "walk" || animation_name == "idle"):
		return
	
	animation_tree["parameters/conditions/" + animation_name] = true
	
	if (animation_name == "idle"):
		animation_tree["parameters/conditions/walk"] = false
	if (animation_name == "walk"):
		animation_tree["parameters/conditions/idle"] = false

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack":
		animation_tree["parameters/conditions/attack"] = false
	if anim_name == "Hurt":
		animation_tree["parameters/conditions/hurt"] = false
