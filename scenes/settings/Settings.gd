extends Control
## Settings
## Réservé pour §36 : langue, volume, effets sonores, animations.
## Pour l'instant : réinitialisation de la progression uniquement.

@onready var background: Panel = $Background


func _ready() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.976, 0.925, 0.902)
	background.add_theme_stylebox_override("panel", style)


func _on_reset_pressed() -> void:
	SaveManager.reset_progress()
	SceneRouter.go_to("onboarding")


func _on_back_pressed() -> void:
	SceneRouter.go_to("home")
