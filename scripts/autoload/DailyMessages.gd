extends Node
## DailyMessages
## Prépare le contenu et la logique de rotation des messages motivants
## quotidiens (§ demande utilisateur : "Nouveau jour..."). La diffusion
## réelle en notification système Android n'est PAS encore branchée —
## ça nécessite un plugin natif + un build Gradle stabilisé. Ce module
## prépare tout ce qui peut l'être en attendant : le contenu, et le choix
## du prochain message sans répétition immédiate.

const MESSAGES_PATH := "res://data/notifications/daily_messages.json"

var _messages: Array = []


func _ready() -> void:
	_load_messages()


func _load_messages() -> void:
	if not FileAccess.file_exists(MESSAGES_PATH):
		return
	var text: String = FileAccess.get_file_as_string(MESSAGES_PATH)
	var parsed = JSON.parse_string(text)
	if parsed is Array:
		_messages = parsed


## Retourne le texte du prochain message à afficher, dans la langue du
## joueur, avec son prénom déjà inséré. Fait tourner un index persisté
## pour ne jamais répéter deux fois le même message d'affilée.
func get_next_message() -> String:
	var lang: String = GameData.profile.get("language", "fr")
	var candidates: Array = []
	for m in _messages:
		if m.get("language", "") == lang:
			candidates.append(m)

	if candidates.is_empty():
		return ""

	var index: int = int(GameData.progress.get("last_notification_index", -1))
	index = (index + 1) % candidates.size()
	GameData.progress.last_notification_index = index
	SaveManager.save_game()

	var player_name: String = GameData.profile.get("player_name", "")
	var text: String = str(candidates[index].get("text", ""))
	return text.replace("{player_name}", player_name)
