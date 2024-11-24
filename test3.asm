	include tubes.inc
	
	org	$e00
start	orcc	#$50
	lds	#$800
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
;	jsr	initjoy
	clr	irq_val
	ldd	#vsyncirq
	std	$fef8
	lda	#$7e	;jmp
	sta	$fef7
	lda	#$ec
	sta	$ff90
	lda	#$08
	sta	$ff92
	andcc	#$ef	;enable irq
	
loop	jsr	readjoyl
	jsr	readjoyr
	jsr	readfire
	jsr	interpfire
	jsr	showval
	jsr	showfire
	jsr	showrnd
	jsr	checkkeyboard
	bra	loop
	rts

bitmask	equ	#$aa

vsyncirq lda $ff02	;clr int? 
	lda $ff92
	anda #$08
	beq @ret
;	inc	irq_val
	lda	#$ff
	anda	#~bitmask
	sta	irq_val
@ret	rti
irq_val rmb 1
@jmp	jmp $10c

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

showrnd lda lf1_stat
	beq @done	;if left1 is down, return
	cmpa old_lf1_stat	;if they're different, then this was just let go
	beq @done
;	jsr printinc
	jsr printrnd
	jsr printirq
@done	rts

printinc lda	oldval
	inca
	cmpa	#$10
	bne	@jmp
	clra
@jmp	sta	oldval
	jmp	_prn
oldval	rmb 1

printrnd ldb	#15
	jsr	RAND
	inca
_prn	ldy	#$500
_prn2	cmpa	#15
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
	rts

printirq orcc	#$10	; disable irq
	lda	irq_val
	anda	#$0f
	ldy	#$520
	jsr	_prn2
	leay	1,y
	lda	irq_val
	andcc	#$ef
	lsra
	lsra
	lsra
	lsra
	jmp	_prn2
		
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

keytable	fdb	$fbf7,$fef7,$f7fd,$f7fe,$fefd,$f7f7,$eff7,$dff7,$bff7
;			z,x,k,c,h,up,down,left,right
		fdb	$0000
chrtable	fcb	'Z','X','K','C','H',$5e,$56,$7c,$7e
checkkeyboard	ldx	#keytable
	ldu	#chrtable
	ldy	#$540
@lp	ldd	,x++	;Z
	beq	@done
	jsr	kbchk
	beq	>
	lda	#$6e	;period
	bra	@k2
!	lda	,u
@k2	sta	,y+
	leau	1,u
	bra	@lp
@done	rts

;a - writeval
;b - cmp val
kbchk	stb	@ck+1
	sta	$ff02
	lda	$ff00
	ora	#$80	;set high bit
@ck	cmpa	#$00	;operand is modified
	bne	@ret
	clra
@ret	rts
				
showkey	rts
	
rxmsg	fcc	"RX: "
rymsg	fcc	"RY: "
lxmsg	fcc	"LX: "
lymsg	fcc	"LY: "

msg	fcc	"HELLO WORLD OF ASSEMBLY"
	fcb	13,0
	
__NON_TEST__ equ	0	
	include input.asm
	include utils.asm
	end	start