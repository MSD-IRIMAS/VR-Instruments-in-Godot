extends Node3D

@onready var XRRig := $XRRig
@onready var TestRig := $TestRig

var xr_interface: XRInterface

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
		_activateXR()
	else:
		print("OpenXR not initialized, please check if your headset is connected")
		_deactivateXR()


func _activateXR():
	XRRig.visible = true
	XRRig.process_mode = Node.PROCESS_MODE_INHERIT
	
	TestRig.visible = false
	TestRig.process_mode = Node.PROCESS_MODE_DISABLED


func _deactivateXR():
	XRRig.visible = false
	XRRig.process_mode = Node.PROCESS_MODE_DISABLED
	
	TestRig.visible = true
	TestRig.process_mode = Node.PROCESS_MODE_INHERIT
