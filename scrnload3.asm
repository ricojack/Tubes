	org	$4a0
	fcc	"LOADING GFX3/4..."

	org	$4000
start	equ	screen3_start_c
screen3_start_c	includebin gfx3.raw
	end	start