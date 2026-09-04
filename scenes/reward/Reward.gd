extends Control
## Reward
## Version simple de l'écran de récompense (§17, §22).
## Le système complet des 100 cartes (§18-§21) est prévu pour une étape
## dédiée ultérieure ; pour l'instant, message personnalisé unique selon
## les catégories préférées du joueur, pour clore le chapitre.

@onready var background: Panel = $Background
@onready var title_label: Label = %TitleLabel
@onready var message_label: Label = %MessageLabel
@onready var btn_continue: Button = %BtnContinue


func _ready() -> void:
	Audio.play_music("reward")
	Audio.play_reward()
	_style_background()

	var chapter_completed: int = int(GameData.progress.get("current_chapter", 2)) - 1
	title_label.text = Loc.t("reward_title", {"chapter": chapter_completed})
	message_label.text = _build_message()
	btn_continue.text = Loc.t("reward_continue")
	Decor.pulse(btn_continue)

	title_label.modulate.a = 0.0
	message_label.get_parent().modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 0.4)
	tween.parallel().tween_property(message_label.get_parent(), "modulate:a", 1.0, 0.6).set_delay(0.2)


func _style_background() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.976, 0.925, 0.902)
	background.add_theme_stylebox_override("panel", style)
	Decor.add_sparkles(self)


## Choisit un ton de message selon les catégories les plus jouées
## par le joueur dans ce chapitre (voir §22 du cahier des charges).
func _build_message() -> String:
	var player_name: String = GameData.profile.get("player_name", "")
	var top_categories: Array = GameData.get_top_categories(3)

	var affectionate_cats := ["relations", "compliments", "emotions"]
	var playful_cats := ["mystere", "fun", "audace"]

	var affectionate_score := 0
	var playful_score := 0
	for cat_id in top_categories:
		if affectionate_cats.has(cat_id):
			affectionate_score += 1
		if playful_cats.has(cat_id):
			playful_score += 1

	var tone := "affectionate"
	if playful_score > affectionate_score:
		tone = "playful"

	return Loc.t("reward_message_%s" % tone, {"player_name": player_name})


func _on_continue_pressed() -> void:
	SceneRouter.go_to("home")
