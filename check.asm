

CHECKBLOCKS inc	check_active
	rts
	
p1_check_lines	lda	check_active
	beq	@ret
	jsr	clearinfodata
	ldx	#leftscrndata
	ldy	#leftinfodata
	lda	p1_dropidx	;clear the 'dropidx' during check
	bmi	@nosv
	ldb	a,x
	stb	st_drop
	clr	a,x
@nosv	jsr	check_left_side
	jsr	check_right_side
	jsr	check_clear_left
	jsr	clear_p1_lines
;	jsr	check_clear_right
;	jsr	check_left_side
;	jsr debug_check
	lda	p1_dropidx	;restore 'dropidx'...
	bmi	@done
	ldb	st_drop
	stb	a,x
@done	clr	check_active
@ret	rts
check_active	rmb 1
st_drop	rmb	1


;Called from 'p1_game_over'
clear_all_p1_blocks clr	check_active	;probably not needed.
;	lda	#$0f
;	sta	check_active	;make sure that no further checking can be done
	jsr	p1_clr_chg_bits
	ldy	#leftinfodata
	ldx	#leftscrndata
;	jsr	p1_clrinfo
	ldb	#78
@lp	decb
	bmi	@done
	lda	b,x
	beq	@lp	; if it's a non-zero val, change it to the 'clear sprite'
	lda	#8
	sta	b,x
	clr	b,y	;dbg --RCTAG
	bra	@lp
@done	ldb	#8
	stb	_P1CLR
	jsr	redraw_p1
	jsr	set_p1_clrln_irq
	lda	#$ff
	sta	p1_dropidx
	lda	#clrline_snd_c
	jsr	ovrd_sound
	rts

; a - rownum	
clear_p1_row clr	check_active
	clr	row_clr_count
	clr	line_clr_done
	jsr	p1_clr_chg_bits
	ldy	#leftinfodata
	ldx	#leftscrndata
	ldb	#6
	mul
	abx
	leay	b,y
	ldb	#6
@lp	lda	,x
	beq	@skp
	lda	#8
@skp	sta	,x+
	clr	,y+
	inc	row_clr_count
	decb
	bne	@lp
	lda	row_clr_count
	beq	@ret		;nothing cleared on this line... 
	ldb	#8
	stb	_P1CLR
	jsr	redraw_p1
	jsr	set_p1_clrln_irq
	lda	#$ff
	sta	p1_dropidx
	lda	#clrline_snd_c
	jsr	ovrd_sound
@ret	rts
	
clear_p1_lines	jsr	clr_add_score
	jsr	clr_bonus
	ldx	#clrcounts
	ldy	#leftinfodata
	clr	@irq_chg
	clrb
@lp	incb
	lda	b,x
	cmpb	#27
	beq	@done
	cmpa	#1		;are there more than 1 charge points marked for this index?
	ble	@lp		;nope, check the next
	jsr	_clr_line	;yep, clear that line
	lda	@irq_chg
	bne	@lp
	coma
	sta	@irq_chg
	bra	@lp
@done   ldb	#8	;clear sprite number
	jsr	redraw_p1	;
;	ldx	left_pos
;	jsr	p1_drawcursor
	inc	p1_cur_dirty
	lda	@irq_chg
	beq	@ret
	lda	#8
	sta	_P1CLR
	inc	p1_clr_active
	jsr	set_p1_clrln_irq
@ret	jsr	add_line_bonus
	jsr	add_blk_bonus
	rts
@irq_chg  rmb 1

; Only called from clear_p1_lines or clear_p2_lines
; y - points to info buffer
; b - is the index to clear		
_clr_line pshs	x
	stb	@cmp+1
	ldb	#$ff
	leax	-156,y	;point x to the screen data
@nxt	incb
	cmpb	#78
	beq	@done
	lda	b,y	;get info...
@cmp	cmpa	#$00	;overwritten by 'stb'
	bne	@nxt	;not the same index, goto next
	lda	#8	;sprite 8... the first 'explosion' sprite
	sta	b,x
	clr	b,y	;DEBUG!!
	jsr	inc_blk_score
	jsr	decrease_remain
	bra	@nxt
@done	puls	x
	ldb	@cmp+1
	jsr	inc_line_bonus
	lda	#clrline_snd_c
	jsr	ovrd_sound	;override the 'block land' sound
	inc	update_score
	inc	update_remain
	inc	line_clr_count
	rts

; Only called from clear_p1_lines or clear_p2_lines
;
redraw_p1 ldx	#leftscrndata	;point x to screen data
	ldu	#leftscrnptrs-2
	lda	#$ff
	stb	_rdsp+1
	bra	_redraw

redraw_p2 ldx	#rightscrndata
	ldu	#rightscrnptrs-2
	lda	#$ff
	stb	_rdsp+1
;	jmp	_redraw
	
_redraw	inca
	leau	2,u	;hate doing this in a loop.
	cmpa	#78
	beq	@done
	ldb	a,x
_rdsp	cmpb	#$08	;the sprite num to redraw
	bne	_redraw	;was this location cleared?
	pshs	x,a	;a & x are clobbered by drawsprite
	ldy	,u
	leay	screenstart,y
	jsr	drawsprite
	puls	x,a	;
	bra	_redraw
@done	rts

animate_p1_clr ldx #leftscrndata
	ldu	#leftscrnptrs-2
	lda	_P1CLR
	anda	#legal_bits
	sta	@mod+1
	lsra			;shifting right points to the next sprite.
	sta	_P1CLR
	ldb	#$ff
@alp	incb
	cmpb	#78
	beq	@done
	leau	2,u
	lda	b,x
	anda	#legal_bits
@mod	cmpa	#$00		;overwritten operand
	bne	@alp
	lsra			;yep, this is the right one!
	sta	b,x
	pshs	b,x
	ldb	_P1CLR
	ldy	,u
	leay	screenstart,y
	jsr	drawsprite
	puls	b,x
	bra	@alp
@done	lda	_P1CLR
	bne	@ret
;	jsr	CHECKBLOCKS	;try checking again!!  [done elsewhere]
;RCTODO - increment score multiplier here??
	jsr	set_p1_irq_drop	;done clearing!
	clr	p1_clr_active
	inc	p1_cur_dirty
	lda	p1_level_flag
	bne	@gmovr
	com	level_done
@gmovr	lda	p1_game_flag
	bne	@chklvl		;game is still going is this is non-zero
; but if we get here, the flag is set... and this was the last frame of the animation being done!!
	com	game_over_flag	;signal to main loop to return to titlescrn.
	rts
@chklvl	com	line_clr_done
@ret	rts
_P1CLR	rmb	1
	
check_clear_left ldy #leftinfodata
	jmp check_clear_lines

check_clear_right ldy #rightinfodata
	jmp check_clear_lines
		
check_clear_lines ldx #clrcounts
	ldu #$0000
	ldb #13
@lp	stu ,x++
	decb
	bne @lp
	clr ,x
	ldx #clrcounts
	ldu #leftscrndata
	clra		;index
@lflp	ldb	a,u
	bitb	#left_bitmask	;this is the left side, skip if not conn'd
	beq	@sk1
	ldb	a,y
	beq	@sk1
	inc	b,x
@sk1	adda	#$6
	cmpa	#72
	ble	@lflp
	lda 	#5	;done left side, now do right
@rtlp	ldb	a,u
	bitb	#right_bitmask	;this is the left side, skip if not conn'd
	beq	@sk2
	ldb	a,y
	beq	@sk2
	inc	b,x
@sk2	adda	#$6
	cmpa	#77
	ble	@rtlp
	rts
clrcounts	rmb 27	;26 + 1 dummy area.
	
; X - pt to tilebuffer
; Y - pt to infobuffer
; U - queue for next checks
; A - current block.
; B -worker var
check_right_side clrb
	stb curr_row
	addb #14		; for right side, add 14 (13 + 1)
	stb curr_start_pt
	lda #5
	sta curr_col
	sta curr_idx
@chknxt	ldu #block_queue	; queue for 'next checks'
	ldb #$ff		; store 'end of que'
	stb ,U
	lda curr_idx		; a - idx, b - startpt
	ldb a,y			; first check if this is already marked.
	bne @next
	lda a,x
	bita #right_bitmask	;
	beq @next		; if 0, doesn't point right
	lda curr_idx
	ldb curr_start_pt
	stb a,Y			; store the pathid in the 'infobuf'
	pshs a,b
	jsr check_conn
	puls a,b
@next	ldb curr_start_pt
	cmpb #26
	bgt @done
	incb
	stb curr_start_pt
	subb #14
	stb curr_row		; curr_row + 13 + 1 == curr_start_pt
	lda #5			; tricky optimization, multiply by 1 row higher, then dec index
	sta curr_col		; also, store 5 in curr_col, but multiply 6
	inca
	incb
	mul
	decb
	stb curr_idx
	bra @chknxt
@done	rts

; X - pt to tilebuffer
; Y - pt to infobuffer
; U - queue for next checks
; A - current block.
; B -worker var
check_left_side	clrb
	stb curr_col
	stb curr_row
	stb curr_idx
	incb
	stb curr_start_pt
@chknxt	ldu #block_queue	; queue for 'next checks'
	ldb #$ff		; store 'end of que'
	stb ,U
	lda curr_idx		; a - idx, b - startpt
	ldb a,y			; first check if this is already marked.
	bne @next
	lda a,x
	bita #left_bitmask	;
	beq @next		; if 0, doesn't point left
	lda curr_idx
	ldb curr_start_pt
	stb a,Y			; store the pathid in the 'infobuf'
	pshs a,b
	jsr check_conn
	puls a,b
@next	ldb curr_start_pt
	cmpb #13
	bge @done
	stb curr_row		; curr_row + 1 == curr_start_pt
	incb
	stb curr_start_pt
	decb
	lda #6
	mul
	stb curr_idx
	clr curr_col
	bra @chknxt
@done	rts

curr_col	rmb 1
curr_row	rmb 1
curr_idx	rmb 1
curr_start_pt	rmb 1

check_conn stu que_end
	stu que_ptr
;debug!!
	inc chkcount_dbg
;debug
	lda curr_col
	ldb curr_idx
	sta my_curr_col
	stb my_curr_idx
@chknxt	jsr check_conn_left
	beq @chkup		; branch if not connected.
; do stuff here
;debgu
	inc cl_dbg
	ldb my_curr_idx
	decb			; put idx to check into queue
	lda b,y			; check to see if this has already been marked
	bne @chkup		; it's been noted already, don't need to repeat
	lda curr_start_pt	; not marked yet... mark and add to check queu
	sta b,y
	lda my_curr_col
	beq @chkup		; at left side, don't add to queue
	deca
	sta ,u+			; stkU - the queue.
	stb ,u+
	lda #$ff		; $ff... marks end of queue
	sta ,u
@chkup	lda my_curr_col
	ldb my_curr_idx
	jsr check_conn_up
	beq @chkdn		; if not conn'd, go to next
; do stuff here!!
	ldb my_curr_idx
	subb #6			; point to higher block (if we're here, we must be on 2nd row or lower)
	lda b,y			; check to see if this has already been marked
	bne @chkdn		; it's been noted already, don't need to repeat
; debug
	inc cu_dbg
	lda curr_start_pt	; not marked yet... mark and add to check queu
	sta b,y
	lda my_curr_col
	sta ,u+			; stkU - the queue.
	stb ,u+
	lda #$ff		; $ff... marks end of queue
	sta ,u
@chkdn	lda my_curr_col
	ldb my_curr_idx
	jsr check_conn_down
	beq @chkrt
; do stuff here!!
	ldb my_curr_idx
	addb #6			; point 1 row  down, must not be lowest row if we're here
	lda b,y			; check to see if this has already been marked
	bne @chkrt		; it's been noted already, don't need to repeat
; debug
	inc cd_dbg
	lda curr_start_pt	; not marked yet... mark and add to check queu
	sta b,y
	lda my_curr_col
	sta ,u+			; stkU - the queue.
	stb ,u+
	lda #$ff		; $ff... marks end of queue
	sta ,u
@chkrt	lda my_curr_col
	ldb my_curr_idx
	jsr check_conn_right
	beq @chkque
; do stuff here!!
	ldb my_curr_idx
	incb			; put idx to check into queue
	lda b,y			; check to see if this has already been marked
	bne @chkque		; it's been noted already, don't need to repeat
; debug
	inc cr_dbg
	lda curr_start_pt	; not marked yet... mark and add to check queu
	sta b,y
	lda my_curr_col
	cmpa #5
	beq @chkque		; at right side, don't add to queue
	inca
	sta ,u+			; stkU - the queue.
	stb ,u+
	lda #$ff		; $ff... marks end of queue
	sta ,u
@chkque	stu que_end		; end of que is currently in stkU
;DEBUG!!
;@chkque bra @ret
; DEBUG!!
	ldu que_ptr
	lda ,U+			; get col
	cmpa #$ff		; is queue empty?
	beq @ret
;debug
	inc rd_que
	sta my_curr_col
	ldb ,U+			; get index
	stb my_curr_idx		; (13*6)-1 should be max, which is 77
	stu que_ptr		; point to next block to check
	ldu que_end		; point u @ end of queue
	lbra @chknxt
@ret	rts
que_ptr		rmb 2
que_end		rmb 2
my_curr_col	rmb 1
my_curr_idx	rmb 1
	
; x -tile buffer
; a -column (trampled -returns non-zero if conn'd)
; b -index
check_conn_up cmpb #$5
	ble	@not		;if index < 5, then on top row.
	lda	B,X		; 
	bita	#up_bitmask	;check if this points up
	beq	@not
	subb	#$6
	lda	b,x		; get block above
	bita	#down_bitmask	;check if points down
	bne	@yes		;if this is set, then a is non-zero, whict means that it's connected
@not	clra			;clr means not connected
@yes	rts

; x -tile buffer
; a -column (trampled -returns non-zero if conn'd)
; b -index
check_conn_down	cmpb #72
	bge	@not		;if index > 72, then on bottom row
	lda	B,X		; 
	bita	#down_bitmask	;check if this points down
	beq	@not
	addb	#$6
	lda	b,x		; get block below
	bita	#up_bitmask	;check if points up
	bne	@yes		;if this is set, then a is non-zero, whict means that it's connected
@not	clra			;clr means not connected
@yes	rts

; x -tile buffer
; a -column (trampled -returns non-zero if conn'd)
; b -index
check_conn_left cmpa #$00
;	beq	@lfsd		;if column is 0, then on left side, skip right check, it does connect
	beq	@not		;TMP -- Might not need to mark as checked as in prev line.
	decb
	lda	B,X		; 
	bita	#right_bitmask	;check if this points right
	beq	@not
	incb			;point to original index
@lfsd	lda	b,x		;get left block
	bita	#left_bitmask	;check if points left
	bne	@yes		;if this is set, then a is non-zero, whict means that it's connected
@not	clra			;clr means not connected
@yes	rts

; x -tile buffer
; a -column (trampled -returns non-zero if conn'd)
; b -index
check_conn_right cmpa #$5
;	beq	@rtsd		;if column is 5, then on right side, skip left check, it does connect
	beq	@not		;TMP
	incb
	lda	b,x		; get block to right
	bita	#left_bitmask	;check if points left
	beq	@not		;if this is set, then a is non-zero, whict means that it's connected
	decb
@rtsd	lda	B,X		; 
	bita	#right_bitmask	;check if this points right
	bne	@yes		;if this is set, then a is non-zero, whict means that it's connected
@not	clra			;clr means not connected
@yes	rts

block_queue rmb 256

; HOOKS

; Check if a block is to be dragged left or right.
; a - drag flag
; a & b are free.
; x can be easily
p1_check_drag	rts
; check if vert movement
; if not, return (clear drag flag)
; if yes, check if that column is empty at that level.
; if not, return & clear drag flag)
; if yes, move this block in that direction, drop those two columns, redraw, check

p2_check_drag	rts
; ****DEBUG

; Print_info
; X - point to infobuf
; Y - screen loc
chkcount_dbg	rmb 1
cl_dbg	rmb 1
cu_dbg	rmb 1
cr_dbg	rmb 1
cd_dbg	rmb 1
rd_que	rmb 1

; y screen loc
; a byte
print_byte pshs a
	lsra
	lsra
	lsra
	lsra
	adda #$30
	cmpa #$39
	ble @out1
	adda #$7
@out1	sta ,y+
	puls a
	anda #$0f
	adda #$30
	cmpa #$39
	ble @out2
	adda #$7
@out2	sta ,y+
	rts
	
; y screen loc
; a byte
print_num adda #$30
	cmpa #$39
	ble @out
	lda #'?
@out	sta ,y+
	rts	
; Print_info
; X - point to infobuf
; Y - screen loc
print_info	ldx	#leftinfodata
	ldy	#$402
	ldb	#13
@lp_out	pshs	b
	ldb	#6
@lp_in	jsr	blk2chr
	decb
	bne	@lp_in
	leay	34,y	
	puls	b
	decb
	bne	@lp_out
	ldy	#$634
	lda	chkcount_dbg
	jsr	print_byte

	ldy	#$65c
	lda	cl_dbg
	jsr	print_byte

	ldy	#$684
	lda	cr_dbg
	jsr	print_byte

	ldy	#$6ac
	lda	cu_dbg
	jsr	print_byte

	ldy	#$6d4
	lda	cd_dbg
	jsr	print_byte

	ldy	#$6fc
	lda	rd_que
	jsr	print_byte
	
	ldy	#$724
	lda	p1_dropidx
	jsr	print_byte
	
	ldy	#$748
	ldx	#clrcounts
	clrb
@lp	lda	b,x
	jsr	print_num
	incb
	cmpb	#26
	ble	@lp
	rts
	
blk2chr	lda	,x+
	bne	@isltr
	adda	#$30
	bra	@wrt
@isltr	cmpa	#26
	bhi	@ovl
	adda	#$40	;create ascii letter
	bra	@wrt
@ovl	lda	#'?
@wrt	sta	,y+
	rts

gmover_print	pshs x,y,d
	ldy	#$400
	ldx	#gmpia
@ln1	lda	,x+
	bne	@nx1
	sta	,y+
	bra	@ln1
@nx1	lda	PIA2+3
	jsr	print_byte
	puls	x,y,d,pc

gmpia	FCC	"FF23:"
	FCB	0
		
init_print	ldy #$400
	lda #'A
	ldb #13
	clr chkcount_dbg
@nx1	sta ,y
	leay 40,y
	inca
	decb
	bne @nx1
	ldb #13
	ldy #$409
@nx2	sta ,y
	leay 40,y
	inca
	decb
	bne @nx2
	ldd #$0000
	std cl_dbg
	std cr_dbg
	sta rd_que
	ldy #$630
	ldx #dbg_msg
	ldb #4
@pn1	lda ,x+
	sta ,y+
	decb
	bne @pn1
	lda chkcount_dbg
	jsr print_byte
	
	ldy #$658
	ldx #l_msg
	ldb #4
@pn2	lda ,x+
	sta ,y+
	decb
	bne @pn2
	lda cl_dbg
	jsr print_byte
	
	ldy #$680
	ldx #r_msg
	ldb #4
@pn3	lda ,x+
	sta ,y+
	decb
	bne @pn3
	lda cr_dbg
	jsr print_byte
	
	ldy #$6a8
	ldx #u_msg
	ldb #4
@pn4	lda ,x+
	sta ,y+
	decb
	bne @pn4
	lda cu_dbg
	jsr print_byte
	
	ldy #$6d0
	ldx #d_msg
	ldb #4
@pn5	lda ,x+
	sta ,y+
	decb
	bne @pn5
	lda cd_dbg
	jsr print_byte
	
	ldy #$6f8
	ldx #q_msg
	ldb #4
@pn6	lda ,x+
	sta ,y+
	decb
	bne @pn6
	lda cd_dbg
	jsr print_byte
	
	ldy #$720
	ldx #di_msg
	ldb #4
@pn7	lda ,x+
	sta ,y+
	decb
	bne @pn7
	lda p1_dropidx
	jsr print_byte
	rts
	
dbg_msg	fcc "CC: "
l_msg	fcc "LF: "
r_msg	fcc "RT: "
u_msg	fcc "UP: "
d_msg	fcc "DN: "
q_msg	fcc "RQ: "
di_msg	fcc "DP: "