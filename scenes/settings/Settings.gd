extends Control
## Settings (§36) : sons, musique, vibration activables, réinitialisation.

@onready var background: Panel = $Background
@onready var title_label: Label = %TitleLabel
@onready var sound_label: Label = %SoundLabel
@onready var sound_toggle: CheckButton = %SoundToggle
@onready var music_label: Label = %MusicLabel
@onready var music_toggle: CheckButton = %MusicToggle
@onready var vibration_label: Label = %VibrationLabel
@onready var vibration_toggle: CheckButton = %VibrationToggle
@onready var reset_button: Button = %ResetButton
@onready var back_button: Button = %BackButton
@onready var howto_button: Button = %HowToButton


func _ready() -> void:
	Audio.play_music("menu")

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.965, 0.958, 0.948)
	background.add_theme_stylebox_override("panel", style)
	Decor.add_sparkles(self)

	title_label.text = Loc.t("settings_title")
	sound_label.text = Loc.t("settings_sound")
	music_label.text = Loc.t("settings_music")
	vibration_label.text = Loc.t("settings_vibration")
	reset_button.text = Loc.t("settings_reset")
	howto_button.text = Loc.t("settings_howto")
	back_button.text = Loc.t("level_back_to_home")

	sound_toggle.button_pressed = GameData.settings.get("sfx_enabled", true)
	music_toggle.button_pressed = GameData.settings.get("music_enabled", true)
	vibration_toggle.button_pressed = GameData.settings.get("vibration_enabled", true)


func _on_sound_toggled(pressed: bool) -> void:
	GameData.settings["sfx_enabled"] = pressed
	SaveManager.save_game()
	if pressed:
		Audio.play_click()


func _on_music_toggled(pressed: bool) -> void:
	GameData.settings["music_enabled"] = pressed
	SaveManager.save_game()
	if pressed:
		Audio.play_music("menu")
	else:
		Audio.stop_music()


func _on_vibration_toggled(pressed: bool) -> void:
	GameData.settings["vibration_enabled"] = pressed
	SaveManager.save_game()
	if pressed:
		Input.vibrate_handheld(80)


func _on_howto_pressed() -> void:
	SceneRouter.go_to("howtoplay")


func _on_reset_pressed() -> void:
	SaveManager.reset_progress()
	SceneRouter.go_to("onboarding")


func _on_back_pressed() -> void:
	SceneRouter.go_to("home")
