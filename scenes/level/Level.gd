extends Control
## Level
## Plateau de jeu avec overlay de choix de catégorie par-dessus (§10-§11),
## puis anagramme jouable (§12-§16) avec lettre(s) pré-placée(s) selon la
## complexité du mot, suppression lettre par lettre, et bouton indice.

const WORDS_PATH := "res://data/words/words.json"

@onready var background: Panel = $Background

@onready var hint_label: Label = %HintLabel
@onready var btn_hint: Button = %BtnHint
@onready var answer_row: HBoxContainer = %AnswerRow
@onready var tiles_row: HBoxContainer = %TilesRow
@onready var feedback_label: Label = %FeedbackLabel
@onready var btn_clear: Button = %BtnClear
@onready var btn_validate: Button = %BtnValidate
@onready var btn_back: Button = %BtnBack

@onready var category_overlay: Control = %CategoryOverlay
@onready var category_title: Label = %CategoryTitle
@onready var category_grid: GridContainer = %CategoryGrid
@onready var overlay_back: Button = %BtnBackToHome

var words_data: Array = []
var used_words_by_category: Dictionary = {}

var current_word: String = ""
var current_hint: String = ""
var current_category: String = ""

var shuffled_letters: Array = []
var tile_used: Array = []
var tile_buttons: Array = []

var free_positions: Array = []       # indices (dans le mot) que le joueur doit remplir
var locked_positions: Dictionary = {} # position (dans le mot) -> lettre pré-placée
var slot_fill: Array = []             # par position libre : -1 ou index dans shuffled_letters
var slot_entries: Array = []          # { "panel":, "label":, "position":, "locked": bool }

var hint_used_this_level: bool = false

var _tile_style_normal: StyleBoxFlat
var _tile_style_disabled: StyleBoxFlat
var _slot_style_empty: StyleBoxFlat
var _slot_style_filled: StyleBoxFlat
var _slot_style_locked: StyleBoxFlat


func _ready() -> void:
	_build_dynamic_styles()
	_style_background()
	_load_words()
	_refresh_texts()

	category_overlay.modulate.a = 1.0
	category_overlay.visible = true
	_populate_categories()


func _build_dynamic_styles() -> void:
	_tile_style_normal = StyleBoxFlat.new()
	_tile_style_normal.bg_color = Color(0.475, 0.353, 0.451)
	_tile_style_normal.set_corner_radius_all(16)
	_tile_style_normal.set_content_margin_all(14)
	_tile_style_normal.shadow_color = Color(0.545, 0.271, 0.361, 0.2)
	_tile_style_normal.shadow_size = 4

	_tile_style_disabled = StyleBoxFlat.new()
	_tile_style_disabled.bg_color = Color(0.867, 0.831, 0.816, 0.5)
	_tile_style_disabled.set_corner_radius_all(16)
	_tile_style_disabled.set_content_margin_all(14)

	_slot_style_empty = StyleBoxFlat.new()
	_slot_style_empty.bg_color = Color(0.941, 0.859, 0.831, 0.6)
	_slot_style_empty.set_corner_radius_all(12)
	_slot_style_empty.set_content_margin_all(12)
	_slot_style_empty.border_width_left = 2
	_slot_style_empty.border_width_top = 2
	_slot_style_empty.border_width_right = 2
	_slot_style_empty.border_width_bottom = 2
	_slot_style_empty.border_color = Color(0.906, 0.573, 0.573, 0.6)

	_slot_style_filled = StyleBoxFlat.new()
	_slot_style_filled.bg_color = Color(0.475, 0.353, 0.451)
	_slot_style_filled.set_corner_radius_all(12)
	_slot_style_filled.set_content_margin_all(12)

	# Style doré discret pour les lettres pré-placées (renfort d'indice).
	_slot_style_locked = StyleBoxFlat.new()
	_slot_style_locked.bg_color = Color(0.85, 0.62, 0.35)
	_slot_style_locked.set_corner_radius_all(12)
	_slot_style_locked.set_content_margin_all(12)

	# Bouton indice flottant : cercle doré avec ombre.
	var hint_style := StyleBoxFlat.new()
	hint_style.bg_color = Color(0.85, 0.62, 0.35)
	hint_style.set_corner_radius_all(40)
	hint_style.shadow_color = Color(0.545, 0.271, 0.361, 0.25)
	hint_style.shadow_size = 8
	hint_style.shadow_offset = Vector2(0, 4)
	btn_hint.add_theme_stylebox_override("normal", hint_style)
	btn_hint.add_theme_stylebox_override("hover", hint_style)
	var hint_style_disabled := StyleBoxFlat.new()
	hint_style_disabled.bg_color = Color(0.867, 0.831, 0.816, 0.7)
	hint_style_disabled.set_corner_radius_all(40)
	btn_hint.add_theme_stylebox_override("disabled", hint_style_disabled)
	_pulse_node(btn_hint)


func _style_background() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.976, 0.925, 0.902)
	background.add_theme_stylebox_override("panel", style)
	Decor.add_sparkles(self)


func _load_words() -> void:
	if not FileAccess.file_exists(WORDS_PATH):
		push_warning("Level: words.json introuvable")
		return
	var text: String = FileAccess.get_file_as_string(WORDS_PATH)
	var parsed = JSON.parse_string(text)
	if parsed is Array:
		words_data = parsed


func _refresh_texts() -> void:
	category_title.text = Loc.t("level_choose_category_title")
	overlay_back.text = Loc.t("level_back_to_home")
	btn_clear.text = Loc.t("level_clear")
	btn_validate.text = Loc.t("level_validate")
	btn_back.text = Loc.t("level_back_to_home")


# ---------------------------------------------------------------------------
# OVERLAY : choix de catégorie (par-dessus le plateau)
# ---------------------------------------------------------------------------

func _populate_categories() -> void:
	for child in category_grid.get_children():
		child.queue_free()

	var lang: String = GameData.profile.get("language", "fr")

	for cat in GameData.categories:
		var btn := Button.new()
		var label: String = cat.get("label_fr", "") if lang == "fr" else cat.get("label_en", "")
		btn.text = "%s\n%s" % [cat.get("emoji", ""), label]
		btn.custom_minimum_size = Vector2(280, 110)
		btn.add_theme_font_size_override("font_size", 26)
		btn.pressed.connect(_on_category_selected.bind(cat.get("id", "")))
		category_grid.add_child(btn)


func _on_category_selected(category_id: String) -> void:
	Audio.play_click()
	GameData.register_category_choice(category_id)
	current_category = category_id
	_pick_word_for_category(category_id)
	_setup_anagram()
	_hide_overlay()


func _show_overlay() -> void:
	category_overlay.visible = true
	category_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	category_overlay.modulate.a = 0.0
	_populate_categories()
	var tween := create_tween()
	tween.tween_property(category_overlay, "modulate:a", 1.0, 0.25)


func _hide_overlay() -> void:
	var tween := create_tween()
	tween.tween_property(category_overlay, "modulate:a", 0.0, 0.25)
	await tween.finished
	category_overlay.visible = false
	category_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE


# ---------------------------------------------------------------------------
# SÉLECTION DU MOT (sans répétition immédiate dans une même catégorie)
# ---------------------------------------------------------------------------

func _pick_word_for_category(category_id: String) -> void:
	var lang: String = GameData.profile.get("language", "fr")
	var candidates: Array = []

	for w in words_data:
		if w.get("category", "") == category_id and w.get("language", "") == lang:
			candidates.append(w)

	if candidates.is_empty():
		current_word = "JOUER" if lang == "fr" else "PLAY"
		current_hint = ""
		return

	var used: Array = used_words_by_category.get(category_id, [])
	var fresh: Array = []
	for w in candidates:
		if not used.has(w.get("word", "")):
			fresh.append(w)

	# Toute la catégorie a déjà été vue : on relance le cycle.
	if fresh.is_empty():
		used.clear()
		fresh = candidates

	var chosen: Dictionary = fresh[randi() % fresh.size()]
	current_word = str(chosen.get("word", "")).to_upper()
	current_hint = str(chosen.get("hint", ""))

	used.append(chosen.get("word", ""))
	used_words_by_category[category_id] = used


# ---------------------------------------------------------------------------
# ANAGRAMME : lettre(s) pré-placée(s), suppression individuelle, indice
# ---------------------------------------------------------------------------

func _setup_anagram() -> void:
	hint_label.text = current_hint
	feedback_label.text = ""
	hint_used_this_level = false
	btn_hint.disabled = false

	var word_length: int = current_word.length()

	# Règle de renfort : 1 lettre pré-placée pour un mot court,
	# 2 pour un mot plus long/complexe.
	var lock_count: int = 1 if word_length <= 6 else 2
	lock_count = min(lock_count, max(word_length - 2, 0))

	locked_positions.clear()
	var all_positions: Array = range(word_length)
	all_positions.shuffle()
	for i in range(lock_count):
		var pos: int = all_positions[i]
		locked_positions[pos] = current_word[pos]

	free_positions.clear()
	for i in range(word_length):
		if not locked_positions.has(i):
			free_positions.append(i)

	# Lettres à mélanger pour les tuiles : le mot moins les lettres
	# déjà consommées par les positions verrouillées.
	var pool: Array = []
	for i in range(word_length):
		pool.append(current_word[i])
	for pos in locked_positions.keys():
		var letter: String = locked_positions[pos]
		var idx: int = pool.find(letter)
		if idx != -1:
			pool.remove_at(idx)
	pool.shuffle()
	shuffled_letters = pool

	tile_used = []
	for i in range(shuffled_letters.size()):
		tile_used.append(false)

	slot_fill = []
	for i in range(free_positions.size()):
		slot_fill.append(-1)

	_rebuild_tiles()
	_rebuild_slots()
	btn_validate.disabled = true


func _rebuild_tiles() -> void:
	for child in tiles_row.get_children():
		child.queue_free()
	tile_buttons.clear()

	for i in range(shuffled_letters.size()):
		var btn := Button.new()
		btn.text = shuffled_letters[i]
		btn.custom_minimum_size = Vector2(72, 72)
		btn.add_theme_stylebox_override("normal", _tile_style_normal)
		btn.add_theme_stylebox_override("hover", _tile_style_normal)
		btn.add_theme_stylebox_override("disabled", _tile_style_disabled)
		btn.add_theme_color_override("font_color", Color(1, 1, 1))
		btn.add_theme_font_size_override("font_size", 36)
		btn.pressed.connect(_on_tile_pressed.bind(i))
		tiles_row.add_child(btn)
		tile_buttons.append(btn)


func _rebuild_slots() -> void:
	for child in answer_row.get_children():
		child.queue_free()
	slot_entries.clear()

	var word_length: int = current_word.length()
	for pos in range(word_length):
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(64, 72)

		var lbl := Label.new()
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 36)

		var is_locked: bool = locked_positions.has(pos)
		if is_locked:
			lbl.text = locked_positions[pos]
			panel.add_theme_stylebox_override("panel", _slot_style_locked)
			lbl.add_theme_color_override("font_color", Color(1, 1, 1))
		else:
			lbl.text = ""
			panel.add_theme_stylebox_override("panel", _slot_style_empty)
			var free_index: int = free_positions.find(pos)
			panel.gui_input.connect(_on_slot_gui_input.bind(free_index))

		panel.add_child(lbl)
		answer_row.add_child(panel)
		slot_entries.append({"panel": panel, "label": lbl, "position": pos, "locked": is_locked})

	_refresh_slots()


func _on_slot_gui_input(event: InputEvent, free_index: int) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_on_slot_pressed(free_index)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_slot_pressed(free_index)


func _on_tile_pressed(tile_index: int) -> void:
	if tile_used[tile_index]:
		return
	var target_k: int = slot_fill.find(-1)
	if target_k == -1:
		return

	slot_fill[target_k] = tile_index
	tile_used[tile_index] = true
	tile_buttons[tile_index].disabled = true
	_refresh_slots()
	_animate_slot_pop(free_positions[target_k])
	_update_validate_state()
	Audio.play_tile()


func _on_slot_pressed(free_index: int) -> void:
	if free_index < 0 or free_index >= slot_fill.size():
		return
	var tile_index: int = slot_fill[free_index]
	if tile_index == -1:
		return

	slot_fill[free_index] = -1
	tile_used[tile_index] = false
	tile_buttons[tile_index].disabled = false
	_refresh_slots()
	_update_validate_state()


func _refresh_slots() -> void:
	for entry in slot_entries:
		if entry["locked"]:
			continue
		var pos: int = entry["position"]
		var free_index: int = free_positions.find(pos)
		var lbl: Label = entry["label"]
		var panel: PanelContainer = entry["panel"]
		var tile_index: int = slot_fill[free_index]
		if tile_index != -1:
			lbl.text = shuffled_letters[tile_index]
			panel.add_theme_stylebox_override("panel", _slot_style_filled)
			lbl.add_theme_color_override("font_color", Color(1, 1, 1))
		else:
			lbl.text = ""
			panel.add_theme_stylebox_override("panel", _slot_style_empty)


func _update_validate_state() -> void:
	btn_validate.disabled = slot_fill.find(-1) != -1


func _on_clear_pressed() -> void:
	for i in range(slot_fill.size()):
		var tile_index: int = slot_fill[i]
		if tile_index != -1:
			tile_used[tile_index] = false
			tile_buttons[tile_index].disabled = false
		slot_fill[i] = -1
	_refresh_slots()
	btn_validate.disabled = true
	feedback_label.text = ""


func _on_hint_pressed() -> void:
	if hint_used_this_level:
		return
	var k: int = slot_fill.find(-1)
	if k == -1:
		return
	Audio.play_click()

	var target_pos: int = free_positions[k]
	var needed_letter: String = current_word[target_pos]

	for i in range(shuffled_letters.size()):
		if not tile_used[i] and shuffled_letters[i] == needed_letter:
			slot_fill[k] = i
			tile_used[i] = true
			tile_buttons[i].disabled = true
			_refresh_slots()
			_animate_slot_pop(target_pos)
			_update_validate_state()
			hint_used_this_level = true
			btn_hint.disabled = true
			break


func _on_validate_pressed() -> void:
	var built := ""
	for pos in range(current_word.length()):
		if locked_positions.has(pos):
			built += locked_positions[pos]
		else:
			var free_index: int = free_positions.find(pos)
			var tile_index: int = slot_fill[free_index]
			built += String(shuffled_letters[tile_index])

	if built == current_word:
		_on_success()
	else:
		_on_failure()


func _on_success() -> void:
	feedback_label.text = Loc.t("level_success_message")
	_pulse_feedback()
	Audio.play_success()
	GameData.statistics.successes = int(GameData.statistics.get("successes", 0)) + 1

	var new_level: int = int(GameData.progress.get("current_level", 1)) + 1
	await get_tree().create_timer(1.1).timeout

	if new_level > 10:
		var completed_chapter: int = int(GameData.progress.get("current_chapter", 1))
		if not GameData.progress.unlocked_rewards.has(completed_chapter):
			GameData.progress.unlocked_rewards.append(completed_chapter)
		GameData.progress.current_chapter = completed_chapter + 1
		GameData.progress.current_level = 1
		SaveManager.save_game()
		SceneRouter.go_to("reward")
	else:
		GameData.progress.current_level = new_level
		SaveManager.save_game()
		_show_overlay()


func _on_failure() -> void:
	feedback_label.text = Loc.t("level_failure_message")
	_pulse_feedback()
	_shake_answer_row()
	Audio.play_failure()
	GameData.statistics.failures = int(GameData.statistics.get("failures", 0)) + 1
	_on_clear_pressed()


func _pulse_feedback() -> void:
	feedback_label.scale = Vector2(0.85, 0.85)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback_label, "scale", Vector2(1.0, 1.0), 0.35)


func _animate_slot_pop(position: int) -> void:
	for entry in slot_entries:
		if entry["position"] == position:
			var panel: PanelContainer = entry["panel"]
			panel.pivot_offset = panel.size / 2.0
			panel.scale = Vector2(0.4, 0.4)
			var tween := create_tween()
			tween.set_trans(Tween.TRANS_BACK)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3)
			return


func _shake_answer_row() -> void:
	var original_pos: Vector2 = answer_row.position
	var tween := create_tween()
	tween.tween_property(answer_row, "position:x", original_pos.x - 12, 0.06)
	tween.tween_property(answer_row, "position:x", original_pos.x + 12, 0.06)
	tween.tween_property(answer_row, "position:x", original_pos.x - 8, 0.06)
	tween.tween_property(answer_row, "position:x", original_pos.x, 0.06)


## Petite pulsation continue pour donner de la vie à un bouton (voir
## demande de dynamisme). Le tween boucle indéfiniment.
func _pulse_node(node: Control) -> void:
	node.pivot_offset = node.size / 2.0
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(node, "scale", Vector2(1.08, 1.08), 0.7).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "scale", Vector2(1.0, 1.0), 0.7).set_trans(Tween.TRANS_SINE)


func _on_back_pressed() -> void:
	SceneRouter.go_to("home")
