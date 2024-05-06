extends Camera2D

var player : Player = null
var viewport_size
var limit_distance = 420

func _ready():
	viewport_size = get_viewport_rect().size
	global_position.x = get_viewport_rect().size.x / 2
	
	limit_bottom = viewport_size.y
	limit_left = 0
	limit_right = viewport_size.x
	
func _process(delta):
	if player:
		if limit_bottom > player.global_position.y + limit_distance:
			limit_bottom = player.global_position.y + limit_distance

func _physics_process(delta):
	if player:
		global_position.y = player.global_position.y
	
func setup_camera(_player: Player):
	if _player:
		player = _player
		
