extends Node

## Startup script for VR

@onready var _XRRig := $XRRig
@onready var _TestRig := $TestRig

var _xr_interface: XRInterface

func _ready():
	_xr_interface = XRServer.find_interface("OpenXR")
	if _xr_interface and _xr_interface.is_initialized():
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
	_XRRig.visible = true
	_XRRig.process_mode = Node.PROCESS_MODE_INHERIT
	
	_TestRig.visible = false
	_TestRig.process_mode = Node.PROCESS_MODE_DISABLED


func _deactivateXR():
	_XRRig.visible = false
	_XRRig.process_mode = Node.PROCESS_MODE_DISABLED
	
	_TestRig.visible = true
	_TestRig.process_mode = Node.PROCESS_MODE_INHERIT
