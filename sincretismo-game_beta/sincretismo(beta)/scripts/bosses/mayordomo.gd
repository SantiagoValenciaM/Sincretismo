extends CharacterBody2D

enum Fase   { UNO, DOS, TRES }
enum Estado { IDLE, APPROACH, ATTACK, PRAY, HURT, DEAD }

const HP_MAX: int = 200

var hp: int       = HP_MAX
var fase: Fase    = Fase.UNO
var estado: Estado = Estado.IDLE

var _atk_cd:     float = 1.5
var _hurt_t:     float = 0.0
var _phase3_t:   float = 0.0
var _pray_t:     float = 0.0
var _triple_i:   int   = 0
var _invulnerable: bool = false
var _dir:        float = -1.0
var _player:     Node  = null
var _base_color: Color = Color.WHITE

signal hp_changed(nuevo: int)
signal boss_muerto

@onready var visual:    Polygon2D        = $Visual
@onready var hitbox:    Area2D           = $Hitbox
@onready var hurtbox:   Area2D           = $Hurtbox
@onready var _cs_hit:   CollisionShape2D = $Hitbox/CollisionShape2D


func _ready() -> void:
	add_to_group("boss")
	_base_color = visual.color
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
	if estado != Estado.PRAY:
		visual.modulate = _color_fase()


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
	visual.scale.x = _dir
	var rango: float = 55.0 if fase == Fase.UNO else 45.0
	var vel: float   = 100.0 if fase == Fase.UNO else 160.0
	if abs(dx) <= rango:
		velocity.x = 0.0
		estado = Estado.ATTACK
	else:
		velocity.x = _dir * vel


func _attackear(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)
	if _atk_cd > 0.0:
		return
	match fase:
		Fase.UNO:  _golpe_lateral()
		Fase.DOS:  _triple_rapido()
		Fase.TRES:
			_phase3_t -= delta
			if _phase3_t <= 0.0:
				_iniciar_rezo()
			else:
				_golpe_lateral()


func _golpe_lateral() -> void:
	_atk_cd = 2.0
	_cs_hit.disabled = false
	get_tree().create_timer(0.25).timeout.connect(func(): _cs_hit.disabled = true)
	get_tree().create_timer(0.4).timeout.connect(func():
		if estado != Estado.DEAD:
			estado = Estado.APPROACH
	)


func _triple_rapido() -> void:
	_atk_cd = 1.2
	_triple_i = 0
	_siguiente_golpe()


func _siguiente_golpe() -> void:
	if _triple_i >= 3 or estado == Estado.DEAD:
		estado = Estado.APPROACH
		return
	_triple_i += 1
	_cs_hit.disabled = false
	hitbox.set_meta("damage", 12)
	get_tree().create_timer(0.12).timeout.connect(func():
		_cs_hit.disabled = true
		get_tree().create_timer(0.18).timeout.connect(_siguiente_golpe)
	)


func _iniciar_rezo() -> void:
	estado       = Estado.PRAY
	_invulnerable = true
	_pray_t      = 4.0
	visual.modulate = Color(0.8, 0.5, 1.0)


func _rezar(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)
	_pray_t -= delta
	hp = min(hp + int(10.0 * delta), HP_MAX)
	hp_changed.emit(hp)
	if _pray_t <= 0.0:
		_invulnerable = false
		_phase3_t    = 3.0
		estado       = Estado.ATTACK


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
	visual.color = Color.WHITE
	var tw := create_tween()
	tw.tween_property(visual, "color", _base_color, 0.2)


func _morir() -> void:
	estado = Estado.DEAD
	velocity = Vector2.ZERO
	GameManager.zone1_boss_defeated = true
	boss_muerto.emit()
	await get_tree().create_timer(1.5).timeout
	SceneTransition.fade_to("res://scenes/ui/Victory.tscn")


func _color_fase() -> Color:
	match fase:
		Fase.UNO:  return Color(0.5, 0.1, 0.7)
		Fase.DOS:  return Color(0.8, 0.1, 0.5)
		Fase.TRES: return Color(1.0, 0.1, 0.2)
	return Color.WHITE


func _on_hurt(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		var dmg: int = area.get_meta("damage", 10)
		recibir_daño(dmg)
