extends Node
## SceneRouter
## Petit utilitaire pour centraliser les chemins de scènes et éviter
## les chaînes de caractères éparpillées dans tout le projet.

const SCENES := {
	"onboarding": "res://scenes/onboarding/Onboarding.tscn",
	"home": "res://scenes/home/Home.tscn",
	"level": "res://scenes/level/Level.tscn",
	"reward": "res://scenes/reward/Reward.tscn",
	"settings": "res://scenes/settings/Settings.tscn",
}


func go_to(scene_key: String) -> void:
	if not SCENES.has(scene_key):
		push_error("SceneRouter: scène inconnue '%s'" % scene_key)
		return
	get_tree().change_scene_to_file(SCENES[scene_key])
