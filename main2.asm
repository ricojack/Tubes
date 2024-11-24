
	org $e00

	include tubes.inc
		
start	orcc	#$50
	clr	DSKREG
	clr	$ffdf	; all RAM mode
	clr	$ffd9	; speedup
	sts	stkstore
	lds	#$200

	clr	pal_saved
	lda	irq_cyc_start
	sta	$ffbe
	jsr	palette_fade_to_black
	jsr	initgfx
	jsr	initpia
	jsr	initjoy
	jsr	task0
	jsr	draw_title
@gs	jsr	set_title_gfx
	jsr	palette_restore
	jsr	task1
	jsr	initscrndata
	jsr	clearinfodata
;
	lda	#$ff
	sta	dropidx
	jsr	clr_txt
	jsr	init_print
	jsr	init_p1_irq
	jsr	init_p2_irq
	andcc	#$ef
	clr	p1_game_flag
	clr	game_over_flag
@jlp	jsr	readjoyl
	jsr	readjoyr
	jsr	readfire
	jsr	interpfire
	jsr	p1_interpmove
	jsr	drawleftblk
	lda	p1_game_flag
	beq	@dr
	jsr	drawleftcur
@dr	jsr	drawrightcur
	jsr	p1_set_dirty_bits
	jsr	p1_full_redraw
	lda	game_over_flag
	beq	@jlp
; GAME'S OVER, start again?
	jsr	palette_fade_to_black
	bra	@gs
;	jsr drawcursor 
@b	bra @b

finito	lds stkstore
	rts

stkstore rmb 2
game_over_flag	rmb 1

; initgfx mode
;
initgfx	lda	#$6c	;irqs on, constant vectors, scs
	sta	$ff90
	LDA     #$80
	STA     $FF98  ; Video mode: gfx
	LDA     #$7E
	STA     $FF99  ; 320x225x16
	ldd	#$f000
;	ldd	#$c000
;	ldd	#$ec00
	std	$ff9d	; set screen
	ldd	#vsyncirq
	std	$fef8
	lda	#$7e	;jmp
	sta	$fef7
	lda	#irq_cyc_max
	sta	irq_cyc_time
	ldd	#irq_cyc_start
	std	irq_cyc_ptr
	rts

;can only be called after 'initgfx'
set_title_gfx lda #$1e
	sta	$ff99	;title screen is 320x192
	ldd	#$f000
;	ldd	#$ec00
	std	$ff9d	; set screen
	rts

set_game_gfx lda #$7e
	sta	$ff99	;game screen is 320x225
	ldd	#$c000
;	ldd	#$ec00
	std	$ff9d	; set screen
	rts

clr_gfx_scrn jsr task0 
	ldd	#$0000
	ldx	#$8000
@lp	std	,x++
	cmpx	#$f800
	bne	@lp
	rts

palette_fade_to_black lda pal_saved
	bne	@ret	;if already saved, don't save again!
	com	pal_saved
	ldx	#$ffb0	;palette regs
	ldy	#save_pals
	ldb	#$10
@lp	lda	,x
	sta	,y+
	clr	,x+
	decb
	bne	@lp
@ret	rts
pal_saved	rmb 1
save_pals	rmb 16

palette_restore lda pal_saved
	beq	@ret	;if not saved, don't restore
	clr	pal_saved
	ldx	#$ffb0	;palette regs
	ldy	#save_pals
	ldb	#$10
@lp	lda	,y+
	sta	,x+
	decb
	bne	@lp
@ret	rts

; title screen tile table
; format: #tiles,tile num,addresses
; toplefts
ts_topleft	fcb 2,chg_topleft
		fdb $8000,$ad68
ts_botleft	fcb 3,chg_botleft
		fdb $ee00,$c138,$b768
ts_topright	fcb 3,chg_topright
		fdb $8098,$b770,$ad50
ts_botright	fcb 4,chg_botright
		fdb $ee98,$c140,$c150,$c170
ts_leftright	fcb 8,chg_leftright
		fdb $ad28,$ad38,$ad40,$ad60,$ad70,$b760,$c160,$c168
ts_updown	fcb 4,chg_updown
		fdb $b730,$b738,$b740,$c130
ts_tridown	fcb 3,chg_tridown
		fdb $ad30,$ad48,$ad58
ts_triright	fcb 2,chg_triright
		fdb $b748,$b758
ts_trileft	fcb 1,chg_trileft
		fdb $b750
ts_triup	fcb 2,chg_triup
		fdb $c148,$c158
ts_done		fdb $0000

draw_title jsr	task0
	jsr	clr_gfx_scrn
	ldx	#ts_topleft
@olp	ldd	,x++		;A - number of sprites, B - spritenum
	beq	@brdr
@ilp	ldy	,x++
	pshs	x,a,b		;these are clobber in drawsprite, so save them here
	jsr	drawsprite
	puls	x,a,b
	deca
	bne	@ilp		;inner loop, keep displaying same sprite
	bra	@olp		;outer loop, load next sprite & count
@brdr	ldy	#$8008		;top line
	lda	#18
	ldb	#chg_leftright
	jsr	draw_title_horz
	lda	#18
	ldy	#$ee08
	jsr	draw_title_horz
	lda	#10
	ldb	#chg_updown
	ldy	#$8a00
	jsr	draw_title_vert
	lda	#10
	ldy	#$8a98
	jsr	draw_title_vert
@done	rts

; y - dst
; a - number to draw
; b - sprite num
draw_title_vert	pshs	y,a,b
	jsr	drawsprite
	puls	y,a,b
	leay	$a00,y
	deca
	bne	draw_title_vert
@done	rts

; y - dst
; a - number to draw
; b - sprite num
draw_title_horz	pshs	y,a,b
	jsr	drawsprite
	puls	y,a,b
	leay	spritewidth,y
	deca
	bne	draw_title_horz
@done	rts

display_title jsr palette_fade_to_black
	jsr	set_title_gfx
	jsr	palette_restore
	rts
	
switch_modes lda $ff98
	bmi	txt_on	;if neg, means we're in gfx mode

gfx_on	ldd	#$807e
	std	$ff98
	ldd	#$c000
	std	$ff9d
	lda	save_color
	sta	$ffb1
	rts
save_color	rmb 1

txt_on	ldd	#$0304
	std	#$ff98	; text mode, 32x16
	ldd	#$e080	; point to regular text area
	std	$ff9d
	lda	$ffb1
	sta	save_color
	lda	#$9
	sta	$ffb1
	jsr	print_info
	rts

clr_txt ldd	#$2020
	ldx	#$400
@nx	std	,x++
	cmpx	#$7c0
	blt	@nx
	rts
	
task0	clr $ff91
	rts
	
task1	pshs	a
	lda	#$01
	sta	$ff91
@x	puls	a,pc

	include input.asm
	include sprites.asm
	include utils.asm
	include system.asm
	include check.asm
	
	end	start
