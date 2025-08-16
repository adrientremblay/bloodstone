class_name Player extends CharacterBody3D

# Exports
@export var bullet_hole_scene: PackedScene
@export var movement_speed = 6.0
@export var jump_velocity = 5.0

# Children
@onready var camera = $Camera3D
@onready var walk_animation_player = $WalkAnimationPlayer
@onready var hand = $Camera3D/hand2
@onready var pistol = $Camera3D/pistolmodel
@onready var weapon_swap = $WeaponSwap
@onready var footstep = $Footstep
@onready var jump = $Jump
@onready var teleport_indicator = $TeleportIndicator
@onready var inspectable_Area: Area3D = $Camera3D/InspectableArea

# Constants
var camera_max_angle = 80
var camera_min_angle = -80
@onready var rng = RandomNumberGenerator.new()

# Signals
signal consumed_blood(amount)
signal update_health(health)
signal update_ammo(ammo_clip, ammo_pool, melee: bool)
signal can_inspect(description: String)
signal cannot_inspect
 
# Properties
@onready var current_weapon: Weapon = hand
var blood_drain = 10 # how much blood the player is able to drain per each feed
var healing_factor = 5 #how much blood is converted to health per execution of the HealingTimer
var health = 100
var melee_damage = 1
var blood = 0
var book: Book = null
var frozen = false

func _ready() -> void:
	pistol.visible = false
	hand.visible = true

func _unhandled_input(event: InputEvent):
	# Don't fuck with Dialogic
	if Dialogic.current_timeline != null:
		return
	
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
	if frozen:
		return
	
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
	
	# Position of the teleport indicator to be raycasted if RMS is down
	if Input.is_action_pressed("cast_spell"):
		var raycast_vector = (-camera.global_transform.basis.z)
		var query = PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position -camera.global_transform.basis.z * 1000)
		var result = get_world_3d().direct_space_state.intersect_ray(query)
		if result:
			var tp_position = result.position
			tp_position.y = 0 #put it on the floor
			teleport_indicator.global_position = tp_position

func _input(event: InputEvent) -> void:
	if frozen:
		return
	
	if event.is_action_pressed("attack"):
		attack()
	elif event.is_action_pressed("reload"):
		reload()
	elif event.is_action_pressed("previous_weapon"):
		var other_weapon: Weapon = null
		if current_weapon == hand:
			other_weapon = pistol
		else:
			other_weapon = hand
		
		switch_weapon(other_weapon)
	elif event.is_action_released("cast_spell"):
		# do the teleportation
		if (teleport_indicator.position != Vector3(0,0,2) and blood >= 10):
			self.global_position.x = teleport_indicator.global_position.x
			self.global_position.z = teleport_indicator.global_position.z
			blood -= 10
			consumed_blood.emit(blood)
			$TeleportSound.play()
		
		# move the teleport indicator behind the player
		teleport_indicator.position = Vector3(0,0,2)

func switch_weapon(weapon: Weapon):
	current_weapon.visible = false
	current_weapon = weapon
	current_weapon.visible = true
	weapon_swap.play()
	update_ammo.emit(current_weapon.ammo_clip, current_weapon.ammo_pool, current_weapon.melee)

func attack() -> void:		
	if current_weapon.melee:
		$Camera3D/MeleeDetectionArea.monitoring = true
		$MeleeMonitoringTimer.start()
	else:
		if current_weapon.can_fire():
			# Shooting Ray
			var space = get_world_3d().direct_space_state
			# Rotate vector around z by UP TO the accuracy angle
			var raycast_vector = (-camera.global_transform.basis.z).rotated(camera.global_transform.basis.x, rng.randf_range(0, 1.0) * current_weapon.accuracy_angle * PI / 180)
			raycast_vector = raycast_vector.rotated(-camera.global_transform.basis.z, rng.randf_range(0, 2*PI))
			var query = PhysicsRayQueryParameters3D.create(camera.global_position, camera.global_position + (raycast_vector*current_weapon.range))
			var result = space.intersect_ray(query)

			if result:
				if result.collider.is_in_group("enemies"):
					var blood_consumed = result.collider.suffer_attack(self)
					if blood_consumed != 0:
						blood += blood_consumed
						consumed_blood.emit(blood)
				elif current_weapon != hand: 
					# Create the bullet hole
					var new_bullet_hole = bullet_hole_scene.instantiate()
					result.collider.add_child(new_bullet_hole)
					new_bullet_hole.global_transform.origin = result.position
					new_bullet_hole.look_at(result.position + result.normal, Vector3.UP)
	
	#animate and play sound
	current_weapon.fire()

func reload():
	current_weapon.reload()

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

func _on_weapon_update_ammo_label(ammo_clip: Variant, ammo_pool: Variant, melee: bool) -> void:
	update_ammo.emit(ammo_clip, ammo_pool, melee)

func _on_melee_monitoring_timer_timeout() -> void:
	$Camera3D/MeleeDetectionArea.monitoring = false

func _on_melee_detection_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("feeding_area"):
		var health_component: HealthComponent = area.health_component
		
		var blood_consumed = health_component.give_up_blood(self)
		if blood_consumed != 0:
			blood += blood_consumed
			consumed_blood.emit(blood)
			health_component.bleed()

func _on_melee_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		var blood_consumed = body.suffer_attack(self)
		if blood_consumed != 0:
			blood += blood_consumed
			consumed_blood.emit(blood)
		

func _on_healing_timer_timeout() -> void:
	if health < 100 && blood > 0:
		var blood_to_convert = min(min(100 - health, healing_factor), blood)
		if blood_to_convert > 0:
			blood -= blood_to_convert
			health += blood_to_convert
			consumed_blood.emit(blood)
			update_health.emit(health)
	$HealingTimer.start()

func _on_inspectable_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("inspectable"):
		var inspectable: Inspectable = body
		can_inspect.emit(inspectable.description)
		if body.is_in_group("book"):
			book = inspectable

func _on_inspectable_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("inspectable"):
		var inspectable: Inspectable = body
		cannot_inspect.emit()
		if body.is_in_group("book"):
			book = null

func return_inspectable():
	for body in inspectable_Area.get_overlapping_bodies():
		if body.is_in_group("inspectable"):
			return body
			
func return_talkable():
	for body in inspectable_Area.get_overlapping_bodies():
		if body.is_in_group("talkable"):
			return body
