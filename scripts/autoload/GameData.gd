extends Node
## GameData
## Autoload central pour les données STATIQUES du jeu (contenu créé par
## Tonton Jiee : catégories, mots, niveaux, récompenses) et pour l'état
## RUNTIME du joueur en cours de partie (profil, progression, choix).
##
## Séparation volontaire (voir cahier des charges §30) :
##   - "game data"   -> chargé depuis res://data/  (lecture seule, versionné dans Git)
##   - "player data" -> lu/écrit via SaveManager (autoload séparé) vers user://

# ---------------------------------------------------------------------------
# DONNÉES DU JEU (lecture seule, chargées au démarrage)
# ---------------------------------------------------------------------------

var categories: Array = []          # contenu de data/categories/categories.json
var translations: Dictionary = {}   # { "fr": {...}, "en": {...} }

# ---------------------------------------------------------------------------
# DONNÉES DU JOUEUR (état runtime, persistées par SaveManager)
# ---------------------------------------------------------------------------

## Identité choisie à l'onboarding (voir Onboarding.gd)
var profile: Dictionary = {
	"language": "",      # "fr" | "en"
	"gender": "",         # "female" | "male"
	"player_name": "",    # playerName saisi par le joueur
	"onboarding_done": false,
	"welcome_seen": false, # animation d'accueil (§8) déjà vue une fois
}

## Progression générale
var progress: Dictionary = {
	"current_chapter": 1,
	"current_level": 1,          # 1..10 dans le chapitre courant
	"completed_levels": [],      # liste d'ids de niveaux terminés
	"unlocked_rewards": [],      # liste d'ids de récompenses débloquées
	"seen_messages": [],         # ids de messages de récompense déjà vus
}

## Historique des choix de catégories (voir §11) : liste ordonnée
## d'ids de catégories choisies par le joueur, un élément par niveau joué.
var category_choice_history: Array = []

## Statistiques utilisées pour l'adaptation de difficulté (voir §15)
var statistics: Dictionary = {
	"successes": 0,
	"failures": 0,
	"average_time_seconds": 0.0,
	"attempts_by_level": {},     # { level_id: attempt_count }
	"estimated_difficulty": 1,   # échelle simple 1..N, ajustée en jeu
}


func _ready() -> void:
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)

	_load_categories()
	_load_translations()


func _load_categories() -> void:
	var path: String = "res://data/categories/categories.json"
	if not FileAccess.file_exists(path):
		push_warning("GameData: categories.json introuvable (%s)" % path)
		return
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if parsed is Array:
		categories = parsed
	else:
		push_warning("GameData: categories.json mal formé")


func _load_translations() -> void:
	for lang in ["fr", "en"]:
		var path: String = "res://data/translations/%s.json" % lang
		if not FileAccess.file_exists(path):
			push_warning("GameData: fichier de traduction introuvable (%s)" % path)
			continue
		var text := FileAccess.get_file_as_string(path)
		var parsed = JSON.parse_string(text)
		if parsed is Dictionary:
			translations[lang] = parsed


## Enregistre le choix de catégorie fait pour le niveau en cours
## et incrémente les statistiques associées (voir §11 / §22).
func register_category_choice(category_id: String) -> void:
	category_choice_history.append(category_id)


## Retourne les N catégories les plus choisies par le joueur
## (utilisé pour orienter le ton de la récompense, voir §22).
func get_top_categories(n: int = 3) -> Array:
	var counts: Dictionary = {}
	for cat_id in category_choice_history:
		counts[cat_id] = counts.get(cat_id, 0) + 1
	var pairs: Array = []
	for cat_id in counts.keys():
		pairs.append([cat_id, counts[cat_id]])
	pairs.sort_custom(func(a, b): return a[1] > b[1])
	var result: Array = []
	for i in range(min(n, pairs.size())):
		result.append(pairs[i][0])
	return result
