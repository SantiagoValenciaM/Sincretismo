extends CanvasLayer

@onready var bar_hp:      ProgressBar = $Panel/VBox/BarHP
@onready var bar_stamina: ProgressBar = $Panel/VBox/BarStamina
@onready var lbl_devocion: Label      = $Panel/VBox/InfoRow/LblDevocion
@onready var lbl_gracia:   Label      = $Panel/VBox/InfoRow/LblGracia
@onready var boss_bar_container: Control = $BossBarContainer
@onready var bar_boss: ProgressBar    = $BossBarContainer/BarBoss


func _ready() -> void:
	boss_bar_container.visible = false
	_conectar_player()


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
	bar_hp.max_value      = p.hp_max
	bar_hp.value          = p.hp
	bar_stamina.max_value = 100.0
	bar_stamina.value     = p.stamina
	lbl_devocion.text     = "Devoción: %d" % p.devocion
	lbl_gracia.text       = "Gracia: %.0f" % p.gracia


func _on_hp(nuevo: int) -> void:
	bar_hp.value = nuevo

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
