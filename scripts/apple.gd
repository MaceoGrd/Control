extends RigidBody2D

signal damaged

const RADIUS: float = 16.0
const INVULNERABILITY_TIME: float = 1.0
const HIT_FLASH_TIME: float = 0.25

var _wind_enabled: bool = true
var _wind_force: Vector2 = Vector2.ZERO
var _invulnerable_remaining: float = 0.0
var _hit_flash_remaining: float = 0.0


func _ready() -> void:
	add_to_group("apple")
	gravity_scale = 1.0
	linear_damp = 0.05
	angular_damp = 0.4
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	can_sleep = false

	var material := PhysicsMaterial.new()
	material.friction = 0.95
	material.bounce = 0.05
	physics_material_override = material

	queue_redraw()


func _process(delta: float) -> void:
	var needs_redraw := false

	if _invulnerable_remaining > 0.0:
		_invulnerable_remaining -= delta
		needs_redraw = true

	if _hit_flash_remaining > 0.0:
		_hit_flash_remaining -= delta
		needs_redraw = true

	if needs_redraw:
		queue_redraw()


func _physics_process(_delta: float) -> void:
	if not _wind_enabled or freeze:
		return
	apply_central_force(_wind_force)


func is_invulnerable() -> bool:
	return _invulnerable_remaining > 0.0


func take_hit() -> void:
	if freeze or is_invulnerable():
		return

	_invulnerable_remaining = INVULNERABILITY_TIME
	_hit_flash_remaining = HIT_FLASH_TIME
	queue_redraw()
	damaged.emit()


func set_wind_enabled(enabled: bool) -> void:
	_wind_enabled = enabled


func set_wind_force(force: Vector2) -> void:
	_wind_force = force


func freeze_for_game_over() -> void:
	_wind_enabled = false
	freeze = true


func reset_at(spawn_position: Vector2) -> void:
	freeze = true
	_wind_enabled = false
	_invulnerable_remaining = 0.0
	_hit_flash_remaining = 0.0

	global_position = spawn_position
	rotation = 0.0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sleeping = false

	var body_rid := get_rid()
	PhysicsServer2D.body_set_state(body_rid, PhysicsServer2D.BODY_STATE_TRANSFORM, global_transform)
	PhysicsServer2D.body_set_state(body_rid, PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
	PhysicsServer2D.body_set_state(body_rid, PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY, 0.0)

	freeze = false
	_wind_enabled = true
	queue_redraw()


func _draw() -> void:
	var body_color: Color = Color(0.85, 0.15, 0.12)

	if _hit_flash_remaining > 0.0:
		body_color = Color(1.0, 0.85, 0.85)
	elif is_invulnerable() and int(Time.get_ticks_msec() / 100.0) % 2 == 0:
		body_color = Color(1.0, 0.45, 0.45, 0.65)

	draw_circle(Vector2.ZERO, RADIUS, body_color)
	draw_line(Vector2(0.0, -RADIUS), Vector2(0.0, -RADIUS - 6.0), Color(0.35, 0.2, 0.1), 2.0)
	draw_circle(Vector2(4.0, -RADIUS - 4.0), 3.0, Color(0.2, 0.55, 0.15))
