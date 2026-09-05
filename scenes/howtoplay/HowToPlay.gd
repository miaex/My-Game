extends Control
## HowToPlay
## Explique les mécaniques de base (choix de catégorie, anagramme,
## suppression d'une lettre, indice) SANS dévoiler ce qui vient après
## un chapitre — le mystère de la récompense doit rester entier.

@onready var background: Panel = $Background
@onready var title_label: Label = %TitleLabel
@onready var steps_box: VBoxContainer = %StepsBox
@onready var btn_back: Button = %BtnBack


func _ready() -> void:
	Audio.play_music("menu")

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.965, 0.958, 0.948)
	background.add_theme_stylebox_override("panel", style)
	Decor.add_sparkles(self)

	title_label.text = Loc.t("howto_title")
	btn_back.text = Loc.t("level_back_to_home")

	var step_keys := ["howto_step_1", "howto_step_2", "howto_step_3", "howto_step_4", "howto_step_5"]
	for key in step_keys:
		_add_step_card(Loc.t(key))


func _add_step_card(text: String) -> void:
	var card := PanelContainer.new()
	card.size_flags_horizontal = SIZE_EXPAND_FILL
	var lbl := Label.new()
	lbl.text = text
	lbl.size_flags_horizontal = SIZE_EXPAND_FILL
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 32)
	card.add_child(lbl)
	steps_box.add_child(card)


func _on_back_pressed() -> void:
	SceneRouter.go_to("settings")
