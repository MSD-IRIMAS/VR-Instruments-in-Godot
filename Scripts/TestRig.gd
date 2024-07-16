extends CharacterBody3D
## A multi-purpouse script for handleing player movement, camera mouvement
## and hands visibility and mouvement

const SPEED := 5.0 ## The max speed of the player, in meters per second
const JUMP_VELOCITY := 4.5 ## The speed of the jump, in meters per second
const HEIGHT := 0.8 ## The height of the player, in meters

## The increment the hand mooves on the Z axis when adjusting distance, in meters
@export var increment := 0.02
## The minimun distance ratio for counterbalancing the perspective effect, unitless
@export_range(0,1) var min_distance := 0.25
## The sensitivity of the mouse, unitless
@export_range(0,1) var mouse_sensitivity := 0.3

## The gravity from the project settings to be synced with RigidBody nodes. [br]
## The unit is meters per squared second. [br]
## Default 9.8
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var left_hand := $LeftHand ## The left hand node
@onready var right_hand := $RightHand ## The right hand node
@onready var camera := $Camera3D ## The camera

var _user_distance := 1.0
var _rotating := false

func _physics_process(delta : float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	#Calculate mouse position in world
	var screen_center := get_viewport().get_visible_rect().size / 2
	var max_length := screen_center.length()
	var mouse_pos := get_viewport().get_mouse_position()
	var distance_from_center := (mouse_pos - screen_center).length()
	var distance_ratio := distance_from_center / max_length
	if distance_ratio > 1: distance_ratio = 1
	if distance_ratio < min_distance: distance_ratio = min_distance
	var pos : Vector3 = camera.project_ray_origin(mouse_pos) \
			+ camera.project_ray_normal(mouse_pos) \
			* distance_ratio * _user_distance
	
	#Handles hands visibility and position
	if Input.is_action_pressed("debug_crl"): 
		left_hand.visible = true
		left_hand.process_mode = Node.PROCESS_MODE_INHERIT
		left_hand.global_position = pos
	else: 
		left_hand.visible = false
		left_hand.process_mode = Node.PROCESS_MODE_DISABLED
	
	if Input.is_action_pressed("debug_alt"): 
		right_hand.visible = true
		right_hand.process_mode = Node.PROCESS_MODE_INHERIT
		right_hand.global_position = pos
	else: 
		right_hand.visible = false
		right_hand.process_mode = Node.PROCESS_MODE_DISABLED
	
	#Handle couching
	if Input.is_action_just_pressed("debug_shift"):
		position.y /= 2
		$Camera3D.position.y /= 2
		$CollisionShape3D.shape.height /= 2
	if Input.is_action_just_released("debug_shift"):
		$Camera3D.position.y *= 2
		$CollisionShape3D.shape.height *= 2
		position.y *= 2
	
	#Handle mouse rotation activation
	_rotating = true if Input.is_action_pressed("debug_rotate") else false

func _unhandled_input(event: InputEvent) -> void:
	#Handle depth adjustement
	if event.is_action_pressed("ui_page_down"): _user_distance -= increment
	if event.is_action_pressed("ui_page_up"): _user_distance += increment
	
	#Handle mouse rotation
	if event is InputEventMouseMotion and _rotating:
		var mevent := event as InputEventMouseMotion
		rotate_y(deg_to_rad(-mevent.relative.x * mouse_sensitivity))
		camera.rotate_x(deg_to_rad(-mevent.relative.y * mouse_sensitivity))
