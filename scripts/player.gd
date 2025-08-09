class_name Player extends CharacterBody3D

# Exports
@export var bullet_hole_scene: PackedScene
@export var movement_speed = 6.0
@export var jump_velocity = 5.0

# Children
@onready var camera = $Camera3D
@onready var weapon_animation_player = $WeaponAnimationPlayer
@onready var walk_animation_player = $WalkAnimationPlayer
@onready var hand = $Camera3D/hand2
@onready var pistol = $Camera3D/pistolmodel
@onready var weapon_swap = $WeaponSwap
@onready var footstep = $Footstep
@onready var jump = $Jump

# Constants
var camera_max_angle = 80
var camera_min_angle = -80

# Signals
signal consumed_blood(amount)
signal update_health(health)
 
# Properties
@onready var current_weapon: Weapon = hand
var blood_drain = 10 # how much blood the player is able to drain per each feed
var health = 100

func _ready() -> void:
	pistol.visible = false
	hand.visible = true

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
	
	var direction : Vector3 = (self.transform.basis * input_dir).normalized()
	
	# movement
	velocity.x = direction.x * movement_speed
	velocity.z = direction.z * movement_speed
	
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = jump_velocity
		jump.play()
	
	handle_air_physics(delta)
	move_and_slide()
	
	#make sure walking animation plays while walking
	if (direction != Vector3.ZERO && is_on_floor() && !walk_animation_player.is_playing()):
		walk_animation_player.play("walk")
	if walk_animation_player.is_playing() and !is_on_floor() or direction == Vector3.ZERO:
		walk_animation_player.pause()

func _input(event: InputEvent) -> void:
	if event.is_action("attack"):
		attack()
	elif event.is_action_pressed("previous_weapon"):
		var other_weapon: Weapon = null
		if current_weapon == hand:
			other_weapon = pistol
		else:
			other_weapon = hand
		
		switch_weapon(other_weapon)

func switch_weapon(weapon: Weapon):
	current_weapon.visible = false
	current_weapon = weapon
	current_weapon.visible = true
	weapon_swap.play()

func attack() -> void:
	#animate and play sound
	if current_weapon == hand:
		current_weapon.switch_to_animation("attack")
	else:
		weapon_animation_player.play(current_weapon.animation_name) # legacy animation for pistol
	current_weapon.fire()
	
	# Shooting Ray
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position + -camera.global_transform.basis.z * 1000)
	var result = space.intersect_ray(query)

	if result:
		if result.collider.is_in_group("enemies"):
			var blood_consumed = result.collider.suffer_attack(self)
			if blood_consumed != 0:
				consumed_blood.emit(blood_consumed)
		elif current_weapon != hand: 
			# Create the bullet hole
			var new_bullet_hole = bullet_hole_scene.instantiate()
			result.collider.add_child(new_bullet_hole)
			new_bullet_hole.global_transform.origin = result.position
			new_bullet_hole.look_at(result.position + result.normal, Vector3.UP)

func take_damage(damage: int):
	health -= damage
	update_health.emit(health)
	
	# Todo: implement death

func handle_air_physics(delta):
	if not is_on_floor():
		self.velocity.y -= ProjectSettings.get_setting(("physics/3d/default_gravity")) * delta

func play_footstep():
	footstep.pitch_scale = randf_range(0.8,1.2)
	footstep.play()
	
