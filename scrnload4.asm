	org	$4c0
	fcc	"LOADING GFX4/4..."

	org	$4000
start	equ	screen4_start_c
screen4_start_c	includebin gfx4.raw
	end	start