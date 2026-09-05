extends Control
## Reward
## Système complet des 100 cartes (§18-§21 du cahier des charges) :
## 10 lots de 10 cartes, un choix par lot qui révèle un fragment du
## message. Quelle que soit la carte choisie DANS un lot, le fragment
## révélé est toujours le même — l'illusion du choix (§19) — mais le
## mécanisme n'est jamais expliqué au joueur.

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
var _fragments: Array = []       # les 10 fragments du message choisi pour ce chapitre
var _current_lot: int = 0        # 0..9
var _progress_dots: Array = []

const CARD_PALETTE := [
	[Color(0.475, 0.353, 0.451), Color(0.85, 0.62, 0.35)],
	[Color(0.796, 0.478, 0.518), Color(1, 0.945, 0.925)],
	[Color(0.294, 0.204, 0.278), Color(0.85, 0.62, 0.35)],
	[Color(0.906, 0.573, 0.573), Color(0.85, 0.62, 0.35)],
	[Color(0.63, 0.5, 0.7), Color(1, 0.945, 0.925)],
]


func _ready() -> void:
	Audio.play_music("reward")
	Audio.play_reward()
	_style_background()
	_load_messages()
	_pick_fragments_for_chapter()
	_refresh_static_texts()
	_build_progress_dots()
	_start_lot(0)


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


## Détermine le ton en pondérant TOUTES les catégories jouées dans le
## chapitre, comme précédemment, mais choisit maintenant un message
## COMPLET en 10 fragments plutôt qu'un seul paragraphe.
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


func _pick_fragments_for_chapter() -> void:
	var lang: String = GameData.profile.get("language", "fr")
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

	var candidates: Array = []
	for m in _messages_data:
		if m.get("language", "") == lang and m.get("tone", "") == best_tone:
			candidates.append(m)
	if candidates.is_empty():
		for m in _messages_data:
			if m.get("language", "") == lang:
				candidates.append(m)

	if candidates.is_empty():
		_fragments = []
		for i in range(10):
			_fragments.append("...")
		return

	var chosen: Dictionary = candidates[randi() % candidates.size()]
	_fragments = chosen.get("fragments", [])
	var player_name: String = GameData.profile.get("player_name", "")
	for i in range(_fragments.size()):
		_fragments[i] = str(_fragments[i]).replace("{player_name}", player_name)


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
	_refresh_progress_dots()

	lot_label.text = Loc.t("secret_lot_label", {"current": lot_index + 1, "total": TOTAL_LOTS})
	choose_label.text = Loc.t("secret_choose_title")
	desc_label.text = Loc.t("secret_choose_desc")

	_build_card_grid()


func _build_card_grid() -> void:
	for child in card_grid.get_children():
		child.queue_free()

	var order: Array = range(CARDS_PER_LOT)
	order.shuffle()

	for i in range(CARDS_PER_LOT):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 130)
		btn.flat = true

		var icon := preload("res://scenes/shared/CardBackIcon.gd").new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		var palette: Array = CARD_PALETTE[i % CARD_PALETTE.size()]
		icon.set_pattern(order[i], palette[0], palette[1])
		btn.add_child(icon)

		btn.pressed.connect(_on_card_picked)
		card_grid.add_child(btn)


func _on_card_picked() -> void:
	Audio.play_click()
	_show_reveal()


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


func _on_reveal_next_pressed() -> void:
	Audio.play_click()
	reveal_overlay.visible = false

	var next_lot: int = _current_lot + 1
	if next_lot >= TOTAL_LOTS:
		_show_final_message()
	else:
		_start_lot(next_lot)


func _show_final_message() -> void:
	_current_lot = TOTAL_LOTS
	_refresh_progress_dots()

	var full_text: String = ""
	for i in range(_fragments.size()):
		full_text += str(_fragments[i])
		if i < _fragments.size() - 1:
			full_text += " "

	final_message_label.text = full_text
	final_overlay.visible = true
	final_overlay.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(final_overlay, "modulate:a", 1.0, 0.5)

	Audio.play_reward()


func _on_back_pressed() -> void:
	SceneRouter.go_to("home")
