extends Area2D

@export var costo_gracia: float = 20.0

var _usado:  bool = false
var _player: Node = null

@onready var visual:       Sprite2D = $Visual
@onready var label_prompt: Label    = $LabelPrompt


func _ready() -> void:
	await get_tree().process_frame
	var players: Array = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		_player = players[0]
	if CheckpointSystem.hay_checkpoint() and \
			CheckpointSystem.checkpoint_pos.distance_to(global_position) < 8.0 and \
			_player != null:
		_player.global_position = global_position + Vector2(0, -20)
		_player.hp = _player.hp_max
		_player.hp_changed.emit(_player.hp)


func _process(_delta: float) -> void:
	if _usado or _player == null:
		label_prompt.visible = false
		return
	label_prompt.visible = _player.global_position.distance_to(global_position) < 65.0


func _input(event: InputEvent) -> void:
	if _usado or _player == null:
		return
	if event.is_action_pressed("interact"):
		if _player.global_position.distance_to(global_position) < 50.0:
			_usar(_player)


func _usar(player: Node) -> void:
	if player.gracia < costo_gracia:
		return
	player.gracia -= costo_gracia
	player.gracia_changed.emit(player.gracia)
	player.hp = player.hp_max
	player.hp_changed.emit(player.hp)
	_usado = true
	visual.frame = 1
	var scene := get_tree().current_scene.scene_file_path
	CheckpointSystem.registrar(global_position, scene)
	AudioManager.play("altar")
	SaveSystem.guardar(GameManager.current_save_slot, {
		"vacio": false,
		"nombre": "Guerrero de la Fe",
		"nivel": 1,
		"zona": "La Parroquia",
		"tiempo": "00:00:00",
		"checkpoint_scene": scene,
		"checkpoint_pos_x": global_position.x,
		"checkpoint_pos_y": global_position.y,
	})
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
