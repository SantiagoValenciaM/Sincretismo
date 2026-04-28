extends Control

enum Seccion { PRINCIPAL, CONTINUAR, NUEVA, OPCIONES, CREDITOS, CARGANDO }

var seccion_actual: Seccion = Seccion.PRINCIPAL
var slot_seleccionado: int = -1

var slots_guardado: Array[Dictionary] = [
	{"nombre": "Guerrero de la Fe", "nivel": 1, "tiempo": "00:00:00", "zona": "La Parroquia", "vacio": false},
	{"vacio": true},
	{"vacio": true},
]

@onready var main_menu: VBoxContainer = $MainMenu
@onready var panel_slots: PanelContainer = $PanelSlots
@onready var panel_opciones: PanelContainer = $PanelOpciones
@onready var panel_creditos: PanelContainer = $PanelCreditos
@onready var modal_sobreescribir: PanelContainer = $ModalSobreescribir
@onready var pantalla_carga: ColorRect = $PantallaCarga

@onready var slots_container: VBoxContainer = $PanelSlots/VBox/SlotsContainer
@onready var panel_slots_titulo: Label = $PanelSlots/VBox/TitleLabel
@onready var slider_volumen: HSlider = $PanelOpciones/VBox/VolumenContainer/HSlider
@onready var check_fullscreen: CheckButton = $PanelOpciones/VBox/PantallaContainer/CheckButton


func _ready() -> void:
	_mostrar_seccion(Seccion.PRINCIPAL)
	_actualizar_slots()


func _mostrar_seccion(nueva: Seccion) -> void:
	seccion_actual = nueva
	get_viewport().gui_release_focus()
	main_menu.visible        = (nueva == Seccion.PRINCIPAL)
	panel_slots.visible      = (nueva == Seccion.CONTINUAR or nueva == Seccion.NUEVA)
	panel_opciones.visible   = (nueva == Seccion.OPCIONES)
	panel_creditos.visible   = (nueva == Seccion.CREDITOS)
	pantalla_carga.visible   = (nueva == Seccion.CARGANDO)
	modal_sobreescribir.visible = false

	if nueva == Seccion.CONTINUAR:
		panel_slots_titulo.text = "Escoger Partida"
	elif nueva == Seccion.NUEVA:
		panel_slots_titulo.text = "Nueva Promesa"


func _actualizar_slots() -> void:
	var btns: Array[Node] = slots_container.get_children()
	for i in btns.size():
		var btn := btns[i] as Button
		var slot := slots_guardado[i]
		if slot.get("vacio", true):
			btn.text = "[ Vacío ]"
			btn.add_theme_color_override("font_color", Color(0.98, 0.655, 0, 0.5))
		else:
			btn.text = "%s\nNivel %d  •  %s  •  %s" % [
				slot["nombre"], slot["nivel"], slot["tiempo"], slot["zona"]
			]
			btn.add_theme_color_override("font_color", Color(0.98, 0.655, 0, 1.0))


func _on_btn_continuar_pressed() -> void:
	_mostrar_seccion(Seccion.CONTINUAR)

func _on_btn_nueva_pressed() -> void:
	_mostrar_seccion(Seccion.NUEVA)

func _on_btn_opciones_pressed() -> void:
	_mostrar_seccion(Seccion.OPCIONES)

func _on_btn_creditos_pressed() -> void:
	_mostrar_seccion(Seccion.CREDITOS)

func _on_btn_salir_pressed() -> void:
	get_tree().quit()

func _on_btn_volver_pressed() -> void:
	_mostrar_seccion(Seccion.PRINCIPAL)


func _on_slot_pressed(indice: int) -> void:
	slot_seleccionado = indice
	var slot := slots_guardado[indice]

	match seccion_actual:
		Seccion.CONTINUAR:
			if not slot.get("vacio", true):
				_iniciar_carga()
		Seccion.NUEVA:
			if not slot.get("vacio", true):
				modal_sobreescribir.visible = true
			else:
				_iniciar_carga()

func _on_btn_confirmar_pressed() -> void:
	modal_sobreescribir.visible = false
	_iniciar_carga()

func _on_btn_cancelar_pressed() -> void:
	modal_sobreescribir.visible = false

func _iniciar_carga() -> void:
	SceneTransition.fade_to("res://scenes/zones/Zone1.tscn")


func _on_slider_volumen_value_changed(valor: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(valor / 100.0))

func _on_btn_fullscreen_toggled(activo: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if activo
		else DisplayServer.WINDOW_MODE_WINDOWED
	)
