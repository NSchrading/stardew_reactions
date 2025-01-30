extends VBoxContainer

@export var text_label: Label
@export var animation: AnimationPlayer
@export var new_text_audio: AudioStreamPlayer

func display_text(choice: String) -> void:
	text_label.visible_characters = 0
	text_label.text = choice

	var chars_per_second = 20.0
	var animation_length = choice.length() / chars_per_second

	animation.play("show_text", -1, 1 / animation_length, false)

	new_text_audio.play()
