extends Node3D
## Shows an estimation of the current beats per minute (BPM) and how to measure it
##
## The name of this script is a little deciving as it only shows the current
## BPM and the movements needed to measure it. The real BPM estimation is done in
## the "beat detection" region of the Hand script.

@onready var _label = $Label3D
@onready var _sprite = $AnimatedSprite3D
@onready var _metronome = $Metronome

var followed_nodes : Array[Hand] = [] ## The eligible nodes to be used.
## The currently used node, null means no suitable node found.
var main_node : Hand = null
var last_value : float ## The last retrived BPM value.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	main_node = null
	
	# Go trough the nodes to find one active
	for node : Node3D in followed_nodes:
		if node.active and main_node == null : main_node = node
		elif node.active and main_node != null : 
			_label.text = "Two nodes can't be active \n at the same time!"
			main_node = null
			break
	
	if main_node != null:
		last_value = main_node.estimated_bpm
		
		_sprite.visible = true
		_sprite.animation = str(main_node.beats)+" beats"
		_sprite.frame = main_node.state % main_node.beats
		
		_metronome.visible = false
		_metronome.process_mode = Node.PROCESS_MODE_DISABLED
		
		_label.text = str(snappedf(main_node.estimated_bpm, 0.1))
	else:
		_sprite.visible = false
		
		_metronome.visible = true
		_metronome.process_mode = Node.PROCESS_MODE_INHERIT
		_metronome.bpm = last_value
		
		if not followed_nodes.is_empty() :
			_label.text = "Please pess the grip button 
					of one controller.
					Last recorded BPM: " + str(snappedf(last_value, 0.1))


func _on_detection_zone_body_entered(body : Node3D) -> void:
	if body is Hand :
		followed_nodes.append(body)
	elif body.get_parent() is Hand :
		followed_nodes.append(body.get_parent())


func _on_detection_zone_body_exited(body : Node3D) -> void:
	followed_nodes.erase(body)
	if followed_nodes.is_empty() : 
		_label.text = "Please stand on the
				platfrom to begin.
				Last recorded BPM: " + str(snappedf(last_value, 0.1))
