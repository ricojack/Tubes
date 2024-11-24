
	org $e00
start	ldx #$400
	lda #$41
@a	sta ,x+
	cmpx #$500
	ble @a
	
	ldx #$ffb0
	clra
	ldb #$10
@b	sta ,x+
	decb
	bne @b
	clr DSKREG
	rts
;	bne @a
;@b	bra @b
	end start