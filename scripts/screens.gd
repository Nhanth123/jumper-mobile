extends CanvasLayer

signal start_game
signal delete_level

@onready var console  = $Debug/ConsoleLog
@onready var title_screen  = $TitleScreen
@onready var pause_screen = $PauseScreen
@onready var game_over_screen = $GameOverScreen
@onready var game_over_score_label = $GameOverScreen/Box/ScoreLabel
@onready var game_over_high_score_label = $GameOverScreen/Box/ScoreLabel

var current_screne = null

func _ready():
	console.visible = false
	
	register_buttons()
	change_screen(title_screen)
	
func _process(_delta):
	pass

func register_buttons():
	var group_buttons = get_tree().get_nodes_in_group("buttons")
	if group_buttons.size() > 0:
		for button in group_buttons:
			if button is ScreenButton:
				button.clicked.connect(_on_button_pressed)

func _on_button_pressed(button):
	SoundFX.play("Click")
	
	match button.name:
		"TitlePlay":
			change_screen(null)
			await(get_tree().create_timer(0.5).timeout)
			start_game.emit()
		"PauseText":
			print("Pause retry")
			change_screen(game_over_screen)
		"PauseRetry":
			change_screen(null)
			await(get_tree().create_timer(0.75).timeout)
			get_tree().paused = false
			start_game.emit()
		"PauseBack":
			change_screen(title_screen)
			get_tree().paused = false
			delete_level.emit()
		"PauseClose":
			change_screen(null)
			await(get_tree().create_timer(0.75).timeout)
			get_tree().paused = false
		"GameOverRetry":
			change_screen(null)
			await(get_tree().create_timer(0.5).timeout)
			start_game.emit()
		"GameOverBack":
			change_screen(title_screen)
			delete_level.emit()

func _on_toggle_console_pressed():
	console.visible = !console.visible

func change_screen(new_screen):
	if current_screne != null:
		var disappear_tween = current_screne.disappear()
		await (disappear_tween.finished)
		current_screne.visible = false
	
	current_screne = new_screen
	
	if current_screne != null:
		var appear_tween =  current_screne.appear()
		await (appear_tween.finished)
		get_tree().call_group("buttons", "set_disabled", false)
		
func game_over(score, highscore):
	game_over_score_label.text = "Score: " + str(score)
	game_over_high_score_label.text = "Best: " + str(highscore)
	change_screen(game_over_screen)

func pause_game():
	change_screen(pause_screen)
