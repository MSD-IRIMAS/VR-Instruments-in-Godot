class_name FourierSerie
## A Fourier's Serie, used here to (try to) reporduce any sound

var sin_coefs : Array ## The sine coeficients
var cos_coefs : Array ## The cosine coeficients
var base_pulse: float ## The base pulse in Hertz, i.e the pitch of the note


func _init(_sin_coefs : Array, _base_pulse: float, _cos_coefs : Array = []) -> void:
	sin_coefs = _sin_coefs
	cos_coefs = _cos_coefs
	base_pulse = _base_pulse
	
	_typecheck()
	_harmonize()


func _typecheck() -> void:
	for i in sin_coefs:
		if not(i is float or i is int):
			sin_coefs[sin_coefs.find(i)] = int(i)
	for i in cos_coefs:
		if not(i is float or i is int):
			cos_coefs[cos_coefs.find(i)] = int(i)


func _harmonize() -> void:
	if sin_coefs.size() > cos_coefs.size():
		var size_diff := sin_coefs.size() - cos_coefs.size()
		for i in range(size_diff): cos_coefs.append(0)
	
	if cos_coefs.size() > sin_coefs.size(): 
		var size_diff := cos_coefs.size() - sin_coefs.size()
		for i in range(size_diff): sin_coefs.append(0)


## Computes the series at the given phase and returns the result
func compute(phase : float) -> float:
	_harmonize()
	
	var ret := 0.0
	
	for i in range(sin_coefs.size()):
		ret += sin_coefs[i] * sin((i+1) * phase * base_pulse * TAU)
		ret += cos_coefs[i] * cos((i+1) * phase * base_pulse * TAU)
	
	return ret
