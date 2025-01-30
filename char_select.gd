extends Control

func _on_char_pressed(name: String) -> void:
	GiftGiver.giver_name = name
	get_tree().change_scene_to_file("res://control.tscn")
