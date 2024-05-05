extends Camera2D

var player : Player = null

func _ready():
	global_position.x = get_viewport_rect().size.x / 2

func _physics_process(delta):
	if player:
		global_position.y = player.global_position.y
	
func setup_camera(_player: Player):
	if _player:
		player = _player
		
