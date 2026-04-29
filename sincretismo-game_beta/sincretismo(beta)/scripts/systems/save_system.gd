extends Node

const _DIR  := "user://saves/"
const _PATH := "user://saves/slot_%d.json"


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(_DIR)


func guardar(slot: int, data: Dictionary) -> void:
	var f := FileAccess.open(_PATH % slot, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()


func cargar(slot: int) -> Dictionary:
	if not FileAccess.file_exists(_PATH % slot):
		return {"vacio": true}
	var f := FileAccess.open(_PATH % slot, FileAccess.READ)
	if not f:
		return {"vacio": true}
	var txt := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(txt)
	if not parsed is Dictionary:
		return {"vacio": true}
	return parsed


func borrar(slot: int) -> void:
	var path := _PATH % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
