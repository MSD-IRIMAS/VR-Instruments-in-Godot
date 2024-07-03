class_name Music
## "Static" class contianing all common data related to music.
##
## Static is quoted besause static classes does not exsist in GDScript,
## but all contents in this class are static.

## A dictionary linking notes names to their difference in semitones to the 
## reference note.
const NOTES := {
	"C" : -9.0,
	"C#" : -8.0,
	"D" : -7.0,
	"D#" : -6.0,
	"E" : -5.0,
	"F" : -4.0,
	"F#" : -3.0,
	"G" : -2.0,
	"G#" : -1.0,
	"A" : 0.0,
	"A#" : 1.0,
	"B" : 2.0
}

## An enum linking notes names to their difference in semitones to the 
## reference note.
enum NOTES_ENUM { C = -9, CS, D, DS, E, F , FS, G, GS, A, AS, B}

## The frenquency of the reference note, in Hertz
const A := 440.0

## A dictionary containing the sine coeficients of the fourier decomposition of some
## musical instruments.
const INSTRUMENTS := {
	"SINE" = [1.0],
	"SQARE" = [1, 0.5, 0.25, 0.0125],
	"FLUTE" = [1, 9, 4.6, 1.75, 0.25, 0.1],
	"OOBE" = [1, 0.95, 2.1, 0.2, 0.21, 0.25, 0.55, 0.3, 0.25, 0.01],
	"CLARINET" = [1, 0.375, 0.275, 0.01, 0.075, 0.2, 0.025],
	"HORN" = [1, 0.39, 0.24, 0.23, 0.08, 0.07, 0.08, 0.07, 0.06, 0.05, 0.04, 0.03, 0.02, 0.01],
	"GUITAR" = [1, 0.675, 1.25, 0.125, 0.125, 0.12, 0.01, 0.025, 0.175, 0.075, 0.02],
	"PIANO" = [1, 0.1, 0.325, 0.075, 0.7, 0.6, 0, 0.5]
}
