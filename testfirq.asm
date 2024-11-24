	org	$e00
	include tubes.inc
	
start	orcc	#$50
	lds	#$dff
	clr	$ff40
	clr	$ffdf	; all RAM mode
	clr	$ffd9	; speedup
	clr	$ff9a
	clr	$ffb0
	jsr	inittask
	jsr	initpia
	jsr	task0
	jsr	initirq
	jsr	clr_gfx_scrn
	jsr	initgfx
	andcc	#$af
@x	bra	@x

clr_gfx_scrn	clra
	clrb
	ldx	#$8000
@lp	std	,x++
	cmpx	#$f800
	bne	@lp
	rts

initirq lda	#$08
	sta	$ff92
	lda	#$10
	sta	$ff93
	rts
	
initgfx	lda	#$7c	;irqs on, constant vectors, scs
	sta	$ff90
	LDA     #$80
	STA     $FF98  ; Video mode: gfx
	LDA     #$1E
	STA     $FF99  ; 320x192x16
	ldd	#$f000
;	ldd	#$c000
;	ldd	#$ec00
	std	$ff9d	; set screen
	ldd	#vsyncirq
	std	$fef8
	ldd	#hsyncirq
	std	$fef5
	lda	#$7e	;jmp
	sta	$fef7
	sta	$fef4
;	lda	#irq_cyc_max
;	sta	irq_cyc_time
;	ldd	#irq_cyc_start
;	std	irq_cyc_ptr
	rts

inittask ldx	#task0blks
	ldy	#$ffa0
	ldb	#$08
@lp	ldu	,x++
	stu	,y++
	decb
	bne	@lp
	rts
	
task0	clr	$ff91
	rts
	
task1	lda	#$01
	sta	$ff91
	rts

hsyncirq bita	$ff93	;5
	inc	$ffb0
;	sta	_f_sva+1	;5
;_bgidx	lda	spritetable	;5
;	sta	$ffb4	;5
;	inc	_bgidx+2	;7
;_f_sva	lda	#$00	;2
	rti	;6
	
vsyncirq lda	$ff92
	clr	$ffb0
;	com	$ff9a
;	lda	$ff02	;clr int? 
;	lda	$ff92	;clr gime int
;	anda	#$08
;	beq	@ret
	rti

initpia	pshs	a
	lda	PIA2+1
	anda	#$fa	;irq/firq off...
	sta	PIA2+1
	lda	#$fc
	sta	PIA2
	lda	PIA2+1
	ora	#$04
	sta	PIA2+1
	lda	PIA2+3
	anda	#$fe	;irq/firq off... (cart)
	sta	PIA2+3
	lda	PIA1+1	;irq off... (hsync)
	anda	#$fe
	sta	PIA1+1
	lda	PIA1+3	;irq off... (vsync)
	anda	#$fe
	sta	PIA1+3
	lda	PIA1	;clear all pending ints
	lda	PIA1+2
	lda	PIA2
	lda	PIA2+2
	puls	a
	rts
;	include system.asm
	end	start