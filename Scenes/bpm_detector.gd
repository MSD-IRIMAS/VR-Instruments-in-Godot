extends Node3D

@onready var _label = $Label3D
@onready var _sprite = $AnimatedSprite3D

var followed_nodes : Array[Node3D] = []
var main_node : Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	main_node = null
	
	for node : Node3D in followed_nodes:
		if node.active and main_node == null : main_node = node
		elif node.active and main_node != null : 
			_label.text = "Two nodes can't be active \n at the same time!"
			main_node = null
			break
	
	if main_node != null:
		_sprite.visible = true
		_sprite.animation = str(main_node.beats)+" beats"
		_sprite.frame = main_node.state % main_node.beats
		_label.text = str(snappedf(main_node.estimated_bpm, 0.1))
	else:
		_sprite.visible = false
		if not followed_nodes.is_empty() :
			_label.text = "Please pess the grip button \n of one controller"


func _on_detection_zone_body_entered(body : Node3D) -> void:
	if body.has_method("get_velocity") :
		followed_nodes.append(body)
	elif body.get_parent().has_method("get_velocity") :
		followed_nodes.append(body.get_parent())


func _on_detection_zone_body_exited(body : Node3D) -> void:
	followed_nodes.erase(body)
	if followed_nodes.is_empty() : 
		_label.text = "Please stand on the \n platfrom to begin"
