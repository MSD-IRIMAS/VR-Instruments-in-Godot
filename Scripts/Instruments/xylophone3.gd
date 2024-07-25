extends Node
## The third version of the xylophone script.
##
## The third version of the xylophone script, it handles polyphony by intenciating
## note scripts with the right frequency to differents sound players. The frequency
## and movement is tranfered by adding metadata to the note object which is then read
## by the note script.

@export var MAX_SPEED := 5.0 ## The speed needed to play at the maximum volume. In m/s.
@export var movement := 0.01 ## The movement of the button when pressed. In meters.

@onready var _Notes := $Notes


func _on_notes_note_begin(note: String, _velocity: float) -> void:
	# TESTING 
	#print(note + " note entered")
	
	var note_object := _Notes.find_child(note) as Area3D
	var script := load("res://Scripts/Technical scripts/note2.gd") as Script
	var pulse: float = Music.A * (1 + Music.NOTES[note]/12) if Music.NOTES[note] >= 0 \
			else Music.A * 1/(2**(-Music.NOTES[note]/12))
	
	note_object.set_meta("pulse", pulse)
	note_object.set_meta("volume", linear_to_db(remap(_velocity, 0, MAX_SPEED, 0, 1)))
	note_object.set_meta("movement", movement)
	
	var error := script.reload(true)
	# TESTING 
	#print(error)
	if error == Error.OK: note_object.set_script(script)
