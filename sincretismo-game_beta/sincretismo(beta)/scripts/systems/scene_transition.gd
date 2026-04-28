extends CanvasLayer

var _overlay: ColorRect
var _busy: bool = false


func _ready() -> void:
	layer = 128
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)


func fade_to(path: String) -> void:
	if _busy:
		return
	_busy = true
	var tw := create_tween()
	tw.tween_property(_overlay, "color", Color(0, 0, 0, 1), 0.5)
	await tw.finished
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	tw = create_tween()
	tw.tween_property(_overlay, "color", Color(0, 0, 0, 0), 0.5)
	await tw.finished
	_busy = false
