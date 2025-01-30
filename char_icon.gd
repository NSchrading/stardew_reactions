extends Control

@export var char_name: String
@export var char_texture: Texture2D
@export var char_button: TextureButton
@export var char_label: Label
@export var font_size: int
@export var hover_audio: AudioStreamPlayer
@export var hearts_container: TextureRect

signal char_pressed(name: String)

func _ready():
	char_button.texture_normal = char_texture
	char_label.text = char_name
	char_label.add_theme_font_size_override("font_size", font_size)
	
	var save_path = "user://save_data.json"
	var save_json_text = FileAccess.get_file_as_string(save_path)
	var save_json_dict = {}
	if not save_json_text:
		print("char -- file didn't exist")
	else:
		save_json_dict = JSON.parse_string(save_json_text)

	var num_hearts = int(save_json_dict.get("gift_givers", {}).get(char_name, 0))

	match num_hearts:
		0:
			hearts_container.texture = load("res://sprites/zero_hearts.png")
		1:
			hearts_container.texture = load("res://sprites/one_hearts.png")
		2:
			hearts_container.texture = load("res://sprites/two_hearts.png")
		3:
			hearts_container.texture = load("res://sprites/three_hearts.png")
		4:
			hearts_container.texture = load("res://sprites/four_hearts.png")
		5:
			hearts_container.texture = load("res://sprites/five_hearts.png")
		6:
			hearts_container.texture = load("res://sprites/six_hearts.png")
		7:
			hearts_container.texture = load("res://sprites/seven_hearts.png")
		8:
			hearts_container.texture = load("res://sprites/eight_hearts.png")
		9:
			hearts_container.texture = load("res://sprites/nine_hearts.png")
		10:
			hearts_container.texture = load("res://sprites/ten_hearts.png")
		_:
			print("unexpected heart value: {}".format(num_hearts))


func _button_haptics() -> void:
	Input.vibrate_handheld(100, 0.2)
	hover_audio.play()


func _on_texture_button_focus_entered() -> void:
	_button_haptics()
	char_button.self_modulate = Color(1.6, 1.6, 1.6, 1.0)

func _on_texture_button_focus_exited() -> void:
	char_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)


func _on_texture_button_mouse_entered() -> void:
	_on_texture_button_focus_entered()


func _on_texture_button_mouse_exited() -> void:
	_on_texture_button_focus_exited()


func _on_texture_button_pressed() -> void:
	char_pressed.emit(char_name)
