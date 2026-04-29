extends Control

enum Seccion { PRINCIPAL, CONTINUAR, NUEVA, BORRAR, OPCIONES, CREDITOS, CARGANDO }

var seccion_actual: Seccion = Seccion.PRINCIPAL
var slot_seleccionado: int  = -1
var _borrar_idx: int        = -1

var slots_guardado: Array[Dictionary] = [
	{"vacio": true}, {"vacio": true}, {"vacio": true},
]

@onready var main_menu:           VBoxContainer    = $MainMenu
@onready var panel_slots:         PanelContainer   = $PanelSlots
@onready var panel_opciones:      PanelContainer   = $PanelOpciones
@onready var panel_creditos:      PanelContainer   = $PanelCreditos
@onready var modal_sobreescribir: PanelContainer   = $ModalSobreescribir
@onready var modal_borrar:        PanelContainer   = $ModalBorrar
@onready var pantalla_carga:      ColorRect        = $PantallaCarga
@onready var slots_container:     VBoxContainer    = $PanelSlots/VBox/SlotsContainer
@onready var panel_slots_titulo:  Label            = $PanelSlots/VBox/TitleLabel
@onready var slider_volumen:      HSlider          = $PanelOpciones/VBox/VolumenContainer/HSlider
@onready var check_fullscreen:    CheckButton      = $PanelOpciones/VBox/PantallaContainer/CheckButton


func _ready() -> void:
	for i in 3:
		slots_guardado[i] = SaveSystem.cargar(i)
	_mostrar_seccion(Seccion.PRINCIPAL)
	_actualizar_slots()


func _mostrar_seccion(nueva: Seccion) -> void:
	seccion_actual = nueva
	get_viewport().gui_release_focus()
	main_menu.visible      = (nueva == Seccion.PRINCIPAL)
	panel_slots.visible    = nueva in [Seccion.CONTINUAR, Seccion.NUEVA, Seccion.BORRAR]
	panel_opciones.visible = (nueva == Seccion.OPCIONES)
	panel_creditos.visible = (nueva == Seccion.CREDITOS)
	pantalla_carga.visible = (nueva == Seccion.CARGANDO)
	modal_sobreescribir.visible = false
	modal_borrar.visible        = false

	match nueva:
		Seccion.CONTINUAR: panel_slots_titulo.text = "Escoger Partida"
		Seccion.NUEVA:     panel_slots_titulo.text = "Nueva Promesa"
		Seccion.BORRAR:    panel_slots_titulo.text = "Borrar Partida"


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
				slot.get("nombre", "Promesero"),
				slot.get("nivel", 1),
				slot.get("tiempo", "00:00:00"),
				slot.get("zona", "La Parroquia"),
			]
			btn.add_theme_color_override("font_color", Color(0.98, 0.655, 0, 1.0))


# ── Secciones ──────────────────────────────────────────────────────────────

func _on_btn_continuar_pressed() -> void:    _mostrar_seccion(Seccion.CONTINUAR)
func _on_btn_nueva_pressed() -> void:        _mostrar_seccion(Seccion.NUEVA)
func _on_btn_opciones_pressed() -> void:     _mostrar_seccion(Seccion.OPCIONES)
func _on_btn_creditos_pressed() -> void:     _mostrar_seccion(Seccion.CREDITOS)
func _on_btn_borrar_partida_pressed() -> void: _mostrar_seccion(Seccion.BORRAR)
func _on_btn_salir_pressed() -> void:        get_tree().quit()
func _on_btn_volver_pressed() -> void:       _mostrar_seccion(Seccion.PRINCIPAL)


# ── Slots ──────────────────────────────────────────────────────────────────

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
		Seccion.BORRAR:
			if not slot.get("vacio", true):
				_borrar_idx = indice
				modal_borrar.visible = true


func _on_btn_confirmar_pressed() -> void:
	modal_sobreescribir.visible = false
	_iniciar_carga()

func _on_btn_cancelar_pressed() -> void:
	modal_sobreescribir.visible = false

func _on_btn_confirmar_borrar_pressed() -> void:
	if _borrar_idx >= 0:
		SaveSystem.borrar(_borrar_idx)
		slots_guardado[_borrar_idx] = {"vacio": true}
		_borrar_idx = -1
		_actualizar_slots()
	modal_borrar.visible = false

func _on_btn_cancelar_borrar_pressed() -> void:
	modal_borrar.visible = false
	_borrar_idx = -1


# ── Carga ──────────────────────────────────────────────────────────────────

func _iniciar_carga() -> void:
	var es_continuar := (seccion_actual == Seccion.CONTINUAR)
	GameManager.current_save_slot = slot_seleccionado
	_mostrar_seccion(Seccion.CARGANDO)

	if es_continuar:
		var slot := slots_guardado[slot_seleccionado]
		var scene: String = slot.get("checkpoint_scene", "res://scenes/zones/Zone1.tscn")
		var px: float = slot.get("checkpoint_pos_x", 0.0)
		var py: float = slot.get("checkpoint_pos_y", 0.0)
		if slot.has("checkpoint_scene"):
			CheckpointSystem.registrar(Vector2(px, py), scene)
		SceneTransition.fade_to(scene)
	else:
		CheckpointSystem.reset()
		SaveSystem.guardar(slot_seleccionado, {
			"vacio": false,
			"nombre": "Guerrero de la Fe",
			"nivel": 1,
			"zona": "La Parroquia",
			"tiempo": "00:00:00",
		})
		SceneTransition.fade_to("res://scenes/zones/Zone1.tscn")


# ── Opciones ───────────────────────────────────────────────────────────────

func _on_slider_volumen_value_changed(valor: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(valor / 100.0))

func _on_btn_fullscreen_toggled(activo: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if activo
		else DisplayServer.WINDOW_MODE_WINDOWED
	)
