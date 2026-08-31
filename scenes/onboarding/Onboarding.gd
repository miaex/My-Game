extends Control
## Onboarding
## Séquence de première ouverture (cahier des charges §5-§8) :
##   1. Langue
##   2. Genre
##   3. Prénom / surnom
## Puis redirection vers l'écran d'accueil personnalisé.

@onready var step_language: VBoxContainer = %StepLanguage
@onready var step_gender: VBoxContainer = %StepGender
@onready var step_name: VBoxContainer = %StepName

@onready var gender_title: Label = %StepGender/TitleLabel
@onready var gender_subtitle: Label = %StepGender/SubtitleLabel
@onready var btn_female: Button = %BtnFemale
@onready var btn_male: Button = %BtnMale

@onready var name_title: Label = %StepName/TitleLabel
@onready var name_edit: LineEdit = %NameEdit
@onready var name_hint: Label = %HintLabel
@onready var btn_continue: Button = %BtnContinue


func _ready() -> void:
	# Si l'onboarding a déjà été fait, on saute directement à l'accueil.
	if SaveManager.has_save() and SaveManager.load_game() and GameData.profile.get("onboarding_done", false):
		SceneRouter.go_to("home")
		return


func _on_lang_fr_pressed() -> void:
	GameData.profile.language = "fr"
	_go_to_gender_step()


func _on_lang_en_pressed() -> void:
	GameData.profile.language = "en"
	_go_to_gender_step()


func _go_to_gender_step() -> void:
	step_language.visible = false
	step_gender.visible = true

	gender_title.text = Loc.t("onboarding_gender_title")
	gender_subtitle.text = Loc.t("onboarding_gender_subtitle")
	btn_female.text = Loc.t("onboarding_gender_option_female")
	btn_male.text = Loc.t("onboarding_gender_option_male")


func _on_gender_female_pressed() -> void:
	GameData.profile.gender = "female"
	_go_to_name_step()


func _on_gender_male_pressed() -> void:
	GameData.profile.gender = "male"
	_go_to_name_step()


func _go_to_name_step() -> void:
	step_gender.visible = false
	step_name.visible = true

	name_title.text = Loc.t("onboarding_name_title")
	name_hint.text = Loc.t("onboarding_name_hint")
	name_edit.placeholder_text = Loc.t("onboarding_name_placeholder")
	btn_continue.text = Loc.t("onboarding_name_button_continue")


## Le bouton "Continuer" reste désactivé tant qu'aucun nom n'est saisi
## (le prénom/surnom est obligatoire, voir §7).
func _on_name_text_changed(new_text: String) -> void:
	btn_continue.disabled = new_text.strip_edges().is_empty()


func _on_name_continue_pressed() -> void:
	var chosen_name := name_edit.text.strip_edges()
	if chosen_name.is_empty():
		return

	GameData.profile.player_name = chosen_name
	GameData.profile.onboarding_done = true
	SaveManager.save_game()

	SceneRouter.go_to("home")
