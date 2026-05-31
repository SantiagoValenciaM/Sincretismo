extends EnemyBase

static var _frames_cache: SpriteFrames = null

var _explotada: bool = false

@onready var _spr: AnimatedSprite2D = $AnimSprite


func _ready() -> void:
	hp_max       = 15
	damage       = 20
	gracia_drop  = 5.0
	speed_chase  = 130.0
	atk_cooldown = 0.0
	super._ready()
	visual.visible = false
	_setup_spr()


func _setup_spr() -> void:
	if _frames_cache != null:
		_spr.sprite_frames = _frames_cache
		_spr.play("idle")
		return

	var frames := SpriteFrames.new()
	frames.remove_animation("default")

	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 8.0)
	for i in range(1, 5):
		frames.add_frame("idle", load("res://assets/sprites/veladora/idle/%d.png" % i))

	frames.add_animation("explosion")
	frames.set_animation_loop("explosion", false)
	frames.set_animation_speed("explosion", 14.0)
	for i in range(1, 14):
		frames.add_frame("explosion", load("res://assets/sprites/veladora/explosion/%d.png" % i))

	_frames_cache = frames
	_spr.sprite_frames = frames
	_spr.play("idle")


func _physics_process(delta: float) -> void:
	if _explotada:
		return
	super._physics_process(delta)
	_spr.flip_h = _dir < 0.0


func get_attack_range() -> float:
	return 18.0


func do_attack() -> void:
	_explotar()


func _flash_white() -> void:
	_spr.modulate = Color(2.5, 2.5, 2.5, 1.0)
	var tw := create_tween()
	tw.tween_property(_spr, "modulate", Color.WHITE, 0.2)


func _on_hurt(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		var dmg: int = area.get_meta("damage", 10)
		if dmg >= 25:
			_explotar()
		else:
			recibir_daño(dmg)


func _explotar() -> void:
	if _explotada:
		return
	_explotada = true
	estado = Estado.DEAD
	velocity = Vector2.ZERO

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

	$CollisionShape2D.set_deferred("disabled", true)
	_spr.scale = Vector2(0.1, 0.1)
	_spr.modulate = Color.WHITE
	_spr.play("explosion")
	_spr.animation_finished.connect(queue_free)
