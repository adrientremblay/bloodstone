extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var p: Player = body
		p.current_weapon.add_ammo(9)
		self.queue_free()
