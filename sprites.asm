
;spritetable	includebin sprites.raw

spritesize	equ 128
spritewidth	equ 8
spriteheight	equ 16

movedownadj	equ (spriteheight*screenwidth)
moveupadj	equ -movedownadj
moveleftadj	equ -spritewidth
moverightadj	equ spritewidth

leftscrndata	rmb 78	
rightscrndata	rmb 78	; 6 columns * 13 rows = 78
leftinfodata	rmb 78
rightinfodata	rmb 78

;spritecnvttable	fcb 0,3,5,6,7,9,10,11,12,13,14,15

spritecnvttable	fcb	5,10,5,10,3,6,9,12,3,6,9,12
		fcb	5,5,5,10,10,3,3,6,9,12,11,13
		fcb	5,5,10,10,3,6,9,12,7,11,14,15
		fcb	5,5,10,10,3,6,9,12,7,14,15,15
		
rotaterighttable fcb 0,1,2,6,4,10,12,14,8,3,5,7,9,11,13,15
rotatelefttable  fcb 0,1,2,9,4,10,3,11,8,12,5,13,6,14,7,15
cleartable	fcb 8,1,2,4,0

;vertoffsettable	fdb $500,$f00,$1900,$2300,$2d00,$3700,$4100,$4b00,$5500,$5f00,$6900,$7300,$7d00
;lefthorztable	fcb $0c,$14,$1c,$24,$2c,$34
;righthorztable	fcb $64,$6c,$74,$7c,$84,$8c

;leftscrnptrs	fdb $50c,$514,$51c,$524,$52c,$534
;		fdb $f0c,$f14,$f1c,$f24,$f2c,$f34
;		fdb $190c,$1914,$191c,$1924,$192c,$1934
;		fdb $230c,$2314,$231c,$2324,$232c,$2334
;		fdb $2d0c,$2d14,$2d1c,$2d24,$2d2c,$2d34
;		fdb $370c,$3714,$371c,$3724,$372c,$3734
;		fdb $410c,$4114,$411c,$4124,$412c,$4134
;		fdb $4b0c,$4b14,$4b1c,$4b24,$4b2c,$4b34
;		fdb $550c,$5514,$551c,$5524,$552c,$5534
;		fdb $5f0c,$5f14,$5f1c,$5f24,$5f2c,$5f34
;		fdb $690c,$6914,$691c,$6924,$692c,$6934
;		fdb $730c,$7314,$731c,$7324,$732c,$7334
;		fdb $7d0c,$7d14,$7d1c,$7d24,$7d2c,$7d34

leftscrnptrs	fdb $41c,$424,$42c,$434,$43c,$444
		fdb $c1c,$c24,$c2c,$c34,$c3c,$c44
		fdb $141c,$1424,$142c,$1434,$143c,$1444
		fdb $1c1c,$1c24,$1c2c,$1c34,$1c3c,$1c44
		fdb $241c,$2424,$242c,$2434,$243c,$2444
		fdb $2c1c,$2c24,$2c2c,$2c34,$2c3c,$2c44
		fdb $341c,$3424,$342c,$3434,$343c,$3444
		fdb $3c1c,$3c24,$3c2c,$3c34,$3c3c,$3c44
		fdb $441c,$4424,$442c,$4434,$443c,$4444
		fdb $4c1c,$4c24,$4c2c,$4c34,$4c3c,$4c44
		fdb $541c,$5424,$542c,$5434,$543c,$5444
		fdb $5c1c,$5c24,$5c2c,$5c34,$5c3c,$5c44
		fdb $641c,$6424,$642c,$6434,$643c,$6444

rightscrnptrs	fdb $564,$56c,$574,$57c,$584,$58c
		fdb $f64,$f6c,$f74,$f7c,$f84,$f8c
		fdb $1964,$196c,$1974,$197c,$1984,$198c
		fdb $2364,$236c,$2374,$237c,$2384,$238c
		fdb $2d64,$2d6c,$2d74,$2d7c,$2d84,$2d8c
		fdb $3764,$376c,$3774,$377c,$3784,$378c
		fdb $4164,$416c,$4174,$417c,$4184,$418c
		fdb $4b64,$4b6c,$4b74,$4b7c,$4b84,$4b8c
		fdb $5564,$556c,$5574,$557c,$5584,$558c
		fdb $5f64,$5f6c,$5f74,$5f7c,$5f84,$5f8c
		fdb $6964,$696c,$6974,$697c,$6984,$698c
		fdb $7364,$736c,$7374,$737c,$7384,$738c
		fdb $7d64,$7d6c,$7d74,$7d7c,$7d84,$7d8c

p1_initdata ldx	#leftscrndata
	clrb
	bsr	@a
	ldx	#leftinfodata
@a	lda	#78
	stb	,x+
	bne	@a
	rts

initscrndata	lda #78
	ldx #leftscrndata
	ldu #$0000
@a	stu ,x++
	deca
	bne @a
	rts

clearinfodata	lda #78
	ldx #leftinfodata
	ldu #$0000
@a	stu ,x++
	deca
	bne @a
	rts
	
__fillscrndata	lda #$f
	ldx #leftscrndata
@a	sta ,x+
	deca
	bge @a
	ldx #rightscrndata
	leax -1,x
	lda #$f
	sta ,x
	rts

initleftscr	ldu #screenstart	;calculate curpos
	clra
@loop	pshs a
	ldx #leftscrndata
	ldb a,x		; get the sprite num from data table
	pshs b
	ldx #leftscrnptrs	; point to screen location table
	lsla
@ok1	ldd a,x			; acca -> offset into table
@ok2	leay d,u	; idxy now points to screen
@ds	puls b
	jsr drawsprite
	puls a
	inca
	cmpa #$20
	bne @loop
	rts

initrightscr	ldu #screenstart	;calculate curpos
	lda #$4b	;last index in table
@loop	pshs a
	ldx #rightscrndata
	ldb a,x		; get the sprite num from data table
	pshs a
	lsla
	ldx #rightscrnptrs	; point to screen location table
	ldd a,x			; acca -> offset into table
	leay d,u	; idxy now points to screen
	jsr drawsprite
	puls a
	deca
	bpl @loop
	rts

p1_start_game ldb #$ff
	stb	p1_game_flag
	stb	p1_level_flag
	stb	p1_last_col
	stb	p1_dropidx
;	stb	p1_cur_redraw
	clr	p1_blk_moved
	clr	check_active	;DEBUG!!!!
	clr	p1_clr_active
	clr	redraw_drop
	clr	p1_halfflag
	lda	#seed_start_c
	sta	random_seed
	jsr	p1_initdata
	jsr	p1_drop_start
	jsr	set_game_gfx
	rts
p1_game_flag	rmb 1
p1_level_flag	rmb 1

p1_game_over jsr clear_all_p1_blocks
	clr	p1_game_flag
	rts

p1_level_over jsr clear_all_p1_blocks
	clr	p1_level_flag
	rts
	
p1_wait_start	lda lf1_stat
	beq	@start		; if not pressed, skip to next button
	lda	lf2_stat
	bne	@wait
@start	jsr	p1_start_game
@wait	rts

p1_drop_start	orcc #$10
	lda	hang_time
;	lsla
;	lsla
	sta	p1_irq_val
	lda	p1_last_col	;
	inca
	cmpa	#6
	blt	@nr
	clra
@nr	sta	p1_dropidx
	sta	p1_last_col
	ldy	#screenstart	;calculate curpos
	ldu	#lefthorztable
;	ldb	#11		; get a random number from 0-11...
	ldb	random_seed
	jsr	RAND
;	inca		; really want 1-12
	ldu	#spritecnvttable
	lda	a,u
	ldx	#leftscrndata	; now, store the block in the screen data array
	ldb	p1_dropidx
	ldb	b,x		;check if there's a block there
	beq	@db
	jsr	p1_game_over	;YEP!! GAME OVER!!
	andcc	#$EF
;	andcc	#$EF
	rts	
@db	ldb	p1_dropidx
	ora	#dirty_bitmask
	sta	b,x
	inc	p1_cur_dirty
	andcc	#$ef
;	andcc	#$ef
	rts
random_seed	rmb 1
hang_time	rmb 1

p1_draw_drop lda redraw_drop
	beq	@done
	lda	p1_dropidx
	bmi	@done	;should never happen, but just in case...
	ldx	#leftscrndata
	ldu	#leftscrnptrs
	leax	a,x		;point to cell
	ldb	,x		;sprite num
	leax	a,u		;
	leax	a,x
	ldx	,x		;
;	ldy	,y		;
	leax	screenstart,x	;
	lda	p1_halfflag
	beq	@nohalf
	jsr	draw_half_blank
@nohalf leay	,x
	jsr	drawsprite
	clr	redraw_drop
@done	rts
p1_halfflag	rmb 1
redraw_drop	rmb 1

p1_dropblk lda	p1_dropidx
	bmi	@ret	;This should only be set @ start
	cmpa	#72
	bge	@setflg
	ldx	#leftscrndata
	leax	a,x	;move correct point
	ldb	well_width_c,x	;check if there's something in the cell below
	bne	@setflg	;non-zero means there's a block
	ldb	p1_halfflag
	bne	@drpnxt
	incb
	stb	p1_halfflag	;set the 'halfflag' for next time
	inc	redraw_drop	;notify draw code that the drop block should be redrawn (correctly).
	lda	p1_cur_dirty
	adda	#$10
	sta	p1_cur_dirty
;	clr	$ff9a	;border
	rts
@drpnxt	ldb	,x		;if we're here, the next line lower must be
	orb	#dirty_bitmask
	stb	well_width_c,x	;put block one level lower
	ldb	#dirty_bitmask
	stb	,x
	adda	#well_width_c
	sta	p1_dropidx
	lda	p1_cur_dirty
	adda	#$10
	sta	p1_cur_dirty
;	inc	p1_cur_dirty
	clr	p1_halfflag
;	com	$ff9a	;border
	rts
@setflg	lda	#$ff
	sta	p1_dropidx
	lda	#blkland_snd_c
	jsr	play_sound
	jsr	CHECKBLOCKS
	jsr	p1_drop_start
@ret	rts

p1_dropblk_v2 lda	p1_dropidx
	bmi	@ret	;This should only be set @ start
	cmpa	#72
	bge	@setflg 
	ldx	#leftscrndata
	leax	a,x	;move correct point
	ldb	well_width_c,x	;check if there's something in the cell below
	bne	@setflg	;non-zero means there's a block
	ldb	,x
	orb	#dirty_bitmask
	stb	well_width_c,x	;put block one level lower
	ldb	#dirty_bitmask
	stb	,x
	adda	#well_width_c
	sta	p1_dropidx
	lda	p1_cur_dirty
	adda	#$10
	sta	p1_cur_dirty
;	inc	p1_cur_dirty
	rts
@setflg	lda	#$ff
	sta	p1_dropidx
	jsr	CHECKBLOCKS
	jsr	p1_drop_start
@ret	rts

_drop_half nop	;a halfway drop... need a 'half_flag'
	; will have to change the falling code... the block is not actually
	; in the array, it's just drawn on the screen.
	; once it settles at the final position, it becomes part of the well
	; details: what about the cursor?  easy: every cursor move means redraw the fall.
	;  - what about the half fall? draw that well spot, then the fall icon, then the 
	; cursor
	rts
; a - index into table
; returns: a==0, finished drop, a!=0, new position
_dropblkone clra	;lda	dropidx
	bmi	@ret	;This should only be set @ start
	cmpa	#72
	bge	@setflg 
	ldx	#leftscrndata
	leax	a,x	;move correct point
	ldb	6,x	;check if there's something in the cell below
	bne	@setflg	;non-zero means there's a block
	ldb	,x
	stb	6,x	;put block one level lower
	clr	,x	;make old location empty
	pshs	b	;a - index, b - spritenum
;	ldy	dropptr
	adda	#6
;	sta	dropidx
;	***optimize later
	clrb		;do the clear first
	jsr	drawsprite
	puls	b
	ldx	#leftscrnptrs
;	lda	dropidx
;	ldy	dropptr
;	leay	$a00,y	;drop 16 rows
	leay	(screenwidth*16),y	;drop 16 rows
;	sty	dropptr
	jsr	drawsprite
	inc	p1_cur_dirty
;	ldx	p1_cur_scrptr
;	jsr	p1_drawcursor
	rts	;return 
@setflg	jsr	CHECKBLOCKS
	jsr	p1_drop_start
@ret	rts
_dropidx	rmb	1
_dropptr rmb	2

; x - source buf
; a - column + 72
copy_col ldy #col_work_buf
@lp	ldb	a,x
	andb	#~(charge_bitmask|dirty_bitmask)
	beq	@sk1
;	andb	#~charge_bitmask	;make sure this is redrawn correctly.
	stb	,y+
@sk1	suba	#6
	bge	@lp
	clr	,y
	rts
col_work_buf	rmb 14

; p1/p2_full_redraw
; This walks through the entire tile well, and redraws each tile, based
; on the dirty bit.  (If set, redraw.  If clr, skip)
; No parameters
p1_full_redraw ldx #leftscrndata
	ldu	#leftscrnptrs
	bra	_gbl_full_redraw

p2_full_redraw ldx #rightscrndata
	ldu	#rightscrnptrs
	
_gbl_full_redraw lda	#77
@lp	ldb	a,x
	bitb	#dirty_bitmask
	beq	@nxt		;if not set, skip to next
	andb	#~dirty_bitmask
	stb	a,x		; clear dirty bit
	pshs	x,y,a,b		;save regs, calculate screenpos & redraw
	leay	a,u		;
	leay	a,y		;
	ldy	,y		;
	leay	screenstart,y	;
	jsr	drawsprite	;
	puls	x,y,a,b		;
@nxt	deca
	bge	@lp
	rts

; sets the dirty bits based on whether the sprite is charged or not charged
p1_set_dirty_bits lda p1_clr_active
	beq	@set		;if this flag is set, then don't bother setting the dirty bits right now.
	rts
@set	ldx	#leftscrndata
	ldu	#leftinfodata
	bra	_gbl_set_dirty_bits

p2_set_dirty_bits lda	p2_clr_active
	beq	@set		;if this flag is set, then don't bother setting the dirty bits right now
	rts
@set	ldx	#rightscrndata
	ldu	#rightinfodata

_gbl_set_dirty_bits ldb	#77
@lp	lda	b,u		; should this square be charged?
	beq	@no_chg		; not charged if 0.
@chg	lda	b,x		; If we are here, then the sprite should be charged
	bita	#charge_bitmask
	bne	@nxt		; if set, skip to next sprite, no need to redraw
	ora	#(dirty_bitmask|charge_bitmask)	; otherwise, set the dirty bit ofr redraw
	sta	b,x
	bra	@nxt 
@no_chg	lda	b,x		; sprite should not be charged
	bita	#charge_bitmask
	beq	@nxt		; if clear, skip to next sprite, no need to redraw
	anda	#~charge_bitmask
	ora	#dirty_bitmask	; otherwise, set the dirty bit, clear charge bit for redraw
	sta	b,x
@nxt	decb
	bge	@lp
	rts

p1_clr_chg_bits ldx #leftscrndata
	ldu	#leftinfodata
	bra	_gbl_clr_chg_bits

p2_clr_chg_bits ldx #rightscrndata
	ldu	#rightinfodata

_gbl_clr_chg_bits ldb #77
@lp	lda	b,x
	bita	#charge_bitmask
	beq	@nxt
	anda	#~charge_bitmask
	sta	b,x
@nxt	decb
	bge	@lp
	rts

; called after a column drop
; acca - index into screen buf
; x - leftscrndata
redraw_col ldy	#col_work_buf
	ldu	#leftscrnptrs	;a constant start point
@lp	ldb	,y+
	beq	@clrrst		;if the work buf returns 0, then the rest of the column is clear
	andb	#~dirty_bitmask	;clear the dirty bit.
	cmpb	a,x		;if the dirty bit is set in the original (pre-dropped) column,
	beq	@sk1		;then this cmp will fail and the sprite will be forced to be redrawn
	;redraw here
	pshs	x,y,a,b
	leay	a,u
	leay	a,y
	ldy	,y
	leay	screenstart,y
	jsr	drawsprite
	puls	x,y,a,b
	stb	a,x
@sk1	suba	#6
	bge	@lp
@clrrst	clrb
@lp2	cmpb	a,x
	beq	@sk2
	;redraw here
	pshs	x,y,a,b
;	ldu	#leftscrnptrs	; probably don't need this anymore
	leay	a,u
	leay	a,y
	ldy	,y
	leay	screenstart,y
	jsr	drawsprite
	puls	x,y,a,b
	stb	a,x
@sk2	suba	#6
	bge	@lp2
	rts
	
drop_p1_cols_irq ldx #leftscrndata
	lda	p1_dropidx
	bmi	@sk1	;if the dropidx is $ff, skip the erase
	ldb	a,x
	stb	@sv_drop_idx
	clrb
	stb	a,x
@sk1	lda	#72	;start @ bottom of col 0
@lp	pshs	a
	jsr	copy_col
	lda	,s
	jsr	redraw_col
	puls	a
	inca
	cmpa	#78
	blt	@lp
	lda	p1_dropidx
	bmi	@sk2
	ldb	@sv_drop_idx
	ldx	#leftscrndata
	orb	#dirty_bitmask
	stb	a,x
@sk2	inc	p1_cur_dirty
;	ldx	p1_cur_scrptr
;	jsr	p1_drawcursor
	jsr	restore_p1_irq
	lda	#blkland_snd_c
	jsr	play_sound
	jsr	CHECKBLOCKS
;increment multiplier??
	rts
@sv_drop_idx	rmb 1

drop_p2_cols rts

; a - column
drop_p1_col adda #72
	pshs	a
	ldx	#leftscrndata
	lda	p1_dropidx
	bmi	@sk1
	ldb	a,x
	stb	@sv_drop_idx
	clrb
	stb	a,x
@sk1	lda	,s
	jsr	copy_col
	lda	,s
	jsr	redraw_col
	lda	p1_dropidx
	bmi	@sk2
	ldb	@sv_drop_idx
	ldx	#leftscrndata
	orb	#dirty_bitmask
	stb	a,x
@sk2	lda	#blkland_snd_c
	jsr	play_sound
	puls	a
	suba	#72
	rts
@sv_drop_idx	rmb 1

left_rotate_ccw lda p1_blk_moved ;only rotate if a block hasn't been dragged
	beq	@dorot
	rts
@dorot	ldu	#rotatelefttable
	clr	p1_drag
	bra	left_rotate
	
left_rotate_cw lda p1_blk_moved	;only rotate if a block hasn't been dragged
	beq	@dorot
	rts
@dorot	ldu	#rotaterighttable
	clr	p1_drag
	bra	left_rotate 

left_rotate lda p1_cur_vpos
	ldb	#$06
	mul
	addb	p1_cur_hpos
	ldy	#leftscrndata
	lda	b,y
	beq	@ret		; if there's no sprite, don't rotate...
	com	p1_drag		; there is a sprite!, set drag flag!
	anda	#$0f
	lda	a,u
	ora	#dirty_bitmask	;NEW
	sta	b,y		; translate sprite
	inc	p1_cur_dirty
;	ldb	b,y
;	ldy	p1_cur_scrptr
;	jsr	drawsprite
;	ldx	p1_cur_scrptr
;	jsr	p1_drawcursor
@ret	rts


;NOTES: fix the 'drag'/'p1_cur_dirty' bits like in 'p1_interpmove'
p1_drag_left lda p1_cur_vpos
	ldb	#$06
	mul
	addb	old_p1_cur_hpos	; this is the block we are dragging
	decb			; drag is always one square over.
	ldy	#leftscrndata
	lda	b,y		; make sure that the new location is clear 
	bne	@nodrg
	incb
	lda	b,y
;	clr	b,y
	decb
	ora	#dirty_bitmask	;force this sprite to be redrawn
	sta	b,y
	incb
	lda	#dirty_bitmask
	sta	b,y
	decb
	cmpb	#lastrow_index_c	;if we're on the last row, the drag stays active!!
	bge	@dodrg
	addb	#well_width_c
	lda	b,y
	bne	@dodrg		;the next line down is populated.. drag active still!!
	clr	p1_drag
@dodrg	inc	p1_cur_dirty	;drag inactive... redraw cursor
@_dodrg	inc	p1_blk_moved	;block moved, don't rotate on button release!!	
	lda	old_p1_cur_hpos
	jsr	drop_p1_col
	deca
	jsr	drop_p1_col
	jsr	CHECKBLOCKS
	rts
@nodrg	clr	p1_drag
	clr	p1_blk_moved
	inc	p1_cur_dirty	;change the cursor color
	rts

p1_drag_right lda p1_cur_vpos
	ldb	#$06
	mul
	addb	old_p1_cur_hpos	; this is the block we are dragging
	incb			; drag is always one square over.
	ldy	#leftscrndata
	lda	b,y		; make sure that the new location is clear 
	bne	@nodrg
	decb
	lda	b,y
	clr	b,y
	incb
	ora	#dirty_bitmask	;force this sprite to be redraw
	sta	b,y
	decb
	lda	#dirty_bitmask
	sta	b,y
	incb
	cmpb	#lastrow_index_c	;if we're on the last row, the drag stays active!!
	bge	@dodrg
	addb	#well_width_c
	lda	b,y
	bne	@dodrg		;the next line down is populated.. drag active still!!
	clr	p1_drag
@dodrg	inc	p1_cur_dirty	;drag inactive... redraw cursor
@_dodrg	inc	p1_blk_moved	;block moved, don't rotate on button release!!	
	lda	old_p1_cur_hpos
	jsr	drop_p1_col
	inca
	jsr	drop_p1_col
	jsr	CHECKBLOCKS
	rts
@nodrg	clr	p1_drag
	clr	p1_blk_moved
	inc	p1_cur_dirty	;change the cursor color
	rts


; Drawsprite - accb: spritenum
;	     - idxX: clobbered
;            - idxY: dst on screen.
; Drawsprite - accb: spritenum
;            - idxX: clobbered
;            - idxY: dst on screen.
drawsprite pshs	u	;7 (5+2)
	lda	#spritesize	;2
	mul			;11
	leax	,y		;4, -needs to be done, using abx saves cycles!
	ldy	#spritetable	;4
	leay	d,y		;8 (4+4)
	lda	#spriteheight	;2
	ldb	#screenwidth	;2
@lp	ldu	,y		;5
	stu	,x		;5
	ldu	2,y		;6
	stu	2,x		;6
	ldu	4,y		;6
	stu	4,x		;6
	ldu	6,y		;6
	stu	6,x		;6
	abx			;3
	leay	spritewidth,y	;5 (4+1)
	deca			;2
	bne	@lp		;5(6)
	puls	u,pc		;9 (5+4)

title_drawsprite pshs	u	;7 (5+2)
	lda	#spritesize	;2
	mul			;11
	leax	,y		;4, -needs to be done, using abx saves cycles!
	ldy	#spritetable	;4
	leay	d,y		;8 (4+4)
	lda	#spriteheight	;2
	ldb	#ts_screenwidth	;2
@lp	ldu	,y		;5
	stu	,x		;5
	ldu	2,y		;6
	stu	2,x		;6
	ldu	4,y		;6
	stu	4,x		;6
	ldu	6,y		;6
	stu	6,x		;6
	abx			;3
	leay	spritewidth,y	;5 (4+1)
	deca			;2
	bne	@lp		;5(6)
	puls	u,pc		;9 (5+4)
	
old_drawsprite	lda #spritesize
	mul
	ldx #spritetable
	leax d,x
	lda #spriteheight
@vlp	ldb #spritewidth
	pshs a
@hlp	lda ,x+
	sta ,y+
	decb
	bne @hlp
	puls a
	deca
	beq @ret
	leay screenwidth-spritewidth,y
	bra @vlp
@ret	rts

;drawleftblk	lda	rf1_stat
;	bne	@afdbg		;pressed - go to after debug
;	cmpa	old_rf1_stat	;if different, just released, switch modes
;	beq	@afdbg		;same.. not just released
;	jsr	draw_pia
;	jsr	draw_pia2	
;@afdbg	lda	p1_game_flag
drawleftblk	lda	p1_game_flag
	bne	@game
	jsr	p1_wait_start	; game isn't going... just wait until start
	rts
@game	lda	lf1_stat
	bne	@p1b1np		; if not pressed, do 'not pressed' actions
	cmpa	old_lf1_stat	; if different, just pressed.
	bne	@p1b1jp		; so branch to 'player 1, button1, just pressed'
	bra	@chkmv		; otherwise, still pressed, so goto 'check movement'
@p1b1jp	ldx	#leftscrndata	;
	lda	p1_cur_abspos	;
	lda	a,x		; get current block
	beq	@skb1
	com	p1_drag		; set the p1 drag flag, if a block is here.
	inc	p1_cur_dirty
	lda	#dragmax
	sta	p1_mv_max
@skb1	bra	@chkmv		; goto check movement
@p1b1np	cmpa	old_lf1_stat	; if different, just released
	bne	@p1b1jr		; so branch to 'player  1, button1, just released'
	bra	@p1b2		; otherwise, skip to 'check p1b2'
@p1b1jr	jsr	left_rotate_ccw
	jsr	CHECKBLOCKS
	clr	p1_drag		; no longer dragging.
	clr	p1_blk_moved
	inc	p1_cur_dirty
	lda	#movecontmax
	sta	p1_mv_max
@p1b2	lda	lf2_stat
	bne	@p1b2np		; if not pressed, do 'not pressed' actions
	cmpa	old_lf2_stat	; if different, just pressed.
	bne	@p1b2jp		; so branch to 'player 1, button2, just pressed'
	bra	@chkmv		; otherwise, still pressed, so goto 'check movement'
@p1b2jp	ldx	#leftscrndata	;
	lda	p1_cur_abspos	;
	lda	a,x		; get current block
	beq	@skb2
	com	p1_drag		; set the p1 drag flag, if a block is here.
	inc	p1_cur_dirty
	lda	#dragmax
	sta	p1_mv_max
@skb2	bra	@chkmv		; goto check movement
@p1b2np	cmpa	old_lf2_stat	; if different, just released
	bne	@p1b2jr		; so branch to 'player  1, button2, just released'
	bra	@chkmv		; otherwise, skip to 'check movement'
@p1b2jr	jsr	left_rotate_cw
	jsr	CHECKBLOCKS
	clr	p1_drag		; no longer dragging.
	clr	p1_blk_moved
	inc	p1_cur_dirty
	lda	#movecontmax
	sta	p1_mv_max
@chkmv	lda	p1_drag		; if this flag isn't set, then skip checking, since the cursor method will
	beq	@done		; figure out where to draw the cursor
	ldd	p1_cur_vpos	; a- vpos, b- hpos
	cmpa	old_p1_cur_vpos	; has the cursor moved on the vertical axis?
	beq	@novt		; if not, check horizontal
	clr	p1_drag		; here, we're doing a vertical move, so clear the flag.
	clr	p1_blk_moved
	inc	p1_cur_dirty
@novt	cmpb	old_p1_cur_hpos	;
	blt	@drglf
	bgt	@drgrt
	rts			;If we're here, then the horz is the same, return
@drglf	jsr	p1_drag_left
	rts
@drgrt	jsr	p1_drag_right
@done	rts

;RCRCRC
;current cursor position
p1_cur_vpos	rmb 1
p1_cur_hpos	rmb 1
p1_cur_abspos	rmb 1	; current cursor 'absolute' position
p1_cur_scrptr	rmb 2
old_p1_cur_vpos	rmb 1
old_p1_cur_hpos	rmb 1
p1_cur_dirty	rmb 1	; used by drawcursor, to determine whether or not to redraw itself.
p1_nomove_flag	rmb 1	; used by drawcursor, to determine whether or not movement should be checked.
p1_blk_moved	rmb 1
p1_clr_active	rmb 1	; used to indicate that a clear is in progress...
p1_dropidx	rmb 1
p1_dropptr	rmb 2
p1_last_col	rmb 1
p2_cur_vpos	rmb 1
p2_cur_hpos	rmb 1
p2_cur_abspos	rmb 1	; current cursor 'absolute' position
p2_cur_scrptr	rmb 2
old_p2_cur_vpos	rmb 1
old_p2_cur_hpos	rmb 1
p2_cur_dirty	rmb 1	; used by drawcursor, to determine whether or not to redraw itself.
p2_nomove_flag	rmb 1	; used by drawcursor, to determine whether or not movement should be checked.
p2_blk_moved	rmb 1
p2_clr_active	rmb 1	; used to indicate that a clear is in progress...
p2_dropidx	rmb 1
p2_last_col	rmb 1
p2_dropptr	rmb 2


p1_drag rmb 1
p2_drag	rmb 1
redraw_flag	rmb 1

drawleftcur lda p1_cur_dirty
	beq	@done		;if the cursor doesn't need to be redrawn, return
	clr	p1_cur_dirty
	cmpa	#$10		;If set by 'dropblk', then don't reset the drag/move codes.
	beq	@nr		;note: if it's #$11 (or anything else) reset the flags 
;	ldx	p1_cur_scrptr
;	jsr	p1_drawcursor
;	clr	p1_cur_redraw
;	rts
	lda	p1_drag		;
	bne	@drg
	lda	#movecontmax	;reset the movement timer
	bra	@rstmv
@drg	lda	#dragmax	;slower, since we're dragging.
@rstmv	sta	p1_mv_chk
	sta	p1_mv_max
;	com	p1_nomove_flag
	inc	p1_nomove_flag
;
;....old code removal!!
;	ldy	p1_cur_scrptr	; erase old cursor
;	ldx	#leftscrndata	; sprites
;	lda	p1_cur_abspos
;	ldb	a,x		;get current sprite
;	jsr	drawsprite
@nr	lda	p1_cur_vpos	;new cursor position
	lsla
	ldu	#vertoffsettable
	ldd	a,u
	ldx	#screenstart
	leax	d,x
	lda	p1_cur_hpos
	ldu	#lefthorztable
	ldb	a,u
	abx
	stx	p1_cur_scrptr	;new 'old cursor' pointer
	jsr	p1_drawcursor
	lda	p1_cur_vpos
	ldb	#6
	mul
	addb	p1_cur_hpos
	stb	p1_cur_abspos
	ldd	p1_cur_vpos
	std	old_p1_cur_vpos
@done	rts

;called by 'gameover' code
p1_erasecur clr	p1_cur_dirty
	ldy	p1_cur_scrptr
	ldb	#blank	;empty cell sprite
	jsr	drawsprite
	rts

drawrightcur pshs a,b,x,u
	lbra @ret
	ldx #screenstart	;calculate curpos
	lda rv_val
	lsla
	ldu #vertoffsettable
	ldd a,u
	leax d,x
	lda rh_val
	ldu #righthorztable
	ldb a,u
	abx
	cmpx right_pos
	beq @ret
	pshs x
	ldx #rightscrndata
	lda old_rv_val
	ldb #6
	mul
	addb old_rh_val		;index into left 'screen' table
	ldb d,x			; get sprite num
	ldy right_pos		; current right pos
	jsr drawsprite
	puls x
	stx right_pos
	jsr _dis_drawcursor
	ldd rh_val
	std old_rh_val
@ret	puls a,b,x,u,pc	

; x - dst pointer on screen
p1_drawcursor pshs a,b,u
	ldb	#screenwidth
	lda	p1_drag
	beq	@bc
	lda	#$99
	ldu	#$9999
	bra	__drawcur
@bc	lda	#$cc
	ldu	#$cccc
	bra	__drawcur
	
_dis_drawcursor pshs a,b,u
	ldb #screenwidth	;screen width
	lda #$c9
	ldu #$c9c9
	
__drawcur stu ,x
	stu 6,x
	abx	;next line
	stu ,x
	stu 6,x
	abx	;next line
	sta ,x
	sta 7,x
	abx
	sta ,x
	sta 7,x
	abx
;	clra
;	sta ,x
;	sta 7,x
;	abx
;	sta ,x
;	sta 7,x
;	abx
;	sta ,x
;	sta 7,x
;	abx
;	sta ,x
;	sta 7,x
;	abx
;	sta ,x
;	sta 7,x
;	abx
;	sta ,x
;	sta 7,x
;	abx
;	sta ,x
;	sta 7,x
;	abx
;	sta ,x
;	sta 7,x
;	abx
	leax (screenwidth*8),x	; $a0*8 ... skip 8 lines
;	lda #$cc
	sta ,x
	sta 7,x
	abx
	sta ,x
	sta 7,x
	abx
	stu ,x
	stu 6,x
	abx	;next line
	stu ,x
	stu 6,x
	puls a,b,u,pc
;	rts

;x -destination on scrn
;
draw_half_blank pshs u,a,b
	ldb #screenwidth	;scrn width
	lda #8		;number  of lines
	ldu #$4444
@lp	stu ,x
	stu 2,x
	stu 4,x
	stu 6,x
	abx
	deca
	bne @lp
	puls u,a,b,pc
	
drawblank pshs u,a,b
	ldb #screenwidth	;scrn width
	lda #16		;number  of lines
	ldu #$4444
@lp	stu ,x
	stu 2,x
	stu 4,x
	stu 6,x
	abx
	deca
	bne @lp
	puls u,a,b,pc
