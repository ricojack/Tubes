
;	include ..\Kaos\public.inc
;	include tubes.inc

	org $e80

	include tubes.inc
		
start	pshs	cc,u,x,y,a,b
	sts stkstore
	lds #$e80
	orcc #$50
	clr DSKREG
	clra
	ldb #$10
	ldx #$ffa0
	ldy #task0blks
@a	lda ,y+
	sta ,x+
	decb
	bne @a
	clr $ffdf	; all RAM mode
	clr $ffd9	; speedup

; clear screen
;	jsr	task1
;	jsr	clrscr
;	jsr	task0
	
; Decompress tubescreen	
	lda #225	; 224 lines
	ldb mainscreen	; get compress byte
	ldx #mainscreen+$13
	jsr ratdec2
	
; Copy sprites
	ldd	#(2048*2)	;numbytes copy
	ldx	#spritestart	;start point of copy
	ldy	#spritetable	;copy destination
	jsr	copy_up
;	jsr	initpia
	
; TODO: draw title screen here!!

; Set palettes	
	ldx #mainscreen+3
	ldy #$ffb0
	ldb #$10
@a	lda ,x+
	sta ,y+
	decb
	bne @a

;DEBUG!!!
;	jsr initgfx
;@b	bra @b
	
finito	jsr	task0
	clr	$ffd8	;slow down
	lds	stkstore
	puls	pc,cc,u,x,y,a,b
	rts

stkstore rmb 2

clrscr	clra
	clrb
	ldx	#$8000
@lp	std	,x++
	cmpx	#$f800
	bne	@lp
	rts
		
ratdec2	stb  @cb+1
	ldb  #screenwidth	; bytes per width
	mul		; D now contains pic size in bytes
	ldu  #screenstart	; start
	leau d,u	; store endpt
	stu  rend2	; 
	ldu  #screenstart
	jsr task1
@nb	lda  ,x+
@cb	CMPA #$00	; Compress byte
	BEQ  @dcmp	; It's compressed, branch to decompress
	STA  ,U+
@cm2	CMPU rend2	; At end?
	BLS  @nb	; no, get next byte
	BRA  @x		; yes, exit
@dcmp	LDD  ,X++	; Count in A, gfx in B
;	jsr  task1	; Task 1
@wb	STB  ,U+
@cm3	CMPU rend2	; At end?
	BHI  @x		; yes, exit
	DECA
	BNE  @wb
	BRA  @nb	; Get next byte
;@x	nop		; debugdebugdebug
;	rts
@x	clr  $ff91	;jsr  task0
	RTS
rend2	rmb  2

; copy_up
; x - start location
; y - dst
; d - numbytes
copy_up	leax	d,x
	leay	d,y
	tfr	d,u
@lp	lda	,-x
	sta	,-y
	leau	-1,u
@cp	cmpu	#$0000
	bne 	@lp
	rts

task0	clr	$ff91
	rts
	
task1	pshs	a
	lda	#$01
	sta	$ff91
@x	puls	a,pc

initgfx	lda	#$6c	;irqs on, constant vectors, scs
	sta	$ff90
	LDA     #$80
	STA     $FF98  ; Video mode: gfx
	LDA     #$7A
	STA     $FF99  ; 320x225x16
	ldd	#$c000
;	ldd	#$c000
;	ldd	#$ec00
	std	$ff9d	; set screen
	rts

; INCLUDES
;	include	input.asm
	
;mainscreen	includebin main16new.rat
;mainscreen	includebin main16v3.rat
mainscreen	includebin main16v6.rat
spritestart	includebin sprites64.raw
chgsprstart	includebin chg_sprites.raw
;spritestart	includebin chg_sprites.raw
;chgsprstart	includebin sprites.raw
endload	fcb	$ff
	end	start
