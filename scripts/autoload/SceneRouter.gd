extends Node
## SceneRouter
## Centralise les chemins de scènes et gère un fondu enchaîné (fade)
## entre chaque changement d'écran, pour éviter les transitions brutales.

const SCENES := {
	"onboarding": "res://scenes/onboarding/Onboarding.tscn",
	"home": "res://scenes/home/Home.tscn",
	"level": "res://scenes/level/Level.tscn",
	"reward": "res://scenes/reward/Reward.tscn",
	"settings": "res://scenes/settings/Settings.tscn",
	"journey": "res://scenes/journey/Journey.tscn",
	"rewards": "res://scenes/rewards/RewardsList.tscn",
}

var _fade_layer: CanvasLayer
var _fade_rect: ColorRect


func _ready() -> void:
	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 100
	add_child(_fade_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0.965, 0.958, 0.948, 1)
	_fade_rect.anchor_right = 1.0
	_fade_rect.anchor_bottom = 1.0
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.modulate.a = 0.0
	_fade_layer.add_child(_fade_rect)


## Bouton "retour" physique Android : ramène vers l'accueil au lieu de
## quitter brutalement l'application (sauf si on y est déjà, auquel cas
## le comportement par défaut du système reprend la main).
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		var current_scene := get_tree().current_scene
		if current_scene == null:
			return
		var scene_path: String = current_scene.scene_file_path
		if scene_path == SCENES.get("home", ""):
			return
		go_to("home")
		get_viewport().set_input_as_handled()


func go_to(scene_key: String) -> void:
	if not SCENES.has(scene_key):
		push_error("SceneRouter: scène inconnue '%s'" % scene_key)
		return
	_fade_and_switch(SCENES[scene_key])


func _fade_and_switch(scene_path: String) -> void:
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween_out := create_tween()
	tween_out.tween_property(_fade_rect, "modulate:a", 1.0, 0.16)
	await tween_out.finished

	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	await get_tree().process_frame

	var tween_in := create_tween()
	tween_in.tween_property(_fade_rect, "modulate:a", 0.0, 0.22)
	await tween_in.finished

	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
