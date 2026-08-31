extends Control
## Home
## Affiche l'animation de bienvenue (§8) une seule fois après l'onboarding,
## puis le menu principal (§35) à chaque ouverture suivante.

@onready var welcome_panel: VBoxContainer = %WelcomePanel
@onready var body_label: Label = %BodyLabel
@onready var question_label: Label = %QuestionLabel
@onready var btn_start: Button = %BtnStart

@onready var menu_panel: VBoxContainer = %MenuPanel
@onready var btn_continue: Button = %BtnContinue
@onready var btn_journey: Button = %BtnJourney
@onready var btn_rewards: Button = %BtnRewards
@onready var btn_settings: Button = %BtnSettings


func _ready() -> void:
	_refresh_menu_texts()

	if GameData.profile.get("welcome_seen", false):
		_show_menu()
	else:
		_show_welcome()


func _show_welcome() -> void:
	welcome_panel.visible = true
	menu_panel.visible = false

	body_label.text = Loc.t("home_welcome_body", {"player_name": GameData.profile.player_name})
	question_label.text = Loc.t_gendered("home_welcome_question")
	btn_start.text = Loc.t("home_welcome_button_start")


func _show_menu() -> void:
	welcome_panel.visible = false
	menu_panel.visible = true


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
	# TODO : écran "Mon parcours" (§35) — chapitres terminés, statistiques.
	pass


func _on_rewards_pressed() -> void:
	# TODO : écran "Mes récompenses" (§35) — relire les messages débloqués.
	pass


func _on_settings_pressed() -> void:
	SceneRouter.go_to("settings")
