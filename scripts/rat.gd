extends CharacterBody3D

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var target_radius = 3
var rng = RandomNumberGenerator.new()
var speed = 0.5

func _ready() -> void:
	_on_find_new_target_timer_timeout()

func _physics_process(delta: float) -> void:
	if navigation_agent.is_target_reached():
		return
	
	var direction = (navigation_agent.get_next_path_position() - self.global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func _on_find_new_target_timer_timeout() -> void:
	var random_angle = rng.randi_range(0, PI * 2)
	var target_position = self.global_position + Vector3(target_radius,0,0).rotated(Vector3.UP,random_angle)
	self.rotation = Vector3(0, random_angle, 0)
	navigation_agent.target_position = target_position
