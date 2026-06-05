extends Area2D

const OFFSCREEN_MARGIN: float = 150.0
const BODY_RADIUS: float = 10.0

var direction: Vector2 = Vector2.RIGHT
var speed: float = 300.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()


func setup(start_position: Vector2, target_position: Vector2, speed_value: float) -> void:
	global_position = start_position
	speed = speed_value

	var to_target: Vector2 = target_position - start_position
	if to_target.length_squared() < 1.0:
		direction = Vector2.RIGHT
	else:
		direction = to_target.normalized()

	queue_redraw()


func _process(delta: float) -> void:
	global_position += direction * speed * delta
	_check_offscreen()


func _check_offscreen() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	if (
		global_position.x < -OFFSCREEN_MARGIN
		or global_position.x > viewport_size.x + OFFSCREEN_MARGIN
		or global_position.y < -OFFSCREEN_MARGIN
		or global_position.y > viewport_size.y + OFFSCREEN_MARGIN
	):
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("apple"):
		body.take_hit()
		queue_free()


func _draw() -> void:
	var facing: Vector2 = direction
	if facing.length_squared() < 0.001:
		facing = Vector2.RIGHT

	draw_circle(Vector2.ZERO, BODY_RADIUS, Color(0.25, 0.25, 0.3))
	draw_circle(Vector2(4.0 * facing.x, 4.0 * facing.y - 2.0), 2.5, Color(1.0, 0.85, 0.2))

	var wing_back: Vector2 = Vector2(-8.0 * facing.x + 2.0 * facing.y, -8.0 * facing.y - 2.0 * facing.x)
	var wing_front: Vector2 = Vector2(6.0 * facing.x, 6.0 * facing.y)
	draw_line(Vector2.ZERO, wing_back, Color(0.4, 0.4, 0.48), 3.0)
	draw_line(Vector2.ZERO, wing_front, Color(0.35, 0.35, 0.42), 2.0)
