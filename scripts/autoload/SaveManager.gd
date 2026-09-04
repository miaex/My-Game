extends Node
## SaveManager
## Sauvegarde/chargement local (user://) de toutes les données joueur
## listées au §27 du cahier des charges. Fonctionne entièrement hors ligne.

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := 1


## Rassemble l'état courant de GameData dans un dictionnaire sérialisable.
func _collect_save_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"profile": GameData.profile,
		"progress": GameData.progress,
		"category_choice_history": GameData.category_choice_history,
		"statistics": GameData.statistics,
		"settings": GameData.settings,
	}


func save_game() -> void:
	var data := _collect_save_data()
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: impossible d'écrire la sauvegarde (%s)" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func load_game() -> bool:
	if not has_save():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: impossible de lire la sauvegarde (%s)" % SAVE_PATH)
		return false
	var text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if not (parsed is Dictionary):
		push_error("SaveManager: fichier de sauvegarde corrompu")
		return false

	# Migration simple si la structure de sauvegarde évolue plus tard.
	if parsed.get("version", 0) != SAVE_VERSION:
		push_warning("SaveManager: version de sauvegarde différente, chargement best-effort")

	if parsed.has("profile"):
		GameData.profile = parsed["profile"]
	if parsed.has("progress"):
		GameData.progress = parsed["progress"]
	if parsed.has("category_choice_history"):
		GameData.category_choice_history = parsed["category_choice_history"]
	if parsed.has("statistics"):
		GameData.statistics = parsed["statistics"]
	if parsed.has("settings"):
		for key in parsed["settings"].keys():
			GameData.settings[key] = parsed["settings"][key]

	return true


## Réinitialisation de la progression (voir §36 Paramètres).
## Ne supprime pas les fichiers de données du jeu, uniquement le joueur.
func reset_progress() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	GameData.profile = {
		"language": GameData.profile.get("language", ""),
		"gender": "",
		"player_name": "",
		"onboarding_done": false,
	}
	GameData.progress = {
		"current_chapter": 1,
		"current_level": 1,
		"completed_levels": [],
		"unlocked_rewards": [],
		"seen_messages": [],
	}
	GameData.category_choice_history = []
	GameData.statistics = {
		"successes": 0,
		"failures": 0,
		"average_time_seconds": 0.0,
		"attempts_by_level": {},
		"estimated_difficulty": 1,
	}
