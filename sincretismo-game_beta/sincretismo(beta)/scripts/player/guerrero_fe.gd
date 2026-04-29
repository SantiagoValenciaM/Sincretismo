extends CharacterBody2D

enum Estado { IDLE, RUN, JUMP, FALL, ATTACK_LIGHT, ATTACK_HEAVY, DODGE, HURT, DEAD }
var estado: Estado = Estado.IDLE

const SPEED    := 300.0
const ACCEL    := 1800.0
const FRICTION := 1400.0
const JUMP_VEL := -550.0
const CUT      := 0.4
const FALL_MUL := 1.6
const COYOTE   := 0.12
const BUFFER   := 0.12

@export var hp_max: int  = 100
@export var dev_max: int = 10

var hp: int        = hp_max
var devocion: int  = dev_max
var stamina: float = 100.0
var gracia: float  = 0.0
var is_invincible: bool = false

signal hp_changed(nuevo: int)
signal devocion_changed(nuevo: int)
signal stamina_changed(nuevo: float)
signal gracia_changed(nuevo: float)
signal player_died

var _coyote:    float = 0.0
var _jbuffer:   float = 0.0
var _atk_t:     float = 0.0
var _dodge_t:   float = 0.0
var _hurt_t:    float = 0.0
var _hitbox_t:  float = 0.0
var _inv_t:     float = 0.0
var _facing:    float = 1.0
var _was_floor: bool  = false
var _flash_t:   float = 0.0
var _flash_col: Color = Color.WHITE
var _usar_sprite: bool = false

@onready var visual:       Polygon2D        = $Visual
@onready var sprite:       Sprite2D         = $Sprite
@onready var hitbox_light: Area2D           = $HitboxLight
@onready var hitbox_heavy: Area2D           = $HitboxHeavy
@onready var hurtbox:      Area2D           = $Hurtbox
@onready var _cs_hl: CollisionShape2D       = $HitboxLight/CollisionShape2D
@onready var _cs_hh: CollisionShape2D       = $HitboxHeavy/CollisionShape2D

const _BASE_SPRITE := "res://assets/sprites/promesero/"
const _SPRITE_MAP := {
	"idle":         "idle.png",
	"walk":         "walk.png",
	"attack_light": "attack_light.png",
	"attack_heavy": "attack_heavy.png",
}
var _texturas: Dictionary = {}

const _COLORES := {
	Estado.IDLE:         Color(0.65, 0.65, 0.65),
	Estado.RUN:          Color(0.25, 0.85, 0.25),
	Estado.JUMP:         Color(0.25, 0.55, 1.0),
	Estado.FALL:         Color(0.15, 0.35, 0.85),
	Estado.ATTACK_LIGHT: Color(1.0,  0.85, 0.0),
	Estado.ATTACK_HEAVY: Color(1.0,  0.4,  0.0),
	Estado.DODGE:        Color(0.0,  1.0,  1.0),
	Estado.HURT:         Color(1.0,  0.0,  0.0),
	Estado.DEAD:         Color(0.2,  0.2,  0.2),
}


func _ready() -> void:
	add_to_group("player")
	_cs_hl.disabled = true
	_cs_hh.disabled = true
	hitbox_light.add_to_group("player_hitbox")
	hitbox_heavy.add_to_group("player_hitbox")
	hitbox_light.set_meta("damage", 10)
	hitbox_heavy.set_meta("damage", 25)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	_cargar_sprites()


func _cargar_sprites() -> void:
	for key in _SPRITE_MAP:
		var path: String = _BASE_SPRITE + _SPRITE_MAP[key]
		if ResourceLoader.exists(path):
			_texturas[key] = load(path)
	if _texturas.has("idle"):
		_usar_sprite = true
		visual.visible = false
		sprite.visible = true
		sprite.texture = _texturas["idle"]


func _physics_process(delta: float) -> void:
	_gravedad(delta)
	_timers(delta)
	_stamina_regen(delta)

	match estado:
		Estado.IDLE, Estado.RUN:
			_mover(delta); _salto(); _ataque(); _esquiva()
		Estado.JUMP, Estado.FALL:
			_mover(delta); _salto(); _ataque()
		Estado.ATTACK_LIGHT, Estado.ATTACK_HEAVY:
			_frenar(delta)
		Estado.DODGE:
			pass
		Estado.HURT:
			pass
		Estado.DEAD:
			return

	move_and_slide()
	_fsm_update()
	_actualizar_visual()


func _actualizar_visual() -> void:
	var tint := _flash_col if _flash_t > 0.0 else Color.WHITE
	if _usar_sprite:
		sprite.modulate = tint
		sprite.scale.x  = abs(sprite.scale.x) * _facing
		var key := "idle"
		match estado:
			Estado.RUN:          key = "walk"
			Estado.ATTACK_LIGHT: key = "attack_light"
			Estado.ATTACK_HEAVY: key = "attack_heavy"
		if _texturas.has(key):
			sprite.texture = _texturas[key]
	else:
		visual.modulate = tint if _flash_t > 0.0 else _COLORES.get(estado, Color.WHITE)
		visual.scale.x  = _facing


func _gravedad(delta: float) -> void:
	var g: float = ProjectSettings.get_setting("physics/2d/default_gravity")
	if is_on_floor():
		if not _was_floor:
			_coyote = COYOTE
		velocity.y = 0.0
	else:
		var mult := FALL_MUL if velocity.y > 0.0 else 1.0
		if estado == Estado.JUMP and not Input.is_action_pressed("jump") and velocity.y < 0.0:
			mult = FALL_MUL
		velocity.y += g * mult * delta
	_was_floor = is_on_floor()


func _timers(delta: float) -> void:
	_coyote  = max(_coyote  - delta, 0.0)
	_jbuffer = max(_jbuffer - delta, 0.0)
	_atk_t   = max(_atk_t   - delta, 0.0)
	_dodge_t = max(_dodge_t - delta, 0.0)
	_hurt_t  = max(_hurt_t  - delta, 0.0)
	_hitbox_t= max(_hitbox_t- delta, 0.0)
	_inv_t   = max(_inv_t   - delta, 0.0)
	_flash_t = max(_flash_t  - delta, 0.0)

	if _inv_t <= 0.0:
		is_invincible = false
	if _hitbox_t <= 0.0:
		_cs_hl.disabled = true
		_cs_hh.disabled = true
	if _atk_t <= 0.0 and estado in [Estado.ATTACK_LIGHT, Estado.ATTACK_HEAVY]:
		estado = Estado.IDLE
	if _dodge_t <= 0.0 and estado == Estado.DODGE:
		estado = Estado.IDLE
	if _hurt_t <= 0.0 and estado == Estado.HURT:
		estado = Estado.IDLE


func _stamina_regen(delta: float) -> void:
	if estado in [Estado.IDLE, Estado.RUN, Estado.JUMP, Estado.FALL] and stamina < 100.0:
		stamina = min(stamina + 25.0 * delta, 100.0)
		stamina_changed.emit(stamina)


func _mover(delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		_facing = sign(dir)
		velocity.x = move_toward(velocity.x, dir * SPEED, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)


func _frenar(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)


func _salto() -> void:
	if Input.is_action_just_pressed("jump"):
		_jbuffer = BUFFER
	var puede := is_on_floor() or _coyote > 0.0
	if _jbuffer > 0.0 and puede:
		velocity.y = JUMP_VEL
		_coyote  = 0.0
		_jbuffer = 0.0
		estado   = Estado.JUMP
		AudioManager.play("jump")
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= CUT


func _ataque() -> void:
	if Input.is_action_just_pressed("attack_light"):
		estado   = Estado.ATTACK_LIGHT
		_atk_t   = 0.35
		_hitbox_t= 0.15
		_cs_hl.disabled = false
		AudioManager.play("atk_light")
	elif Input.is_action_just_pressed("attack_heavy"):
		if devocion <= 0:
			return
		devocion -= 1
		devocion_changed.emit(devocion)
		estado   = Estado.ATTACK_HEAVY
		_atk_t   = 0.55
		_hitbox_t= 0.20
		_cs_hh.disabled = false
		hitbox_heavy.set_meta("damage", int(25.0 * MandaSystem.modificador_ataque_pesado()))
		AudioManager.play("atk_heavy")


func _esquiva() -> void:
	if Input.is_action_just_pressed("dodge") and stamina >= 30.0:
		stamina -= 30.0
		stamina_changed.emit(stamina)
		estado    = Estado.DODGE
		_dodge_t  = 0.4
		is_invincible = true
		_inv_t    = 0.3
		velocity.x = _facing * SPEED * 2.2


func _fsm_update() -> void:
	if estado in [Estado.ATTACK_LIGHT, Estado.ATTACK_HEAVY,
				  Estado.DODGE, Estado.HURT, Estado.DEAD]:
		return
	estado = (Estado.RUN if abs(velocity.x) > 10.0 else Estado.IDLE) \
		if is_on_floor() else \
		(Estado.JUMP if velocity.y < 0.0 else Estado.FALL)


func recibir_daño(cantidad: int, dir_knockback: float = 0.0) -> void:
	if is_invincible or estado == Estado.DEAD:
		return
	hp = max(hp - cantidad, 0)
	hp_changed.emit(hp)
	is_invincible = true
	_inv_t      = 0.6
	velocity.x  = dir_knockback * 200.0
	velocity.y  = -150.0
	_flash_col  = Color(1.0, 0.15, 0.15, 1.0)
	_flash_t    = 0.35
	GameManager.shake_camera.emit(3.0)
	AudioManager.play("damage")
	if hp <= 0:
		_morir()
	else:
		estado  = Estado.HURT
		_hurt_t = 0.3


func _morir() -> void:
	estado   = Estado.DEAD
	velocity = Vector2.ZERO
	AudioManager.play("death")
	player_died.emit()


func ganar_gracia(cantidad: float) -> void:
	gracia += cantidad
	gracia_changed.emit(gracia)


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hitbox"):
		var dmg: int = area.get_meta("damage", 10)
		var kdir: float = sign(area.global_position.x - global_position.x)
		recibir_daño(dmg, kdir)
