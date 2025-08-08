extends Camera3D

@export var main_camera: Camera3D

func _process(delta: float) -> void:
	var my_transform = global_transform
	var cam_transform = main_camera.global_transform
	
	# Copy rotation from camera
	my_transform.basis = cam_transform.basis
	
	# Keep my own Y position
	my_transform.origin.y = global_transform.origin.y
	
	# Copy X and Z position from camera
	my_transform.origin.x = cam_transform.origin.x
	my_transform.origin.z = cam_transform.origin.z
	
	global_transform = my_transform
