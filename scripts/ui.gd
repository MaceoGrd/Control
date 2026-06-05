extends CanvasLayer

@onready var lives_label: Label = $MarginContainer/VBoxContainer/LivesLabel
@onready var timer_label: Label = $MarginContainer/VBoxContainer/TimerLabel
@onready var wind_label: Label = $MarginContainer/VBoxContainer/WindLabel
@onready var game_over_panel: Control = $GameOverPanel
@onready var game_over_label: Label = $GameOverPanel/CenterContainer/VBoxContainer/GameOverLabel
@onready var restart_hint: Label = $GameOverPanel/CenterContainer/VBoxContainer/RestartHint


func setup() -> void:
	hide_game_over()
	update_lives(3, 3)
	update_timer(0.0)
	update_wind(1, 0.0)


func update_lives(current_lives: int, max_lives: int) -> void:
	var hearts: String = ""
	for i in max_lives:
		if i < current_lives:
			hearts += "❤️ "
		else:
			hearts += "🤍 "
	lives_label.text = hearts.strip_edges()


func update_timer(seconds: float) -> void:
	timer_label.text = "Temps : %.1f s" % seconds


func update_wind(direction: int, power: float) -> void:
	var arrow := "←" if direction < 0 else "→"
	var side := "gauche" if direction < 0 else "droite"
	wind_label.text = "Vent : %s %s (%.0f)" % [arrow, side, power]


func show_game_over(final_time: float) -> void:
	game_over_panel.visible = true
	game_over_label.text = "Game Over"
	restart_hint.text = "Score : %.1f secondes\nAppuyez sur R" % final_time


func hide_game_over() -> void:
	game_over_panel.visible = false
