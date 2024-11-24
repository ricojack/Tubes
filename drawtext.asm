; drawText
; A-FG, B-BG, X-String, Y-scrndest

draw_text pshs	u,x,y,d
	stb	@bg_col
	sta	@fg_set+1
;	std	@fg_col
	lda	$ffa2	;mmu
	sta	@mmu_sv
	lda	#font_mmu
	sta	$ffaa	;swap in fonts (task2, mmu2)
@nxtltr	lda	,x+
	beq	@done
	suba	#' '	;space is first char
	ldb	#small_font_size_c
	mul
	ldu	#font_start_c
	leau	d,u
	ldb	#small_font_height_c
	pshs	y
@vlp	pshs	b
	ldb	#small_font_width_c
@hlp	lda	,u
	eora	#$ff	;invert mask for bg col
	anda	@bg_col	;
	sta	,y
	lda	,u+
@fg_set	anda	#$00	;overwritten
	ora	,y
	sta	,y+
	decb
	bne	@hlp
	puls	b
	leay	screenwidth-small_font_width_c,y
	decb
	bne	@vlp
	puls	y
	leay	small_font_width_c+1,y
	bra	@nxtltr
@done	lda	@mmu_sv
	sta	$ffaa
_dtrt	puls	u,x,y,d,pc
@mmu_sv	rmb 1
@bg_col	rmb 1

ts_drawtext	pshs	u,x,y,d
	stb	@bg_col
	sta	@fg_set+1
;	std	@fg_col
	lda	$ffa2	;mmu
	sta	@mmu_sv
	lda	#font_mmu
	sta	$ffa2	;swap in fonts
@nxtltr	lda	,x+
	beq	@done
	suba	#' '	;space is first char
	ldb	#small_font_size_c
	mul
	ldu	#font_start_c
	leau	d,u
	ldb	#small_font_height_c
	pshs	y
@vlp	pshs	b
	ldb	#small_font_width_c
@hlp	lda	,u
	eora	#$ff	;invert mask for bg col
	anda	@bg_col	;
	sta	,y
	lda	,u+
@fg_set	anda	#$00	;overwritten
	ora	,y
	sta	,y+
	decb
	bne	@hlp
	puls	b
	leay	ts_screenwidth-small_font_width_c,y
	decb
	bne	@vlp
	puls	y
	leay	small_font_width_c+1,y
	bra	@nxtltr
@done	lda	@mmu_sv
	sta	$ffa2
_tdtrt	puls	u,x,y,d,pc
@mmu_sv	rmb 1
@bg_col	rmb 1

; drawText
; A-FG, B-BG, X-String, Y-scrndest

draw_big_num pshs	u,x,y,d
	stb	@bg_col
	sta	@fg_set+1
;	std	@fg_col
	lda	$ffa2	;mmu
	sta	@mmu_sv
	lda	#font_mmu
	sta	$ffaa	;swap in fonts (task2, mmu2)
@nxtltr	lda	,x+
	beq	@done
	suba	#'0'	;0 is first char
	ldb	#big_font_size_c
	mul
	ldu	#bignum_start_c
	leau	d,u
	ldb	#big_font_height_c
	pshs	y
@vlp	pshs	b
	ldb	#big_font_width_c
@hlp	lda	,u
	eora	#$ff	;invert mask for bg col
	anda	@bg_col	;
	sta	,y
	lda	,u+
@fg_set	anda	#$00	;overwritten
	ora	,y
	sta	,y+
	decb
	bne	@hlp
	puls	b
	leay	screenwidth-big_font_width_c,y
	decb
	bne	@vlp
	puls	y
	leay	big_font_width_c,y
	bra	@nxtltr
@done	lda	@mmu_sv
	sta	$ffaa
_bnrt	puls	u,x,y,d,pc
@mmu_sv	rmb 1
@bg_col	rmb 1

p1_testtext ldx	#ts_test_text
	ldy	#($1a30+screenstart)
	lda	#$55
	ldb	#$00
	jsr	ts_drawtext
	rts

p1_draw_gameover ldx #gmover_text1
	ldy	#(gameover_ln2_c+screenstart)
	lda	#$ee
	ldb	#$44
	jsr	draw_text
	rts

p1_clr_gameover ldy	#(gameover_ln2_c+screenstart)
	bra	p1_clrline

p1_clrline ldx #clrline_text
	lda	#$00
	ldb	#$44
	jsr	draw_text
	rts

p1_draw_levelclear ldx #lvlclr_text
	ldy	#(levelclr_c+screenstart)
	lda	#$ff
	ldb	#$44
	jsr	draw_text
	rts

p1_clr_levelclear ldx #lvlclr_text
	ldy #(levelclr_c+screenstart)
	ldd	#$4444
	jsr	draw_text
	rts
	
draw_copyright	ldx #copyright_text
	ldy	#(copyright_msg_c+screenstart)
	lda	#$ff
	ldb	#$00
	jsr	ts_drawtext
	rts
	
draw_highscore	ldx #hiscore_text
	ldy	#(hiscore_msg_c+screenstart)
	lda	#$ff
	ldb	#$00
	jsr	ts_drawtext
	ldy	#(hiscore_scrnloc_c+screenstart)
	ldx	#ascii_hiscore
	lda	#$ff
	ldb	#$00
	jsr	ts_drawtext
	rts

draw_pia	ldx #gmpia
	ldy	#($0064+screenstart)
	lda	PIA2+3
	jsr	byte_to_txt
	jsr	draw_reg
	rts

draw_pia2	ldx #gmso
	ldy	#($0464+screenstart)
	lda	PIA2
	jsr	byte_to_txt
	jsr	draw_reg
	rts

draw_reg	lda	#$ff
	ldb	#$00
	jsr	draw_text
	ldx	#textbyte
	leay	20,y
	lda	#$ff
	ldb	#$00
	jsr	draw_text
	rts
	
gmso	fcc	"FF20:"
	fcb	0
	
byte_to_txt	pshs a
	lsra
	lsra
	lsra
	lsra
	adda #$30
	cmpa #$39
	ble @out1
	adda #$7
@out1	sta textbyte
	puls a
	anda #$0f
	adda #$30
	cmpa #$39
	ble @out2
	adda #$7
@out2	sta textbyte+1
	rts
	
textbyte fcb $00,$00,$00

copyright_text	fcc "(C)2008 BY RANDY COCEK"
		fcb 0
hiscore_text	fcc "HIGH SCORE: "
		fcb 0
gmover_text1	fcc " GAME OVER! "
		fcb	$00
clrline_text	fcc "            "
		fcb	$00
lvlclr_text	fcc "LEVEL CLEAR"
		fcb	$00
ts_test_text	fcc "TESTTESTTEST 000000"
	fcb	$00
	
