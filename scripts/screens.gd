extends CanvasLayer

@onready var console  = $Debug/ConsoleLog

func _ready():
	console.visible = false
	
	register_buttons()
	
func _process(_delta):
	pass

func register_buttons():
	var group_buttons = get_tree().get_nodes_in_group("buttons")
	if group_buttons.size() > 0:
		for button in group_buttons:
			if button is ScreenButton:
				button.clicked.connect(_on_button_pressed)

func _on_button_pressed(button):
	match button.name:
		"TitlePlay":
			print("Title play pressed")
		"PauseText":
			print("PausePlay pressed")
		"PauseRetry":
			print("PauseRetry")
		"PauseBack":
			print("PauseBack")
		"PauseClose":
			print("PauseClose")
		"GameOverRetry":
			print("GameOverRetry")
		"GameOverBack":
			print("GameOverBack")
			

func _on_toggle_console_pressed():
	console.visible = !console.visible
