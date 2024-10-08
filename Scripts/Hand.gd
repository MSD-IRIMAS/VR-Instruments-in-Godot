class_name RigHand
extends Node3D
## Manages the speed detection of the hand and the pluse detection system.

const UP_LEFT := Vector3.UP + Vector3.LEFT
const DOWN_LEFT := Vector3.DOWN + Vector3.LEFT

## The beat paterns
const PATERNS := {
	2 : [Vector3.DOWN, Vector3.UP],
	3 : [DOWN_LEFT, Vector3.RIGHT, UP_LEFT],
	4 : [Vector3.DOWN, UP_LEFT, Vector3.RIGHT, UP_LEFT]
}

## The maximum angle accepted for beat detection, 
## in degrees.
@export_range(0, 90, 0.5, "degrees") var MAX_ANGLE := 22.5
## The minimum distance the hand shall travel to count for beat detection, 
## in meters.
@export var MIN_DISTANCE := 0.05
## The minimum speed the hand shall travel to count for beat detection, 
## in meters per second.
@export var MIN_SPEED := 0.05

## The number of last beat lenghs to account for pulse calculation.
const CALCULATION_WINDOW_SIZE := 10

## The number of Frames per second, fetched from the project's settings, default 60.
var fps : int = ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 60)

## The current velocity in meters per second.
var velocity : float
## The last known position
@onready var last_position : Vector3
## All the recorded positions
@onready var recorded_positions : Array[Vector3] = []
## The reference node if it isn't the parent node
@export var deported_origin : Node3D

var _FingerHitbox : Node
var _HandHitbox : Node

@export_range(2, 4) var beats := 4 ## The number of beats per bar.
var state := 0 ## The current beat minus one.

var active := false ## Weather or not if the beat detection system is active
var elapsed_time := 0.0 ## The elapsed time in seconds since the last recorded beat.
var beat_lengths : Array[float] = [] ## The lengths of recorded beats.
var estimated_bpm : float ## The estimated pulse in beats per minute.

## Calculates the mean value of the passed list.
func mean(list : Array) -> float:
	var ret := 0.0
	for i in list:
		ret += i
	return ret / list.size()


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_node(".") is XRController3D:
		_FingerHitbox = $FingerHitbox
		_HandHitbox = $HandHitbox

	if deported_origin != null :
		last_position = position.rotated(Vector3.UP, deported_origin.rotation.y)
		recorded_positions.append(last_position)
	else:
		last_position = position
		recorded_positions.append(position)


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta : float) -> void:
	# Register variables and calculate velocity
	var movement := position - last_position if deported_origin == null \
			else position.rotated(Vector3.UP, deported_origin.rotation.y) - last_position
	velocity = movement.length() * fps
	last_position = position if deported_origin == null \
			else position.rotated(Vector3.UP, deported_origin.rotation.y)
	
	if active : elapsed_time += delta
	else : elapsed_time = 0
	
	# TESTING
	#print(velocity)
	
	#region beat detection
	# If the length between the two last points is longer than the minimun distance
	# and if the velocity is lower than the minimum speed...
	if active and (recorded_positions[-1] - last_position).length() >= MIN_DISTANCE \
	and velocity <= MIN_SPEED:
		# ...Add the position to the record
		recorded_positions.append(last_position)
		# TESTING
		#print(recorded_positions[-1])
		
		# Calculate the movement between the two last recorded positions...
		movement = recorded_positions[-1] - recorded_positions[-2]
		# TESTING
		#print(movement)
		
		# ... And use it to calculate the angle between the reference vector of
		# the current beat and this vector
		var angle := rad_to_deg(PATERNS[beats][state % beats].angle_to(movement))
		# TESTING
		#print(angle)
		
		# If this angle is equal of less than the max angle...
		if angle <= MAX_ANGLE :
			state += 1 # ... increment the state, ...
			beat_lengths.append(elapsed_time) # ... record the length ...
			elapsed_time = 0.0 # ... And reset the time
			
			# TESTING
			#print("Pass, go to state "+str(state % beats))
			#print(beat_lengths)
			
			# Here is where the BPM are calculated
			estimated_bpm = (1/mean(beat_lengths)) * 60 \
					if beat_lengths.size() < CALCULATION_WINDOW_SIZE \
					else (1/mean(beat_lengths.slice(-CALCULATION_WINDOW_SIZE))) * 60
			# TESTING
			#print(estimated_bpm)
	#endregion

func _activate_finger() -> void:
	_FingerHitbox.process_mode = Node.PROCESS_MODE_INHERIT
	_HandHitbox.process_mode = Node.PROCESS_MODE_DISABLED
	active = true


func _deactivate_finger() -> void:
	_FingerHitbox.process_mode = Node.PROCESS_MODE_DISABLED
	_HandHitbox.process_mode = Node.PROCESS_MODE_INHERIT
	active = false


func _on_button_pressed(button_name: String) -> void:
	# TESTING
	#print("Button "+name+" pressed")
	if button_name == "grip_click" : _activate_finger()



func _on_button_released(button_name: String) -> void:
	# TESTING
	#print("Button "+name+" released")
	if button_name == "grip_click" : _deactivate_finger()

