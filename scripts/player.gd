extends CharacterBody3D

func _physics_process(delta):
	var input_dir = Vector3.ZERO
	
	# direction
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.z += 1
	if not is_on_floor():
		input_dir.y -= 1
	var direction : Vector3 = (transform.basis * self.transform.basis * input_dir).normalized()
	
	# movement
	var move_speed = 5.0
	
	if direction != Vector3.ZERO:
		velocity = direction * move_speed
	else:
		velocity = Vector3.ZERO
	
	move_and_slide()
