class_name entity extends CharacterBody3D

@onready var health_component: HealthComponent = $HealthComponent

func suffer_attack(player: Player) -> int:
	if health_component != null:
		return health_component.handle_attack(player)
	return 0
