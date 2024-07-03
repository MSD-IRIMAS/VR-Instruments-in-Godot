extends Node3D

const MAX_SPEED := 4.0
enum MODES {SINGLE_NOTE, POLYPHONIC, FOURIER_SINGLE}

@export var movement := 0.01
@export_enum("Single note", "Polyphonic", "Fourier serie single note") var mode : int

@onready var Notes := $Notes
@onready var Player := $Player

var sample_hz := 22050.0 # Keep the number of samples to mix low, GDScript is not super fast.
var pulse_hz := 440.0
var phase := 0.0
var active_notes : Array[String] = []
var instrument := FourierSerie.new(Music.INSTRUMENTS.SINE, 440)

var playback : AudioStreamPlayback = null
var playing := false


func _ready() -> void:
	# Setting mix rate is only possible before play().
	Player.stream.mix_rate = sample_hz
	Player.play()
	playback = Player.get_stream_playback()
	# WARNING `_fill_buffer` must be called *after* setting `playback`,
	# as `fill_buffer` uses the `playback` member variable.
	#_fill_buffer()


func fill_buffer() -> void:
	var increment := 1 / sample_hz
	
	var to_fill : int = playback.get_frames_available()
	# TESTING 
	#print(to_fill)
	while to_fill > 0:
		playback.push_frame(Vector2.ONE * sin(phase * pulse_hz * TAU)) # Audio frames are stereo.
		phase = fmod(phase + increment, 1.0)
		to_fill -= 1


func fill_buffer_polyphonic() -> void:
	var increment := 1 / sample_hz
	
	var to_fill : int = playback.get_frames_available()
	# TESTING 
	#print(to_fill)
	while to_fill > 0:
		var x: float = 0.0
		for note in active_notes:
			var pulse : float = Music.A * (1 + Music.NOTES[note]/12) \
					if Music.NOTES[note] >= 0 \
					else Music.A * 1/(2**(-Music.NOTES[note]/12))
			x += sin(phase * pulse * TAU)
		playback.push_frame(Vector2.ONE * x) # Audio frames are stereo.
		phase = fmod(phase + increment, 1.0)
		to_fill -= 1

func fill_buffer_serie(serie : FourierSerie) -> void:
	var increment := 1 / sample_hz
	
	var to_fill : int = playback.get_frames_available()
	# TESTING 
	#print(to_fill)
	while to_fill > 0:
		var x := serie.compute(phase)
		#print(x)
		playback.push_frame(Vector2.ONE * x) # Audio frames are stereo.
		phase = fmod(phase + increment, 1.0)
		to_fill -= 1

## DEPRECATED: Use fill_buffer instead
## @deprecated
func push() -> void:
	var increment := pulse_hz / sample_hz
	playback.push_frame(Vector2.ONE * sin(phase * TAU)) # Audio frames are stereo.
	phase = fmod(phase + increment, 1.0)

func _process(_delta : float) -> void:
	# TESTING
	#print(phase)
	if playing : 
		if mode == MODES.SINGLE_NOTE: fill_buffer()
		if mode == MODES.POLYPHONIC: fill_buffer_polyphonic()
		if mode == MODES.FOURIER_SINGLE: fill_buffer_serie(instrument)

func _on_notes_note_begin(note: String, _velocity: float) -> void:
	# TESTING 
	#print(note + " note entered")
	print(remap(_velocity, 0, MAX_SPEED, 0, 1))
	Player.volume_db = linear_to_db(remap(_velocity, 0, MAX_SPEED, 0, 1))
	
	var mesh := Notes.find_child(note).get_node(^"MeshInstance3D") as MeshInstance3D
	mesh.position.y -= movement
	
	# TESTING 
	#print(NOTES[note])
	active_notes.append(note)
	pulse_hz = Music.A * (1 + Music.NOTES[note]/12) if Music.NOTES[note] >= 0 \
			else Music.A * 1/(2**(-Music.NOTES[note]/12))
	instrument.base_pulse = pulse_hz
	# TESTING 
	#print(pulse_hz)
	
	_ready()
	playing = true


func _on_notes_note_end(note: String) -> void:
	# TESTING 
	#print(note + " note exited")
	
	var mesh := Notes.find_child(note).get_node("MeshInstance3D") as MeshInstance3D
	mesh.position.y += movement
	
	active_notes.remove_at(active_notes.find(note))
	
	playing = false
	#Player.stop()
