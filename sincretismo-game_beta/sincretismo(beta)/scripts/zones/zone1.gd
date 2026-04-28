extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var player: CharacterBody2D = $Player
@onready var boss_door: Area2D = $BossDoor

var _shake_t: float = 0.0
var _shake_mag: float = 0.0


func _ready() -> void:
	boss_door.body_entered.connect(_on_boss_door)
	GameManager.shake_camera.connect(_on_shake)


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


func _on_boss_door(body: Node) -> void:
	if body.is_in_group("player"):
		SceneTransition.fade_to("res://scenes/zones/BossArena.tscn")
