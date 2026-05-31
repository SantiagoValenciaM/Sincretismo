extends CanvasLayer

@onready var overlay: ColorRect    = $Overlay
@onready var panel:   PanelContainer = $Panel


func _ready() -> void:
	overlay.visible = false
	panel.visible   = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		_toggle()


func _toggle() -> void:
	var pausing := not get_tree().paused
	get_tree().paused = pausing
	overlay.visible   = pausing
	panel.visible     = pausing


func _on_btn_reanudar_pressed() -> void:
	_toggle()


func _on_btn_menu_pressed() -> void:
	get_tree().paused = false
	overlay.visible   = false
	panel.visible     = false
	SceneTransition.fade_to("res://scenes/ui/TitleScreen.tscn")


func _on_btn_salir_pressed() -> void:
	get_tree().quit()
