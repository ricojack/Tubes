
initsound jsr	copyfirq
	lda	#$fe	;direct page to be $feXX
	tfr	a,dp
;	jsr	pia_ena_sound
	rts

copyfirq ldx	#firqrtn
	ldy	#$fe00
@lp	cmpx	#cpy_end
	beq	@done
	lda	,x+
	sta	,y+
	bra	@lp
@done	rts

pia_ena_sound lda	PIA1+1
	anda	#$f7	;reset mux bit
	sta	PIA1+1
	lda	PIA1+3	;reset other mux bit
	anda	#$f7
	sta	PIA1+3
	lda	PIA2+3	;set sound out bit
	ora	#sound_bit
	sta	PIA2+3
;	lda	#$80	;silence bit
;	sta	PIA2
	rts

pia_reena_sound lda	PIA2+3	;set sound out bit
	ora	#sound_bit
	sta	PIA2+3
	rts
	
pia_dis_sound lda	PIA2+3	;set sound out bit
	anda	#~(sound_bit)
	sta	PIA2+3
	rts

sound_ena lda	#brn_opcode
	sta	[sound_enable]
;	ldx	sound_enable
;	sta	,x
	rts

sound_dis lda	#bra_opcode
	clr	playing_sound
	sta	[sound_enable]
;	ldx	sound_enable
;	sta	,x
	rts
	
;a - sound num
;
play_sound pshs	d,x,y
	ldb	playing_sound
	bne	@done	;skip, if already playing a sound
	inc	playing_sound
	ldb	#$06		;sound description table is 6bytes/sound
	mul
	addd	#sound_info
	tfr	d,x
	ldy	sound_struct
	lda	,x		;get 1st block num
	sta	SOUND_MMU
	ldd	1,x		;get start offset
	std	[sample_offset]
	lda	3,x
	sta	2,y		;mmu number
	ldd	4,x
	std	,y
;	ldb	#inc_opcode	;turn on sound..
;	stb	[sound_enable]
	jsr	sound_ena
	jsr	pia_ena_sound
@done	puls d,x,y,pc

; Called by 'clearline', because that sound is more important than 'landing'
ovrd_sound pshs	d,x,y
	ldb	playing_sound
;	bne	@done	;skip, if already playing a sound
	orb	#$01	;
	stb	playing_sound
	ldb	#$06		;sound description table is 6bytes/sound
	mul
	addd	#sound_info
	tfr	d,x
	ldy	sound_struct
	lda	,x		;get 1st block num
	sta	SOUND_MMU
	ldd	1,x		;get start offset
	std	[sample_offset]
	lda	3,x
	sta	2,y		;mmu number
	ldd	4,x
	std	,y
;	ldb	#inc_opcode	;turn on sound..
;	stb	[sound_enable]
	jsr	sound_ena
	jsr	pia_ena_sound
@done	puls d,x,y,pc

BLOCK_EFFECTS	equ	$35
MEM_SAMPLES	equ	$6000
SOUND_MMU	equ	$ffa3
SOUND_PREFIX	equ	$60	;sounds are at $6000-$7fff

;fx_clearline	fcb	BLOCK_EFFECTS		;MMU Block
;		fdb	MEM_SAMPLES+$00f6	;starting offset
;		fcb	$00			;num of MMU blocks - 1
;		fcb	$0f,$00			;pages in first/last block

fx_clearline	fcb	BLOCK_EFFECTS		;MMU Block
		fdb	MEM_SAMPLES+$00a4	;starting offset
		fcb	$00			;num of MMU blocks - 1
		fcb	$10,$00			;pages in first/last block
		
fx_blockland	fcb	BLOCK_EFFECTS		;MMU Block
		fdb	MEM_SAMPLES+$109f	;starting offset
		fcb	$00			;num of MMU blocks - 1
		fcb	$06,$00			;pages in first/last block
		
;fx_clearline	fcb	BLOCK_EFFECTS		;MMU Block
;		fdb	MEM_SAMPLES+$06a4	;starting offset
;		fcb	$00			;num of MMU blocks - 1
;		fcb	$10,$00			;pages in first/last block


sound_info	equ	fx_clearline

firq_vec_offset	equ $fe00
sound_struct	equ $fe02
sound_enable	equ $fe04
sample_offset	equ $fe06
playing_sound	equ $fe08

bra_opcode	equ $20
brn_opcode	equ $21
inc_opcode	equ $0c

;firqrtn	includebin Files\firq.bin
firqrtn	includebin Files\firq2.bin
;sound_fx_start	includebin effects.snd
cpy_end	rmb 1
;	end	start