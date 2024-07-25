@tool
extends Node3D
## Tool script for dynamicaly creating buttons and managing them.


const PADDING := 0.1 ## The distance between two buttons, in meters.

var buttons_shown := true ## The state of the buttons.

## The template which is use to create the buttons.
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
	_on_instruments_body_entered(null)


func _on_instruments_body_entered(_body):
	if buttons_shown:
		#TESTING
		#print("Hide buttons")
		buttons_shown = false
		for i in Music.INSTRUMENTS.keys():
			var button : Node3D = find_child(i, true, false)
			button.visible = false
			button.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		#TESTING
		#print("Show buttons")
		buttons_shown = true 
		for i in Music.INSTRUMENTS.keys():
			var button : Node3D = find_child(i, true, false)
			button.visible = true
			button.process_mode = Node.PROCESS_MODE_INHERIT


func _on_node_entered(emitter: String):
	#TESTING
	#print(emitter+" pressed")
	get_parent().instrument = Music.INSTRUMENTS_NAMES.get(emitter)
