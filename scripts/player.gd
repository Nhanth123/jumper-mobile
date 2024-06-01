extends CharacterBody2D
class_name Player

@onready var animator = $AnimationPlayer
@onready var cshape = $CollisionShape2D
signal died

var speed = 300.0
var viewport_size
var gravity = 15.0
var max_fall_velocity = 1000.0
var jump_velocity = -800

var accelerometer_speed = 130
var dead = false
var use_accelerometer = false

func _ready():
	viewport_size = get_viewport_rect().size

func _process(_delta):
	if velocity.y > 0:
		if animator.current_animation != "fall":
			animator.play("fall")
	elif velocity.y < 0:
		if animator.current_animation != "jump":
			animator.play("jump")

func _physics_process(_delta):
	velocity.y += gravity
	if velocity.y > max_fall_velocity:
		velocity.y = max_fall_velocity
	
	if !dead:
		if use_accelerometer:
			var mobile_input = Input.get_accelerometer()
			velocity.x = mobile_input.x * accelerometer_speed
		else:
			var direction = Input.get_axis("move_left","move_right")
			if direction:
				velocity.x = speed * direction
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
			
	move_and_slide()
	var margin = 20
	if global_position.x > viewport_size.x + margin:
		global_position.x = -margin
	if global_position.x < -margin:
		global_position.x = viewport_size.x + margin

func jump():
	velocity.y = jump_velocity
	MyUtility.add_log_msg("Player jump")

func _on_visible_on_screen_notifier_2d_screen_exited():
	die()
	
func die():
	if !dead:
		dead = true
		cshape.set_deferred("disabled", true)
		died.emit()	
	
