extends CanvasLayer

var redshift_intensity = 1.0

func _process(delta: float) -> void:
	if redshift_intensity > 0:
		redshift_intensity -= delta
		redshift_intensity = max(0, redshift_intensity)
		$ColorRect.material.set("shader_param/intensity", redshift_intensity)
