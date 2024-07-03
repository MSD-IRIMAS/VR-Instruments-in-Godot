extends Area3D
## Second version of the note script meant to be dynamicaly attached and detached
## of the notes objects as they are activated of deactivated.
##
## This version use metadata to pass information and customize the scipt instead
## of dynamicaly changing the source code.


var Player : AudioStreamPlayer3D = null
var mesh : MeshInstance3D = null

## The sample frequency, in Hertz.[br]
## Keep the number of samples to mix low, GDScript is not super fast.
var sample_hz := 22050.0
## The note's pulse in Hertz, fetched from the Object's metadata
var pulse_hz : float = get_meta("pulse")
var phase := 0.0

var playback : AudioStreamPlayback = null
var movement : float = get_meta("movement")

func _init() -> void:
	# TESTING print(pulse_hz)
	body_exited.connect(_on_body_exited)
	Player = $Player
	mesh = $MeshInstance3D
	
	set_process(true)
	mesh.position.y -= movement
	
	# Setting mix rate is only possible before play().
	Player.stream.mix_rate = sample_hz
	Player.volume_db = get_meta("volume")
	Player.play()
	playback = Player.get_stream_playback()
	# WARNING `_fill_buffer` must be called *after* setting `playback`,
	# as `fill_buffer` uses the `playback` member variable.
	fill_buffer()


func _ready() -> void:
	Player = $Player
	mesh = $MeshInstance3D
	
	mesh.position.y -= movement
	
	Player.stream.mix_rate = sample_hz
	Player.volume_db = get_meta("volume")
	Player.play()
	playback = Player.get_stream_playback()
	fill_buffer()

func fill_buffer() -> void:
	var increment := pulse_hz / sample_hz

	var to_fill : int = playback.get_frames_available()
	# TESTING 
	#print(to_fill)
	while to_fill > 0:
		playback.push_frame(Vector2.ONE * sin(phase * TAU)) # Audio frames are stereo.
		phase = fmod(phase + increment, 1.0)
		to_fill -= 1


func _process(_delta : float) -> void:
	fill_buffer()


func _on_body_exited(_body: Node3D) -> void:
	# TESTING 
	#print(body.name + " exited note")
	mesh.position.y += movement
	#Player.stop()
	body_exited.disconnect(_on_body_exited)
	# TESTING 
	#print("goodbye")
	set_script(null)
