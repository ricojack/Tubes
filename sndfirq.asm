sample	equ	$6000
PIA2	equ	$ff20
bra_operand	equ	$20
brn_operand	equ	$21
SOUND_MMU	equ	$ffa3
SOUND_PREFIX	equ	$60	;sounds are at $6000-$7fff
;	org	$e000
firqvec	fcb	$fe,start	;odd, but works around assembler.
sndinfo	fcb	$fe,fxblkcur
sndena	fcb	$fe,decpt
sndoff	fcb	$fe,_smpl+1
start	bra	colchg
	sta	<sv+1
	inc	$ffb0
;_brn1	bra	sv	;might get changed
_smpl	lda	sample	;get sample and put it in the DAC
	sta	PIA2
	inc	<_smpl+2	;low byte of sample
	bne	sv
	inc	<_smpl+1	;high byte of sample
	dec	<fxblkcur	;if this isn't the last block, continue
	bne	sv
	tst	<fxmmunum
	beq	snd_dn2
	inc	<_brn2	;change bra to brn!	
sv	lda	#$ff	;restore acca
	dec	<start	;change brn to bra!
	bita	$ff93
	rti
	
colchg	inc	$ffb0
decpt	inc	<start	;chg bra to brn (reset if snd active)
	bita	$ff93
_brn2	bra	rti2	;if last block, reset ptrs
	sta	<rti_r1+1
	inc	SOUND_MMU	;get next sound block
	lda	#$20
	sta	<fxblkcur
	lda	#SOUND_PREFIX
	sta	<_smpl+1
	dec	<fxmmunum	;is this the last block now?
	bne	rti_r1
	lda	<fxblklst	;yep, last blk
	beq	snddone		;if ==0, then done!
	sta	<fxblkcur	;not done...
_strt	dec	<_brn2	;back to bra
rti_r1	lda	#$00
rti2	rti

snd_dn2 dec	<_brn2
;	dec	<start		;have to change brn to bra
snddone	lda	#brn_operand
	sta	decpt		;disable sound playing...
	bra	rti_r1
	
fxblkcur	rmb 1
fxblklst	rmb 1
fxmmunum	rmb 1
	end	start