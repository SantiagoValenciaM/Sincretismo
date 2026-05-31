extends CharacterBody2D

enum Fase   { UNO, DOS, TRES }
enum Estado { IDLE, APPROACH, ATTACK, PRAY, HURT, DEAD }

const HP_MAX: int = 200

var hp: int        = HP_MAX
var fase: Fase     = Fase.UNO
var estado: Estado = Estado.IDLE

var _atk_cd:        float = 0.0
var _hurt_t:        float = 0.0
var _phase3_t:      float = 0.0
var _pray_t:        float = 0.0
var _triple_i:      int   = 0
var _triple_active: bool  = false
var _single_active: bool  = false
var _invulnerable:  bool  = false
var _dir:           float = -1.0
var _player:       Node  = null

signal hp_changed(nuevo: int)
signal boss_muerto

@onready var visual:   Polygon2D        = $Visual
@onready var _spr:     AnimatedSprite2D = $AnimSprite
@onready var hitbox:   Area2D           = $Hitbox
@onready var hurtbox:  Area2D           = $Hurtbox
@onready var _cs_hit:  CollisionShape2D = $Hitbox/CollisionShape2D


func _ready() -> void:
	add_to_group("boss")
	visual.visible = false
	_setup_spr()
	hitbox.add_to_group("enemy_hitbox")
	hitbox.set_meta("damage", 15)
	_cs_hit.disabled = true
	hitbox.monitorable = true
	hurtbox.monitoring = true
	hurtbox.area_entered.connect(_on_hurt)
	await get_tree().process_frame
	var players: Array = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		_player = players[0]
	estado = Estado.APPROACH


func _setup_spr() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")

	var anims := {
		"acercarse":    {"dir": "acercarse",    "count": 4, "fps": 8.0,  "loop": true},
		"attack":       {"dir": "attack",       "count": 4, "fps": 10.0, "loop": false},
		"triple_attack":{"dir": "triple_attack","count": 6, "fps": 14.0, "loop": false},
		"rezo":         {"dir": "rezo",         "count": 6, "fps": 7.0,  "loop": true},
		"hurt":         {"dir": "hurt",         "count": 2, "fps": 10.0, "loop": false},
		"muerto":       {"dir": "muerto",       "count": 4, "fps": 5.0,  "loop": false},
	}

	for anim_name in anims:
		var info: Dictionary = anims[anim_name]
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, info["loop"])
		frames.set_animation_speed(anim_name, info["fps"])
		for i in range(1, int(info["count"]) + 1):
			frames.add_frame(anim_name,
				load("res://assets/sprites/mayordomo/%s/%d.png" % [info["dir"], i]))

	_spr.sprite_frames = frames
	_spr.play("acercarse")


func _physics_process(delta: float) -> void:
	if estado == Estado.DEAD:
		return
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	_atk_cd = max(_atk_cd - delta, 0.0)
	_hurt_t = max(_hurt_t - delta, 0.0)
	_actualizar_fase()
	_fsm(delta)
	move_and_slide()
	_update_spr()


func _update_spr() -> void:
	match estado:
		Estado.APPROACH:
			_play("acercarse")
		Estado.ATTACK:
			if _triple_active:
				_play("triple_attack")
			elif _single_active:
				_play("attack")
			else:
				_play("acercarse")
		Estado.PRAY:
			_play("rezo")
		Estado.HURT:
			_play("hurt")
		Estado.DEAD:
			_play("muerto")
		_:
			_play("acercarse")
	_spr.flip_h = _dir < 0.0
	if estado != Estado.PRAY:
		_spr.modulate = _color_fase()


func _play(anim: String) -> void:
	if _spr.animation != anim:
		_spr.play(anim)


func _actualizar_fase() -> void:
	if hp > 133:
		fase = Fase.UNO
	elif hp > 66:
		if fase != Fase.DOS:
			fase = Fase.DOS
			hitbox.set_meta("damage", 12)
	else:
		if fase != Fase.TRES:
			fase = Fase.TRES
			_phase3_t = 3.0


func _fsm(delta: float) -> void:
	if _player == null:
		return
	match estado:
		Estado.APPROACH: _approachar()
		Estado.ATTACK:   _attackear(delta)
		Estado.PRAY:     _rezar(delta)
		Estado.HURT:
			velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
			if _hurt_t <= 0.0:
				estado = Estado.APPROACH
		_: pass


func _approachar() -> void:
	var dx: float = _player.global_position.x - global_position.x
	_dir = sign(dx)
	var rango: float = 55.0 if fase == Fase.UNO else 45.0
	var vel: float   = 100.0 if fase == Fase.UNO else 160.0
	if abs(dx) <= rango:
		velocity.x = 0.0
		estado = Estado.ATTACK
	else:
		velocity.x = _dir * vel


func _attackear(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
	if fase == Fase.TRES:
		_phase3_t -= delta
	if _player != null:
		var dx: float = _player.global_position.x - global_position.x
		_dir = sign(dx) if abs(dx) > 2.0 else _dir
		var rango: float = 55.0 if fase == Fase.UNO else 45.0
		if abs(dx) > rango + 20.0 and not _triple_active:
			estado = Estado.APPROACH
			return
	if _atk_cd > 0.0:
		return
	if _triple_active:
		return
	match fase:
		Fase.UNO:  _golpe_lateral()
		Fase.DOS:  _triple_rapido()
		Fase.TRES:
			if _phase3_t <= 0.0:
				_iniciar_rezo()
			else:
				_golpe_lateral()


func _golpe_lateral() -> void:
	_atk_cd = 2.0
	_single_active = true
	_cs_hit.position.x = abs(_cs_hit.position.x) * _dir
	_cs_hit.disabled = false
	get_tree().create_timer(0.15).timeout.connect(func(): _daño_directo(hitbox.get_meta("damage", 15)))
	get_tree().create_timer(0.25).timeout.connect(func(): _cs_hit.disabled = true)
	get_tree().create_timer(0.4).timeout.connect(func():
		_single_active = false
		if estado != Estado.DEAD:
			estado = Estado.APPROACH
	)


func _triple_rapido() -> void:
	_atk_cd = 1.2
	_triple_i = 0
	_triple_active = true
	_siguiente_golpe()


func _siguiente_golpe() -> void:
	if _triple_i >= 3 or estado == Estado.DEAD:
		_triple_active = false
		_cs_hit.disabled = true
		estado = Estado.APPROACH
		return
	_triple_i += 1
	if _player != null:
		var dx: float = _player.global_position.x - global_position.x
		if abs(dx) > 2.0:
			_dir = sign(dx)
	_cs_hit.position.x = abs(_cs_hit.position.x) * _dir
	_cs_hit.disabled = false
	hitbox.set_meta("damage", 12)
	get_tree().create_timer(0.08).timeout.connect(func(): _daño_directo(12))
	get_tree().create_timer(0.12).timeout.connect(func():
		_cs_hit.disabled = true
		get_tree().create_timer(0.18).timeout.connect(_siguiente_golpe)
	)


func _iniciar_rezo() -> void:
	estado        = Estado.PRAY
	_invulnerable = true
	_pray_t       = 4.0
	_spr.modulate = Color(0.85, 0.65, 1.0)


func _rezar(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
	_pray_t -= delta
	hp = min(hp + int(10.0 * delta), HP_MAX)
	hp_changed.emit(hp)
	if _pray_t <= 0.0:
		_invulnerable = false
		_phase3_t     = 3.0
		_spr.modulate = Color.WHITE
		estado        = Estado.ATTACK


func recibir_daño(cantidad: int) -> void:
	if _invulnerable or estado == Estado.DEAD:
		return
	hp = max(hp - cantidad, 0)
	hp_changed.emit(hp)
	_flash_white()
	GameManager.shake_camera.emit(2.0)
	AudioManager.play("boss_hit")
	if hp <= 0:
		_morir()
		return
	estado  = Estado.HURT
	_hurt_t = 0.25
	velocity.x = -_dir * 120.0


func _flash_white() -> void:
	_spr.modulate = Color(2.5, 2.5, 2.5, 1.0)
	var tw := create_tween()
	tw.tween_property(_spr, "modulate", _color_fase(), 0.2)


func _morir() -> void:
	estado    = Estado.DEAD
	velocity  = Vector2.ZERO
	_spr.modulate = Color.WHITE
	_play("muerto")
	GameManager.zone1_boss_defeated = true
	boss_muerto.emit()
	await get_tree().create_timer(1.8).timeout
	SceneTransition.fade_to("res://scenes/ui/Victory.tscn")


func _color_fase() -> Color:
	match fase:
		Fase.UNO:  return Color.WHITE
		Fase.DOS:  return Color(1.0, 0.55, 0.95)
		Fase.TRES: return Color(1.0, 0.3,  0.3)
	return Color.WHITE


func _daño_directo(dmg: int) -> void:
	if _player == null or estado == Estado.DEAD or _invulnerable:
		return
	var dist: float = _player.global_position.distance_to(global_position)
	if dist <= 80.0:
		_player.recibir_daño(dmg, _dir)


func _on_hurt(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		var dmg: int = area.get_meta("damage", 10)
		recibir_daño(dmg)
