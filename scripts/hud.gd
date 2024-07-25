extends Control

signal pause_game

@onready var topbar = $TopBar
@onready var topbar_bg = $TopBarBG
@onready var score_label = $TopBar/ScoreLabel

func _ready():
	var os_name = OS.get_name()
	if os_name == "Android" || os_name == "iOS":
		var safe_area = DisplayServer.get_display_safe_area()
		var safe_area_top = safe_area.position.y
		
		if os_name == "iOS":
			var screen_scale = DisplayServer.screen_get_scale()
			safe_area_top = (safe_area_top / screen_scale)
		
		topbar.position.y += safe_area_top
		
		var margin = 10
		topbar_bg.size.y += safe_area_top + margin

func _on_pause_button_pressed():
	SoundFX.play("Click")
	pause_game.emit()
	
func set_score(new_score):
	score_label.text = str(new_score)
