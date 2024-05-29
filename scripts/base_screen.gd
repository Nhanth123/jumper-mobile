extends Control

var fade_duration = 0.5

func _ready():
	visible = false
	modulate.a = 0.0
	
	get_tree().call_group("buttons", "set_disabled", true)
	
func appear():
	visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)
	return tween
	
func disappear():
	get_tree().call_group("buttons", "set_disabled", true)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	return tween
