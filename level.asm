
levelsize_c	equ	5
max_level_c	equ	9
leveldata	fcb	$00,$10	;blocks to clear
		fcb	$07	;drop speed
		fcb	$1c	;hang time
		fcb	11	;random seed
		fcb	$00,$20	;2
		fcb	$05
		fcb	$18
		fcb	23
		fcb	$00,$40	;3
		fcb	$04
		fcb	$18
		fcb	35
		fcb	$00,$80	;4
		fcb	$03
		fcb	$14
		fcb	47
		fcb	$01,$50	;5
		fcb	$02
		fcb	$14
		fcb	47
		fcb	$02,$25 ;6
		fcb	$02
		fcb	$12
		fcb	47
		fcb	$03,$00	;7
		fcb	$01
		fcb	$12
		fcb	47
		fcb	$04,$00	;8
		fcb	$01
		fcb	$10
		fcb	47
		fcb	$06,$00	;9
		fcb	$01
		fcb	$10
		fcb	47
		fcb	$09,$99	;10
		fcb	$01
		fcb	$07
		fcb	47
		
set_level_data	lda	cur_level
	ldu	#leveldata
	ldb	#levelsize_c
	mul
	leau	b,u
	ldd	,u++
	std	bcd_remain
	inc	update_remain
	lda	,u+
	sta	p1_irq_max
	lda	,u+
	sta	hang_time
	lda	,u+
	sta	random_seed
	lda	cur_level
	adda	#$01
	daa
	sta	bcd_round
	inc	update_round
	clr	level_done
	rts
	
level_cleared	jsr	init_next_level
;	jsr	p1_draw_levelclear
;	jsr	init_next_level
	rts
;	lda	p1_level_flag
;	bne	@clact
;	jsr	p1_level_over
;
; cnp from memfill.asm
;
@clrlp	lda	vsync_done	;wait for vsync
	beq	@clrlp
	clr	vsync_done
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
	jsr	[joyrtn]
	jsr	[firertn]
	jsr	interpfire
	lda	lf1_stat
	beq	@nl
	ldb	lf2_stat
	beq	@nl
@clact	rts
	
old_level_cleared	jsr	p1_erasecur
; clear all lines
@vlp1	lda	vsync_done
	beq	@vlp1
	clr	vsync_done
	lda	#12	;number of rows - 1
	pshs	a
@clrrow	jsr	clear_p1_row
@wtclr	jsr	p1_draw_levelclear
	lda	row_clr_count	;if no blocks were cleared, skip to the next row
	beq	@nxtln
; at this point, add the count to the bonus subtract
	jsr	p1_set_dirty_bits
	jsr	p1_full_redraw
@vlp2	lda	vsync_done
	beq	@vlp2
	clr	vsync_done
	lda	line_clr_done
	beq	@wtclr
@nxtln	puls	a
	deca
	bge	@clrrow	
@snd	lda	playing_sound
	beq	@vlp3
	jsr	pia_dis_sound
@vlp3	lda	vsync_done	;wait for vsync
	beq	@snd
	clr	vsync_done
	jsr	[joyrtn]
	jsr	[firertn]	;wait until user releases all buttons
	jsr	interpfire
	lda	lf1_stat
	beq	@nl
	lda	lf2_stat
	bne	@vlp3
@nl	lda	vsync_done	;wait for vsync
	beq	@nl
	clr	vsync_done
	jsr	[joyrtn]
	jsr	[firertn]
	jsr	interpfire
	lda	lf1_stat
	beq	@nl
	ldb	lf2_stat
	beq	@nl
	jsr	p1_clr_levelclear
	jsr	initscrndata
	jsr	clearinfodata
	lda	#$ff
	sta	p1_dropidx
;	sta	update_score
	jsr	init_p1_irq
	jsr	init_next_level
	rts

init_next_level	lda	cur_level
	cmpa	#max_level_c
	beq	@set
	inca
	sta	cur_level
@set	jsr	set_level_data
	rts
	
init_level_data	lda #$00
	sta	cur_level
	jsr	set_level_data
	rts
cur_level	rmb 1
line_clr_done	rmb 1
row_clr_count	rmb 1