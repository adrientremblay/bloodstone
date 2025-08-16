extends Node3D

@export var timeline_name: String

func _ready() -> void:
	$AnimationPlayer.play("Idle")
	$DialogueComponent.timeline_name = timeline_name

func _on_dialogue_component_started_speaking() -> void:
	$AnimationPlayer.play("Speak")

func _on_dialogue_component_stopped_speaking() -> void:
	$AnimationPlayer.play("Idle")
