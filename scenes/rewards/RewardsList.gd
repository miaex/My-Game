extends Control
## RewardsList ("Mes récompenses", §35) : liste des chapitres débloqués.

@onready var background: Panel = $Background
@onready var title_label: Label = %TitleLabel
@onready var empty_label: Label = %EmptyLabel
@onready var list_box: VBoxContainer = %ListBox
@onready var btn_back: Button = %BtnBack


func _ready() -> void:
	Audio.play_music("menu")
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.965, 0.958, 0.948)
	background.add_theme_stylebox_override("panel", style)

	title_label.text = Loc.t("rewards_title")
	btn_back.text = Loc.t("level_back_to_home")

	var unlocked: Array = GameData.progress.get("unlocked_rewards", [])
	empty_label.visible = unlocked.is_empty()
	empty_label.text = Loc.t("rewards_empty")

	for chapter in unlocked:
		var card := PanelContainer.new()
		var lbl := Label.new()
		lbl.text = Loc.t("rewards_entry", {"chapter": chapter})
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card.add_child(lbl)
		list_box.add_child(card)


func _on_back_pressed() -> void:
	SceneRouter.go_to("home")
