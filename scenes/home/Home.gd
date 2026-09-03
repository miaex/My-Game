extends Control
## Home
## Affiche l'animation de bienvenue (§8) une seule fois après l'onboarding,
## puis le menu principal (§35) à chaque ouverture suivante, avec un
## message de retour personnalisé, une barre de progression du chapitre
## en cours, et un bouton d'action principal mis en avant.

@onready var background: Panel = $Background
@onready var btn_settings_top: Button = %BtnSettingsTop

@onready var welcome_panel: VBoxContainer = %WelcomePanel
@onready var body_label: Label = %BodyLabel
@onready var question_label: Label = %QuestionLabel
@onready var btn_start: Button = %BtnStart

@onready var menu_panel: VBoxContainer = %MenuPanel
@onready var greeting_label: Label = %GreetingLabel
@onready var progress_label: Label = %ProgressLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var btn_continue: Button = %BtnContinue
@onready var btn_journey: Button = %BtnJourney
@onready var journey_label: Label = %JourneyLabel
@onready var btn_rewards: Button = %BtnRewards
@onready var rewards_label: Label = %RewardsLabel


func _ready() -> void:
	_style_background()
	_style_icon_buttons()
	_style_progress_bar()
	_wire_click_sounds()

	if GameData.profile.get("welcome_seen", false):
		_show_menu()
	else:
		_show_welcome()


func _style_background() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.976, 0.925, 0.902)
	background.add_theme_stylebox_override("panel", style)
	Decor.add_sparkles(self)

	var gear_style := StyleBoxFlat.new()
	gear_style.bg_color = Color(1, 0.984, 0.973, 0.9)
	gear_style.set_corner_radius_all(30)
	gear_style.border_width_left = 2
	gear_style.border_width_top = 2
	gear_style.border_width_right = 2
	gear_style.border_width_bottom = 2
	gear_style.border_color = Color(0.941, 0.859, 0.831, 1)
	btn_settings_top.add_theme_stylebox_override("normal", gear_style)
	btn_settings_top.add_theme_stylebox_override("hover", gear_style)
	btn_settings_top.add_theme_color_override("font_color", Color(0.475, 0.353, 0.451))
	btn_settings_top.add_theme_font_size_override("font_size", 30)


func _style_icon_buttons() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 0.984, 0.973, 1)
	style.set_corner_radius_all(48)
	style.shadow_color = Color(0.545, 0.271, 0.361, 0.12)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 3)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.941, 0.859, 0.831, 1)

	for btn in [btn_journey, btn_rewards]:
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_font_size_override("font_size", 40)


func _style_progress_bar() -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.941, 0.859, 0.831, 0.7)
	bg.set_corner_radius_all(9)

	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.906, 0.573, 0.573, 1)
	fill.set_corner_radius_all(9)

	progress_bar.add_theme_stylebox_override("background", bg)
	progress_bar.add_theme_stylebox_override("fill", fill)


func _wire_click_sounds() -> void:
	for btn in [btn_settings_top, btn_start, btn_continue, btn_journey, btn_rewards]:
		btn.pressed.connect(Audio.play_click)


func _show_welcome() -> void:
	welcome_panel.visible = true
	menu_panel.visible = false
	btn_settings_top.visible = false

	body_label.text = Loc.t("home_welcome_body", {"player_name": GameData.profile.player_name})
	question_label.text = Loc.t_gendered("home_welcome_question")
	btn_start.text = Loc.t("home_welcome_button_start")
	Decor.pulse(btn_start)


func _show_menu() -> void:
	welcome_panel.visible = false
	menu_panel.visible = true
	btn_settings_top.visible = true

	greeting_label.text = Loc.t("menu_greeting", {"player_name": GameData.profile.player_name})
	journey_label.text = Loc.t("menu_journey_short")
	rewards_label.text = Loc.t("menu_rewards_short")
	btn_continue.text = Loc.t("menu_continue")
	Decor.pulse(btn_continue)

	var level: int = int(GameData.progress.get("current_level", 1))
	var chapter: int = int(GameData.progress.get("current_chapter", 1))
	progress_label.text = Loc.t("home_progress_label", {"chapter": chapter, "level": level})
	progress_bar.max_value = 10
	progress_bar.value = level - 1


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
