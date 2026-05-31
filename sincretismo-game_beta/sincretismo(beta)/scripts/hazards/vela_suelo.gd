extends Area2D

const DAÑO:      int   = 5
const INTERVALO: float = 0.5

static var _frames_cache: SpriteFrames = null

var _dentro: Array = []
var _timer:  float = 0.0
var _spr:    AnimatedSprite2D = null


func _ready() -> void:
	_spr = AnimatedSprite2D.new()
	_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_spr.position       = Vector2(0.0, -22.0)
	_spr.scale          = Vector2(0.21, 0.21)
	add_child(_spr)
	_setup_spr()
	body_entered.connect(func(b): if b.is_in_group("player"): _dentro.append(b))
	body_exited.connect(func(b): _dentro.erase(b))


func _setup_spr() -> void:
	if _frames_cache != null:
		_spr.sprite_frames = _frames_cache
		_spr.play("burn")
		return
	var tex := load("res://assets/sprites/env/vela_suelo.png") as Texture2D
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation("burn")
	frames.set_animation_loop("burn", true)
	frames.set_animation_speed("burn", 6.0)
	for i in 3:
		var at := AtlasTexture.new()
		at.atlas  = tex
		at.region = Rect2(i * 293, 0, 293, 215)
		frames.add_frame("burn", at)
	_frames_cache      = frames
	_spr.sprite_frames = frames
	_spr.play("burn")


func _process(delta: float) -> void:
	_dentro = _dentro.filter(func(b): return is_instance_valid(b))
	if _dentro.is_empty():
		_timer = 0.0
		return
	_timer -= delta
	if _timer <= 0.0:
		_timer = INTERVALO
		for b in _dentro:
			b.recibir_daño(DAÑO)
