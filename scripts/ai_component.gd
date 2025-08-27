class_name AiComponent extends Node3D

# Constants
var rng = RandomNumberGenerator.new()

# Properties
var enabled = true
enum AiMode {IDLE, CHASING_PLAYER}
var mode: AiMode = AiMode.IDLE
var player: Player = null

# Exports
@export var speed = 0.5
@export var target_radius = 3 # the wandering radius when idling
@export var model_component: ModelComponent
@export var attack_enabled: bool = true
@export var damage: int
@export var attack_sound: AudioStreamPlayer3D
@export var attack_speed: float = 0.5
@export var spotted_sound: AudioStreamPlayer3D
@export var attack_radius = 1 # the scale of the area to detect players for attacks
@export var melee = true
@export var accuracy_angle = 0 # degrees

# Children and parents
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var body: CharacterBody3D = get_parent()
@onready var attack_again_timer: Timer = $AttackAgainTimer
@onready var player_attack_area_shape: CollisionShape3D = $PlayerAttackArea/CollisionShape3D

func _ready() -> void:
	if enabled:
		find_new_target()
		attack_again_timer.wait_time = attack_speed
	
	player_attack_area_shape.scale = Vector3(attack_radius, attack_radius, attack_radius)

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	
	if attack_enabled and player != null:
		navigation_agent.target_position = player.global_position
		
		# look at player
		var direction = (player.global_position - body.global_position).normalized()
		direction.y = 0  # ignore vertical difference (just rotate on Y-axis)
		body.look_at(body.global_position + direction)
	
	if navigation_agent.is_target_reached():
		return
	
	# Stop and shoot if not a melee character and player is in attack area
	if not melee:
		var bodies = $PlayerAttackArea.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player"):
				return
	
	var direction = (navigation_agent.get_next_path_position() - self.global_position).normalized()
	body.velocity = direction * speed
	body.move_and_slide()

func find_new_target() -> void:
	if not enabled:
		return
	
	if mode == AiMode.IDLE:
		var random_angle = rng.randi_range(0, PI * 2)
		var target_position = body.global_position + Vector3(target_radius,0,0).rotated(Vector3.UP,random_angle)
		body.look_at(target_position)
		navigation_agent.target_position = target_position
	model_component.switch_to_animation("walk")

func _on_find_new_target_timer_timeout() -> void:
	find_new_target() 

func _on_player_detection_area_body_entered(body: Node3D) -> void:
	if enabled and body.is_in_group("player") and mode != AiMode.CHASING_PLAYER and attack_enabled:
		switch_mode(AiMode.CHASING_PLAYER)
		player = body
		spotted_sound.play()

func switch_mode(new_mode: AiMode):
	mode = new_mode
	find_new_target()

func _on_player_attack_area_body_entered(body: Node3D) -> void:
	if enabled and body.is_in_group("player") and attack_enabled:
		if player == null:
			player = body
		attack()
		attack_again_timer.start()

func attack():
	model_component.switch_to_animation("attack")
	attack_sound.play()
	if melee: # If the enemy is a melee one, then the player simply takes damage
		player.take_damage(damage)
	else:
		# Otherwise, we want to shoot a ray towards the player
		# Shooting Ray
		var space = get_world_3d().direct_space_state
		# Rotate vector around z by UP TO the accuracy angle
		var raycast_vector = (-self.global_transform.basis.z).rotated(self.global_transform.basis.x, rng.randf_range(0, 1.0) * accuracy_angle * PI / 180)
		raycast_vector = raycast_vector.rotated(-self.global_transform.basis.z, rng.randf_range(0, 2*PI))
		var query = PhysicsRayQueryParameters3D.create(self.global_position, player.global_position + (raycast_vector*attack_radius))
		var result = space.intersect_ray(query)

		if result:
			if result.collider.is_in_group("player"):
				player.take_damage(damage)

func _on_attack_again_timer_timeout() -> void:
	if player != null and enabled:
		attack()
		attack_again_timer.start()

func _on_player_attack_area_body_exited(body: Node3D) -> void:
	if enabled and body.is_in_group("player") and attack_enabled:
		attack_again_timer.stop()

func _on_navigation_agent_3d_target_reached() -> void:
	model_component.switch_to_animation("idle")
