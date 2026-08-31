extends Control
## Settings
## Réservé pour §36 : langue, volume, effets sonores, animations.
## Pour l'instant : réinitialisation de la progression uniquement,
## car SaveManager.reset_progress() est déjà fonctionnel.


func _on_reset_pressed() -> void:
	SaveManager.reset_progress()
	SceneRouter.go_to("onboarding")


func _on_back_pressed() -> void:
	SceneRouter.go_to("home")
