
fontstart	equ	$f09d
fontend		equ	$f39c

	org	$e00
	
start	lds	#$dff
	pshs	cc
	orcc	#$50
	clr	$ffde	;rom/ram
	ldx	#fontstart
	ldy	#$2000
@end	bra	@end
	puls	cc
	
conversion_table fcc	$00,$00,$00,$00, $00,$00,$00,$0f, $00,$00,$00,$f0, $00,$00,$00,$ff
;	fcc		
;	fcc		
;	fcc		
; 256*4 table converting binary gfx to 16 color bitmask.	
	end	start