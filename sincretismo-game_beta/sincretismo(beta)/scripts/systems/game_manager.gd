extends Node

var zone1_boss_defeated: bool = false
var current_save_slot: int    = 0

signal shake_camera(magnitude: float)


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if node.is_in_group("player"):
		node.player_died.connect(_on_player_died)


func _on_player_died() -> void:
	await get_tree().create_timer(1.5).timeout
	SceneTransition.fade_to("res://scenes/ui/GameOver.tscn")
