extends Node3D
## A script for a metronome.

@export var bpm : float = 120 ## The BPM of the metronome
## The number of beats in one bar
@export var beats := 4 :
	set(new_beats):
		if new_beats > 0 : beats = new_beats
		else : beats = 1

var _sample_hz := 22050.0 # Keep the number of samples to mix low, GDScript is not super fast.
var _pulse_hz := 220.0
var _phase := 0.0
var _playback : AudioStreamPlayback = null

var _state := 0

@onready var _Player := $Player
@onready var _Timer := $Timer
@onready var _Button := $Button


func _fill_buffer() -> void:
	var increment := 1 / _sample_hz
	
	var to_fill : int = _playback.get_frames_available()
	# TESTING 
	#print(to_fill)
	while to_fill > 0:
		_playback.push_frame(Vector2.ONE * sin(_phase * _pulse_hz * TAU)) # Audio frames are stereo.
		_phase = fmod(_phase + increment, 1.0)
		to_fill -= 1


# Called when the node enters the scene tree for the first time.
func _ready():
	_Player.stream.mix_rate = _sample_hz
	_Player.play()
	_playback = _Player.get_stream_playback()


func _on_button_node_entered(emitter):
	if _Timer.is_stopped():
		_Button.label = "Stop Metronome"
		_Timer.start(60.0/bpm)
	else:
		_Button.label = "Start Metronome"
		_Timer.stop()


func _on_timer_timeout():
	if _state % beats == 0: _pulse_hz *= 2
	if _state % beats == 1: _pulse_hz /= 2
	_state += 1
	_fill_buffer()
