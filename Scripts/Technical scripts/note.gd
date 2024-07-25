extends Area3D
## DEPRECATED: use note2 instead (and see xylophone2 for more information)
##
## First version of the note script meant to be dynamicaly attached and detached
## of the notes objects as they are activated of deactivated.
## This source code is disigned to be dynamicaly changed to pass information
## between the instenciator and the instance (see xylophone2 for more information)
##
## @deprecated

var _Player : AudioStreamPlayer3D = null
var _mesh : MeshInstance3D = null

var _sample_hz : float = 22050.0 # Keep the number of samples to mix low, GDScript is not super fast.
var _pulse_hz : float = 440
var _phase := 0.0

var _playback : AudioStreamPlayback = null
var _movement := 0.01

func _init() -> void:
	#TESTING print(pulse_hz)
	body_exited.connect(_on_body_exited)
	_Player = $Player
	_mesh = $MeshInstance3D
	set_process(true)
	_mesh.position.y -= _movement
	# Setting mix rate is only possible before play().
	_Player.stream.mix_rate = _sample_hz
	_Player.play()
	_playback = _Player.get_stream_playback()
	#WARNING `_fill_buffer` must be called *after* setting `playback`,
	# as `fill_buffer` uses the `playback` member variable.
	_fill_buffer()

func _ready() -> void:
	_Player = $Player
	_mesh = $MeshInstance3D
	_mesh.position.y -= _movement
	_Player.stream.mix_rate = _sample_hz
	_Player.play()
	_playback = _Player.get_stream_playback()
	_fill_buffer()

func _fill_buffer() -> void:
	var increment := _pulse_hz / _sample_hz

	var to_fill : int = _playback.get_frames_available()
	#TESTING print(to_fill)
	while to_fill > 0:
		_playback.push_frame(Vector2.ONE * sin(_phase * TAU)) # Audio frames are stereo.
		_phase = fmod(_phase + increment, 1.0)
		to_fill -= 1

func _process(_delta : float) -> void:
	_fill_buffer()

func _on_body_exited(_body: Node3D) -> void:
	#TESTING print(body.name + " exited note")
	_mesh.position.y += _movement
	_Player.stop()
	body_exited.disconnect(_on_body_exited)
	#TESTING print("goodbye")
	set_script(null)
