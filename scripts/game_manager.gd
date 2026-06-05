extends Node2D

enum State { PLAYING, GAME_OVER }

const ROCK_SCENE: PackedScene = preload("res://scenes/Rock.tscn")
const BIRD_SCENE: PackedScene = preload("res://scenes/Bird.tscn")
const APPLE_SPAWN_OFFSET: Vector2 = Vector2(0.0, -28.0)
const OUT_OF_BOUNDS_MARGIN: float = 40.0
const RESET_GRACE_TIME: float = 0.75
const MAX_LIVES: int = 3
const FIRST_ROCK_MIN_TIME: float = 5.0
const FIRST_ROCK_MAX_TIME: float = 10.0
const FIRST_BIRD_MIN_TIME: float = 3.0
const FIRST_BIRD_MAX_TIME: float = 6.0
const BIRD_OFFSCREEN_MARGIN: float = 150.0
const ROCK_CLEANUP_MARGIN: float = 60.0
const WIND_CHANGE_MIN: float = 3.0
const WIND_CHANGE_MAX: float = 6.0
const WIND_POWER_MIN: float = 90.0
const WIND_POWER_MAX: float = 210.0

var game_over: bool = false
var state: State = State.PLAYING
var lives: int = MAX_LIVES
var survival_time: float = 0.0
var reset_grace_remaining: float = 0.0
var next_rock_time: float = 0.0
var next_bird_time: float = 0.0
var wind_direction: int = 1
var wind_power: float = 0.0
var wind_change_timer: float = 0.0

@onready var apple: RigidBody2D = $Apple
@onready var plank: StaticBody2D = $Plank
@onready var ui: CanvasLayer = $UI
@onready var rocks_container: Node2D = $Rocks
@onready var birds_container: Node2D = $Birds


func _ready() -> void:
	apple.damaged.connect(_on_apple_damaged)
	ui.setup()
	_reset_game()


func _process(delta: float) -> void:
	if state != State.PLAYING:
		return

	survival_time += delta
	ui.update_timer(survival_time)

	if reset_grace_remaining > 0.0:
		reset_grace_remaining -= delta

	_update_wind(delta)
	_update_rocks(delta)
	_update_birds(delta)

	if reset_grace_remaining <= 0.0 and _is_apple_out_of_bounds():
		_trigger_game_over()


func _physics_process(_delta: float) -> void:
	if state != State.PLAYING:
		apple.set_wind_enabled(false)
		return

	apple.set_wind_enabled(true)
	apple.set_wind_force(Vector2(wind_direction * wind_power, 0.0))


func _is_apple_out_of_bounds() -> bool:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var apple_position: Vector2 = apple.global_position

	return (
		apple_position.y > viewport_size.y + OUT_OF_BOUNDS_MARGIN
		or apple_position.x < -OUT_OF_BOUNDS_MARGIN
		or apple_position.x > viewport_size.x + OUT_OF_BOUNDS_MARGIN
	)


func _on_apple_damaged() -> void:
	if state != State.PLAYING:
		return

	lives -= 1
	ui.update_lives(lives, MAX_LIVES)

	if lives <= 0:
		_trigger_game_over()


func _trigger_game_over() -> void:
	if state == State.GAME_OVER:
		return

	state = State.GAME_OVER
	game_over = true
	apple.freeze_for_game_over()
	ui.show_game_over(survival_time)


func _reset_game() -> void:
	state = State.PLAYING
	game_over = false
	lives = MAX_LIVES
	survival_time = 0.0
	reset_grace_remaining = RESET_GRACE_TIME

	_clear_rocks()
	_clear_birds()
	plank.reset_rotation()

	var spawn_position: Vector2 = plank.global_transform * APPLE_SPAWN_OFFSET
	apple.reset_at(spawn_position)

	_reset_wind()
	_schedule_first_rock()
	_schedule_first_bird()

	ui.hide_game_over()
	ui.update_timer(0.0)
	ui.update_lives(lives, MAX_LIVES)
	ui.update_wind(wind_direction, wind_power)


func _reset_wind() -> void:
	_randomize_wind()
	wind_change_timer = randf_range(WIND_CHANGE_MIN, WIND_CHANGE_MAX)


func _randomize_wind() -> void:
	wind_direction = -1 if randf() < 0.5 else 1
	wind_power = randf_range(WIND_POWER_MIN, WIND_POWER_MAX)


func _update_wind(delta: float) -> void:
	wind_change_timer -= delta
	if wind_change_timer <= 0.0:
		_randomize_wind()
		wind_change_timer = randf_range(WIND_CHANGE_MIN, WIND_CHANGE_MAX)

	ui.update_wind(wind_direction, wind_power)


func _schedule_first_rock() -> void:
	next_rock_time = randf_range(FIRST_ROCK_MIN_TIME, FIRST_ROCK_MAX_TIME)


func _schedule_first_bird() -> void:
	next_bird_time = randf_range(FIRST_BIRD_MIN_TIME, FIRST_BIRD_MAX_TIME)


func _update_rocks(delta: float) -> void:
	next_rock_time -= delta
	if next_rock_time <= 0.0:
		_spawn_rock()
		next_rock_time = _compute_next_rock_delay()

	_cleanup_rocks()


func _update_birds(delta: float) -> void:
	next_bird_time -= delta
	if next_bird_time <= 0.0:
		_spawn_bird()
		next_bird_time = _compute_next_bird_delay()


func _get_bird_difficulty() -> Dictionary:
	if survival_time >= 60.0:
		return {
			"speed_min": 340.0,
			"speed_max": 580.0,
			"delay_min": 0.6,
			"delay_max": 2.0,
		}
	if survival_time >= 30.0:
		return {
			"speed_min": 280.0,
			"speed_max": 500.0,
			"delay_min": 1.0,
			"delay_max": 3.0,
		}

	return {
		"speed_min": 220.0,
		"speed_max": 420.0,
		"delay_min": 1.5,
		"delay_max": 4.0,
	}


func _compute_next_bird_delay() -> float:
	var difficulty: Dictionary = _get_bird_difficulty()
	return randf_range(difficulty["delay_min"], difficulty["delay_max"])


func _compute_next_rock_delay() -> float:
	var base_delay: float = randf_range(4.0, 7.0)
	var difficulty: float = clampf(survival_time / 120.0, 0.0, 0.55)
	return maxf(base_delay * (1.0 - difficulty), 1.8)


func get_random_spawn_position_outside_screen() -> Vector2:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var margin: float = BIRD_OFFSCREEN_MARGIN
	var edge: int = randi() % 4

	match edge:
		0:
			return Vector2(
				-margin,
				randf_range(-margin, viewport_size.y + margin)
			)
		1:
			return Vector2(
				viewport_size.x + margin,
				randf_range(-margin, viewport_size.y + margin)
			)
		2:
			return Vector2(
				randf_range(-margin, viewport_size.x + margin),
				-margin
			)
		_:
			return Vector2(
				randf_range(-margin, viewport_size.x + margin),
				viewport_size.y + margin
			)


func _spawn_rock() -> void:
	var rock: RigidBody2D = ROCK_SCENE.instantiate() as RigidBody2D
	rocks_container.add_child(rock)

	var from_left: bool = randf() < 0.5
	var plank_half_width: float = 160.0
	var side_offset: float = randf_range(plank_half_width * 0.55, plank_half_width * 0.85)
	if from_left:
		side_offset = -side_offset

	var spawn_position: Vector2 = Vector2(plank.global_position.x + side_offset, -24.0)
	rock.global_position = spawn_position

	var horizontal_speed: float = randf_range(40.0, 110.0)
	if from_left:
		rock.linear_velocity = Vector2(horizontal_speed, randf_range(90.0, 150.0))
	else:
		rock.linear_velocity = Vector2(-horizontal_speed, randf_range(90.0, 150.0))


func _spawn_bird() -> void:
	var bird: Area2D = BIRD_SCENE.instantiate() as Area2D
	birds_container.add_child(bird)

	var difficulty: Dictionary = _get_bird_difficulty()
	var spawn_position: Vector2 = get_random_spawn_position_outside_screen()
	var apple_position: Vector2 = apple.global_position
	var speed: float = randf_range(difficulty["speed_min"], difficulty["speed_max"])

	bird.setup(spawn_position, apple_position, speed)


func _cleanup_rocks() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	for rock in rocks_container.get_children():
		var rock_node: Node2D = rock as Node2D
		var rock_position: Vector2 = rock_node.global_position
		if (
			rock_position.y > viewport_size.y + ROCK_CLEANUP_MARGIN
			or rock_position.x < -ROCK_CLEANUP_MARGIN
			or rock_position.x > viewport_size.x + ROCK_CLEANUP_MARGIN
		):
			rock_node.queue_free()


func _clear_rocks() -> void:
	for rock in rocks_container.get_children():
		rock.queue_free()


func _clear_birds() -> void:
	for bird in birds_container.get_children():
		bird.queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		_reset_game()
