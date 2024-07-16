@tool
extends Area3D

signal node_entered(emitter : String)

const CHAR_LENGTH := 0.025

@export var label := "Label" :
	set(newLabel):
		label = newLabel
		if _label_object != null : _label_object.text = label
		print("New label: "+label)
		if _label_object != null : update_size(newLabel)
@export var movement := 0.01

@onready var _hitbox : CollisionShape3D = $CollisionShape3D
@onready var _mesh : MeshInstance3D = $MeshInstance3D
@onready var _label_object : Label3D = $Label3D

func update_size(newLabel : String):
	_hitbox.shape.size.x = newLabel.length() * CHAR_LENGTH
	_mesh.mesh.size.x = newLabel.length() * CHAR_LENGTH

func _ready():
	_label_object.text = label
	_hitbox.shape = _hitbox.shape.duplicate()
	_mesh.mesh = _mesh.mesh.duplicate()
	update_size(label)

func _on_body_entered(_body):
	_mesh.position.z -= movement
	_label_object.position.z -= movement
	node_entered.emit(name)
	pass # Replace with function body.


func _on_body_exited(_body):
	_mesh.position.z += movement
	_label_object.position.z += movement
	pass # Replace with function body.
