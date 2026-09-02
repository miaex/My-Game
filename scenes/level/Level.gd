extends Control
## Level
## Choix de catégorie (§10-§11) puis jeu d'anagramme (§12-§16).
## Version simple : un mot par passage, tuiles à toucher pour reconstituer
## la réponse, indice affiché, aucune pénalité en cas d'erreur.

const WORDS_PATH := "res://data/words/words.json"

@onready var background: Panel = $Background

@onready var category_panel: VBoxContainer = %CategoryPanel
@onready var category_title: Label = %CategoryTitle
@onready var category_grid: GridContainer = %CategoryGrid
@onready var btn_back_to_home: Button = %BtnBackToHome

@onready var anagram_panel: VBoxContainer = %AnagramPanel
@onready var hint_label: Label = %HintLabel
@onready var answer_row: HBoxContainer = %AnswerRow
@onready var tiles_row: HBoxContainer = %TilesRow
@onready var feedback_label: Label = %FeedbackLabel
@onready var btn_clear: Button = %BtnClear
@onready var btn_validate: Button = %BtnValidate
@onready var btn_back: Button = %BtnBack

var words_data: Array = []

var current_word: String = ""
var current_hint: String = ""
var current_category: String = ""

var shuffled_letters: Array = []
var answer_letters: Array = []
var tile_buttons: Array = []
var slot_labels: Array = []

# Styles construits par code pour les tuiles/emplacements (indépendants
# du thème global des boutons, qui est pensé pour les gros boutons de menu).
var _tile_style_normal: StyleBoxFlat
var _tile_style_disabled: StyleBoxFlat
var _slot_style_empty: StyleBoxFlat
var _slot_style_filled: StyleBoxFlat


func _ready() -> void:
	_build_dynamic_styles()
	_style_background()
	_load_words()
	_refresh_texts()
	_show_category_panel()


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


func _style_background() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.976, 0.925, 0.902)
	background.add_theme_stylebox_override("panel", style)


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
	btn_back_to_home.text = Loc.t("level_back_to_home")
	btn_clear.text = Loc.t("level_clear")
	btn_validate.text = Loc.t("level_validate")
	btn_back.text = Loc.t("level_back_to_home")


# ---------------------------------------------------------------------------
# ÉCRAN 1 : choix de catégorie
# ---------------------------------------------------------------------------

func _show_category_panel() -> void:
	category_panel.visible = true
	anagram_panel.visible = false
	_populate_categories()
	_animate_panel_appear(category_panel)


func _populate_categories() -> void:
	for child in category_grid.get_children():
		child.queue_free()

	var lang: String = GameData.profile.get("language", "fr")

	for cat in GameData.categories:
		var btn := Button.new()
		var label: String = cat.get("label_fr", "") if lang == "fr" else cat.get("label_en", "")
		btn.text = "%s  %s" % [cat.get("emoji", ""), label]
		btn.custom_minimum_size = Vector2(0, 90)
		btn.clip_text = false
		btn.add_theme_font_size_override("font_size", 28)
		btn.pressed.connect(_on_category_selected.bind(cat.get("id", "")))
		category_grid.add_child(btn)


func _on_category_selected(category_id: String) -> void:
	GameData.register_category_choice(category_id)
	current_category = category_id
	_pick_word_for_category(category_id)
	_setup_anagram()
	_show_anagram_panel()


func _show_anagram_panel() -> void:
	category_panel.visible = false
	anagram_panel.visible = true
	_animate_panel_appear(anagram_panel)


func _animate_panel_appear(panel: Control) -> void:
	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.28)


func _pulse_feedback() -> void:
	feedback_label.scale = Vector2(0.85, 0.85)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(feedback_label, "scale", Vector2(1.0, 1.0), 0.35)


# ---------------------------------------------------------------------------
# ÉCRAN 2 : anagramme
# ---------------------------------------------------------------------------

func _pick_word_for_category(category_id: String) -> void:
	var lang: String = GameData.profile.get("language", "fr")
	var candidates: Array = []

	for w in words_data:
		if w.get("category", "") == category_id and w.get("language", "") == lang:
			candidates.append(w)

	if candidates.is_empty():
		for w in words_data:
			if w.get("language", "") == lang:
				candidates.append(w)

	if candidates.is_empty():
		current_word = "JOUER" if lang == "fr" else "PLAY"
		current_hint = ""
	else:
		var chosen: Dictionary = candidates[randi() % candidates.size()]
		current_word = str(chosen.get("word", "")).to_upper()
		current_hint = str(chosen.get("hint", ""))


func _setup_anagram() -> void:
	hint_label.text = current_hint
	feedback_label.text = ""
	answer_letters.clear()

	var letters: Array = []
	for i in range(current_word.length()):
		letters.append(current_word[i])
	letters.shuffle()
	shuffled_letters = letters

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
	slot_labels.clear()

	for i in range(shuffled_letters.size()):
		var panel := PanelContainer.new()
		panel.custom_minimum_size = Vector2(64, 72)
		panel.add_theme_stylebox_override("panel", _slot_style_empty)

		var lbl := Label.new()
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 36)
		lbl.text = ""

		panel.add_child(lbl)
		answer_row.add_child(panel)
		slot_labels.append({"panel": panel, "label": lbl})

	_refresh_slots()


func _on_tile_pressed(tile_index: int) -> void:
	if tile_buttons[tile_index].disabled:
		return
	if answer_letters.size() >= shuffled_letters.size():
		return

	answer_letters.append(tile_index)
	tile_buttons[tile_index].disabled = true
	_refresh_slots()
	btn_validate.disabled = answer_letters.size() != shuffled_letters.size()


func _refresh_slots() -> void:
	for i in range(slot_labels.size()):
		var entry: Dictionary = slot_labels[i]
		var lbl: Label = entry["label"]
		var panel: PanelContainer = entry["panel"]
		if i < answer_letters.size():
			lbl.text = shuffled_letters[answer_letters[i]]
			panel.add_theme_stylebox_override("panel", _slot_style_filled)
			lbl.add_theme_color_override("font_color", Color(1, 1, 1))
		else:
			lbl.text = ""
			panel.add_theme_stylebox_override("panel", _slot_style_empty)


func _on_clear_pressed() -> void:
	for btn in tile_buttons:
		btn.disabled = false
	answer_letters.clear()
	_refresh_slots()
	btn_validate.disabled = true
	feedback_label.text = ""


func _on_validate_pressed() -> void:
	var built := ""
	for idx in answer_letters:
		built += String(shuffled_letters[idx])

	if built == current_word:
		_on_success()
	else:
		_on_failure()


func _on_success() -> void:
	feedback_label.text = Loc.t("level_success_message")
	_pulse_feedback()
	GameData.statistics.successes = int(GameData.statistics.get("successes", 0)) + 1
	GameData.progress.current_level = int(GameData.progress.get("current_level", 1)) + 1
	SaveManager.save_game()

	await get_tree().create_timer(1.1).timeout
	_show_category_panel()


func _on_failure() -> void:
	feedback_label.text = Loc.t("level_failure_message")
	_pulse_feedback()
	GameData.statistics.failures = int(GameData.statistics.get("failures", 0)) + 1

	for btn in tile_buttons:
		btn.disabled = false
	answer_letters.clear()
	_refresh_slots()
	btn_validate.disabled = true


func _on_back_pressed() -> void:
	SceneRouter.go_to("home")
