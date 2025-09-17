
; Tiles should be in a single width strip

; draw tile:
; U - tile source
; Y - memptr (draw point)
__draw_tile pulu D,X
	std ,Y
	stx 2,Y
	leay 256,Y	; Jump 2 lines and write using negative offsets also
	pulu D,X
	std -128,Y
	stx -126,Y
	pulu D,X
	std ,Y
	stx 2,Y
	leay 256,Y
	pulu D,X
	std -128,Y
	stx -126,Y
	pulu D,X
	std ,Y
	stx 2,Y
	leay 256,Y
	pulu D,X
	std -128,Y
	stx -126,Y
	pulu D,X
	std ,Y
	stx 2,Y
	leay 127,Y	; max 8 bit forward offset
	std 1,Y
	stx 3,Y
	
	