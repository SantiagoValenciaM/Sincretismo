extends Area2D

@export var costo_gracia: float = 20.0

var _usado: bool = false

@onready var visual:       ColorRect = $Visual
@onready var label:        Label     = $Label
@onready var label_prompt: Label     = $LabelPrompt


func _process(_delta: float) -> void:
	if _usado:
		label_prompt.visible = false
		return
	var players: Array = get_tree().get_nodes_in_group("player")
	label_prompt.visible = not players.is_empty() and \
		players[0].global_position.distance_to(global_position) < 65.0


func _input(event: InputEvent) -> void:
	if _usado or not event.is_action_pressed("interact"):
		return
	var players: Array = get_tree().get_nodes_in_group("player")
	for p in players:
		if p.global_position.distance_to(global_position) < 50.0:
			_usar(p)


func _usar(player: Node) -> void:
	if player.gracia < costo_gracia:
		return
	player.gracia -= costo_gracia
	player.gracia_changed.emit(player.gracia)
	player.hp = player.hp_max
	player.hp_changed.emit(player.hp)
	_usado = true
	visual.color = Color(0.98, 0.655, 0.0, 1)
	label.text   = "★"
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
