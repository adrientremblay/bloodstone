extends CharacterBody3D

@onready var camera = $Camera3D
@onready var weapon_animation_player = $WeaponAnimationPlayer
@onready var swipe_sound = $Swipe

var camera_max_angle = 80
var camera_min_angle = -80

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			self.rotate_y(-event.relative.x * 0.01)
			camera.rotate_x(-event.relative.y * 0.01)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(camera_min_angle), deg_to_rad(camera_max_angle))

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
	var direction : Vector3 = (self.transform.basis * input_dir).normalized()
	
	# movement
	var move_speed = 5.0
	
	if direction != Vector3.ZERO:
		velocity = direction * move_speed
	else:
		velocity = Vector3.ZERO
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action("attack"):
		weapon_animation_player.play("swipe")
		swipe_sound.play()
