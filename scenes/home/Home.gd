extends Control
## Home
## Écran d'accueil dynamisé, inspiré d'une référence fournie par
## l'utilisateur (adaptée : aucune mécanique de monétisation/défis —
## seulement ce qui sert vraiment le jeu). Fond blanc cassé, contenu
## dans notre palette, carte "message secret" reliée à la progression
## du chapitre, navigation basse persistante.

@onready var background: Panel = $Background

@onready var welcome_panel: VBoxContainer = %WelcomePanel
@onready var body_label: Label = %BodyLabel
@onready var question_label: Label = %QuestionLabel
@onready var btn_start: Button = %BtnStart

@onready var menu_margin: MarginContainer = %MenuMargin
@onready var avatar_label: Label = %AvatarLabel
@onready var greeting_label: Label = %GreetingLabel
@onready var secret_title: Label = %SecretTitle
@onready var secret_subtitle: Label = %SecretSubtitle
@onready var secret_bar: ProgressBar = %SecretBar
@onready var btn_continue: Button = %BtnContinue

@onready var btn_nav_home: Button = %BtnNavHome
@onready var nav_home_label: Label = %NavHomeLabel
@onready var btn_journey: Button = %BtnJourney
@onready var journey_label: Label = %JourneyLabel
@onready var btn_rewards: Button = %BtnRewards
@onready var rewards_label: Label = %RewardsLabel
@onready var btn_settings_nav: Button = %BtnSettingsNav
@onready var settings_label: Label = %SettingsLabel


func _ready() -> void:
	_style_background()
	_style_cards()
	_wire_click_sounds()

	if GameData.profile.get("welcome_seen", false):
		_show_menu()
	else:
		_show_welcome()


func _style_background() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.965, 0.958, 0.948)
	background.add_theme_stylebox_override("panel", style)
	Decor.add_blobs(self)
	Decor.add_sparkles(self, 10)


func _style_cards() -> void:
	# Badge avatar : initiale du prénom, cercle coloré.
	var avatar_style := StyleBoxFlat.new()
	avatar_style.bg_color = Color(0.906, 0.573, 0.573, 1)
	avatar_style.set_corner_radius_all(32)
	%AvatarBadge.add_theme_stylebox_override("panel", avatar_style)
	avatar_label.add_theme_color_override("font_color", Color(1, 1, 1))

	# Carte "message secret"
	var secret_style := StyleBoxFlat.new()
	secret_style.bg_color = Color(1, 0.984, 0.973, 1)
	secret_style.set_corner_radius_all(28)
	secret_style.shadow_color = Color(0.545, 0.271, 0.361, 0.1)
	secret_style.shadow_size = 10
	secret_style.shadow_offset = Vector2(0, 4)
	secret_style.border_width_left = 2
	secret_style.border_width_top = 2
	secret_style.border_width_right = 2
	secret_style.border_width_bottom = 2
	secret_style.border_color = Color(0.941, 0.859, 0.831, 1)
	%SecretCard.add_theme_stylebox_override("panel", secret_style)

	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.941, 0.859, 0.831, 0.7)
	bar_bg.set_corner_radius_all(8)
	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = Color(0.85, 0.62, 0.35, 1)
	bar_fill.set_corner_radius_all(8)
	secret_bar.add_theme_stylebox_override("background", bar_bg)
	secret_bar.add_theme_stylebox_override("fill", bar_fill)

	# Barre de navigation basse
	var nav_style := StyleBoxFlat.new()
	nav_style.bg_color = Color(1, 0.984, 0.973, 1)
	nav_style.set_corner_radius_all(30)
	nav_style.shadow_color = Color(0.545, 0.271, 0.361, 0.1)
	nav_style.shadow_size = 8
	nav_style.shadow_offset = Vector2(0, -2)
	%BottomNav.add_theme_stylebox_override("panel", nav_style)

	for btn in [btn_nav_home, btn_journey, btn_rewards, btn_settings_nav]:
		btn.flat = true
		btn.add_theme_font_size_override("font_size", 32)


func _wire_click_sounds() -> void:
	for btn in [btn_start, btn_continue, btn_nav_home, btn_journey, btn_rewards, btn_settings_nav]:
		btn.pressed.connect(Audio.play_click)


func _show_welcome() -> void:
	welcome_panel.visible = true
	menu_margin.visible = false

	body_label.text = Loc.t("home_welcome_body", {"player_name": GameData.profile.player_name})
	question_label.text = Loc.t_gendered("home_welcome_question")
	btn_start.text = Loc.t("home_welcome_button_start")
	Decor.pulse(btn_start)


func _show_menu() -> void:
	welcome_panel.visible = false
	menu_margin.visible = true

	var player_name: String = GameData.profile.get("player_name", "")
	avatar_label.text = player_name.substr(0, 1).to_upper() if player_name.length() > 0 else "?"
	greeting_label.text = Loc.t("menu_greeting", {"player_name": player_name})

	nav_home_label.text = Loc.t("nav_home_short")
	journey_label.text = Loc.t("menu_journey_short")
	rewards_label.text = Loc.t("menu_rewards_short")
	settings_label.text = Loc.t("nav_settings_short")

	btn_continue.text = Loc.t("menu_continue")
	Decor.pulse(btn_continue)

	var level: int = int(GameData.progress.get("current_level", 1))
	var chapter: int = int(GameData.progress.get("current_chapter", 1))
	secret_title.text = Loc.t("home_secret_title")
	secret_subtitle.text = Loc.t("home_secret_subtitle", {"chapter": chapter, "level": level})
	secret_bar.max_value = 10
	secret_bar.value = level - 1


func _on_start_pressed() -> void:
	GameData.profile.welcome_seen = true
	SaveManager.save_game()
	_show_menu()


func _on_continue_pressed() -> void:
	SceneRouter.go_to("level")


func _on_journey_pressed() -> void:
	SceneRouter.go_to("journey")


func _on_rewards_pressed() -> void:
	SceneRouter.go_to("rewards")


func _on_settings_pressed() -> void:
	SceneRouter.go_to("settings")
