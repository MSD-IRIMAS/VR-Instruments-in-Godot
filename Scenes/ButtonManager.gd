@tool
extends Node3D

const PADDING := 0.1

var buttons_shown := true
var button_template : PackedScene = load("res://Scenes/button.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var padding := PADDING
	for i in Music.INSTRUMENTS.keys():
		var button := button_template.instantiate()
		button.name = i
		button.label = i
		button.position.y = -padding
		button.node_entered.connect(_on_node_entered)
		add_child(button)
		padding += PADDING


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_instruments_body_entered(_body):
	if buttons_shown:
		print("Hide buttons")
		buttons_shown = false
	else:
		print("Show buttons")
		buttons_shown = true 

func _on_node_entered(emitter: String):
	print(emitter+" pressed")
