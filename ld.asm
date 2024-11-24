	include tubes.inc

	org $e00
start	orcc #$50
	clr DSKREG
	clra
	ldb #$10
	ldx #$ffa0
	ldy #task0blks
@a	lda ,y+
	sta ,x+
	decb
	bne @a
	clra
	sta $ffdf	; all RAM mode

	sts stkstore
	lds #$200
	ldx #mainscreen+3
	ldy #$ffb0
	ldb #$10
@a	lda ,x+
	sta ,y+
	decb
	bne @a
	
	jsr reloc
	jsr initgfx
	lda #224	; 224 lines
	ldb mainscreen	; get compress byte
	ldx #$6000
	jsr ratdec
@b	bra @b
finito	lds stkstore
	rts

stkstore rmb 2

; initgfx mode
;
initgfx	lda	#$44
	sta	$ff90
	LDA     #$80
	STA     $FF98  ; Video mode: gfx
	LDA     #$7E
	STA     $FF99  ; 320x225x16
	ldd	#$c000
	std	$ff9d	; set screen
	rts
	
; RAT Decode
; X - start addr
; A - num lines
; B - compress byte
; NOTE: Task addresses must be set up.  Decoded graphics will start in same
;   memory locations, but in back buffer
; task1: uncompressed gfx
; task0: compressed gfx
;
ratdec	TFR  X,U
	stb  @cb+1
	ldb  #160	; bytes per width
	mul		; D now contains pic size in bytes
	leax d,x	; store endpt
	stx  rendpt	; store in compare instructions
	tfr  u,x
@nb	jsr  task0
@cm1	CMPX rendpt	; end point
	BHI  @x		; reached end... exit
	LDA  ,X+
@cb	CMPA #$00	; Compress byte
	BEQ  @dcmp	; It's compressed, branch to decompress
	jsr  task1	; Task 1
	STA  ,U+
@cm2	CMPU rendpt	; At end?
	BLS  @nb	; no, get next byte
	BRA  @x		; yes, exit
@dcmp	LDD  ,X++	; Count in A, gfx in B
	jsr  task1	; Task 1
@wb	STB  ,U+
@cm3	CMPU rendpt	; At end?
	BHI  @x		; yes, exit
	DECA
	BNE  @wb
	BRA  @nb	; Get next byte
@x	jsr  task0
	RTS
rendpt	rmb  2

reloc   pshs x,y,a,b
	jsr task0
	ldx #$1013
	ldy #$6000
@a	lda ,x+
	sta ,y+
	cmpx #$6000
	bne @a
	puls x,y,a,b
	rts
	
task0	clr $ff91
	rts
	
task1	sta @x+1
	lda #$01
	sta $ff91
@x	lda #$00
	rts	
coltable	fcb $00,$01,$08,$09,$00,$02,$10,$12
		fcb $00,$04,$20,$24,$00,$07,$38,$3f
task0blks	fcb $38,$39,$3a,$3b,$3c,$3d,$3e,$3f
task1blks	fcb $38,$39,$3a,$30,$31,$32,$33,$34

	org $1000

mainscreen	includebin main16wrk.rat
	end	start
