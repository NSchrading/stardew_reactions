extends Control

@export var text_label: Label
@export var animation: AnimationPlayer
@export var nic: Sprite2D
@export var nic_jump: Sprite2D
@export var nic_char_area: Area2D
@export var nic_reaction_timer: Timer
@export var close_button_area: Area2D
@export var dbox: BoxContainer
@export var buttons: GridContainer
@export var affinity_selection: Control
@export var debounce_timer: Timer

@export var love_audio: AudioStreamPlayer
@export var like_audio: AudioStreamPlayer
@export var neutral_audio: AudioStreamPlayer
@export var dislike_audio: AudioStreamPlayer
@export var hate_audio: AudioStreamPlayer
@export var hit_reaction_audio: AudioStreamPlayer
@export var new_text_audio: AudioStreamPlayer
@export var close_audio: AudioStreamPlayer
@export var button_hover_audio: AudioStreamPlayer

@export var default_emote: AnimatedSprite2D
@export var love_emote: AnimatedSprite2D
@export var like_emote: AnimatedSprite2D
@export var neutral_emote: AnimatedSprite2D
@export var dislike_emote: AnimatedSprite2D
@export var hate_emote: AnimatedSprite2D
@export var shock_emote: AnimatedSprite2D


var debounced = true


func create_save_data_file() -> void:
	var save_path = "user://save_data.json"
	var save_file_handle := FileAccess.open(save_path, FileAccess.WRITE)
	if not save_file_handle:
		print("An error happened while saving data: ", FileAccess.get_open_error())
		return

	save_file_handle.store_line('{"gift_givers":{}}')
	save_file_handle.close()


func _ready() -> void:
	print(GiftGiver.giver_name)
	
	var save_path = "user://save_data.json"
	var save_json_text = FileAccess.get_file_as_string(save_path)
	if not save_json_text:
		print("file didn't exist")
		create_save_data_file()
		return

	var save_json_dict = JSON.parse_string(save_json_text)
	var gift_givers = save_json_dict.get("gift_givers")
	if gift_givers == null:
		create_save_data_file()
		return


func display_text(choice: String) -> void:
	text_label.visible_characters = 0
	text_label.text = choice

	var chars_per_second = 20.0
	var animation_length = choice.length() / chars_per_second

	animation.play("show_text", -1, 1 / animation_length, false)
	
	new_text_audio.play()

func show_dialogue() -> void:
	dbox.visible = true
	affinity_selection.visible = false
	

func vibrate(num_cycles: int, vibrate_speed: float):
	var orig_x = nic.position.x
	var orig_y = nic.position.y
	var mult = 1
	for idx in num_cycles:
		nic.position.x = orig_x + (mult * (randi() % 2))
		nic.position.y = orig_y + (mult * (randi() % 2))
		mult = mult * -1
		await get_tree().create_timer(vibrate_speed).timeout
	nic.position.x = orig_x
	nic.position.y = orig_y


func vibrate_x():
	var orig_x = nic.position.x
	var mult = 1
	for idx in 4:
		nic.position.x = orig_x + mult
		mult = mult * -1
		await get_tree().create_timer(.4).timeout
	nic.position.x = orig_x
	
	
func move_down():
	var orig_y = nic.position.y
	nic.position.y = nic.position.y + 1
	await get_tree().create_timer(.8).timeout
	nic.position.y = nic.position.y + 1
	await get_tree().create_timer(.4).timeout
	nic.position.y = orig_y
	
	
func hate_reaction():
	nic.self_modulate = Color(1.0, 0.5, 0.5, 1.0)
	await move_down()
	nic.self_modulate = Color(1.0, 1.0, 1.0, 1.0)


func _save_gift(heart_val: int) -> void:
	var save_path = "user://save_data.json"
	var save_json_text = FileAccess.get_file_as_string(save_path)
	var save_json_dict = JSON.parse_string(save_json_text)
	
	var hearts_before = save_json_dict["gift_givers"].get(GiftGiver.giver_name, 0)
	var hearts_after = clamp(hearts_before + heart_val, 0, 10)
	
	if hearts_before != hearts_after:
		save_json_dict["gift_givers"][GiftGiver.giver_name] = clamp(save_json_dict["gift_givers"].get(GiftGiver.giver_name, 0) + heart_val, 0, 10)

		var save_file_handle := FileAccess.open(save_path, FileAccess.WRITE)
		if not save_file_handle:
			print("An error happened while saving data: ", FileAccess.get_open_error())
			return

		save_file_handle.store_line(JSON.stringify(save_json_dict))
		save_file_handle.close()


func _on_love_button_pressed() -> void:
	love_audio.play()
	var duration_ms = 600
	Input.vibrate_handheld(600, 1.0)
	await vibrate(duration_ms / 10, 0.01)
	show_dialogue()
	
	var file = "res://dialogue/love.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	
	var responses = json_as_dict["responses"]
	var choice = responses[randi() % responses.size()]
	
	display_text(choice)
	_save_gift(2)


func _on_like_button_pressed() -> void:
	like_audio.play()
	var duration_ms = 500
	Input.vibrate_handheld(duration_ms, 0.8)
	await vibrate(duration_ms / 100, 0.1)
	show_dialogue()
	
	var file = "res://dialogue/like.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	
	var responses = json_as_dict["responses"]
	var choice = responses[randi() % responses.size()]
	
	display_text(choice)
	_save_gift(1)
	
	
func _on_neutral_button_pressed() -> void:
	neutral_audio.play()
	
	var duration_ms = 500
	Input.vibrate_handheld(duration_ms, 0.5)
	await vibrate_x()

	show_dialogue()
	
	var file = "res://dialogue/neutral.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	
	var responses = json_as_dict["responses"]
	var choice = responses[randi() % responses.size()]
	
	display_text(choice)


func _on_dislike_button_pressed() -> void:
	dislike_audio.play()
	Input.vibrate_handheld(900, 0.8)
	await move_down()
	
	show_dialogue()
	
	var file = "res://dialogue/dislike.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	
	var responses = json_as_dict["responses"]
	var choice = responses[randi() % responses.size()]
	
	display_text(choice)
	_save_gift(-1)


func _on_hate_button_pressed() -> void:
	hate_audio.play()
	Input.vibrate_handheld(2000, 1.0)
	await hate_reaction()
	
	show_dialogue()
	
	var file = "res://dialogue/hate.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	
	var responses = json_as_dict["responses"]
	var choice = responses[randi() % responses.size()]
	
	display_text(choice)
	_save_gift(-2)
	

func _button_haptics() -> void:
	Input.vibrate_handheld(100, 0.2)
	button_hover_audio.play()


func _on_love_button_focus_entered() -> void:
	_button_haptics()
	default_emote.visible = false
	default_emote.pause()
	love_emote.visible = true
	love_emote.play()


func _on_love_button_focus_exited() -> void:
	default_emote.visible = true
	default_emote.play()
	love_emote.visible = false
	love_emote.pause()


func _on_love_button_mouse_entered() -> void:
	_on_love_button_focus_entered()


func _on_love_button_mouse_exited() -> void:
	_on_love_button_focus_exited()


func _on_like_button_focus_entered() -> void:
	_button_haptics()
	default_emote.visible = false
	default_emote.pause()
	like_emote.visible = true
	like_emote.play()


func _on_like_button_focus_exited() -> void:
	default_emote.visible = true
	default_emote.play()
	like_emote.visible = false
	like_emote.pause()


func _on_like_button_mouse_entered() -> void:
	_on_like_button_focus_entered()


func _on_like_button_mouse_exited() -> void:
	_on_like_button_focus_exited()
	
	
func _on_neutral_button_focus_entered() -> void:
	_button_haptics()
	default_emote.visible = false
	default_emote.pause()
	neutral_emote.visible = true
	neutral_emote.play()


func _on_neutral_button_focus_exited() -> void:
	default_emote.visible = true
	default_emote.play()
	neutral_emote.visible = false
	neutral_emote.pause()


func _on_neutral_button_mouse_entered() -> void:
	_on_neutral_button_focus_entered()


func _on_neutral_button_mouse_exited() -> void:
	_on_neutral_button_focus_exited()


func _on_dislike_button_focus_entered() -> void:
	_button_haptics()
	default_emote.visible = false
	default_emote.pause()
	dislike_emote.visible = true
	dislike_emote.play()


func _on_dislike_button_focus_exited() -> void:
	default_emote.visible = true
	default_emote.play()
	dislike_emote.visible = false
	dislike_emote.pause()


func _on_dislike_button_mouse_entered() -> void:
	_on_dislike_button_focus_entered()


func _on_dislike_button_mouse_exited() -> void:
	_on_dislike_button_focus_exited()
	
	
func _on_hate_button_focus_entered() -> void:
	_button_haptics()
	default_emote.visible = false
	default_emote.pause()
	hate_emote.visible = true
	hate_emote.play()


func _on_hate_button_focus_exited() -> void:
	default_emote.visible = true
	default_emote.play()
	hate_emote.visible = false
	hate_emote.pause()


func _on_hate_button_mouse_entered() -> void:
	_on_hate_button_focus_entered()


func _on_hate_button_mouse_exited() -> void:
	_on_hate_button_focus_exited()


func _on_timer_timeout():
	nic.visible = true
	nic_jump.visible = false

	default_emote.visible = true
	default_emote.play()
	shock_emote.visible = false
	shock_emote.pause()


func _on_nic_char_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_pressed():
		hit_reaction_audio.play()
		nic_reaction_timer.start()
		nic.visible = false
		nic_jump.visible = true

		default_emote.visible = false
		default_emote.pause()
		shock_emote.visible = true
		shock_emote.play()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	new_text_audio.stop()
	close_button_area.visible = true


func _on_close_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_pressed():
		close_audio.play()
		dbox.visible = false
		close_button_area.visible = false
		debounced = false
		debounce_timer.start()
		affinity_selection.visible = true


func _on_text_area_collision_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_pressed():
		animation.advance(9999) # hopefully 9999 is long enough to reach the end


func _on_end_gift_giver_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_pressed() and debounced:
		close_audio.play()
		get_tree().change_scene_to_file("res://char_select.tscn")


func _on_debounce_timer_timeout() -> void:
	debounced = true
