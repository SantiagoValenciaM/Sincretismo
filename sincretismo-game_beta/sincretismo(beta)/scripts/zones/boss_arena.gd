extends Node2D

@onready var camera:    Camera2D        = $Camera2D
@onready var player:    CharacterBody2D = $Player
@onready var mayordomo: CharacterBody2D = $Mayordomo
@onready var hud:       CanvasLayer     = $HUD

var _shake_t:   float = 0.0
var _shake_mag: float = 0.0


func _ready() -> void:
	mayordomo.hp_changed.connect(_on_boss_hp)
	hud.mostrar_boss_bar("El Mayordomo", mayordomo.HP_MAX)
	if not GameManager.shake_camera.is_connected(_on_shake):
		GameManager.shake_camera.connect(_on_shake)


func _exit_tree() -> void:
	if GameManager.shake_camera.is_connected(_on_shake):
		GameManager.shake_camera.disconnect(_on_shake)


func _process(delta: float) -> void:
	if is_instance_valid(player):
		camera.global_position = player.global_position
	if _shake_t > 0.0:
		_shake_t -= delta
		camera.offset = Vector2(
			randf_range(-_shake_mag, _shake_mag),
			randf_range(-_shake_mag, _shake_mag)
		)
	else:
		camera.offset = Vector2.ZERO


func _on_shake(mag: float) -> void:
	_shake_t   = 0.2
	_shake_mag = mag


func _on_boss_hp(nuevo: int) -> void:
	hud.actualizar_boss_bar(nuevo)
