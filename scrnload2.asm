	org	$480
	fcc	"LOADING GFX2/4..."

	org	$4000
start	equ	screen2_start_c
screen2_start_c	includebin gfx2.raw
	end	start