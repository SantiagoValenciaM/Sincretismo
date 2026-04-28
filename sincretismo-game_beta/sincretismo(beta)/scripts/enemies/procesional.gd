extends EnemyBase

# HP=40, daño=15, gracia=8, velocidad=50
# Swing con ventana de 0.8s post-ataque donde es vulnerable (sin atacar)

var _post_swing: bool  = false
var _post_swing_t: float = 0.0

func _ready() -> void:
	hp_max       = 40
	damage       = 15
	gracia_drop  = 8.0
	speed_patrol = 50.0
	speed_chase  = 50.0
	atk_cooldown = 2.0
	patrol_dist  = 60.0
	super._ready()
	visual.color = Color(0.6, 0.15, 0.55, 1)


func _physics_process(delta: float) -> void:
	if _post_swing:
		_post_swing_t = max(_post_swing_t - delta, 0.0)
		if _post_swing_t <= 0.0:
			_post_swing = false
	super._physics_process(delta)


func do_attack() -> void:
	_atk_cd = atk_cooldown
	# Swing: hitbox arco (simulado con rect grande 0.25s)
	_cs_hitbox.disabled = false
	get_tree().create_timer(0.25).timeout.connect(func():
		_cs_hitbox.disabled = true
		_post_swing   = true
		_post_swing_t = 0.8
	)
	get_tree().create_timer(0.35).timeout.connect(func():
		if _player != null and abs(_player.global_position.x - global_position.x) > get_attack_range() + 20.0:
			estado = Estado.CHASE
	)


func recibir_daño(cantidad: int) -> void:
	# Durante ventana post-swing toma 1.5× daño
	var real: int = int(float(cantidad) * 1.5) if _post_swing else cantidad
	super.recibir_daño(real)


func get_attack_range() -> float:
	return 60.0
