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


	
;right joystick, clear MSB of selector
old_readjoyl	pshs a,b,x
	lda	PIA2
	sta	@xp1+1
	lda	playing_sound
	sta	@xp2+1
	beq	@smpl
	clr	playing_sound
	jsr	sound_dis
	jsr	pia_dis_sound
@smpl	lda	PIA1+3
	anda	#$f7	;clear MSB sel
	sta	PIA1+3
	jsr	readlh
	jsr	readlv
@xp1	lda	#00	;modified above
	sta	PIA2
@xp2	lda	#00	;modified operand above
	sta	playing_sound
	beq	@sndoff
	jsr	pia_reena_sound
	jsr	sound_ena
@sndoff	puls	a,b,x
	rts
	
readjoyl pshs	a,b,x
	lda	p1_game_flag	;game's not going, don't read joysticks!
	beq	readjoy_gmover
	lda	playing_sound
	bne	readjoy_sound
;	bne	@rts
	lda	PIA1+3
	anda	#$f7	;clear MSB sel
	sta	PIA1+3
	jsr	readlh
	jsr	readlv
@rts	puls	a,b,x
	rts

readjoy_gmover	clr	PIA2
	puls	a,b,x
	rts
	
readjoy_sound	lda	PIA2
	sta	@xp1+1
	clr	playing_sound
	jsr	sound_dis
	jsr	pia_dis_sound
	lda	PIA1+3
	anda	#$f7	;clear MSB sel
	sta	PIA1+3
	jsr	readlh
	jsr	readlv
	jsr	pia_ena_sound
@xp1	lda	#00	;modified above
	sta	PIA2
	lda	#01	;modified operand above
	sta	playing_sound
	jsr	sound_ena
	puls	a,b,x
	rts

;left joystick, set MSB of selector
readjoyr	rts
	pshs a,b,x	
	lda	PIA1+3
	ora	#$08	;set MSB sel
	sta	PIA1+3
	jsr	readrh
	jsr	readrv
	puls	a,b,x
	rts

;'left keyboard'... not really left, but full keyboard, since only one player now
;note:  puts appropriate values in the same locations as the joystick reads, so that the 'interp'
;is the same.
readkeyl pshs	a,b,x
	jsr	readlkh
	jsr	readlkv
	puls	a,b,x,pc

readlkh ldx	#lh_val
	clr	,x
	lda	#leftarrowcode
	jsr	_kbrd
	beq	@ret	;equal... left arrow pressed
	lda	#rightarrowcode
	jsr	_kbrd
	beq	@rp	;equal... right arrow pressed
	lda	#1	;nothing pressed
	sta	,x
	rts
@rp	lda	#2
	sta	,x
@ret	rts	

readlkv ldx	#lv_val
	clr	,x
	lda	#uparrowcode
	jsr	_kbrd
	beq	@ret	;equal... up arrow pressed
	lda	#downarrowcode
	jsr	_kbrd
	beq	@rp	;equal... down arrow pressed
	lda	#1	;nothing pressed
	sta	,x
	rts
@rp	lda	#2
	sta	,x
@ret	rts	

;a - writeval
;b - cmp val
_kbrd	sta	$ff02
	lda	$ff00
	ora	#$80	;set high bit
@ck	cmpa	#arrowretcode
	rts

readrv	ldx	#rv_val
	bra	readvert
	
readrh	ldx	#rh_val
	bra	readhorz
	
readlv	ldx	#lv_val
	bra	readvert
	
readlh	ldx	#lh_val
	bra	readhorz


;Set LSB of selector for up/down
readvert	lda	PIA1+1
	ora	#$08	;clear LSB
	sta	PIA1+1
	ldb	#joyystart
	clr	,x
@nxt	stb	PIA2	;store in d/a
	lda	PIA1	;read comparator
	bpl	@dn
	inc	,x
	cmpb	#joyyend
	beq	@dn
	addb	#joyystep
	bra	@nxt
@dn	rts

;Clear LSB of selector for left/right
readhorz	lda	PIA1+1
	anda	#$f7	;clear LSB
	sta	PIA1+1
	ldb	#joyxstart
	clr	,x
@nxt	stb	PIA2	;store in d/a
	lda	PIA1	;read comparator
	bpl	@dn
	inc	,x
	cmpb	#joyxend
	beq	@dn
	addb	#joyxstep
	bra	@nxt
@dn	rts

	cond	__NON_TEST__
;RCNOTE
;Change the code so that at each 'p1_cur_dirty' flag set, set the dirty bit for the sprite at that location
;Then modify the 'drawcursor' method to just draw the new cursor at the new location.
; ...actually create a new method 'p1_draw_cursor' to do it...

; this routine interprets the movement.
; if any axis moves from center (when both are centered), then the cursor vals will change instantly
; - a timer is set appropriately, based on the drag flag
; if both axes move back to center, then the 'timer' will reset to zero
; if p1_flag is cleared, then the timer is reset also.
; the timer is set in the 'update cursor' methods in the sprites.asm file
p1_interpmove	ldd lh_val	;acca - new horz val, accb, new vert val
	cmpd	#$0101		;if equal, both axes are now centered again
	bne	@chkmv		;if not, more complex checking req'd
	std	old_lh_val	;this is the new 'old' value
	clr	p1_nomove_flag	;clear the 'no movement flag'
	lda	p1_drag
	bne	@nd
	lda	#movestartmax
	sta	p1_mv_max	;reset to regular movement
@nd	rts			;return
@chkmv	ldx	#leftscrndata	;May need to set a dirty bit, so set the pointer here
	lda	p1_nomove_flag	;First thing, should we even bother checking if we moved yet?
	lbne	@done		;If the flag is set, then return immediately.
	lda	lh_val
;	cmpa	old_lh_val	;any change in the horz?
	cmpa	#cent_horz_c	;horz away from center?
	beq	@chkvt		;if same, then no.
	sta	old_lh_val	;different, so store the 'new old val'
	cmpa	#0		;if equal, then the cursor moved left
	bne	@chkrt
	ldb	p1_cur_hpos	;move cursor left
	beq	@chkvt		;unless it's already at the left side
	decb
	stb	p1_cur_hpos	;
	inc	p1_cur_dirty	;indicate that the cursor pos has changed
	ldb	p1_cur_abspos
	lda	b,x
	ora	#dirty_bitmask
	sta	b,x
	bra	@chkvt
@chkrt	cmpa	#2		;if equal, then the cursor moved right
	bne	@chkvt		;if different, then the joystick is centered horizontally
	ldb	p1_cur_hpos	;move cursor right
	cmpb	#5		;at right side?
	beq	@chkvt
	incb
	stb	p1_cur_hpos
	inc	p1_cur_dirty	;if not, move cursor and set dirty indicator
	ldb	p1_cur_abspos
	lda	b,x
	ora	#dirty_bitmask
	sta	b,x
@chkvt	lda	lv_val
;	cmpa	old_lv_val	;any change in the vert?
	cmpa	#cent_vert_c	;vert moved from center?
	beq	@done		;if same, then no.
	sta	old_lv_val	;different, so store the 'new old val'
	cmpa	#0		;if equal, then the cursor moved up
	bne	@chkdn		;if not, then move down
	ldb	p1_cur_vpos	;move cursor up
	beq	@done		;unless it's already at the top
	decb
	stb	p1_cur_vpos	;
	inc	p1_cur_dirty	;indicate that the cursor pos has changed
	ldb	p1_cur_abspos
	lda	b,x
	ora	#dirty_bitmask
	sta	b,x
	clr	p1_drag		;also, clear the drag flag, if set.  can't drag up or down
	bra	@done		;if we moved up, we can't move down, skip to end.
@chkdn	cmpa	#2		;if equal, then the cursor moved down
	bne	@done		;if different, then the joystick is centered vertically
	ldb	p1_cur_vpos	;move cursor down
	cmpb	#12		;at bottom?
	beq	@done
	incb
	stb	p1_cur_vpos
	inc	p1_cur_dirty	;if not, move cursor and set dirty indicator
	ldb	p1_cur_abspos
	lda	b,x
	ora	#dirty_bitmask
	sta	b,x
	clr	p1_drag		;also, clear the drag flag, if set.  can't drag up or down
@done	rts
	
	endc	;__NON_TEST__
	
readfire lda	PIA1
	anda	#$f
	sta	fire_stat
	rts

readkbfire lda	#rotleftmask
	ldb	#$0f
	jsr	_kbrd
	bne	>
	andb	#~lf1_mask
!	lda	#rotrightmask
	jsr	_kbrd
	bne	>
	andb	#~lf2_mask
!	stb	fire_stat
	rts
	
interpfire lda fire_stat	;first, check if any change in fire buttons...
	cmpa old_fire_stat	;if not, exit immediately
	bne @ok
	rts
@ok	ldx lf1_stat		;save the detailed status
	stx old_lf1_stat
	ldx rf1_stat
	stx old_rf1_stat
	ldb #$ff
	ldx #$0000		;slightly less efficient, but should work
	stx lf1_stat
	stx rf1_stat
	
	jmp _finit
		
__interpfire lda fire_stat	;first, check if any change in fire buttons...
	cmpa old_fire_stat	;if not, exit immediately
	beq @done
	ldx lf1_stat		;save the detailed status
	stx old_lf1_stat
	ldx rf1_stat
	stx old_rf1_stat
	tfr a,b			;need a second copy of the new fire_stat
;	sta old_fire_stat	;store current fire stat in 'old' now
	eora old_fire_stat	;xor the fire status... the bits set to 1 are the ones that changed
_finit	rora			;rotate right, but fire chg status in carry
	bcc @r1
	com lf1_stat
@r1	rora
	bcc @l2
	com rf1_stat
@l2	rora
	bcc @r2
	com lf2_stat
@r2	rora
	bcc @done
	com rf2_stat
@done	stb old_fire_stat
	rts
		
left_fire_mask	equ	$05
right_fire_mask	equ	$0a
left_fire1_mask	equ	$01
left_fire2_mask equ	$04
right_fire1_mask equ	$02
right_fire2_mask equ	$08

rh_val	rmb 1
rv_val	rmb 1
lh_val	rmb 1
lv_val	rmb 1
fire_stat	rmb 1

old_rh_val	rmb 1
old_rv_val	rmb 1
old_lh_val	rmb 1
old_lv_val	rmb 1
old_fire_stat	rmb 1

left_pos	rmb 2
right_pos	rmb 2

lf1_stat rmb 1
lf2_stat rmb 1
rf1_stat rmb 1
rf2_stat rmb 1

old_lf1_stat rmb 1
old_lf2_stat rmb 1
old_rf1_stat rmb 1
old_rf2_stat rmb 1

	cond	__NON_TEST__

p1_initjoy ldd	#$0101
	std	lh_val
	std	old_lh_val
	ldd	#$c91c
	std	p1_cur_scrptr
	lda	#absstart_c
	sta	p1_cur_abspos
	ldd	#xystart_c
	std	p1_cur_vpos
	std	old_p1_cur_vpos
	clr	p1_cur_dirty
	clr	p1_nomove_flag
	jsr	readfire
	lda	fire_stat
	anda	#left_fire_mask
	ora	old_fire_stat
	sta	old_fire_stat
	ldx	#$ffff
	stx	lf1_stat
	stx	old_lf1_stat
	rts

p2_initjoy ldd	#$0101
	std	rh_val
	std	old_rh_val
	ldd	#$c97c
	std	p2_cur_scrptr
	lda	#absstart_c
	sta	p2_cur_abspos
	ldd	#xystart_c
	std	p2_cur_vpos
	std	old_p2_cur_vpos
	clr	p2_cur_dirty
	clr	p2_nomove_flag
	jsr	readfire
	lda	fire_stat
	anda	#right_fire_mask
	ora	old_fire_stat
	sta	old_fire_stat
	ldx	#$ffff
	stx	rf1_stat
	stx	old_rf1_stat
	rts

initjoy ldx	#rh_val
@a	lda	#$01
	sta	,x+
	cmpx	#left_pos
	bne	@a
	clr	fire_stat
	clr	old_fire_stat
	ldd	#$c91c
	std	p1_cur_scrptr
	addd	#$0060
	std	p2_cur_scrptr
	lda	#62
	sta	p1_cur_abspos
	ldd	#$0a02
	std	p1_cur_vpos
	std	p2_cur_vpos
	std	old_p1_cur_vpos
	std	old_p2_cur_vpos
	clr	p1_cur_dirty
	clr	p2_cur_dirty
	clr	p1_nomove_flag
	clr	p2_nomove_flag
	jsr readfire
	lda fire_stat
	sta old_fire_stat
	ldx #$ffff
	stx lf1_stat
	stx rf1_stat
	stx old_lf1_stat
	stx old_rf1_stat
	ldx	#$0101
	stx	old_lh_val
	stx	old_rh_val
;DEBUG
	ldx	#screenstart
	stx	left_pos
	rts
;	tfr a,b
;	jmp _finit	;use the routine to store the current firebutton status
;	rts

;showval	ldx	#rh_val
;	ldy	#$404
;	ldb	#$04
;@nxt	lda	,x+
;	cmpa	#$c
;	bhi	@ovl
;	cmpa	#$a
;	bge	@ltr
;	adda	#$70	;it's a number, create digit
;	bra	@wrt
;@ovl	lda	#'X
;	bra	@wrt	
;@ltr	adda	#$37	;create ascii letter
;	bra	@wrt
;@wrt	sta	,y
;	leay	32,y
;	decb
;	bne	@nxt
;	rts	

;rxmsg	fcc	"RX: "
;rymsg	fcc	"RY: "
;lxmsg	fcc	"LX: "
;lymsg	fcc	"LY: "
	endc	;__NON_TEST__
vertoffsettable	fdb $400,$c00,$1400,$1c00,$2400,$2c00,$3400,$3c00,$4400,$4c00,$5400,$5c00,$6400
lefthorztable	fcb $1c,$24,$2c,$34,$3c,$44
righthorztable	fcb $64,$6c,$74,$7c,$84,$8c

