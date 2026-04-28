extends EnemyBase

# HP=15, daño=20 (explosión), gracia=5
# Explota al contacto con jugador. Destruible con ataque pesado.

var _explotada: bool = false

func _ready() -> void:
	hp_max      = 15
	damage      = 20
	gracia_drop = 5.0
	speed_chase = 130.0
	atk_cooldown= 99.0  # no usa el ataque normal
	super._ready()
	visual.color = Color(1.0, 0.85, 0.1, 1)
	# Detecta cuerpos para explosión por contacto
	detection_zone.body_entered.connect(_on_contact)


func _on_contact(body: Node) -> void:
	if body.is_in_group("player") and not _explotada:
		_explotar()


func _on_hurt(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		var dmg: int = area.get_meta("damage", 10)
		# Solo el ataque pesado la destruye directamente
		if dmg >= 25:
			_explotar()
		else:
			recibir_daño(dmg)


func _explotar() -> void:
	if _explotada:
		return
	_explotada = true
	# Daño en área 60px a jugadores Y enemigos cercanos
	var todos: Array = get_tree().get_nodes_in_group("player") + \
					   get_tree().get_nodes_in_group("enemies")
	for nodo in todos:
		if nodo == self:
			continue
		if nodo.global_position.distance_to(global_position) <= 60.0:
			if nodo.has_method("recibir_daño"):
				nodo.recibir_daño(damage)
	var players: Array = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		players[0].ganar_gracia(gracia_drop)
	queue_free()
