extends Control
## Home
## Affiche l'animation de bienvenue (§8) une seule fois après l'onboarding,
## puis le menu principal (§35) à chaque ouverture suivante, avec un
## message de retour personnalisé.

@onready var background: Panel = $Background

@onready var welcome_panel: VBoxContainer = %WelcomePanel
@onready var body_label: Label = %BodyLabel
@onready var question_label: Label = %QuestionLabel
@onready var btn_start: Button = %BtnStart

@onready var menu_panel: VBoxContainer = %MenuPanel
@onready var greeting_label: Label = %GreetingLabel
@onready var btn_continue: Button = %BtnContinue
@onready var btn_journey: Button = %BtnJourney
@onready var btn_rewards: Button = %BtnRewards
@onready var btn_settings: Button = %BtnSettings


func _ready() -> void:
	_style_background()
	_refresh_menu_texts()

	if GameData.profile.get("welcome_seen", false):
		_show_menu()
	else:
		_show_welcome()


func _style_background() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.976, 0.925, 0.902)
	background.add_theme_stylebox_override("panel", style)
	Decor.add_sparkles(self)


func _show_welcome() -> void:
	welcome_panel.visible = true
	menu_panel.visible = false

	body_label.text = Loc.t("home_welcome_body", {"player_name": GameData.profile.player_name})
	question_label.text = Loc.t_gendered("home_welcome_question")
	btn_start.text = Loc.t("home_welcome_button_start")
	Decor.pulse(btn_start)


func _show_menu() -> void:
	welcome_panel.visible = false
	menu_panel.visible = true
	greeting_label.text = Loc.t("menu_greeting", {"player_name": GameData.profile.player_name})


func _refresh_menu_texts() -> void:
	btn_continue.text = Loc.t("menu_continue")
	btn_journey.text = Loc.t("menu_journey")
	btn_rewards.text = Loc.t("menu_rewards")
	btn_settings.text = Loc.t("menu_settings")


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
