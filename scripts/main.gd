extends Node3D

@onready var blood_bar = $BloodBar
@onready var health_bar = $HealthBar

func _on_player_consumed_blood(amount: Variant) -> void:
	blood_bar.value += amount

func _on_player_update_health(health: Variant) -> void:
	health_bar.value = health
