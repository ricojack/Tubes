bcd_score	fcb 00,00,00
ascii_score	fcc "000000"
		fcb 0
bcd_add_score	fcb 00,00,00
blk_bonus	fcb 00	;5,15,35,75
line_bonus	fcb 00
line_clr_count	fcb 00

bcd_round	fcb 01
ascii_round	fcc "01"
		fcb 0

bcd_remain	fdb $0010
ascii_remain	fcc "0010"
		fcb 0

bcd_hiscore	fcb 00,00,00
ascii_hiscore	fcc "000000"
		fcb 00
		
p1_initscore	clra
	clrb
	std	bcd_score
	sta	bcd_score+2
	ldd	#$3030
	std	ascii_score
	std	ascii_score+2
	std	ascii_score+4
	lda	#$01
	sta	bcd_round
	lda	#'1'
	sta	ascii_round+1
	sta	ascii_remain+2
	ldd	#$0010
	std	bcd_remain
	lda	#'0'
	sta	ascii_remain
	sta	ascii_remain+1
	sta	ascii_remain+3
	clr	level_done
	lda	#$01
	sta	update_score
	sta	update_remain
	sta	update_round
	rts

p1_check_hiscore ldx #bcd_score
	ldy	#bcd_hiscore
	lda	,x+
	cmpa	,y+
	blo	@done
	lda	,x+
	cmpa	,y+
	blo	@done
	lda	,x+
	cmpa	,y+
	bls	@done
	ldx	#bcd_score
	ldy	#bcd_hiscore
@lp	lda	,x+
	sta	,y+
	cmpx	#bcd_add_score
	bne	@lp
@done	rts

p1_draw_high ldd #$00ff
	ldx	#ascii_hiscore
	ldy	#hiscore_scrnloc_c+screenstart
	jsr	ts_drawtext
	rts

p1_drawround lda update_round
	beq	@done
	ldx	#bcd_round
	ldy	#ascii_round
	ldb	#1
	jsr	bcd_to_ascii
	ldd	#$22ff
	ldx	#ascii_round
;	ldy	#round_bgloc_c+screenstart
;	jsr	draw_big_num
	ldy	#round_scrnloc_c+screenstart
;	ldd	#$2255
	jsr	draw_big_num
	clr	update_round
@done	rts
update_round	rmb	1

p1_drawremain lda update_remain
	beq	@done
;	ldd	bcd_remain
;	bgt	@drw
;	ldd	#$0000
;	std	bcd_remain
@drw	ldx	#bcd_remain
	ldy	#ascii_remain
	ldb	#2
	jsr	bcd_to_ascii
	ldd	#$22ff
	ldx	#ascii_remain+1
	ldy	#remn_scrnloc_c+screenstart
	jsr	draw_big_num
	clr	update_remain
@done	rts
update_remain	rmb	1

p1_drawscore lda update_score
	beq	@done
	ldx	#bcd_score
	ldy	#ascii_score
	ldb	#3
	jsr	increase_score
	jsr	bcd_to_ascii
	ldx	#ascii_score
	lda	#$ff
	ldb	#$22
	ldy	#score_scrnloc_c+screenstart
	jsr	draw_text
@done	clr	update_score
	rts
update_score	rmb 1

inc_blk_score	lda	bcd_add_score+2
	adda	#1
	daa
	sta	bcd_add_score+2
	jsr	inc_blk_bonus
	rts
	
;A - current low num
inc_blk_bonus sta	@rstr+1
	anda	#$0f
	cmpa	#5
	bne	@rstr
	lda	blk_bonus
	cmpa	#bonus_max
	bge	@rstr
	adda	blk_bonus
	daa
	adda	#5
	daa
	sta	blk_bonus
@rstr	lda	#$00	;overwritten
@ret	rts

inc_line_bonus	lda	line_bonus
	cmpa	#bonus_max
	bge	@ret
	lsla		; multiply by two
	inca		; and add 1
	sta	line_bonus
@ret	rts

;A -  bcd num
;X -  src
;Y -  dst
;carry bit will be set appropriately
bcd_add_byte adda ,x
	daa
	sta	,y
	rts

bcd_adc_byte adca ,x
	daa
	sta	,y
	rts

add_line_bonus lda	line_clr_count
	cmpa	#$01
	beq	@ret	;no bonus if you only clear 1 line!
	lda	line_bonus
	adda	bcd_add_score+1
	daa
	sta	bcd_add_score+1
	bcc	@ret
	lda	bcd_add_score
	adda	#1
	daa
	sta	bcd_add_score
@ret	rts

add_blk_bonus lda blk_bonus
_24bi	adda	bcd_add_score+2	; 24 bit inc
	daa
	sta	bcd_add_score+2
	bcc	@ret
	lda	bcd_add_score+1
	adda	#1
	daa
	sta	bcd_add_score+1
	bcc	@ret
	lda	bcd_add_score
	adda	#1
	daa
	sta	bcd_add_score
@ret	rts

increase_score lda	bcd_add_score+2
	adda	bcd_score+2
	daa
	sta	bcd_score+2
	lda	bcd_add_score+1
	adca	bcd_score+1
	daa
	sta	bcd_score+1
	lda	bcd_add_score
	adca	bcd_score
	daa
	sta	bcd_score
;	inc	update_score
	rts
;	jmp	bcd_to_ascii
	
increase_round	lda bcd_round
	adda	#$01
	daa
	sta	bcd_round
	rts

decrease_remain lda level_done
	bne	@ret
	lda	bcd_remain+1
	adda	#$99
	daa
	sta	bcd_remain+1
	bcs	@done	;if carry is clear, then the number was @0, so borrow from next byte
	lda	bcd_remain
	adda	#$99
	sta	bcd_remain
	bcs	@done	;no problem, still more to clear
;	bne	@done	;no problem, still more to clear
	clra		;if we are here, then the counter is now 0!!
	sta	bcd_remain+1
	sta	bcd_remain
;	inc	level_done
@done	ldd	bcd_remain
	bne	@ret
	inc	level_done
@ret	rts	
level_done	rmb 1

;B - num bytes to conver
;X - src byte
;Y - dst loc
bcd_to_ascii lda	,x
	lsra
	lsra
	lsra
	lsra
	adda	#$30
	sta	,y+
	lda	,x+
	anda	#$0f
	adda	#$30
	sta	,y+
	decb
	bne	bcd_to_ascii
	rts

clr_add_score ldd #$0000
	std	bcd_add_score
	sta	bcd_add_score+2
	rts

clr_bonus ldd	#$0000
	std	blk_bonus
	sta	line_clr_count
	rts


