extends Control
## Boot
## Donne un rôle à l'écran de démarrage (au lieu d'un flash gris vide) :
## une vraie barre de progression 0→100%, puis redirection vers
## l'onboarding ou l'accueil selon si le joueur a déjà une sauvegarde.
##
## Note honnête : le projet est petit et se charge en réalité quasi
## instantanément, donc cette progression est en partie "mise en scène"
## (durée fixe courte) plutôt qu'un vrai suivi de chargement de gros
## fichiers — il n'y a rien de lourd à charger ici. Le but est de
## remplacer un flash brut par une transition intentionnelle, en moins
## de 2 secondes, bien en dessous des 5-6 secondes maximum demandées.

@onready var background: Panel = $Background
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var percent_label: Label = %PercentLabel

const BOOT_DURATION := 1.4


func _ready() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.965, 0.958, 0.948)
	background.add_theme_stylebox_override("panel", style)

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.941, 0.859, 0.831, 0.7)
	bg.set_corner_radius_all(11)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.906, 0.573, 0.573, 1)
	fill.set_corner_radius_all(11)
	progress_bar.add_theme_stylebox_override("background", bg)
	progress_bar.add_theme_stylebox_override("fill", fill)
	progress_bar.max_value = 100
	progress_bar.value = 0

	var tween := create_tween()
	tween.tween_method(_update_progress, 0.0, 100.0, BOOT_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished

	_go_to_next_screen()


func _update_progress(value: float) -> void:
	progress_bar.value = value
	percent_label.text = "%d%%" % int(value)


func _go_to_next_screen() -> void:
	if SaveManager.has_save() and SaveManager.load_game() and GameData.profile.get("onboarding_done", false):
		get_tree().change_scene_to_file("res://scenes/home/Home.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/onboarding/Onboarding.tscn")
