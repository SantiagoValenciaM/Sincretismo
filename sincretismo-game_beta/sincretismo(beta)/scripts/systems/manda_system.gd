extends Node

var activa: bool    = false
var cumplida: bool  = false
var rota: bool      = false

signal manda_activada
signal manda_cumplida
signal manda_rota


func activar() -> void:
	if activa or cumplida:
		return
	activa = true
	var players: Array = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var p: Node = players[0]
	p.hp_max = int(float(p.hp_max) * 0.8)
	p.hp     = min(p.hp, p.hp_max)
	p.hp_changed.emit(p.hp)
	manda_activada.emit()


func cumplir() -> void:
	if not activa or cumplida:
		return
	activa   = false
	cumplida = true
	manda_cumplida.emit()


func romper() -> void:
	if not activa:
		return
	activa = false
	rota   = true
	var players: Array = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		var p: Node = players[0]
		p.hp_max = int(float(p.hp_max) / 0.8)
		p.recibir_daño(20)
	manda_rota.emit()


func modificador_ataque_pesado() -> float:
	return 1.4 if (activa or cumplida) else 1.0
