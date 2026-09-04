extends Node
## Audio
## Petits sons d'interface générés par code (voir §25 : le jeu doit
## rester vivant sans être bruyant). Utilise un pool de lecteurs pour
## permettre des sons qui se chevauchent (ex: taper vite plusieurs lettres).

const SOUNDS := {
	"tile": "res://assets/sounds/tile_tap.wav",
	"click": "res://assets/sounds/button_click.wav",
	"success": "res://assets/sounds/success.wav",
	"failure": "res://assets/sounds/failure.wav",
	"reward": "res://assets/sounds/reward.wav",
}

const MUSIC := {
	"menu": "res://assets/music/menu_music.ogg",
	"reward": "res://assets/music/reward_music.ogg",
}

const POOL_SIZE := 6

var _streams: Dictionary = {}
var _players: Array = []
var _next_player: int = 0

var _music_streams: Dictionary = {}
var _music_player: AudioStreamPlayer
var _current_music_key: String = ""



func _ready() -> void:
	for key in SOUNDS.keys():
		var path: String = SOUNDS[key]
		if ResourceLoader.exists(path):
			_streams[key] = load(path)

	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_players.append(p)

	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Master"
	_music_player.volume_db = -6.0
	add_child(_music_player)

	for key in MUSIC.keys():
		var path: String = MUSIC[key]
		if ResourceLoader.exists(path):
			var stream = load(path)
			if stream is AudioStreamOggVorbis:
				stream.loop = true
			_music_streams[key] = stream


func play(key: String) -> void:
	if not GameData.settings.get("sfx_enabled", true):
		return
	if not _streams.has(key):
		return
	var player: AudioStreamPlayer = _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	player.stream = _streams[key]
	player.play()


func play_tile() -> void:
	play("tile")


func play_click() -> void:
	play("click")


func play_success() -> void:
	play("success")


## Petit son "désolé" accompagné d'une brève vibration (voir demande :
## vibration suivie d'un son qui exprime l'échec en douceur).
func play_failure() -> void:
	play("failure")
	if GameData.settings.get("vibration_enabled", true):
		Input.vibrate_handheld(140)


func play_reward() -> void:
	play("reward")


## Musique de fond en boucle. Ne redémarre pas si le même morceau
## est déjà en cours (évite une coupure à chaque changement d'écran).
func play_music(key: String) -> void:
	if not GameData.settings.get("music_enabled", true):
		return
	if _current_music_key == key and _music_player.playing:
		return
	if not _music_streams.has(key):
		return
	_current_music_key = key
	_music_player.stream = _music_streams[key]
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()
	_current_music_key = ""
