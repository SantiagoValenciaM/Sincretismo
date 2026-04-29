extends CanvasLayer

@onready var panel:       PanelContainer = $Panel
@onready var lbl_estado:  Label          = $Panel/VBox/LblEstado
@onready var btn_aceptar: Button         = $Panel/VBox/BtnRow/BtnAceptar
@onready var btn_rechazar: Button        = $Panel/VBox/BtnRow/BtnRechazar


func _ready() -> void:
	panel.visible = false
	btn_aceptar.pressed.connect(_on_aceptar)
	btn_rechazar.pressed.connect(_on_rechazar)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_M \
			and event.pressed and not event.echo:
		if panel.visible:
			panel.visible = false
		else:
			_mostrar()


func _mostrar() -> void:
	btn_aceptar.visible = true
	btn_rechazar.text   = "Rechazar"

	if MandaSystem.activa:
		lbl_estado.text     = "Manda activa — ataque pesado +40%"
		lbl_estado.modulate = Color(0.98, 0.655, 0.0)
		btn_aceptar.visible = false
		btn_rechazar.text   = "Cerrar"
	elif MandaSystem.cumplida:
		lbl_estado.text     = "Manda cumplida — bendición permanente"
		lbl_estado.modulate = Color(0.3, 1.0, 0.3)
		btn_aceptar.visible = false
		btn_rechazar.text   = "Cerrar"
	elif MandaSystem.rota:
		lbl_estado.text     = "Manda rota — sin beneficio"
		lbl_estado.modulate = Color(0.7, 0.7, 0.7)
		btn_aceptar.visible = false
		btn_rechazar.text   = "Cerrar"
	else:
		lbl_estado.text     = ""

	panel.visible = true


func _on_aceptar() -> void:
	MandaSystem.activar()
	panel.visible = false


func _on_rechazar() -> void:
	panel.visible = false
