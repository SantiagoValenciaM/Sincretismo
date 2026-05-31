extends CanvasLayer

const _TEX_FULL  := preload("res://assets/sprites/ui/heart_full.png")
const _TEX_HALF  := preload("res://assets/sprites/ui/heart_half.png")
const _TEX_EMPTY := preload("res://assets/sprites/ui/heart_empty.png")

@onready var bar_hp:             ProgressBar = $Panel/VBox/BarHP
@onready var bar_stamina:        ProgressBar = $Panel/VBox/BarStamina
@onready var lbl_devocion:       Label       = $Panel/VBox/InfoRow/LblDevocion
@onready var lbl_gracia:         Label       = $Panel/VBox/InfoRow/LblGracia
@onready var lbl_almas:          Label       = $LblAlmas
@onready var boss_bar_container: Control     = $BossBarContainer
@onready var bar_boss:           ProgressBar = $BossBarContainer/BarBoss

var _ultimo_conteo: int   = -1
var _corazones:     Array[TextureRect] = []
var _hp_actual:     int   = 100
var _hp_max:        int   = 100
var _count_tick:    float = 0.0

const _COUNT_INTERVAL: float = 0.5


func _ready() -> void:
	boss_bar_container.visible = false
	_setup_corazones()
	_conectar_player()
	MandaSystem.hp_max_changed.connect(_on_hp_max_changed)


func _setup_corazones() -> void:
	bar_hp.visible = false
	var hbox := HBoxContainer.new()
	hbox.name = "CorazonesContainer"
	hbox.add_theme_constant_override("separation", 4)
	bar_hp.get_parent().add_child(hbox)
	bar_hp.get_parent().move_child(hbox, bar_hp.get_index())
	for i in 4:
		var tr := TextureRect.new()
		tr.texture             = _TEX_FULL
		tr.custom_minimum_size = Vector2(32, 32)
		tr.stretch_mode        = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.expand_mode         = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		hbox.add_child(tr)
		_corazones.append(tr)


func _actualizar_corazones() -> void:
	var hp_por_corazon: float = float(_hp_max) / 4.0
	for i in _corazones.size():
		var hp_en_slot: float = clampf(float(_hp_actual) - i * hp_por_corazon, 0.0, hp_por_corazon)
		if hp_en_slot > hp_por_corazon * 0.5:
			_corazones[i].texture = _TEX_FULL
		elif hp_en_slot > 0.0:
			_corazones[i].texture = _TEX_HALF
		else:
			_corazones[i].texture = _TEX_EMPTY


func _process(delta: float) -> void:
	_count_tick += delta
	if _count_tick < _COUNT_INTERVAL:
		return
	_count_tick = 0.0
	var conteo: int = get_tree().get_nodes_in_group("enemies").size()
	if conteo == _ultimo_conteo:
		return
	_ultimo_conteo = conteo
	lbl_almas.visible = conteo > 0
	lbl_almas.text = "%d alma%s" % [conteo, "s" if conteo != 1 else ""]


func _on_hp_max_changed(nuevo_max: int) -> void:
	_hp_max = nuevo_max
	_actualizar_corazones()


func _conectar_player() -> void:
	await get_tree().process_frame
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var p := players[0]
	p.hp_changed.connect(_on_hp)
	p.stamina_changed.connect(_on_stamina)
	p.devocion_changed.connect(_on_devocion)
	p.gracia_changed.connect(_on_gracia)
	_hp_actual        = p.hp
	_hp_max           = p.hp_max
	bar_stamina.max_value = 100.0
	bar_stamina.value     = p.stamina
	lbl_devocion.text     = "Devoción: %d" % p.devocion
	lbl_gracia.text       = "Gracia: %.0f" % p.gracia
	_actualizar_corazones()


func _on_hp(nuevo: int) -> void:
	_hp_actual = nuevo
	_actualizar_corazones()

func _on_stamina(nuevo: float) -> void:
	bar_stamina.value = nuevo

func _on_devocion(nuevo: int) -> void:
	lbl_devocion.text = "Devoción: %d" % nuevo

func _on_gracia(nuevo: float) -> void:
	lbl_gracia.text = "Gracia: %.0f" % nuevo


func mostrar_boss_bar(nombre: String, hp_max: int) -> void:
	boss_bar_container.visible = true
	bar_boss.max_value = hp_max
	bar_boss.value     = hp_max
	%LblBossNombre.text = nombre

func actualizar_boss_bar(hp: int) -> void:
	bar_boss.value = hp
