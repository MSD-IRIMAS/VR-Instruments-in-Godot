extends Node3D
## Shows an estimation of the current beats per minute (BPM) and how to measure it
##
## The name of this script is a little deciving as it only shows the current
## BPM and the movements needed to measure it. The real BPM estimation is done in
## the "beat detection" region of the Hand script.

@onready var _label = $BPMLabel
@onready var _sprite = $AnimatedSprite3D
@onready var _metronome = $Metronome
@onready var _beats_label = $BeatsLabel

var followed_nodes : Array[Hand] = [] ## The eligible nodes to be used.
## The currently used node, null means no suitable node found.
var main_node : Hand = null
var last_value : float ## The last retrived BPM value.
var last_beats : int = 4 ## The last retrived Beats value.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	var error := false
	main_node = null
	
	# Go trough the nodes to find one active
	for node : Hand in followed_nodes:
		if node.active and main_node == null : main_node = node
		elif node.active and main_node != null : 
			_label.text = "Two hands can't be active \n at the same time!"
			main_node = null
			error = true
			break
	
	if main_node != null:
		last_value = main_node.estimated_bpm
		#last_beats = main_node.beats
		
		_sprite.visible = true
		_sprite.animation = str(main_node.beats)+" beats"
		_sprite.frame = main_node.state % main_node.beats
		
		_metronome.visible = false
		_metronome.process_mode = Node.PROCESS_MODE_DISABLED
		
		_label.text = str(snappedf(main_node.estimated_bpm, 0.1))
	else:
		_sprite.visible = false
		
		if not error:
			_metronome.visible = true
			_metronome.process_mode = Node.PROCESS_MODE_INHERIT
			_metronome.bpm = last_value
			_metronome.beats = last_beats
			
			if not followed_nodes.is_empty():
				_label.text = "Please pess the grip button 
						of one controller.
						Last recorded BPM: " + str(snappedf(last_value, 0.1))


func _on_detection_zone_body_entered(body : Node3D) -> void:
	#TESTING
	#print("node "+body.name+" entered")
	if body is Hand :
		followed_nodes.append(body)
	elif body.get_parent() is Hand :
		followed_nodes.append(body.get_parent())


func _on_detection_zone_body_exited(body : Node3D) -> void:
	#TESTING
	#print("node "+body.name+" exited")
	followed_nodes.erase(body)
	followed_nodes.erase(body.get_parent())
	if followed_nodes.is_empty() : 
		_label.text = "Please stand on the
				platfrom to begin.
				Last recorded BPM: " + str(snappedf(last_value, 0.1))


func _on_minus_button_body_entered(_body):
	if last_beats > 2: last_beats -= 1
	_beats_label.text = str(last_beats)
	for hand : Hand in followed_nodes: hand.beats = last_beats
	pass # Replace with function body.


func _on_plus_button_body_entered(_body):
	if last_beats < 4: last_beats += 1
	_beats_label.text = str(last_beats)
	for hand : Hand in followed_nodes: hand.beats = last_beats
	pass # Replace with function body.
