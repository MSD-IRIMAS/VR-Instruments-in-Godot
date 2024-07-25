@tool
extends Area3D
## Tool script for a self-resizing button.


## Similar to [signal Area3D.body_entered] but passes the node name instead of
## the coliding object.
signal node_entered(emitter : String)

const CHAR_LENGTH := 0.025 ## The length of a character, in meters.

## The label of the button
@export var label := "Label" :
	set(newLabel):
		label = newLabel
		if _label_object != null : _label_object.text = label
		#TESTING
		#print("New label: "+label)
		if _label_object != null : _update_size(newLabel)

## The movement of the button when pressed, in meters
@export var movement := 0.01

@onready var _hitbox : CollisionShape3D = $CollisionShape3D
@onready var _mesh : MeshInstance3D = $MeshInstance3D
@onready var _label_object : Label3D = $Label3D


func _update_size(newLabel : String):
	_hitbox.shape.size.x = newLabel.length() * CHAR_LENGTH
	_mesh.mesh.size.x = newLabel.length() * CHAR_LENGTH


func _ready():
	_label_object.text = label
	if get_parent() != null:
		_hitbox.shape = _hitbox.shape.duplicate()
		_mesh.mesh = _mesh.mesh.duplicate()
	_update_size(label)


func _on_body_entered(_body):
	_mesh.position.z -= movement
	_label_object.position.z -= movement
	node_entered.emit(name)
	pass # Replace with function body.


func _on_body_exited(_body):
	_mesh.position.z += movement
	_label_object.position.z += movement
	pass # Replace with function body.
