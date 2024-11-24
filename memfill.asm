
	org	$167
	fcb	$7e	;jmp instruction
	fdb	start
	
	org	$4e0
;	fcc	"                                "
	fcc	"LOADING MAIN                    "
;	fcc	"                                "
;	fcc	"                                "
;	fcc	"                                "
;	fcc	"                                "
;	fcc	"                                "
;	fcc	"                                "
;	fcc	"                                "
;	fcc	"                                "
;	fcc	"                                "
;	fcc	"                                "
;	fcc	"                                "
;	fcc	"                                "
;	fcc	"                                "
;	fcc	"                                "
	
	org	$e00
;	fdb	p1_nomove_flag
;	fdb 	leftscrndata
;	fdb	leftinfodata
;	fdb	hsyncirq
;	jmp	spritetable
;	jmp	clear_all_p1_blocks
;	jmp	p1_set_dirty_bits
;	jmp	CHECKBLOCKS
;	jmp	p1_initjoy
;	jmp	p1_cur_vpos
;	jmp	p1_drawcursor
;	jmp	ts_drawtext
;	jmp	_tdtrt
;	jmp	_dtrt
;	jmp	draw_text
	jmp	p1_clr_levelclear
	jmp	init_next_level
	jmp	p1_check_hiscore
	jmp	readjoyl
	jmp	readjoy_sound
;	jmp	decrease_remain
;	jmp	play_sound
;	jmp	update_score
;	jmp	p1_drawscore
;	jmp	increase_score
;	jmp	_clr_line
;	fcb	00
;	jmp	bcd_add_score
;	jmp	hsyncirq
;	jmp	initgfx
	org	$e80
	
	include tubes.inc
joyrtn	fdb	readjoyl
firertn	fdb	readfire
;joyrtn	fdb	readkeyl
;firertn	fdb	readkbfire

start	tfr	cc,a
	sta	ccsv
	orcc	#$50
	clr	DSKREG
	clr	$ff9a
	clr	$ffdf	; all RAM mode
	clr	$ffd9	; speedup
	sts	stkstore
	lds	#$200
	clra
	sta	$ffb0
	jsr	inittask
	jsr	task0
	jsr	initgfx
	jsr	initpia
	clr	game_over_flag
	clr	pal_saved
	lda	irq_cyc_start
	sta	$ffbe
	jsr	palette_fade_to_black
	jsr	draw_title
	jsr	clr_txt
;	jsr	p1_testtext
;	jsr	task1
;	jsr	clr_btm_line
;	jsr	task0
@gs	jsr	task0
	jsr	set_title_gfx
	jsr	draw_highscore
	jsr	palette_restore
	jsr	task1
	jsr	initscrndata
	jsr	clearinfodata
;
	lda	#$ff
	sta	p1_dropidx
;	sta	update_score
	jsr	init_p1_irq
	jsr	init_p2_irq
;	andcc	#~(irq_bit)
	andcc	#~(firq_bit|irq_bit)
	clr	p1_game_flag
;	clr	p1_clr_active
	clr	game_over_flag
;	clr	level_done
;	jsr	initjoy
	jsr	p1_initjoy
	jsr	p2_initjoy
	jsr	p1_initscore
	jsr	init_level_data
@jlp	clr	vsync_done
;	jsr	readjoyl
;	jsr	readjoyr
;	jsr	readfire
	jsr	[joyrtn]
	jsr	[firertn]
	jsr	interpfire
	jsr	p1_interpmove
	jsr	drawleftblk
;	lda	p1_game_flag
;	beq	@dr
;	jsr	drawleftcur	;RESTORE???
;@dr	jsr	drawrightcur
@dr	jsr	p1_check_lines
	jsr	p1_set_dirty_bits
	jsr	p1_full_redraw
	jsr	p1_draw_drop	;new!!
	jsr	drawleftcur
	jsr	p1_drawscore
	jsr	p1_drawround
	jsr	p1_drawremain
	lda	playing_sound
	bne	@chkflg
	jsr	pia_dis_sound
@chkflg	lda	game_over_flag
	bne	@gmover
	lda	level_done
	beq	@wsync
	jsr	level_cleared	;in 'level.asm'
@wsync	lda	vsync_done
	beq	@wsync
	bra	@jlp
; GAME'S OVER, start again?
@gmover	jsr	p1_erasecur
;	jsr	palette_fade_to_black
;	jsr	p1_erasecur
;	bra	@gs
;	jsr	initpia
;	jsr	pia_dis_sound
@wtclr	jsr	p1_draw_gameover
@clrlp	lda	vsync_done	;wait for vsync
	beq	@clrlp	
	clr	vsync_done
@clrsnd	lda	playing_sound	;wait for sound to finish
	bne	@clrsnd
	jsr	[joyrtn]
	jsr	[firertn]	;wait until user releases all buttons
	jsr	interpfire
	lda	lf1_stat
	beq	@nl
	lda	lf2_stat
	bne	@clrlp
@nl	lda	vsync_done	;wait for vsync
	beq	@nl
	clr	vsync_done
	lda	playing_sound
;	bne	@sndply
	pshs	cc
	orcc	#$50		;ints off
	jsr	sound_dis
	jsr	pia_dis_sound
;	clr	playing_sound
	lda	#bra_operand_c
	sta	firq_vec_offset
	clr	PIA2
	puls	cc
@sndply	jsr	[joyrtn]
	jsr	[firertn]
	jsr	interpfire
	lda	lf1_stat
	beq	@nl
	ldb	lf2_stat
	beq	@nl
	jsr	p1_check_hiscore
	jsr	p1_clr_gameover
	lbra	@gs
	
@a	bra	@a
stkstore	rmb 2
ccsv	rmb 1	
game_over_flag	rmb 1	;see animate_p1_clr in check.asm

clr_gfx_scrn	clra
	clrb
	ldx	#$8000
@lp	std	,x++
	cmpx	#$f800
	bne	@lp
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
clr_btm_line lda #224
	ldb	#screenwidth
	mul
	ldu	#screenstart
	leau	d,u
	ldb	#screenwidth
	clra
@lp	sta	,u+
	decb
	bne	@lp
	rts
	
initgfx	jsr	palette_set
	lda	#$7c	;irqs on, constant vectors, scs
	sta	$ff90
	LDA     #$80
	STA     $FF98  ; Video mode: gfx
	LDA     #$7E
	STA     $FF99  ; 320x225x16
	ldd	#$c000
;	ldd	#$c000
;	ldd	#$ec00
	std	$ff9d	; set screen
	jsr	initsound	;set up pia, firq, etc
	ldd	#vsyncirq
	std	$fef8
;	ldd	#hsyncirq
	ldd	firq_vec_offset	;points to address of firq
	std	$fef5
	lda	#$7e	;jmp
	sta	$fef7
	sta	$fef4
	lda	#irq_cyc_max
	sta	irq_cyc_time
	ldd	#irq_cyc_start
	std	irq_cyc_ptr
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

;ts_topleft	fcb 2,chg_topleft
;		fdb $8000,$ad68
;ts_botleft	fcb 3,chg_botleft
;		fdb $ee00,$c138,$b768
;ts_topright	fcb 3,chg_topright
;		fdb $8098,$b770,$ad50
;ts_botright	fcb 4,chg_botright
;		fdb $ee98,$c140,$c150,$c170
;ts_leftright	fcb 8,chg_leftright
;		fdb $ad28,$ad38,$ad40,$ad60,$ad70,$b760,$c160,$c168
;ts_updown	fcb 4,chg_updown
;		fdb $b730,$b738,$b740,$c130
;ts_tridown	fcb 3,chg_tridown
;		fdb $ad30,$ad48,$ad58
;ts_triright	fcb 2,chg_triright
;		fdb $b748,$b758
;ts_trileft	fcb 1,chg_trileft
;		fdb $b750
;ts_triup	fcb 2,chg_triup
;		fdb $c148,$c158
;ts_done		fdb $0000

ts_topleft	fcb 2,chg_topleft
		fdb $8000,$a458
ts_botleft	fcb 3,chg_botleft
		fdb $e800,$ac58,$b428
ts_topright	fcb 3,chg_topright
		fdb $8078,$a440,$ac60
ts_botright	fcb 4,chg_botright
		fdb $e878,$b430,$b440,$b460
ts_leftright	fcb 8,chg_leftright
		fdb $a418,$a428,$a430,$a450,$a460,$ac50,$b450,$b458
ts_updown	fcb 4,chg_updown
		fdb $ac20,$ac28,$ac30,$b420
ts_tridown	fcb 3,chg_tridown
		fdb $a420,$a438,$a448
ts_triright	fcb 2,chg_triright
		fdb $ac38,$ac48
ts_trileft	fcb 1,chg_trileft
		fdb $ac40
ts_triup	fcb 2,chg_triup
		fdb $b438,$b448
ts_done		fdb $0000

rgb_palette	fcb $00,$04,$02,$06,$01,$28,$03,$07,$38,$24,$12,$36,$09,$26,$1b,$3f

draw_title	jsr	clr_gfx_scrn
;	rts	;DEBUG
	ldx	#ts_topleft
@olp	ldd	,x++		;A - number of sprites, B - spritenum
	beq	@brdr
@ilp	ldy	,x++
	pshs	x,a,b		;these are clobber in drawsprite, so save them here
	jsr	title_drawsprite
	puls	x,a,b
	deca
	bne	@ilp		;inner loop, keep displaying same sprite
	bra	@olp		;outer loop, load next sprite & count
@brdr	ldy	#$8008		;top line
	lda	#14
	ldb	#chg_leftright
	jsr	draw_title_horz
	lda	#14
	ldy	#$e808
	jsr	draw_title_horz
	lda	#12
	ldb	#chg_updown
	ldy	#$8800
	jsr	draw_title_vert
	lda	#12
	ldy	#$8878
	jsr	draw_title_vert
	jsr	draw_copyright
	jsr	draw_highscore
@done	rts

; y - dst
; a - number to draw
; b - sprite num
draw_title_vert	pshs	y,a,b
	jsr	title_drawsprite
	puls	y,a,b
	leay	(ts_screenwidth*16),y
	deca
	bne	draw_title_vert
@done	rts

; y - dst
; a - number to draw
; b - sprite num
draw_title_horz	pshs	y,a,b
	jsr	title_drawsprite
	puls	y,a,b
	leay	spritewidth,y
	deca
	bne	draw_title_horz
@done	rts

;can only be called after 'initgfx'
set_title_gfx lda #$7a	;lda #$1e
	sta	$ff99	;title screen was 320x192, now 256x225
	ldd	#$f000
;	ldd	#$ec00
	std	$ff9d	; set screen
	rts

set_game_gfx lda #$7a	;256x225,16
	sta	$ff99	;game screen is 256x225
	ldd	#$c000
;	ldd	#$ec00
	std	$ff9d	; set screen
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

palette_set ldx #$ffb0
	ldy	#rgb_palette
	ldb	#$10
@lp	lda	,y+
	sta	,x+
	decb
	bne	@lp
@ret	rts

;switch_modes	rts

__NON_TEST__ equ 1
	include input.asm
	include sprites.asm
	include utils.asm
	include system.asm
	include check.asm
	include sound.asm
	include drawtext.asm
	include score.asm
	include level.asm
	org	spritetable
spritestart	includebin sprites64.raw
chgsprstart	includebin chg_sprites.raw

	end	start