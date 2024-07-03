extends Node
## The third version of the xylophone script, it handles polyphony by intenciating
## note scripts with the right frequency to differents sound players.
@export var MAX_SPEED := 5.0 # In m/s
@export var movement := 0.01

@onready var Notes := $Notes


func _on_notes_note_begin(note: String, _velocity: float) -> void:
	# TESTING 
	#print(note + " note entered")
	
	var note_object := Notes.find_child(note) as Area3D
	var script := load("res://Scripts/note2.gd") as Script
	var pulse: float = Music.A * (1 + Music.NOTES[note]/12) if Music.NOTES[note] >= 0 \
			else Music.A * 1/(2**(-Music.NOTES[note]/12))
	
	note_object.set_meta("pulse", pulse)
	note_object.set_meta("volume", linear_to_db(remap(_velocity, 0, MAX_SPEED, 0, 1)))
	note_object.set_meta("movement", movement)
	
	var error := script.reload(true)
	# TESTING 
	#print(error)
	if error == Error.OK: note_object.set_script(script)
