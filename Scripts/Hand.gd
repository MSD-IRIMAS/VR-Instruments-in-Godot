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
@export var MAX_ANGLE := 22.5
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
## The last known position, defaults to the starting position.
@onready var last_position := position
## All the recorded positions, staring with the starting position.
@onready var recorded_positions : Array[Vector3] = [position]

@export_range(2, 4) var beats := 2 ## The number of beats per bar.
var state := 0 ## The current beat minus one.

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
	pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta) -> void:
	# Register variables and calculate velocity
	var movement := position - last_position
	velocity = movement.length() * fps
	last_position = position
	
	elapsed_time += _delta
	
	# TESTING
	#print(velocity)
	
	if (recorded_positions[-1] - position).length() >= MIN_DISTANCE \
	and velocity <= MIN_SPEED:
		recorded_positions.append(position)
		# TESTING
		#print(recorded_positions[-1])
		
		movement = recorded_positions[-1] - recorded_positions[-2]
		# TESTING
		#print(movement)
		
		var angle := rad_to_deg(PATERNS[beats][state % beats].angle_to(movement))
		# TESTING
		#print(angle)
		
		if angle <= MAX_ANGLE :
			state += 1
			beat_lengths.append(elapsed_time)
			elapsed_time = 0.0
			
			# TESTING
			#print("Pass, go to state "+str(state % beats))
			#print(beat_lengths)
			
			estimated_bpm = (1/mean(beat_lengths)) * 60 \
					if beat_lengths.size() < CALCULATION_WINDOW_SIZE \
					else (1/mean(beat_lengths.slice(-CALCULATION_WINDOW_SIZE))) * 60
			# TESTING
			#print(estimated_bpm)
