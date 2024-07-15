@tool
extends Area3D

const CHAR_LENGTH := 0.025

@export var label := "Label" :
	set(newLabel):
		label = newLabel
		_label_object.text = label
		print("New label: "+label)
		update_size(newLabel)

@onready var _hitbox : CollisionShape3D = $CollisionShape3D
@onready var _mesh : MeshInstance3D = $MeshInstance3D
@onready var _label_object : Label3D = $Label3D

func update_size(newLabel : String):
	_hitbox.shape.size.x = newLabel.length() * CHAR_LENGTH
	_mesh.mesh.size.x = newLabel.length() * CHAR_LENGTH
