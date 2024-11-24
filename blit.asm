******************************************************************************
*	Copyright (c) 1997, 2004
*	Chet Simpson, Digital Asphyxia. All rights reserved.
*
*	The distribution, use, and duplication this file in source or binary form
*	is restricted by an Artistic License (see license.txt) included with the
*	standard distribution. If the license was not included with this package
*	please refer to http://www.oarizo.com for more information.
*
*
*	Redistribution and use in source and binary forms, with or without
*	modification, are permitted provided that: (1) source code distributions
*	retain the above copyright notice and this paragraph in its entirety, (2)
*	distributions including binary code include the above copyright notice and
*	this paragraph in its entirety in the documentation or other materials
*	provided with the distribution, and (3) all advertising materials
*	mentioning features or use of this software display the following
*	acknowledgement:
*
*		"This product includes software developed by Chet Simpson"
*	
*	The name of the author may be used to endorse or promote products derived
*	from this software without specific priorwritten permission.
*
*	THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
*	WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
*	MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
*
******************************************************************************
*

*
			lib	blit.mac

DoBlits		ldd	sc_vx_pos
		subd	#$08
		bpl	@a
		ldd	#$00
@a		std	min_x_pos
		ldd	sc_vx_pos
		addd	#$a8
		std	max_x_pos
*
		ldd	sc_vy_pos
		subd	#$10
		bpl	@b
		ldd	#$00
@b		std	min_y_pos
		ldd	sc_vy_pos
		addd	#$c0
		std	max_y_pos

;
; calc sprites coordinates
;
		setsptmmu
		ldu	#player
		ldb	#$06
		pshs	b
@a		clra
		ldb	object_xx,u
		subd	#$04
		pshs	d
		lda	object_x,u
		ldb	#$08
		mul
		addd	,s++
		std	blit_x
		clra
		ldb	object_yy,u
		subd	#$08
		pshs	d
		lda	object_y,u
		ldb	#$10
		mul
		addd	,s++
		std	blit_y
		clrb
		lda	object_sprite,u
		adda	object_cycle1,u
		addd	#MEM_SPRITES
		tfr	d,x
		bsr	blit
		leau	object_sizex,u
		dec	,s
		bne	@a
; check to see if player has colided with a gaurd
		tst	invincible
      beq	@b
		bsr	chk_ply_colide
		bcc	@b
		clr	we_die
@b		jsr	do_scorebar
		puls	b,pc

chk_ply_colide	pshs	x
		clra
		ldb	object_xx+player
		subd	#$04
		pshs	d
		lda	object_x+player
		ldb	#$08
		mul
		addd	,s++
		std	blit_x
		clra
		ldb	object_yy+player
		subd	#$08
		pshs	d
		lda	object_y+player
		ldb	#$10
		mul
		addd	,s++
		std	blit_y
		clrb
		lda	object_sprite+player
		adda	object_cycle1+player
		addd	#MEM_SPRITES
		tfr	d,x
		jsr	chk_colide
      puls	x,pc


****************************************
* Blit 16x16 image to screen 0 or 1 using virtual space
* a = mmu block of sprite
* x = offset to sprite
*
blit	pshs	x,u
; translate blit_x and blit_y into physical coordinates
		ldd	blit_x
		cmpd	min_x_pos
		bhs	@a
		puls	x,u,pc
@a		cmpd	max_x_pos
		blo	@b
		puls	x,u,pc
@b		subd	sc_vx_pos
		stb	blit_x

		ldd	blit_y
		cmpd	min_y_pos
		bhs	@a
		puls	x,u,pc
@a		cmpd	max_y_pos
		blo	@b
		puls	x,u,pc
@b		subd	sc_vy_pos
		std	blit_y


* check and adjust for X coortinates
* Get MMU and offset for screen
* xxxxxxx0 000|11111
*   mmu start  Offset line offset
		ldu	DirtyPool_ptr	* Get current dirty pool position
		ldd	blit_y
		addd	sc_vy_pos
		pshs	b
		lslb						* shift into A to get MMU block
		rola
		lslb
		rola
		lslb
		rola
		sta	,u+				* Save MMU block into dirty pool
		adda	sc_mmu_start	* Add mmu block the current screen starts on
		sta	MMUT0				* Set mmu register
		inca						* Go to next block
		sta	MMUT0+1        * Set next mmu register
		puls	a					* Get page (256 bytes) offset
		anda	#$1f				* Keep only significantly needed bits
;
		ldb	sc_x_pos
		lslb
		addb	blit_x
;
		bitb	#$80
		beq	@a
		pshs	b
		andb	#$7f				* make a positive offset
		stb	,u+				* save offset
		stb	blit_offset		*
		puls	b					* Get old value
		andb	#$80				* keep 128 (128+offset = original position)
		bra	@b
@a		clr	,u+
		clr	blit_offset
@b		std	,u++				* save it in dirty pool
		stu	DirtyPool_ptr	* Save new current position in dirty pool
		tfr	d,u
; Blit the image
		ldb	blit_offset
		blitline
		subb	#$07
		leau	$100,u
		blitline
		subb	#$07
		leau	$100,u
		blitline
		subb	#$07
		leau	$100,u
		blitline
		subb	#$07
		leau	$100,u
		blitline
		subb	#$07
		leau	$100,u
		blitline
		subb	#$07
		leau	$100,u
		blitline
		subb	#$07
		leau	$100,u
		blitline
		subb	#$07
		leau	$100,u
		blitline
		subb	#$07
		leau	$100,u
		blitline
		subb	#$07
		leau	$100,u
		blitline
		subb	#$07
		leau	$100,u
		blitline
		subb	#$07
		leau	$100,u
		blitline
		subb	#$07
		leau	$100,u
		blitline
		subb	#$07
		leau	$100,u
		blitline
		subb	#$07
		leau	$100,u
		blitline
		inc	DirtyPool_cnt	; Update the dirty pool counter
		puls	x,u,pc


****************************************
* Blit 16x16 image to screen 0 or 1 using virtual space
* a = mmu block of sprite
* x = offset to sprite
*
blit_block	pshs	x,u
; translate blit_x and blit_y into physical coordinates
		ldd	blit_x
		cmpd	min_x_pos
		bhs	@a
		puls	x,u,pc
@a		cmpd	max_x_pos
		blo	@b
		puls	x,u,pc
@b		subd	sc_vx_pos
		stb	blit_x

		ldd	blit_y
		cmpd	min_y_pos
		bhs	@a
		puls	x,u,pc
@a		cmpd	max_y_pos
		blo	@b
		puls	x,u,pc
@b		subd	sc_vy_pos
		std	blit_y


* check and adjust for X coortinates
* Get MMU and offset for screen
* xxxxxxx0 000|11111
*   mmu start  Offset line offset
		ldu	DirtyPool_ptr	* Get current dirty pool position
		ldd	blit_y
		addd	sc_vy_pos
		pshs	b
		lslb						* shift into A to get MMU block
		rola
		lslb
		rola
		lslb
		rola
		sta	,u+				* Save MMU block into dirty pool
		sta	temp1+1			* Save for later
		adda	#BLOCK_BSC		* Add mmu block the current screen starts on
		sta	MMUT0				* Set mmu register
		puls	a					* Get page (256 bytes) offset
		anda	#$1f				* Keep only significantly needed bits
;
		ldb	sc_x_pos
		lslb
		addb	blit_x
;
		bitb	#$80
		beq	@a
		pshs	b
		andb	#$7f				* make a positive offset
		stb	,u+				* save offset
		stb	blit_offset		*
		puls	b					* Get old value
		andb	#$80				* keep 128 (128+offset = original position)
		bra	@b
@a		clr	,u+
		clr	blit_offset
@b		std	,u++				* save it in dirty pool
		stu	DirtyPool_ptr	* Save new current position in dirty pool
		tfr	d,u				* Send into correct pointer
		tst	temp1				* Do we need to add this to the unused screen?
		beq	@m					* No
;--- Yes, add to the other page
		jsr	switch_pages	* Switch to the other page
		ldy	DirtyPool_ptr	* Get current dirty pool position
		inc	DirtyPool_cnt	* Update the dirty pool counter
		ldb	blit_offset		* Get wrap/sliver offset
		lda	temp1+1			* Get mmu block
		std	,y++				* save it
		stu	,y++				* save it
		sty	DirtyPool_ptr	* Save new current dirty pool position
		jsr	switch_pages	* Switch back to original page
@m		blit_soline
		leau	$100,u
		blit_soline
		leau	$100,u
		blit_soline
		leau	$100,u
		blit_soline
		leau	$100,u
		blit_soline
		leau	$100,u
		blit_soline
		leau	$100,u
		blit_soline
		leau	$100,u
		blit_soline
		leau	$100,u
		blit_soline
		leau	$100,u
		blit_soline
		leau	$100,u
		blit_soline
		leau	$100,u
		blit_soline
		leau	$100,u
		blit_soline
		leau	$100,u
		blit_soline
		leau	$100,u
		blit_soline
		leau	$100,u
		blit_soline
		inc	DirtyPool_cnt	; Update the dirty pool counter
		puls	x,u,pc




update_dirty	tst	DirtyPool_cnt		; Anything to restore?
		bne	@b						; yes go do it
		rts							; nope, return
@b		ldu	DirtyPool_pos		* Get start of pool
@a		lda	,u						; get mmu block of where to restore to
		adda	sc_mmu_start		; Add start of display screen MMU block
		sta	MMUT0					; set mmu block
		inca
		sta	MMUT0+1				; set mmu block+1
		lda	,u+					; get it again
		adda	#BLOCK_BSC			; add block for background to restore from
		sta	MMUT0+2				; set to start
		inca							;
		sta	MMUT0+3				; set mmu block+1
		ldb	,u+					; get ACCB offset value
		ldx	,u++					; get offset into blocks to copy to
		pshs	b,u					; save u and b
		leau	$4000,x				; adjust into BSC
		restline
		restline
		restline
		restline
		restline
		restline
		restline
		restline
		restline
		restline
		restline
		restline
		restline
		restline
		restline
		restline
		puls	b,u
		dec	DirtyPool_cnt
		lbne	@a

* Reset the dirty pool
nodirty		ldd	DirtyPool_pos		* Reset dirty pool ptr
		std	DirtyPool_ptr
		clr	DirtyPool_cnt		* Reset dirty pool count
		rts



chk_colide	pshs	x,u
; translate blit_x and blit_y into physical coordinates
		ldd	blit_x
		subd	sc_vx_pos
		stb	blit_x
		ldd	blit_y
		subd	sc_vy_pos
		std	blit_y

* check and adjust for X coortinates
* Get MMU and offset for screen
* xxxxxxx0 000|11111
*   mmu start  Offset line offset
		ldd	blit_y
		addd	sc_vy_pos
		pshs	b
		lslb						* shift into A to get MMU block
		rola
		lslb
		rola
		lslb
		rola
		adda	sc_mmu_start	* Add mmu block the current screen starts on
		sta	MMUT0				* Set mmu register
		inca						* Go to next block
		sta	MMUT0+1        * Set next mmu register
		puls	a					* Get page (256 bytes) offset
		anda	#$1f				* Keep only significantly needed bits
		ldb	sc_x_pos
		lslb
		addb	blit_x
		bitb	#$80
		beq	@a
		pshs	b
		andb	#$7f				* make a positive offset
		stb	blit_offset		*
		puls	b					* Get old value
		andb	#$80				* keep 128 (128+offset = original position)
		bra	@b
@a		clr	blit_offset
@b		tfr	d,u
; Blit the image
		ldb	blit_offset
; Check top of player
		addb	#$03
		lda	b,u				* Get from screen
		com	6,x
		anda	6,x				* Clear out mask
		com	6,x
		cmpa	7,x				* It is the same as the sprite?
		lbne	@z					* No, colide
; check left of player
		subb	#$03
		leau	$700,u
		leax	$70,x
		lda	b,u				* Get from screen
		com	,x
		anda	,x				* Clear out mask
		com	,x
		cmpa	1,x				* It is the same as the sprite?
		bne	@z					* No, colide
; check center of player
		addb	#$02
		lda	b,u				* Get from screen
		com	4,x
		anda	4,x				* Clear out mask
		com	4,x
		cmpa	5,x				* It is the same as the sprite?
		bne	@z					* No, colide
;
		addb	#$02
		lda	b,u				* Get from screen
		com	8,x
		anda	8,x				* Clear out mask
		com	8,x
		cmpa	9,x				* It is the same as the sprite?
		bne	@z					* No, colide
; check right of player
		addb	#$02
		lda	b,u				* Get from screen
		com	12,x
		anda	12,x				* Clear out mask
		com	12,x
		cmpa	13,x				* It is the same as the sprite?
		bne	@z					* No, colide
; check bottom of player
		subb	#$05
		leax	$40,x
		leau	$400,u
		lda	b,u				* Get from screen
		com	2,x
		anda	2,x				* Clear out mask
		com	2,x
		cmpa	3,x				* It is the same as the sprite?
		bne	@z					* No, colide
;
		addb	#$05
		lda	b,u				* Get from screen
		com	12,x
		anda	12,x				* Clear out mask
		com	12,x
		cmpa	13,x				* It is the same as the sprite?
		bne	@z					* No, colide
;
		subb	#$05
		leax	$30,x
		leau	$300,u
		lda	b,u				* Get from screen
		com	2,x
		anda	2,x				* Clear out mask
		com	2,x
		cmpa	3,x				* It is the same as the sprite?
		bne	@z					* No, colide
;
		addb	#$05
		lda	b,u				* Get from screen
		com	12,x
		anda	12,x				* Clear out mask
		com	12,x
		cmpa	13,x				* It is the same as the sprite?
		bne	@z					* No, colide
;
		andcc	#$fe
		puls	x,u,pc
@z		orcc	#$01
		puls	x,u,pc





