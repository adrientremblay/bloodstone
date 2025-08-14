extends Node3D

func _ready() -> void:
	$AnimationPlayer.play("Idle")

func _on_dialogue_component_started_speaking() -> void:
	$AnimationPlayer.play("Speak")

func _on_dialogue_component_stopped_speaking() -> void:
	$AnimationPlayer.play("Idle")
