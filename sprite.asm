
spritetable	includebin sprites.raw

spritesize	equ 128
spritewidth	equ 8
spriteheight	equ 16

leftscrndata	rmb 78	
rightscrndata	rmb 78	; 6 columns * 13 rows = 78

;vertoffsettable	fdb $500,$f00,$1900,$2300,$2d00,$3700,$4100,$4b00,$5500,$5f00,$6900,$7300,$7d00
;lefthorztable	fcb $0c,$14,$1c,$24,$2c,$34
;righthorztable	fcb $64,$6c,$74,$7c,$84,$8c

leftscrnptrs	fdb $50c,$514,$51c,$524,$52c,$534
		fdb $f0c,$f14,$f1c,$f24,$f2c,$f34
		fdb $190c,$1914,$191c,$1924,$192c,$1934
		fdb $230c,$2314,$231c,$2324,$232c,$2334
		fdb $2d0c,$2d14,$2d1c,$2d24,$2d2c,$2d34
		fdb $370c,$3714,$371c,$3724,$372c,$3734
		fdb $410c,$4114,$411c,$4124,$412c,$4134
		fdb $4b0c,$4b14,$4b1c,$4b24,$4b2c,$4b34
		fdb $550c,$5514,$551c,$5524,$552c,$5534
		fdb $5f0c,$5f14,$5f1c,$5f24,$5f2c,$5f34
		fdb $690c,$6914,$691c,$6924,$692c,$6934
		fdb $730c,$7314,$731c,$7324,$732c,$7334
		fdb $7d0c,$7d14,$7d1c,$7d24,$7d2c,$7d34

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
		
initscrndata	lda #78
	ldx #leftscrndata
@a	clr ,x+
	clr ,x+
	deca
	bne @a
	rts

fillscrndata	lda #$f
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
;	lda #$41	;last index in table
	clra
@loop	pshs a
	ldx #leftscrndata
	ldb a,x		; get the sprite num from data table
	pshs b
	ldx #leftscrnptrs	; point to screen location table
;	cmpa #$4d
;	bne @ok1
	lsla
;	cmpa #$82
;	beq @ok1
;	ldy #$6564	;right top left
;	bra @ds
@ok1	ldd a,x			; acca -> offset into table
;	cmpd #$0000
;	bne @ok2
;	ldy #$6f6c	;right 1,1
;	bra @ds
@ok2	leay d,u	; idxy now points to screen
@ds	puls b
	jsr drawsprite
	puls a
	inca
	cmpa #$20
;	cmpa #4
	bne @loop
;	bpl @loop
;	ldd leftscrnptrs
;	std left_pos
;	clr lh_val
;	clr lv_val
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

; a - index into table
; returns: a==0, finished drop, a!=0, new position
dropblkone lda	dropidx 
	cmpa	#$72
	bge	@done 
	ldx	#leftscrndata
	ldb	6,x	;check if there's something in the cell below
	bne	@done	;non-zero means there's a block
	stb	6,x	;put block one level lower
	clr	,x	;make old location empty
	pshs	b	;a - index, b - spritenum
	ldx	#leftscrnptrs
	leay	a,x
	leay	a,y	;do leax twice to avoid the signed problem
	adda	#6
	sta	dropidx
;	***optimize later
	clrb		;do the clear first
	jsr	drawsprite
	puls	b
	ldx	#leftscrnptrs
	lda	dropidx
	leay	a,x
	leay	a,y
	jsr	drawsprite
	ldx	left_pos
	jsr	drawcursor
	rts	;return 
@done	lda	#$ff
	sta	dropidx	; end of drop
	rts
dropidx	rmb	1

; Drawsprite - accb: spritenum
;	     - idxX: clobbered
;            - idxY: dst on screen.
drawsprite	lda #spritesize
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

; Draws the sprite at the current cursor pos
;
;drawleftblk lda fire_stat
;	cmpa old_fire_stat
;	beq @done	; if no fire buttons have changed, return
;	anda #left_fire1_mask
;	beq @done	; if fire button is up, check if old status was down, else exit
;	lda old_fire_stat	;currently, left fire is not pressed.  check old status
;	anda #left_fire1_mask
;	bne @done	; old status was up too... so exit
drawleftblk lda lf1_stat
	beq @done	;if left1 is down, return
	cmpa old_lf1_stat	;if they're different, then this was just let go
	beq @done		;if they're the same, exit
; if we're here, the button has gone from pressed to not pressed.
;
; are we already dropping a block?
	lda dropidx
	cmpa #$ff
	bne @done
; drop not in progress, do something
; point y to top row...
	lda lh_val
	sta dropidx
	ldy #screenstart	;calculate curpos
	ldu #lefthorztable
	ldb a,u
	leay b,y
	ldx #leftscrndata
; get a random number from 0-14...
	ldb #15
	jsr RAND
	inca		; really want 1-15
; now, store the block in the screen data arra
	ldb lh_val
	sta b,x
	pshs a
;	ldy left_pos	; current left position
;	ldx #leftscrndata
;	lda lv_val
;	ldb #6
;	mul
;	addb lh_val		;index into left 'screen' table
	ldb lh_val
	clra
	stb dropidx		; indicate that a block is to be dropped
;	ldb d,x			; get sprite num
	ldy #screenstart
	leax d,x
	puls b
	stb ,x
	ldy #screenstart

	jsr drawsprite
	ldx left_pos
	jsr drawcursor
;	jsr drawleftcur
@done	rts
	
drawleftcur pshs a,b,x,u
	ldx #screenstart	;calculate curpos
	lda lv_val
	lsla
	ldu #vertoffsettable
	ldd a,u
	leax d,x
	lda lh_val
	ldu #lefthorztable
	ldb a,u
	abx
	cmpx left_pos		; check to see if this is where the cursor already was
	beq @ret
	pshs x
	ldx #leftscrndata
	lda old_lv_val
	ldb #6
	mul
	addb old_lh_val		;index into left 'screen' table
	ldb d,x			; get sprite num
	ldy left_pos		; current left position
	jsr drawsprite
	puls x
	stx left_pos
	jsr drawcursor
	ldd lh_val
	std old_lh_val
@ret	puls a,b,x,u,pc	

drawrightcur pshs a,b,x,u
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
	jsr drawcursor
	ldd rh_val
	std old_rh_val
@ret	puls a,b,x,u,pc	

; x - dst pointer on screen
drawcursor pshs a,b,u
	ldb #$a0	;screen width
	lda #$cc
	ldu #$cccc
	stu ,x
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
	leax $500,x	; $a0*8 ... skip 8 lines
	lda #$cc
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

drawblank pshs u,a,b
	ldb #$a0	;scrn width
	lda #16		;number  of lines
	ldu #$0000
@lp	stu ,x
	stu 2,x
	stu 4,x
	stu 6,x
	abx
	deca
	bne @lp
	puls u,a,b,pc
