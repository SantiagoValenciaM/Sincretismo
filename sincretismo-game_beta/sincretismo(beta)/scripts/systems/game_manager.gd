extends Node

var zone1_boss_defeated: bool = false
var current_save_slot: int    = 0

signal shake_camera(magnitude: float)


func _on_player_died() -> void:
	await get_tree().create_timer(1.5).timeout
	if CheckpointSystem.hay_checkpoint():
		CheckpointSystem.respawn()
	else:
		SceneTransition.fade_to("res://scenes/ui/GameOver.tscn")
