extends HBoxContainer
## LogoHeader
## Petit logo "JieePlay" en haut des écrans : chaque lettre dans une
## couleur différente de la palette, avec une apparition lettre par
## lettre rapide à l'ouverture de l'application (§ demande utilisateur).

const WORD := "JieePlay"
const COLORS := [
	Color(0.796, 0.478, 0.518),
	Color(0.475, 0.353, 0.451),
	Color(0.906, 0.573, 0.573),
	Color(0.63, 0.5, 0.7),
	Color(0.85, 0.62, 0.35),
	Color(0.796, 0.478, 0.518),
	Color(0.475, 0.353, 0.451),
	Color(0.906, 0.573, 0.573),
]

## Passe à true après la toute première apparition, pour ne jouer
## l'animation lettre par lettre qu'une seule fois par lancement de l'app.
static var has_played_intro: bool = false


func _ready() -> void:
	custom_minimum_size = Vector2(0, 70)
	_build_letters()
	if not has_played_intro:
		has_played_intro = true
		_play_intro()


func _build_letters() -> void:
	for i in range(WORD.length()):
		var lbl := Label.new()
		lbl.text = WORD[i]
		lbl.add_theme_font_size_override("font_size", 50)
		lbl.add_theme_color_override("font_color", COLORS[i % COLORS.size()])
		add_child(lbl)


## Anime les lettres une par une, rapidement (voir demande : "apparaît
## lettre après lettre de façon rapide").
func _play_intro() -> void:
	for child in get_children():
		child.modulate.a = 0.0
		child.scale = Vector2(0.3, 0.3)
		child.pivot_offset = Vector2(child.size.x / 2.0, child.size.y / 2.0)

	var delay := 0.0
	for child in get_children():
		var tween := create_tween()
		tween.tween_interval(delay)
		tween.tween_property(child, "modulate:a", 1.0, 0.12)
		tween.parallel().tween_property(child, "scale", Vector2(1.0, 1.0), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		delay += 0.045
