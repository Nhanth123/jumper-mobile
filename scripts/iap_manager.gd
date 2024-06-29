extends Node

signal unlock_new_skin

func purchase_skin():
	unlock_new_skin.emit()
