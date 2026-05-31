extends Node

const _CLIPS: Dictionary = {
	"jump":      "res://assets/audio/jump.wav",
	"atk_light": "res://assets/audio/attack_light.wav",
	"atk_heavy": "res://assets/audio/attack_heavy.wav",
	"damage":    "res://assets/audio/damage.wav",
	"death":     "res://assets/audio/death.wav",
	"altar":     "res://assets/audio/altar.wav",
	"boss_hit":  "res://assets/audio/boss_hit.wav",
	"enemy_die": "res://assets/audio/enemy_die.wav",
}

var _pool: Dictionary = {}


func _ready() -> void:
	for key in _CLIPS:
		var path: String = _CLIPS[key]
		if not ResourceLoader.exists(path):
			continue
		var ap := AudioStreamPlayer.new()
		ap.stream = load(path)
		add_child(ap)
		_pool[key] = ap


func play(clip: String) -> void:
	if _pool.has(clip):
		_pool[clip].play()
