extends Area2D

const DAÑO: int    = 5
const INTERVALO: float = 0.5

var _dentro: Array = []
var _timer: float  = 0.0


func _ready() -> void:
	body_entered.connect(func(b): if b.is_in_group("player"): _dentro.append(b))
	body_exited.connect(func(b): _dentro.erase(b))


func _process(delta: float) -> void:
	if _dentro.is_empty():
		return
	_timer -= delta
	if _timer <= 0.0:
		_timer = INTERVALO
		for b in _dentro:
			if is_instance_valid(b) and b.has_method("recibir_daño"):
				b.recibir_daño(DAÑO)
