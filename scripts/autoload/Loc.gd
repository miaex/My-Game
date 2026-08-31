extends Node
## Loc
## Accès centralisé aux textes localisés.
##
## IMPORTANT (voir cahier des charges §5) : data/translations/fr.json et
## data/translations/en.json ne sont PAS des traductions mot à mot l'un de
## l'autre. Chaque fichier doit contenir des formulations naturelles dans
## sa langue. Ce script se contente de choisir le bon fichier selon
## GameData.profile.language et de faire le remplacement de variables.


## Retourne le texte associé à `key` dans la langue courante du joueur.
## `vars` permet de remplacer des jetons du type {player_name} dans le texte.
##
## Exemple :
##   Loc.t("home_welcome_title", {"player_name": GameData.profile.player_name})
func t(key: String, vars: Dictionary = {}) -> String:
	var lang: String = GameData.profile.get("language", "fr")
	if lang == "":
		lang = "fr"

	var table: Dictionary = GameData.translations.get(lang, {})
	var text: String = table.get(key, "")

	if text == "":
		# Repli sur le français si la clé manque dans la langue active,
		# puis sur la clé brute si vraiment introuvable, pour ne jamais
		# planter l'affichage.
		text = GameData.translations.get("fr", {}).get(key, key)

	for var_name in vars.keys():
		text = text.replace("{%s}" % var_name, str(vars[var_name]))

	return text


## Variante genrée : choisit entre `key_female` et `key_male` selon
## GameData.profile.gender (voir §6 — le genre adapte certains accords).
func t_gendered(key_base: String, vars: Dictionary = {}) -> String:
	var gender: String = GameData.profile.get("gender", "female")
	var suffix := "female" if gender == "female" else "male"
	return t("%s_%s" % [key_base, suffix], vars)
