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

const POOL_SIZE := 6

var _streams: Dictionary = {}
var _players: Array = []
var _next_player: int = 0

var sfx_enabled: bool = true
var vibration_enabled: bool = true


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


func play(key: String) -> void:
	if not sfx_enabled:
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
	if vibration_enabled:
		Input.vibrate_handheld(140)


func play_reward() -> void:
	play("reward")
