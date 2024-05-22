extends Control

func _ready():
	visible = false
	modulate.a = 0.0
	
func appear():
	visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	return tween
	
func disappear():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	return tween
