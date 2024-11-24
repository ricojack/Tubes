;NOTE: add in the 'cursor' timer

vsyncirq lda	$ff92
	clr	$ffb4
;	lda	$ff02	;clr int? 
;	lda	$ff92	;clr gime int
	anda	#$08
	beq	@ret
	dec	p1_irq_val
	bne	@p2
; - Here... do stuff!!
	lda	p1_irq_max
	sta	p1_irq_val	;reset counter
_p1_idx	jsr	p1_dropblk	;was 'dropblkone' ... chg to set flag!
@p2	nop	;fill in later!!
@rnd	ldb	#$ff		;seed random counter.
	jsr	RAND
@cyc	dec	irq_cyc_time
	bne	@mvchk
	lda	#irq_cyc_max
	sta	irq_cyc_time
	ldx	irq_cyc_ptr
	lda	,x+
	bne	@c_ok
	ldx	#irq_cyc_start
	lda	,x+
@c_ok	sta	$ffbe
	stx	irq_cyc_ptr
@mvchk	dec	p1_mv_chk
	bne	@p2mc
	clr	p1_nomove_flag
	lda	p1_mv_max
	sta	p1_mv_chk
@p2mc	nop
;	clr	_bgidx+2
;	com	$ff9a	;debug
	inc	vsync_done
@ret	rti
vsync_done	rmb 1

hsyncirq bita	$ff93	;5
;	sta	_f_sva+1	;5
;_bgidx	lda	spritetable	;5
	inc	$ffb4	;5
;	inc	_bgidx+2	;7
;_f_sva	lda	#$00	;2
	rti	;6
		
p1_irq_val	rmb 1
p1_irq_max	rmb 1
p1_irq_sv	rmb 2
p2_irq_val	rmb 1
p2_irq_max	rmb 1
p2_irq_sv	rmb 2
irq_cyc_ptr	rmb 2
irq_cyc_time	rmb 1
irq_cyc_start	fcb $01,$08,$09,$0f,$39,$0f,$09,$08,$01,$04,$20,$24,$27,$3c,$27,$24,$20,$04,$00
irq_cyc_max	equ 15	; 4 cycles a second
p1_mv_max	rmb 1
p1_mv_chk	rmb 1
p2_mv_max	rmb 1
p2_mv_chk	rmb 1

init_p1_irq lda #7
	sta	p1_irq_val
	sta	p1_irq_max
	lda	#$08
	sta	$ff92
	lda	#$10
	sta	$ff93
;	ldd	#dropblkone
	ldd	#p1_dropblk
	std	_p1_idx+1
	lda	#movestartmax
	sta	p1_mv_max
	sta	p1_mv_chk
;	lda	#$10
;	sta	$ff93
	rts

init_p2_irq rts

set_p1_clrln_irq orcc #(irq_bit)
;	lda	$ffb0
;	eora	#$3f
;	sta	$ffb0
;	andcc	#$af
;	rts 
	ldd	p1_irq_val
	std	p1_irq_sv
	ldd	#$0505
	std	p1_irq_val
	ldd	#animate_p1_clr
	std	_p1_idx+1
;	andcc	#$ef
	andcc	#~(irq_bit)
	rts

set_p1_irq_drop	ldd #drop_p1_cols_irq
	std	_p1_idx+1
	rts

restore_p1_irq orcc #(irq_bit)
	ldd	p1_irq_sv
	std	p1_irq_val
;	ldd	#dropblkone
	ldd	#p1_dropblk
	std	_p1_idx+1
	andcc	#(~irq_bit)
;	andcc	#$af
	rts
	
_set_p1_reg_move orcc #$00
	rts