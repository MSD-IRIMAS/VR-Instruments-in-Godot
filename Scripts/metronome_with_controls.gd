extends Node3D
## Control script for the metronome

@onready var _metronome := $Metronome
@onready var _beats_label := $"Beats Selector/BeatsLabel"
@onready var _BPM_label := $"BPM Selector/BPMLabel"

func _on_minus_button_body_entered(_body : Node3D) -> void :
	if _metronome.beats > 2: _metronome.beats -= 1
	_beats_label.text = str(_metronome.beats)


func _on_plus_button_body_entered(_body : Node3D) -> void:
	if _metronome.beats < 4: _metronome.beats += 1
	_beats_label.text = str(_metronome.beats)


func _on_node_entered(emitter : String) -> void:
	if emitter == "MinusOneButton" and _metronome.bpm > 0:
		_metronome.bpm -= 1
	if emitter == "MinusFiveButton" and _metronome.bpm >= 5:
		_metronome.bpm -= 5
	if emitter == "PlusOneButton" and _metronome.bpm < 999:
		_metronome.bpm += 1
	if emitter == "PlusFiveButton" and _metronome.bpm < 995:
		_metronome.bpm += 5
	_BPM_label.text = str(_metronome.bpm)
