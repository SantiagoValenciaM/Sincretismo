extends EnemyBase

const _P := [
	preload("res://assets/sprites/procesional/patrol_1.png"),
	preload("res://assets/sprites/procesional/patrol_2.png"),
	preload("res://assets/sprites/procesional/patrol_3.png"),
	preload("res://assets/sprites/procesional/patrol_4.png"),
	preload("res://assets/sprites/procesional/patrol_5.png"),
]
const _C := [
	preload("res://assets/sprites/procesional/chase_1.png"),
	preload("res://assets/sprites/procesional/chase_2.png"),
	preload("res://assets/sprites/procesional/chase_3.png"),
	preload("res://assets/sprites/procesional/chase_4.png"),
]
const _A := [
	preload("res://assets/sprites/procesional/attack_1.png"),
	preload("res://assets/sprites/procesional/attack_2.png"),
	preload("res://assets/sprites/procesional/attack_3.png"),
	preload("res://assets/sprites/procesional/attack_4.png"),
	preload("res://assets/sprites/procesional/attack_5.png"),
]

static var _frames_cache: SpriteFrames = null

var _post_swing: bool  = false
var _post_swing_t: float = 0.0

@onready var _sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	hp_max       = 40
	damage       = 15
	gracia_drop  = 8.0
	speed_patrol = 55.0
	speed_chase  = 130.0
	atk_cooldown = 1.2
	patrol_dist  = 80.0
	super._ready()
	_setup_sprite()


func _setup_sprite() -> void:
	if _frames_cache != null:
		_sprite.sprite_frames = _frames_cache
		_sprite.play("patrol")
		return

	var frames := SpriteFrames.new()
	frames.remove_animation("default")

	frames.add_animation("patrol")
	frames.set_animation_loop("patrol", true)
	frames.set_animation_speed("patrol", 8.0)
	for tex in _P:
		frames.add_frame("patrol", tex)

	frames.add_animation("chase")
	frames.set_animation_loop("chase", true)
	frames.set_animation_speed("chase", 12.0)
	for tex in _C:
		frames.add_frame("chase", tex)

	frames.add_animation("attack")
	frames.set_animation_loop("attack", false)
	frames.set_animation_speed("attack", 14.0)
	for tex in _A:
		frames.add_frame("attack", tex)

	_frames_cache = frames
	_sprite.sprite_frames = frames
	_sprite.play("patrol")


func _physics_process(delta: float) -> void:
	if _post_swing:
		_post_swing_t = max(_post_swing_t - delta, 0.0)
		if _post_swing_t <= 0.0:
			_post_swing = false
	super._physics_process(delta)
	if estado == Estado.DEAD:
		return
	_sprite.flip_h = _dir < 0.0
	var anim: String
	match estado:
		Estado.ATTACK:
			anim = "attack"
		Estado.CHASE:
			anim = "chase"
		_:
			anim = "patrol"
	if _sprite.animation != anim or (anim != "attack" and not _sprite.is_playing()):
		_sprite.play(anim)


func _flash_white() -> void:
	_sprite.modulate = Color(1.0, 0.3, 0.3, 1.0)
	var tw := create_tween()
	tw.tween_property(_sprite, "modulate", Color.WHITE, 0.25)


func do_attack() -> void:
	_atk_cd = atk_cooldown
	if _cs_hitbox:
		_cs_hitbox.position.x = abs(_cs_hitbox.position.x) * _dir
		_cs_hitbox.disabled = false
	get_tree().create_timer(0.15).timeout.connect(func(): _infligir_daño_directo())
	get_tree().create_timer(0.25).timeout.connect(func():
		if _cs_hitbox:
			_cs_hitbox.disabled = true
		_post_swing   = true
		_post_swing_t = 0.8
	)
	get_tree().create_timer(0.35).timeout.connect(func():
		if _player != null and abs(_player.global_position.x - global_position.x) > get_attack_range() + 20.0:
			estado = Estado.CHASE
	)


func recibir_daño(cantidad: int) -> void:
	var real: int = int(float(cantidad) * 1.5) if _post_swing else cantidad
	super.recibir_daño(real)


func get_attack_range() -> float:
	return 60.0
