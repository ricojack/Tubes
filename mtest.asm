
	org $e00
	
	include tubes.inc
start	tfr	cc,a
	sta	ccsv
	orcc	#$50
	jsr	task1
	clr	DSKREG
	clr	$ffdf	; all RAM mode
	clr	$ffd9	; speedup
	sts	stkstore

	jsr	initgfx
@a	bra	@a

	lds	stkstore
	lda	ccsv
	tfr	a,cc
	rts
stkstore rmb	2
ccsv	rmb	1

initgfx	lda	#$6c	;irqs on, constant vectors, scs
	sta	$ff90
	LDA     #$80
	STA     $FF98  ; Video mode: gfx
	LDA     #$7E
	STA     $FF99  ; 320x225x16
	ldd	#$c000
;	ldd	#$c000
;	ldd	#$ec00
	std	$ff9d	; set screen
	rts

task0	clr	$ff91
	rts
	
task1	lda	#$01
	sta	$ff91
	rts

	end	start