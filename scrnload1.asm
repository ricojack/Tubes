	org	$460
	fcc	"LOADING GFX1/4..."
	
	org	$4000
start	equ	screen1_start_c
screen1_start_c	includebin gfx1.raw
	end	start