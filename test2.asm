	include tubes.inc
	
	org	$e00
start	orcc	#$50
	ldx	#$400
	ldd	#$6060
@a	std	,x++
	cmpx	#$600
	bne	@a
	
	ldx	#$400
	ldy	#rxmsg
@b	ldd	,y++
	std	,x++
	ldd	,y++
	std	,x++
	leax	28,x
	cmpy	#msg
	blt	@b
	jsr	initpia
	
loop	jsr	readjoyl
	jsr	readjoyr
	jsr	readfire
	jsr	showval
	jsr	showfire
	bra	loop
	rts

initpia	lda	PIA2+1
	anda	#$fb
	sta	PIA2+1
	lda	#$fc
	sta	PIA2
	lda	PIA2+1
	ora	#$04
	sta	PIA2+1
	rts
	
;right joystick, clear MSB of selector
readjoyr	lda	PIA1+3
	anda	#$f7	;clear MSB sel
	sta	PIA1+3
	jsr	readrh
	jsr	readrv
	rts
;left joystick, set MSB of selector
readjoyl	lda	PIA1+3
	ora	#$08	;set MSB sel
	sta	PIA1+3
	jsr	readlh
	jsr	readlv
	rts

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


readrv	ldx	#rv_val
	jsr	readvert
	rts
	
readrh	ldx	#rh_val
	jsr	readhorz
	rts
	
readlv	ldx	#lv_val
	jsr	readvert
	rts
	
readlh	ldx	#lh_val
	jsr	readhorz
	rts

readfire lda	PIA1
	anda	#$f
	sta	fire_stat
	rts

rh_val	rmb 1
rv_val	rmb 1
lh_val	rmb 1
lv_val	rmb 1
fire_stat rmb 1

showval	ldx	#rh_val
	ldy	#$404
	ldb	#$04
@nxt	lda	,x+
	cmpa	#$c
	bhi	@ovl
	cmpa	#$a
	bge	@ltr
	adda	#$70	;it's a number, create digit
	bra	@wrt
@ovl	lda	#'X
	bra	@wrt	
@ltr	adda	#$37	;create ascii letter
	bra	@wrt
@wrt	sta	,y
	leay	32,y
	decb
	bne	@nxt
	rts	

showfire ldb	#$70	; char 0
	ldx	#$480
	lda	fire_stat
	rora
	bcc	@n1
	orb	#$01
@n1	stb	,x+
	andb	#$fe
	rora
	bcc	@n2
	orb	#$01
@n2	stb	,x+
	andb	#$fe
	rora
	bcc	@n3
	orb	#$01
@n3	stb	,x+
	andb	#$fe
	rora
	bcc	@n4
	orb	#$01
@n4	stb	,x+
	rts
	
rxmsg	fcc	"RX: "
rymsg	fcc	"RY: "
lxmsg	fcc	"LX: "
lymsg	fcc	"LY: "

msg	fcc	"HELLO WORLD OF ASSEMBLY"
	fcb	13,0
	end	start