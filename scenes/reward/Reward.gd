extends Control
## Reward
## Version enrichie de l'écran de récompense (§17, §22-§23).
## Le système complet des 100 cartes (§18-§21) reste prévu pour une étape
## dédiée ; ici, un vrai choix de ton parmi 6 profils émotionnels, avec
## plusieurs variantes chacun pour éviter les répétitions, déterminé par
## TOUTES les catégories jouées durant le chapitre (pas juste 2 groupes).

@onready var background: Panel = $Background
@onready var title_label: Label = %TitleLabel
@onready var message_label: Label = %MessageLabel
@onready var btn_continue: Button = %BtnContinue

## Poids de chaque catégorie vers chaque ton (voir §22 : les tons possibles
## sont affectueux, motivant/admiratif, taquin/joueur, réconfortant,
## mystérieux, chaleureux).
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
	style.bg_color = Color(0.965, 0.958, 0.948)
	background.add_theme_stylebox_override("panel", style)
	Decor.add_sparkles(self)


## Détermine le ton en pondérant TOUTES les catégories jouées dans le
## chapitre (pas seulement le top 3), puis choisit une variante de ce
## ton sans répéter immédiatement la précédente.
func _build_message() -> String:
	var player_name: String = GameData.profile.get("player_name", "")
	var scores: Dictionary = {}
	for t in TONES:
		scores[t] = 0

	for cat_id in GameData.category_choice_history:
		if CATEGORY_TONE_WEIGHTS.has(cat_id):
			var weights: Dictionary = CATEGORY_TONE_WEIGHTS[cat_id]
			for tone in weights.keys():
				scores[tone] += weights[tone]

	var best_tone: String = "affectionate"
	var best_score: int = -1
	for t in TONES:
		if scores[t] > best_score:
			best_score = scores[t]
			best_tone = t

	var variant_count: int = int(Loc.t("reward_variant_count_%s" % best_tone))
	if variant_count <= 0:
		variant_count = 1

	var last_variant: int = int(GameData.progress.get("last_reward_variant_%s" % best_tone, -1))
	var variant: int = randi() % variant_count
	if variant_count > 1:
		while variant == last_variant:
			variant = randi() % variant_count
	GameData.progress["last_reward_variant_%s" % best_tone] = variant
	SaveManager.save_game()

	return Loc.t("reward_message_%s_%d" % [best_tone, variant], {"player_name": player_name})


func _on_continue_pressed() -> void:
	SceneRouter.go_to("home")
