extends CharacterBody2D
class_name EnemyBase

enum Estado { PATROL, CHASE, ATTACK, HURT, DEAD }
var estado: Estado = Estado.PATROL

@export var hp_max: int          = 30
@export var speed_patrol: float  = 80.0
@export var speed_chase: float   = 120.0
@export var damage: int          = 10
@export var gracia_drop: float   = 5.0
@export var patrol_dist: float   = 80.0
@export var atk_cooldown: float  = 1.5

var hp: int = 0
var _atk_cd:  float = 0.0
var _hurt_t:  float = 0.0
var _lost_t:  float = 0.0
var _dir:     float = 1.0
var _patrol_origin: Vector2
var _last_known_pos: Vector2 = Vector2.ZERO
var _player: Node = null
var _base_color: Color = Color.WHITE

@onready var visual:          Polygon2D        = $Visual
@onready var detection_zone:  Area2D           = $DetectionZone
@onready var hitbox:          Area2D           = $Hitbox
@onready var hurtbox:         Area2D           = $Hurtbox
var _cs_hitbox: CollisionShape2D = null


func _ready() -> void:
	add_to_group("enemies")
	hp = hp_max
	_patrol_origin = global_position
	_base_color = visual.color
	_cs_hitbox = get_node_or_null("Hitbox/CollisionShape2D")
	hitbox.add_to_group("enemy_hitbox")
	hitbox.set_meta("damage", damage)
	if _cs_hitbox:
		_cs_hitbox.disabled = true
	hitbox.monitorable  = true
	hitbox.monitoring   = false
	hurtbox.monitoring  = true
	detection_zone.body_entered.connect(_on_detected)
	detection_zone.body_exited.connect(_on_lost)
	hurtbox.area_entered.connect(_on_hurt)


func _physics_process(delta: float) -> void:
	if estado == Estado.DEAD:
		return
	_atk_cd = max(_atk_cd - delta, 0.0)
	_hurt_t = max(_hurt_t - delta, 0.0)
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	_lost_t = max(_lost_t - delta, 0.0)
	_fsm(delta)
	move_and_slide()


func _fsm(delta: float) -> void:
	match estado:
		Estado.PATROL: _patrol()
		Estado.CHASE:  _chase()
		Estado.ATTACK: _attack_idle(delta)
		Estado.HURT:
			velocity.x = move_toward(velocity.x, 0.0, 800.0 * delta)
			if _hurt_t <= 0.0:
				estado = Estado.CHASE if _player != null else Estado.PATROL


func _patrol() -> void:
	velocity.x = _dir * speed_patrol
	visual.scale.x = _dir
	var dist := global_position.x - _patrol_origin.x
	if _dir > 0.0 and dist >= patrol_dist:
		_dir = -1.0
	elif _dir < 0.0 and dist <= -patrol_dist:
		_dir = 1.0


func _chase() -> void:
	var target: Vector2
	if _player != null:
		target = _player.global_position
		_last_known_pos = target
	elif _lost_t > 0.0:
		target = _last_known_pos
	else:
		estado = Estado.PATROL
		return
	var dx: float = target.x - global_position.x
	_dir = sign(dx)
	visual.scale.x = _dir
	if _player != null and abs(dx) <= get_attack_range():
		estado     = Estado.ATTACK
		velocity.x = 0.0
	elif abs(dx) < 8.0:
		estado = Estado.PATROL
	else:
		velocity.x = _dir * speed_chase


func _attack_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 800.0 * delta)
	if _player == null:
		estado = Estado.PATROL
		return
	if _atk_cd <= 0.0:
		do_attack()


func get_attack_range() -> float:
	return 40.0


func do_attack() -> void:
	_atk_cd = atk_cooldown
	if _cs_hitbox:
		_cs_hitbox.position.x = abs(_cs_hitbox.position.x) * _dir
		_cs_hitbox.disabled = false
	get_tree().create_timer(0.15).timeout.connect(func(): _infligir_daño_directo())
	get_tree().create_timer(0.2).timeout.connect(
		func(): if _cs_hitbox: _cs_hitbox.disabled = true
	)
	get_tree().create_timer(0.3).timeout.connect(func():
		if _player != null and abs(_player.global_position.x - global_position.x) > get_attack_range() + 20.0:
			estado = Estado.CHASE
	)


func _infligir_daño_directo() -> void:
	if _player == null or estado == Estado.DEAD:
		return
	var dist: float = _player.global_position.distance_to(global_position)
	if dist <= get_attack_range() + 20.0:
		_player.recibir_daño(damage, _dir)


func recibir_daño(cantidad: int) -> void:
	if estado == Estado.DEAD:
		return
	hp -= cantidad
	_flash_white()
	GameManager.shake_camera.emit(2.0)
	if hp <= 0:
		_morir()
		return
	estado  = Estado.HURT
	_hurt_t = 0.3
	velocity.x = -_dir * 150.0
	velocity.y = -80.0


func _flash_white() -> void:
	visual.color = Color.WHITE
	var tw := create_tween()
	tw.tween_property(visual, "color", _base_color, 0.2)


func _morir() -> void:
	estado   = Estado.DEAD
	velocity = Vector2.ZERO
	var players: Array = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		players[0].ganar_gracia(gracia_drop)
	AudioManager.play("enemy_die")
	queue_free()


func _on_detected(body: Node) -> void:
	if body.is_in_group("player"):
		_player = body
		if estado == Estado.PATROL:
			estado = Estado.CHASE


func _on_lost(body: Node) -> void:
	if body == _player:
		_last_known_pos = _player.global_position
		_lost_t = 2.0
		_player = null


func _on_hurt(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		var dmg: int = area.get_meta("damage", 10)
		recibir_daño(dmg)
