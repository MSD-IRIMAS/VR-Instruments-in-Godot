extends Node
## DEPRECATED: Use Xylophone3 instead
##
## The second version of the xylophone script it handles polyphony by intenciating
## note scripts with the right frequency to differents sound players. The freqency
## is tranfered by editing the source code and re-compileing it on the fly before
## attaching this (new) script to the node
##
## @deprecated

## A dictionary linking notes names to their difference in semitones to the 
## reference note.
const NOTES := {
	"C" : -9.0,
	"C#" : -8.0,
	"D" : -7.0,
	"D#" : -6.0,
	"E" : -5.0,
	"F" : -4.0,
	"F#" : -3.0,
	"G" : -2.0,
	"G#" : -1.0,
	"A" : 0.0,
	"A#" : 1.0,
	"B" : 2.0
}
const A := 440.0 ## The frenquency of the reference note, in Hertz.

@onready var Notes := $Notes ## The node containing the notes

var last_pulse := A ## The last recorded pulse, in Hertz.

func _on_notes_note_begin(note: String, _velocity: float) -> void:
	#TESTING print(note + " note entered")
	var script := load("res://Scripts/note.gd") as Script
	var pulse : float
	if NOTES[note] >= 0: 
		pulse = A * (1 + NOTES[note]/12)
		script.source_code = script.source_code.replace(str(last_pulse), str(pulse))
	else : 
		pulse = A * 1/(2**(-NOTES[note]/12))
		script.source_code = script.source_code.replace(str(last_pulse), str(pulse))
	#TESTING print(script.source_code)
	last_pulse = pulse
	var error := script.reload(true)
	#TESTING print(error)
	if error == Error.OK: Notes.find_child(note).set_script(script)
