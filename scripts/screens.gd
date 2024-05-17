extends CanvasLayer

@onready var console  = $Debug/ConsoleLog

func _ready():
	console.visible = false
	
func _process(_delta):
	pass

func _on_toggle_console_pressed():
	console.visible = !console.visible
