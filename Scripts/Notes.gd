extends Object
## A multiplexing script to get one signal for all notes.

signal note_begin(note: String, velocity : float) ## Emited when a notes begins.
signal note_end(note: String) ## Emited when a note ends.

func _get_velocity(body: Node3D) -> float:
	if body is Hand :
		return body.velocity
	elif body.get_parent() is Hand :
		return body.get_parent().velocity
	else :
		push_error(ERR_BUG)
		return -1

func _on_c_body_entered(body: Node3D) -> void:
	note_begin.emit("C", _get_velocity(body))

func _on_c_body_exited(_body: Node3D) -> void:
	note_end.emit("C")


func _on_c_sharp_body_entered(body: Node3D) -> void:
	note_begin.emit("C#", _get_velocity(body))

func _on_c_sharp_body_exited(_body: Node3D) -> void:
	note_end.emit("C#")


func _on_d_body_entered(body: Node3D) -> void:
	note_begin.emit("D", _get_velocity(body))

func _on_d_body_exited(_body: Node3D) -> void:
	note_end.emit("D")


func _on_d_sharp_body_entered(body: Node3D) -> void:
	note_begin.emit("D#", _get_velocity(body))

func _on_d_sharp_body_exited(_body: Node3D) -> void:
	note_end.emit("D#")


func _on_e_body_entered(body: Node3D) -> void:
	note_begin.emit("E", _get_velocity(body))

func _on_e_body_exited(_body: Node3D) -> void:
	note_end.emit("E")


func _on_f_body_entered(body: Node3D) -> void:
	note_begin.emit("F", _get_velocity(body))

func _on_f_body_exited(_body: Node3D) -> void:
	note_end.emit("F")


func _on_f_sharp_body_entered(body: Node3D) -> void:
	note_begin.emit("F#", _get_velocity(body))

func _on_f_sharp_body_exited(_body: Node3D) -> void:
	note_end.emit("F#")


func _on_g_body_entered(body: Node3D) -> void:
	note_begin.emit("G", _get_velocity(body)) 

func _on_g_body_exited(_body: Node3D) -> void:
	note_end.emit("G")


func _on_g_sharp_body_entered(body: Node3D) -> void:
	note_begin.emit("G#", _get_velocity(body))

func _on_g_sharp_body_exited(_body: Node3D) -> void:
	note_end.emit("G#")


func _on_a_body_entered(body: Node3D) -> void:
	note_begin.emit("A", _get_velocity(body))

func _on_a_body_exited(_body: Node3D) -> void:
	note_end.emit("A")


func _on_a_sharp_body_entered(body) -> void:
	note_begin.emit("A#", _get_velocity(body))

func _on_a_sharp_body_exited(_body) -> void:
	note_end.emit("A#")


func _on_b_body_entered(body) -> void:
	note_begin.emit("B", _get_velocity(body))

func _on_b_body_exited(_body) -> void:
	note_end.emit("B")
