@tool
extends Area3D

const CHAR_LENGTH := 0.025

@export var label := "Label" :
	set(newLabel):
		label = newLabel
		_label_object.text = label
		print("New label: "+label)
		update_size(newLabel)
@export var movement := 0.01

@onready var _hitbox : CollisionShape3D = $CollisionShape3D
@onready var _mesh : MeshInstance3D = $MeshInstance3D
@onready var _label_object : Label3D = $Label3D

func update_size(newLabel : String):
	_hitbox.shape.size.x = newLabel.length() * CHAR_LENGTH
	_mesh.mesh.size.x = newLabel.length() * CHAR_LENGTH

func _ready():
	_label_object.text = label

func _on_body_entered(_body):
	position.z -= movement
	pass # Replace with function body.


func _on_body_exited(body):
	position.z += movement
	pass # Replace with function body.
