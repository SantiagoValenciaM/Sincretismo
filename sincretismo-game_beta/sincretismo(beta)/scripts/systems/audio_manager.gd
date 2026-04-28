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


func play(clip: String) -> void:
	if not _CLIPS.has(clip):
		return
	var path: String = _CLIPS[clip]
	if not ResourceLoader.exists(path):
		return
	if not _pool.has(clip):
		var ap := AudioStreamPlayer.new()
		add_child(ap)
		_pool[clip] = ap
	var ap: AudioStreamPlayer = _pool[clip]
	if ap.stream == null:
		ap.stream = load(path)
	ap.play()
