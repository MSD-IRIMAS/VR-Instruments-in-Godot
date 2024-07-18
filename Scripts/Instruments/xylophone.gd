extends Node
## The first version of the Xylophone script
##
## The first version of the Xylophone script, supports polyphonia on one single
## speaker and multiple instrument sounds via the implementation of the Fourier
## Serie System.


## The modes avaiables.
enum MODES {SINGLE_NOTE, POLYPHONIC, FOURIER_SINGLE}

## The speed at wich the note will play at full volume, in meters per second.
@export var MAX_SPEED := 4.0
@export var movement := 0.01 ## The movement of the keys, in meters
@export var mode := MODES.SINGLE_NOTE ## The current mode.

## The current instrument (usefull only in FOURIER_SINGLE mode).
@export var instrument := Music.INSTRUMENTS_NAMES.SINE :
	set(new_instrument):
		print("New instrument: "+Music.INSTRUMENTS_NAMES.find_key(new_instrument))
		instrument = new_instrument
		_instrument_serie = FourierSerie.new( \
				Music.INSTRUMENTS[Music.INSTRUMENTS_NAMES.find_key(instrument)], \
				440)
		$Label3D.text = Music.INSTRUMENTS_NAMES.find_key(instrument)

@onready var _Notes := $Notes
@onready var _Player := $Player 

@onready var _instrument_serie := FourierSerie.new( \
		Music.INSTRUMENTS[Music.INSTRUMENTS_NAMES.find_key(instrument)], \
		440)

var _sample_hz := 22050.0 # Keep the number of samples to mix low, GDScript is not super fast.
var _pulse_hz := 440.0
var _phase := 0.0
var _active_notes : Array[String] = []

var _playback : AudioStreamPlayback = null
var _playing := false


func _reset_buffer() -> void:
	# Setting mix rate is only possible before play().
	_Player.stream.mix_rate = _sample_hz
	_Player.play()
	_playback = _Player.get_stream_playback()
	# WARNING `_fill_buffer` must be called *after* setting `playback`,
	# as `fill_buffer` uses the `playback` member variable.
	#_fill_buffer()


func _ready() -> void:
	_reset_buffer()


func _fill_buffer() -> void:
	var increment := 1 / _sample_hz
	
	var to_fill : int = _playback.get_frames_available()
	# TESTING 
	#print(to_fill)
	while to_fill > 0:
		_playback.push_frame(Vector2.ONE * sin(_phase * _pulse_hz * TAU)) # Audio frames are stereo.
		_phase = fmod(_phase + increment, 1.0)
		to_fill -= 1


func _fill_buffer_polyphonic() -> void:
	var increment := 1 / _sample_hz
	
	var to_fill : int = _playback.get_frames_available()
	# TESTING 
	#print(to_fill)
	while to_fill > 0:
		var x: float = 0.0
		for note in _active_notes:
			var pulse : float = Music.A * (1 + Music.NOTES[note]/12) \
					if Music.NOTES[note] >= 0 \
					else Music.A * 1/(2**(-Music.NOTES[note]/12))
			x += sin(_phase * pulse * TAU)
		_playback.push_frame(Vector2.ONE * x) # Audio frames are stereo.
		_phase = fmod(_phase + increment, 1.0)
		to_fill -= 1


func _fill_buffer_serie(serie : FourierSerie) -> void:
	var increment := 1 / _sample_hz
	
	var to_fill : int = _playback.get_frames_available()
	# TESTING 
	#print(to_fill)
	while to_fill > 0:
		var x := serie.compute(_phase)
		#print(x)
		_playback.push_frame(Vector2.ONE * x) # Audio frames are stereo.
		_phase = fmod(_phase + increment, 1.0)
		to_fill -= 1


## DEPRECATED: Use fill_buffer instead
## @deprecated
func _push() -> void:
	var increment := _pulse_hz / _sample_hz
	_playback.push_frame(Vector2.ONE * sin(_phase * TAU)) # Audio frames are stereo.
	_phase = fmod(_phase + increment, 1.0)


func _process(_delta : float) -> void:
	# TESTING
	#print(phase)
	if _playing : 
		if mode == MODES.SINGLE_NOTE: _fill_buffer()
		if mode == MODES.POLYPHONIC: _fill_buffer_polyphonic()
		if mode == MODES.FOURIER_SINGLE: _fill_buffer_serie(_instrument_serie)


func _on_notes_note_begin(note: String, velocity: float) -> void:
	# TESTING 
	#print(note + " note entered")
	#print(remap(_velocity, 0, MAX_SPEED, 0, 1))
	_Player.volume_db = linear_to_db(remap(velocity, 0, MAX_SPEED, 0, 1))
	
	var mesh := _Notes.find_child(note).get_node(^"MeshInstance3D") as MeshInstance3D
	mesh.position.y -= movement
	
	# TESTING 
	#print(NOTES[note])
	_active_notes.append(note)
	_pulse_hz = Music.A * (1 + Music.NOTES[note]/12) if Music.NOTES[note] >= 0 \
			else Music.A * 1/(2**(-Music.NOTES[note]/12))
	_instrument_serie.base_pulse = _pulse_hz
	# TESTING 
	#print(instrument_serie.base_pulse)
	
	_reset_buffer()
	_playing = true


func _on_notes_note_end(note: String) -> void:
	# TESTING 
	#print(note + " note exited")
	
	var mesh := _Notes.find_child(note).get_node("MeshInstance3D") as MeshInstance3D
	mesh.position.y += movement
	
	_active_notes.remove_at(_active_notes.find(note))
	
	_playing = false
	#Player.stop()
