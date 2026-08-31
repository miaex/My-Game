# Tonton Jiee — projet Godot

Structure de base du jeu, conforme au cahier des charges (§38). Le
gameplay (anagrammes, cartes de récompense) n'est pas encore implémenté :
seuls l'onboarding (langue/genre/prénom) et l'écran d'accueil/menu le sont,
pour valider que l'architecture (autoloads, sauvegarde, localisation)
fonctionne de bout en bout.

## Arborescence

```
tonton_jiee/
├── project.godot              # config projet, autoloads, écran de démarrage
├── assets/                    # images, cartes, sons, polices (à remplir)
├── data/                      # contenu créé par Tonton Jiee (lecture seule)
│   ├── categories/categories.json
│   ├── words/                 # base de mots par catégorie (à venir)
│   ├── levels/                # niveaux pré-générés ou règles de génération
│   ├── rewards/                # bibliothèque de messages de récompense
│   └── translations/          # fr.json / en.json — textes naturels, pas
│                                 une traduction mot à mot l'un de l'autre
├── scenes/
│   ├── onboarding/             # ✅ langue → genre → prénom
│   ├── home/                   # ✅ animation de bienvenue + menu principal
│   ├── level/                  # 🚧 placeholder (choix catégorie + anagramme)
│   ├── reward/                 # 🚧 placeholder (système des 100 cartes)
│   └── settings/               # réinitialisation de la progression
└── scripts/
    ├── autoload/
    │   ├── GameData.gd         # données jeu (JSON) + état runtime joueur
    │   ├── SaveManager.gd      # sauvegarde/chargement local user://save.json
    │   ├── Loc.gd               # textes localisés (Loc.t("clé", {vars}))
    │   └── SceneRouter.gd      # navigation entre scènes
    ├── player/                 # logique liée au profil (à venir)
    └── level/                  # génération de niveaux (à venir)
```

## Pourquoi cette séparation

- **`data/`** = contenu créé/édité par Tonton Jiee, versionné dans Git,
  jamais modifié par le jeu lui-même.
- **`user://save.json`** (géré par `SaveManager`) = tout ce qui concerne
  le joueur : profil, progression, historique de choix, statistiques.
  C'est la seule chose qui change à l'exécution.

Cette séparation permet d'ajouter du contenu (mots, catégories, messages)
sans jamais toucher au moteur.

## Comment ouvrir le projet

1. Installer Godot 4.3+ (Mobile renderer).
2. `Importer` → sélectionner `project.godot`.
3. Lancer avec F5 : la scène de démarrage est `Onboarding.tscn`.

## Workflow 100% smartphone : Termux → GitHub → APK

Le build de l'APK ne se fait PAS sur le téléphone : Termux sert uniquement
à pousser le code sur GitHub. C'est **GitHub Actions** (voir
`.github/workflows/build-apk.yml`) qui compile l'APK dans le cloud à
chaque `git push`, puis le publie automatiquement dans l'onglet
**Releases** du dépôt, prêt à télécharger et installer.

```
Termux (git push)
   ↓
GitHub Actions : godot --export-release "Android"
   ↓
GitHub Release : tonton-jiee.apk téléchargeable
```

### 1. Créer le dépôt GitHub

Depuis le navigateur du téléphone (ou l'app GitHub) : créer un nouveau
dépôt, par ex. `tonton-jiee`. Le laisser vide (pas de README auto-généré).

### 2. Installer Git dans Termux

```bash
pkg update && pkg upgrade
pkg install git
git config --global user.name "Ton Nom"
git config --global user.email "ton@email.com"
git config --global credential.helper store
```

### 3. Créer un token d'accès GitHub

Sur GitHub (mobile) : Paramètres → Developer settings → Personal access
tokens → Fine-grained tokens → générer un token avec accès en écriture
(Contents) sur le dépôt `tonton-jiee`. Le garder de côté : il servira de
mot de passe au premier `git push`.

### 4. Pousser ce projet

Décompresser ce zip dans le stockage du téléphone, puis dans Termux :

```bash
cd /sdcard/Download/tonton_jiee     # ou l'emplacement de la décompression
git init
git add .
git commit -m "Structure initiale du projet"
git branch -M main
git remote add origin https://github.com/<ton-utilisateur>/tonton-jiee.git
git push -u origin main
```

Au push, Git demande un nom d'utilisateur puis un mot de passe : entrer
le token créé à l'étape 3 comme mot de passe.

### 5. Récupérer l'APK

Le push déclenche automatiquement le workflow. Sur GitHub (onglet
**Actions**), suivre le build (2-5 minutes). Une fois terminé, l'APK
apparaît dans l'onglet **Releases** du dépôt → le télécharger directement
depuis le téléphone → l'installer (autoriser l'installation depuis le
navigateur/gestionnaire de fichiers si demandé).

Chaque `git push` suivant régénère automatiquement une nouvelle release
avec l'APK à jour.

### Notes importantes

- L'APK est signé avec un **keystore de debug généré à la volée** en CI
  (suffisant pour installer sur ton propre téléphone ; pas destiné au
  Play Store).
- `export_presets.cfg` est un point de départ standard ; s'il manque des
  champs selon la version exacte de Godot utilisée par l'image CI, les
  logs de l'onglet Actions indiquent précisément quoi ajuster.
- Le nom de package (`com.tontonjiee.game`) peut être changé dans
  `export_presets.cfg` si besoin.

## Prochaines étapes possibles

- Générer `data/words/*.json` (mots par catégorie, avec indices fr/en).
- Implémenter `scenes/level/Level.gd` : sélection de catégorie (§10),
  génération d'anagramme (§29), interface tactile (§13), et
  enregistrement des statistiques utilisées pour l'adaptation de
  difficulté (§15, déjà modélisées dans `GameData.statistics`).
- Implémenter `scenes/reward/Reward.gd` : tirage des 10×10 cartes,
  résolution du message final via `data/rewards/*.json` et
  `GameData.get_top_categories()`.
