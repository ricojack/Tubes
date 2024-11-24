sample	equ	$6000
PIA2	equ	$ff20
bra_operand	equ	$20
brn_operand	equ	$21
SOUND_MMU	equ	$ffa3
SOUND_PREFIX	equ	$60	;sounds are at $6000-$7fff

firqvec	fcb	$fe,start	;odd, but works around assembler.
sndinfo	fcb	$fe,fxblkcur
sndena	fcb	$fe,start
sndoff	fcb	$fe,_smpl+1
in_effect fcb	$00
start	bra	@colchg		;color change only firq
	inc	$ffb4
	sta	<@z+1		; (001:+4) save ACCA
_smpl	lda	sample		; (001:+5) get sound byte
	sta	PIA2			; (001:+5) send sound out
	inc	<_smpl+2		; (001:+6) inc LSB of offset
	bne	@y			; (001:+3) if no overflow go reset FIRQ
	inc	<_smpl+1		; (256:+6) overflow, inc MSB 
	dec	<fxblkcur		; (256:+6) decr num of 256 byte blks
	bne	@y			; (256:+3) yes
; We are here to go to next mmu block (numerb of mmu blocks times)
	tst	<fxmmunum		; (6) Are we done with the effect
	bne	@c			; (4) nope, go to next mmu block
@a	clr	<in_effect
@b	bra	@y			; reset FIRQ status and return
@c	inc	SOUND_MMU		; go to next mmu block
	lda	#$20			; There are always 32 pages in a block
	sta	<fxblkcur		; set it
	lda	#SOUND_PREFIX		; reset offset to start of MMU block
	sta	<_smpl+1		;
	dec	<fxmmunum		; are we done yet?
	bne	@y			; nope
; this is the last mmu block (once per track)
	lda	<fxblklst		; Get num of blocks in last mmu
	beq	@a
	sta	<fxblkcur		; set it
@y	bita	$ff93			; (001:+5) reset FIRQ status
@z	lda	#$ff			; (001:+2) Restore ACCA
	dec	<start			; change brn to bra
	rti
;
@colchg	inc	$ffb4
	bita	$ff93
	tst	in_effect
	beq	@ret
	inc	<start
@ret	rti

fxblkcur	rmb 1
fxblklst	rmb 1
fxmmunum	rmb 1
	end	start