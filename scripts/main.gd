extends Node

@onready var game = $Game
@onready var screens = $Screens
@onready var iap_manager = $IAPManager

var game_in_progress = false

func _ready():
	DisplayServer.window_set_window_event_callback(_on_window_event)
	screens.start_game.connect(_on_screens_start_game)
	game.player_died.connect(_on_game_player_died)
	screens.delete_level.connect(_on_screens_delete_level)
	game.pause_game.connect(_on_game_pause_game)
	
	# IAP signals
	iap_manager.unlock_new_skin.connect(_iap_manager_unlock_new_skin)
	screens.purchase_skin.connect(_on_screens_purchase_skin)
	screens.reset_purchases.connect(_on_screens_reset_purchases)
	screens.restore_purchases.connect(_on_screens_restore_purchases)

func _on_window_event(event):
	print("New the mouse pointer enters or exit the window. Event: " + str(event))
	match event:
		DisplayServer.WINDOW_EVENT_FOCUS_IN:
			print("Focus in")
		DisplayServer.WINDOW_EVENT_FOCUS_OUT:
			print("Focus out")
			if game_in_progress == true && !get_tree().paused:
				print("Windows minimized, paused game")
				_on_game_pause_game()
		DisplayServer.WINDOW_EVENT_CLOSE_REQUEST:
			get_tree().quit()


func _on_screens_start_game():
	game_in_progress = true
	game.new_game()

func _on_game_player_died(score, highscore):
	game_in_progress = false
	await (get_tree().create_timer(0.75).timeout)
	screens.game_over(score, highscore)

func _on_screens_delete_level():
	game_in_progress = false
	game.reset_game()

func _on_game_pause_game():
	get_tree().paused = true
	screens.pause_game()

func _on_screens_purchase_skin():
	iap_manager.purchase_skin()

# IAP Signals
func _iap_manager_unlock_new_skin():
	if game.new_skin_unlocked == false:
		game.new_skin_unlocked = true
		print("Unlock the new skin")

func _on_screens_reset_purchases():
	iap_manager.reset_purchases()
	
func _on_screens_restore_purchases():
	iap_manager.restore_purchases()
