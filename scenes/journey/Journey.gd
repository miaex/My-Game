extends Control
## Journey ("Mon parcours", §35) : progression, statistiques simples.

@onready var background: Panel = $Background
@onready var title_label: Label = %TitleLabel
@onready var stats_label: Label = %StatsLabel
@onready var btn_back: Button = %BtnBack


func _ready() -> void:
	Audio.play_music("menu")
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.976, 0.925, 0.902)
	background.add_theme_stylebox_override("panel", style)

	title_label.text = Loc.t("journey_title")
	btn_back.text = Loc.t("level_back_to_home")

	var chapter: int = int(GameData.progress.get("current_chapter", 1))
	var level: int = int(GameData.progress.get("current_level", 1))
	var successes: int = int(GameData.statistics.get("successes", 0))
	var failures: int = int(GameData.statistics.get("failures", 0))
	var rewards_count: int = GameData.progress.get("unlocked_rewards", []).size()

	stats_label.text = Loc.t("journey_stats", {
		"chapter": chapter,
		"level": level,
		"successes": successes,
		"failures": failures,
		"rewards_count": rewards_count,
	})


func _on_back_pressed() -> void:
	SceneRouter.go_to("home")
