extends Area3D

enum PICKUP_TYPE {
	AMMO,
	GUN
}

@export var type: PICKUP_TYPE

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var p: Player = body
		if type == PICKUP_TYPE.AMMO:
			p.pistol.add_ammo(9)
			$PickupSound.play()
		elif type == PICKUP_TYPE.GUN:
			p.pick_up_gun()
			self.queue_free() # gun has no pickup sound

func _on_audio_stream_player_finished() -> void:
	self.queue_free()
