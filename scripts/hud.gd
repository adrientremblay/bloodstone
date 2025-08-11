extends Control

@onready var blood_bar = $BloodBar
@onready var health_bar = $HealthBar
@onready var ammo_label = $AmmoLabel

func _on_player_consumed_blood(amount: Variant) -> void:
	blood_bar.value += amount

func _on_player_update_health(health: Variant) -> void:
	health_bar.value = health

func _on_player_update_ammo(ammo_clip: Variant, ammo_pool: Variant, melee: bool) -> void:
	if melee:
		ammo_label.text = ''
		return
	
	ammo_label.text = str(ammo_clip) + "/" + str(ammo_pool)
