	org	$e00
	fdb	snd_ladder
	fdb	play_sound
	
	org	$e80
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
	jsr	copyfirq
	jsr	copy_snd_fx
	jsr	init_sound
	jsr	sound_dis
	andcc	#$af
@x	clr	vsync_done
	jsr	checkkeyboard
@wait	lda	vsync_done
	bne	@x
	bra	@wait
	
vsync_done	rmb 1

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
;	lda	#$20
	sta	$ff93
;	ldd	#235
;	stb	$ff95
;	sta	$ff94
	jsr	copyfirq
	lda	#$fe	;direct page to be $feXX
	tfr	a,dp
	rts

init_sound lda	PIA1+1
	anda	#$f7	;reset mux bit
	sta	PIA1+1
	lda	PIA1+3	;reset other mux bit
	anda	#$f7
	sta	PIA1+3
	lda	PIA2+3	;set sound out bit
	ora	#$08
	sta	PIA2+3
	clr	sound_playing
	rts
sound_playing	rmb 1
	
copyfirq ldx	#firqrtn
	ldy	#$fe00
@lp	cmpx	#sound_fx_start
	beq	@done
	lda	,x+
	sta	,y+
	bra	@lp
@done	rts

copy_snd_fx ldx	#sound_fx_start
	leax	2,x	;skip file size...
	lda	#$30
	sta	$ffa4
	ldb	#$04
@oloop	pshs	b
	ldy	#$8000
@iloop	lda	,x+
	tfr	a,b	;save orig.
	anda	#$fc	;mask 6 high bits
	sta	,y+
	clra
	lsrb
	rora
	lsrb
	rora
	pshs	a
	lda	,x+
	tfr	a,b
	anda	#$f0
	lsra
	lsra
	ora	,s+
	sta	,y+
	lda	,x+
	lsla
	rolb
	lsla
	rolb
	lslb
	lslb
	stb	,y+
	sta	,y+
	cmpy	#$a000
	blt	@iloop
	inc	$ffa4
	puls	b
	decb
	bne	@oloop
	lda	#$3c
	sta	$ffa4	;restore mmu block
	rts

initgfx	lda	#$7c	;irqs on, constant vectors, scs
	sta	$ff90
	lda	#$20
	sta	$ff91
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
;	ldd	#hsyncirq
;	ldd	#firqrtn
	ldd	firq_vec_offset
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
	inc	vsync_done
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
	
keytable	fdb	$fdef,$fbef,$f7ef,$efef,$dfef,$bfef,$7fef
;			1,2,3,4,5,6,7
		fdb	$0000
chrtable	fcb	'Z','X','K','C','H',$5e,$56,$7c,$7e
checkkeyboard	ldx	#keytable
	lda	#$ff
	sta	@keyval
@lp	inc	@keyval
	ldd	,x++	;Z
	beq	@done
	jsr	kbchk
	bne	@lp	;if equal, then key pressed
	lda	@keyval	;should be sample num
	jsr	play_sound
@done	rts
@keyval	rmb	1

;a - writeval
;b - cmp val
kbchk	stb	@ck+1
	sta	$ff02
	lda	$ff00
	ora	#$80	;set high bit
@ck	cmpa	#$00	;operand is modified
	bne	@ret
	clr
@ret	rts
;	include system.asm

sound_ena lda	#brn_opcode
	sta	[sound_enable]
;	ldx	sound_enable
;	sta	,x
	rts

sound_dis lda	#bra_opcode
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
@done	puls d,x,y,pc


BLOCK_EFFECTS	equ	$30
MEM_SAMPLES	equ	$6000
SOUND_MMU	equ	$ffa3
SOUND_PREFIX	equ	$60	;sounds are at $6000-$7fff

;1 end ladder	0	0000	20	B
snd_ladder	fcb	BLOCK_EFFECTS+0		* MMU BLock
		fdb	MEM_SAMPLES+$0009	* Starting offset
		fcb	$01			* Number of MMU blocks - 1
		fcb	$20,$0b			* pages in first/last block
;
;2 dig		1	0B00	3	0
snd_dig		fcb	BLOCK_EFFECTS+1
		fdb	MEM_SAMPLES+$0b5e
		fcb	$00
		fcb	$03,$00
;
;3 player die	1	0E00	12	0d
snd_playerdie	fcb	BLOCK_EFFECTS+1
		fdb	MEM_SAMPLES+$0e48
		fcb	$00
		fcb	$12,$0d
;
;4 win board			2	0500	14 0
snd_winboard	fcb	BLOCK_EFFECTS+2
		fdb	MEM_SAMPLES+$0518
		fcb	$00
		fcb	$14,$0
;
;5 gaurd get gold		3	0100	1	C
snd_grdgetgold	fcb	BLOCK_EFFECTS+2
		fdb	MEM_SAMPLES+$194c
		fcb	$01
		fcb	$07,$06
;
;6 player get gold	3	0600	E	0
snd_plygetgold	fcb	BLOCK_EFFECTS+3
		fdb	MEM_SAMPLES+$06b1
		fcb	$00
		fcb	$0e,$00
;
;7 guard die			3	1400	F	0
snd_gaurdeie	fcb	BLOCK_EFFECTS+3
		fdb	MEM_SAMPLES+$14f6
		fcb	$01
		fcb	$0c,$00 	*2

sound_info	equ	snd_ladder

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
;sound_fx_start	fcb $ff
sound_fx_start	includebin effects.snd
;sound_fx_start	includebin clearline.snd
;snd_blockland	includebin blockland.snd

;sound_fx_start	includebin fx.snd
cpy_end	rmb 1
	end	start