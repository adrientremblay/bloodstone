extends Node3D

@onready var blood_bar = $BloodBar

func _on_player_consumed_blood(amount: Variant) -> void:
	blood_bar.value += amount
