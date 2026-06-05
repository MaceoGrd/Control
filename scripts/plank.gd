extends StaticBody2D

const PLANK_SIZE: Vector2 = Vector2(320.0, 16.0)
const TILT_SPEED: float = 1.8
const MAX_TILT: float = deg_to_rad(35.0)
const TORQUE_DAMPING: float = 4.5
const IMPACT_STRENGTH: float = 0.35

var external_torque: float = 0.0


func _ready() -> void:
	add_to_group("plank")

	var material := PhysicsMaterial.new()
	material.friction = 1.0
	material.bounce = 0.0
	physics_material_override = material
	queue_redraw()


func _physics_process(delta: float) -> void:
	var input_direction: float = Input.get_axis("tilt_left", "tilt_right")
	rotation += input_direction * TILT_SPEED * delta
	rotation += external_torque * delta
	external_torque = lerpf(external_torque, 0.0, TORQUE_DAMPING * delta)
	rotation = clampf(rotation, -MAX_TILT, MAX_TILT)


func apply_impact(world_position: Vector2, force: float) -> void:
	var local_position: Vector2 = to_local(world_position)
	var half_width: float = PLANK_SIZE.x * 0.5
	var normalized_offset: float = clampf(local_position.x / half_width, -1.0, 1.0)
	external_torque += normalized_offset * force * IMPACT_STRENGTH


func reset_rotation() -> void:
	rotation = 0.0
	external_torque = 0.0


func get_ball_spawn_position(offset: Vector2) -> Vector2:
	return global_transform * offset


func _draw() -> void:
	var half_size: Vector2 = PLANK_SIZE * 0.5
	var rect: Rect2 = Rect2(-half_size, PLANK_SIZE)
	draw_rect(rect, Color(0.58, 0.38, 0.18))
	draw_rect(rect, Color(0.32, 0.2, 0.08), false, 2.0)
