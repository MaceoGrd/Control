extends RigidBody2D

@export var min_radius: float = 22.0
@export var max_radius: float = 50.0

var radius: float = 30.0
var _impact_applied: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	gravity_scale = 1.5
	linear_damp = 0.1
	angular_damp = 0.05
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	contact_monitor = true
	max_contacts_reported = 4

	var material := PhysicsMaterial.new()
	material.friction = 1.0
	material.bounce = 0.08
	physics_material_override = material

	body_entered.connect(_on_body_entered)
	_apply_random_size()
	queue_redraw()


func _apply_random_size() -> void:
	radius = randf_range(min_radius, max_radius)
	mass = radius / 6.0

	var circle_shape := collision_shape.shape as CircleShape2D
	if circle_shape == null:
		circle_shape = CircleShape2D.new()
		collision_shape.shape = circle_shape

	circle_shape.radius = radius


func _on_body_entered(body: Node) -> void:
	if _impact_applied or not body.is_in_group("plank"):
		return

	_impact_applied = true
	body.apply_impact(global_position, mass)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(0.5, 0.5, 0.55))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(0.3, 0.3, 0.35), 2.0)
