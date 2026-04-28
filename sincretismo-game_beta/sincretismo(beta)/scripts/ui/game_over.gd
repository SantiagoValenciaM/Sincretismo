extends Control

func _ready() -> void:
	get_tree().paused = false

func _on_btn_reiniciar_pressed() -> void:
	if CheckpointSystem.hay_checkpoint():
		CheckpointSystem.respawn()
	else:
		SceneTransition.fade_to("res://scenes/zones/Zone1.tscn")

func _on_btn_menu_pressed() -> void:
	SceneTransition.fade_to("res://scenes/ui/TitleScreen.tscn")
