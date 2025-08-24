class_name TelportIndicator extends Node3D

func _ready() -> void:
	arrow()

func arrow():
	$arrow.visible = true
	$wall_arrow.visible = false

func wall_arrow():
	$arrow.visible = false
	$wall_arrow.visible = true

func arrow_visible():
	return $arrow.visible
	
