extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var p: Player = body
		p.pistol.add_ammo(9)
		$AudioStreamPlayer.play()

func _on_audio_stream_player_finished() -> void:
	self.queue_free()
