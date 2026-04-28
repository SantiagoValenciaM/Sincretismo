extends Area2D

@export var costo_gracia: float = 5.0

var _activado: bool = false

@onready var visual: ColorRect = $Visual
@onready var label:  Label     = $Label


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_actualizar_visual()
	# Si spawn point activo coincide con este altar, reposicionar jugador
	if CheckpointSystem.checkpoint_pos.distance_to(global_position) < 8.0:
		await get_tree().process_frame
		var players: Array = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			players[0].global_position = global_position + Vector2(0, -20)
			players[0].hp = players[0].hp_max
			players[0].hp_changed.emit(players[0].hp)


func _on_body_entered(body: Node) -> void:
	if _activado or not body.is_in_group("player"):
		return
	if not Input.is_action_just_pressed("interact"):
		return
	_usar(body)


func _input(event: InputEvent) -> void:
	if _activado:
		return
	if event.is_action_pressed("interact"):
		var players: Array = get_tree().get_nodes_in_group("player")
		for p in players:
			if p.global_position.distance_to(global_position) < 40.0:
				_usar(p)


func _usar(player: Node) -> void:
	if player.gracia < costo_gracia:
		return
	player.gracia -= costo_gracia
	player.gracia_changed.emit(player.gracia)
	player.hp = player.hp_max
	player.hp_changed.emit(player.hp)
	_activado = true
	_actualizar_visual()
	CheckpointSystem.registrar(global_position, get_tree().current_scene.scene_file_path)


func _actualizar_visual() -> void:
	if _activado:
		visual.color = Color(0.98, 0.655, 0.0, 1)
		label.text   = "✦"
	else:
		visual.color = Color(0.3, 0.3, 0.3, 1)
		label.text   = "†"
