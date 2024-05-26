extends Control

@onready var topbar = $TopBar
@onready var topbar_bg = $TopBarBG

func _ready():
	var os_name = OS.get_name()
	if os_name == "Android" || os_name == "iOS":
		var safe_area = DisplayServer.get_display_safe_area()
		var safe_area_top = safe_area.position.y
		
		topbar.position.y += safe_area_top
		
		var margin = 10
		topbar_bg.size.y += safe_area_top + margin
		
		 

func _on_pause_button_pressed():
	pass # Replace with function body.
