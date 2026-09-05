extends Control
## Reward
## Système complet des 100 cartes (§18-§21 du cahier des charges, précisé
## par la spécification UI dédiée) : 10 lots de 10 cartes, un choix par
## lot qui révèle un fragment. Quelle que soit la carte choisie DANS un
## lot, le fragment révélé est toujours le même — l'illusion du choix —
## mais le mécanisme n'est jamais expliqué au joueur.
##
## La progression (lot en cours + fragments déjà révélés) est sauvegardée
## localement : fermer l'application en plein milieu reprend exactement
## où le joueur s'était arrêté.

const MESSAGES_PATH := "res://data/rewards/messages.json"
const CARDS_PER_LOT := 10
const TOTAL_LOTS := 10

@onready var background: Panel = $Background

@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var progress_row: HBoxContainer = %ProgressRow
@onready var lot_label: Label = %LotLabel
@onready var choose_label: Label = %ChooseLabel
@onready var desc_label: Label = %DescLabel
@onready var select_label: Label = %SelectLabel
@onready var card_grid: GridContainer = %CardGrid
@onready var tip_label: Label = %TipLabel

@onready var reveal_overlay: Control = %RevealOverlay
@onready var reveal_fragment_label: Label = %RevealFragmentLabel
@onready var reveal_text_label: Label = %RevealTextLabel
@onready var btn_next: Button = %BtnNext

@onready var final_overlay: Control = %FinalOverlay
@onready var final_title: Label = %FinalTitle
@onready var final_message_label: Label = %FinalMessageLabel
@onready var btn_final_continue: Button = %BtnFinalContinue

var _messages_data: Array = []
var _fragments: Array = []
var _current_lot: int = 0
var _progress_dots: Array = []
var _card_buttons: Array = []
var _selection_locked: bool = false

const CARD_PALETTE := [
	[Color(0.475, 0.353, 0.451), Color(0.85, 0.62, 0.35)],
	[Color(0.796, 0.478, 0.518), Color(1, 0.945, 0.925)],
	[Color(0.294, 0.204, 0.278), Color(0.85, 0.62, 0.35)],
	[Color(0.906, 0.573, 0.573), Color(0.85, 0.62, 0.35)],
	[Color(0.63, 0.5, 0.7), Color(1, 0.945, 0.925)],
]

const CATEGORY_TONE_WEIGHTS := {
	"relations":    {"affectionate": 2, "warm": 1},
	"compliments":  {"affectionate": 2, "admiring": 1},
	"emotions":     {"comforting": 2, "warm": 1},
	"quotidien":    {"warm": 2, "comforting": 1},
	"esprit":       {"admiring": 2, "mysterious": 1},
	"aventure":     {"mysterious": 1, "admiring": 2},
	"mystere":      {"mysterious": 2, "playful": 1},
	"fun":          {"playful": 2},
	"audace":       {"playful": 1, "admiring": 2},
	"personnalite": {"admiring": 2, "affectionate": 1},
}
const TONES := ["affectionate", "admiring", "playful", "comforting", "mysterious", "warm"]


func _ready() -> void:
	Audio.play_music("reward")
	_style_background()
	_load_messages()
	_refresh_static_texts()
	_build_progress_dots()
	_resume_or_start()


func _style_background() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.965, 0.958, 0.948)
	background.add_theme_stylebox_override("panel", style)
	Decor.add_sparkles(self, 8)


func _load_messages() -> void:
	if not FileAccess.file_exists(MESSAGES_PATH):
		return
	var text: String = FileAccess.get_file_as_string(MESSAGES_PATH)
	var parsed = JSON.parse_string(text)
	if parsed is Array:
		_messages_data = parsed


# ---------------------------------------------------------------------------
# REPRISE / DÉMARRAGE — sauvegarde robuste (reward_active, reward_lot,
# reward_fragments, reward_tone, reward_completed)
# ---------------------------------------------------------------------------

func _resume_or_start() -> void:
	var active: bool = GameData.progress.get("reward_active", false)
	var completed: bool = GameData.progress.get("reward_completed", false)

	if active and not completed:
		var tone: String = GameData.progress.get("reward_tone", "")
		_fragments = _fragments_for_tone(tone)
		var saved_fragments: Array = GameData.progress.get("reward_fragments", [])
		_current_lot = saved_fragments.size()
		if _current_lot >= TOTAL_LOTS:
			_show_assembly_sequence()
			return
		_start_lot(_current_lot)
	else:
		_pick_fragments_for_chapter()
		GameData.progress["reward_active"] = true
		GameData.progress["reward_completed"] = false
		GameData.progress["reward_fragments"] = []
		SaveManager.save_game()
		_start_lot(0)


func _pick_fragments_for_chapter() -> void:
	var scores: Dictionary = {}
	for t in TONES:
		scores[t] = 0
	for cat_id in GameData.category_choice_history:
		if CATEGORY_TONE_WEIGHTS.has(cat_id):
			for tone in CATEGORY_TONE_WEIGHTS[cat_id].keys():
				scores[tone] += CATEGORY_TONE_WEIGHTS[cat_id][tone]

	var best_tone: String = "affectionate"
	var best_score: int = -1
	for t in TONES:
		if scores[t] > best_score:
			best_score = scores[t]
			best_tone = t

	GameData.progress["reward_tone"] = best_tone
	_fragments = _fragments_for_tone(best_tone)


func _fragments_for_tone(tone: String) -> Array:
	var lang: String = GameData.profile.get("language", "fr")
	var candidates: Array = []
	for m in _messages_data:
		if m.get("language", "") == lang and m.get("tone", "") == tone:
			candidates.append(m)
	if candidates.is_empty():
		for m in _messages_data:
			if m.get("language", "") == lang:
				candidates.append(m)
	if candidates.is_empty():
		var empty: Array = []
		for i in range(10):
			empty.append("...")
		return empty

	var chosen: Dictionary = candidates[randi() % candidates.size()]
	var fragments: Array = chosen.get("fragments", []).duplicate()
	var player_name: String = GameData.profile.get("player_name", "")
	for i in range(fragments.size()):
		fragments[i] = str(fragments[i]).replace("{player_name}", player_name)
	return fragments


func _refresh_static_texts() -> void:
	title_label.text = Loc.t("secret_title")
	subtitle_label.text = Loc.t("secret_subtitle")
	select_label.text = Loc.t("secret_select_label")
	tip_label.text = Loc.t("secret_tip")
	btn_next.text = Loc.t("secret_continue")
	final_title.text = Loc.t("secret_final_title")
	btn_final_continue.text = Loc.t("reward_continue")


func _build_progress_dots() -> void:
	for child in progress_row.get_children():
		child.queue_free()
	_progress_dots.clear()

	for i in range(TOTAL_LOTS):
		var dot := PanelContainer.new()
		dot.custom_minimum_size = Vector2(56, 56)
		var lbl := Label.new()
		lbl.text = str(i + 1)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 22)
		dot.add_child(lbl)
		progress_row.add_child(dot)
		_progress_dots.append({"panel": dot, "label": lbl})

	_refresh_progress_dots()


func _refresh_progress_dots() -> void:
	for i in range(_progress_dots.size()):
		var entry: Dictionary = _progress_dots[i]
		var panel: PanelContainer = entry["panel"]
		var style := StyleBoxFlat.new()
		style.set_corner_radius_all(28)
		if i < _current_lot:
			style.bg_color = Color(0.85, 0.62, 0.35, 1)
			entry["label"].add_theme_color_override("font_color", Color(1, 1, 1))
		elif i == _current_lot:
			style.bg_color = Color(0.906, 0.573, 0.573, 1)
			entry["label"].add_theme_color_override("font_color", Color(1, 1, 1))
		else:
			style.bg_color = Color(0.941, 0.859, 0.831, 0.6)
			entry["label"].add_theme_color_override("font_color", Color(0.294, 0.204, 0.278))
		panel.add_theme_stylebox_override("panel", style)


func _start_lot(lot_index: int) -> void:
	_current_lot = lot_index
	_selection_locked = false
	_refresh_progress_dots()

	lot_label.text = Loc.t("secret_lot_label", {"current": lot_index + 1, "total": TOTAL_LOTS})
	choose_label.text = Loc.t("secret_choose_title")
	desc_label.text = Loc.t("secret_choose_desc")

	_build_card_grid()


func _build_card_grid() -> void:
	for child in card_grid.get_children():
		child.queue_free()
	_card_buttons.clear()

	var order: Array = range(CARDS_PER_LOT)
	order.shuffle()

	for i in range(CARDS_PER_LOT):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 130)
		btn.flat = true
		btn.pivot_offset = Vector2(btn.custom_minimum_size.x / 2.0, btn.custom_minimum_size.y / 2.0)

		var icon := preload("res://scenes/shared/CardBackIcon.gd").new()
		icon.name = "Icon"
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		var palette: Array = CARD_PALETTE[i % CARD_PALETTE.size()]
		icon.set_pattern(order[i], palette[0], palette[1])
		btn.add_child(icon)

		btn.pressed.connect(_on_card_picked.bind(btn))
		card_grid.add_child(btn)
		_card_buttons.append(btn)


# ---------------------------------------------------------------------------
# SÉLECTION — verrouillage des autres cartes + retournement (§ spec UI)
# ---------------------------------------------------------------------------

func _on_card_picked(picked_btn: Button) -> void:
	if _selection_locked:
		return
	_selection_locked = true
	Audio.play_click()

	for btn in _card_buttons:
		if btn != picked_btn:
			btn.disabled = true
			var tween := btn.create_tween()
			tween.tween_property(btn, "modulate:a", 0.35, 0.2)

	var highlight := picked_btn.create_tween()
	highlight.tween_property(picked_btn, "scale", Vector2(1.08, 1.08), 0.15).set_trans(Tween.TRANS_BACK)
	await highlight.finished

	await _flip_card(picked_btn)
	_show_reveal()


## Petite animation de retournement en 2D : on écrase la carte à plat
## sur l'axe horizontal, puis on la ré-étire — l'illusion d'un vrai
## retournement de carte physique.
func _flip_card(btn: Button) -> void:
	var tween := btn.create_tween()
	tween.tween_property(btn, "scale:x", 0.0, 0.14).set_trans(Tween.TRANS_SINE)
	await tween.finished

	var icon: Control = btn.get_node("Icon")
	icon.set_pattern(99, Color(0.85, 0.62, 0.35), Color(1, 1, 1))

	var tween2 := btn.create_tween()
	tween2.tween_property(btn, "scale:x", 1.08, 0.16).set_trans(Tween.TRANS_SINE)
	await tween2.finished


func _show_reveal() -> void:
	var fragment_text: String = ""
	if _current_lot < _fragments.size():
		fragment_text = str(_fragments[_current_lot])

	reveal_fragment_label.text = Loc.t("secret_fragment_label", {"current": _current_lot + 1, "total": TOTAL_LOTS})
	reveal_text_label.text = fragment_text

	reveal_overlay.visible = true
	reveal_overlay.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(reveal_overlay, "modulate:a", 1.0, 0.3)

	Audio.play_success()

	# Sauvegarde immédiate du fragment obtenu (§ sauvegarde robuste).
	var saved_fragments: Array = GameData.progress.get("reward_fragments", [])
	saved_fragments.append(fragment_text)
	GameData.progress["reward_fragments"] = saved_fragments
	SaveManager.save_game()


func _on_reveal_next_pressed() -> void:
	Audio.play_click()
	reveal_overlay.visible = false

	var next_lot: int = _current_lot + 1
	if next_lot >= TOTAL_LOTS:
		_show_assembly_sequence()
	else:
		_start_lot(next_lot)


# ---------------------------------------------------------------------------
# ASSEMBLAGE + MESSAGE FINAL
# ---------------------------------------------------------------------------

func _show_assembly_sequence() -> void:
	_current_lot = TOTAL_LOTS
	_refresh_progress_dots()

	final_overlay.visible = true
	final_overlay.modulate.a = 0.0
	final_message_label.text = Loc.t("secret_assembling")
	btn_final_continue.visible = false

	var tween := create_tween()
	tween.tween_property(final_overlay, "modulate:a", 1.0, 0.4)
	await tween.finished

	await get_tree().create_timer(1.0).timeout
	_show_final_message()


func _show_final_message() -> void:
	var full_text: String = ""
	for i in range(_fragments.size()):
		full_text += str(_fragments[i])
		if i < _fragments.size() - 1:
			full_text += " "

	final_message_label.text = ""
	btn_final_continue.visible = true

	var tween := create_tween()
	tween.tween_method(func(t: float):
		var count: int = int(full_text.length() * t)
		final_message_label.text = full_text.substr(0, count)
	, 0.0, 1.0, 0.9)

	Audio.play_reward()

	GameData.progress["reward_active"] = false
	GameData.progress["reward_completed"] = true
	SaveManager.save_game()


func _on_back_pressed() -> void:
	SceneRouter.go_to("home")
