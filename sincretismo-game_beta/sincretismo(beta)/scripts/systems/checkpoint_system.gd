extends Node

var checkpoint_pos: Vector2  = Vector2.ZERO
var checkpoint_scene: String = ""
var _active: bool            = false


func registrar(pos: Vector2, scene_path: String) -> void:
	checkpoint_pos   = pos
	checkpoint_scene = scene_path
	_active          = true


func hay_checkpoint() -> bool:
	return _active


func respawn() -> void:
	if not _active:
		return
	SceneTransition.fade_to(checkpoint_scene)


func reset() -> void:
	checkpoint_pos   = Vector2.ZERO
	checkpoint_scene = ""
	_active          = false
