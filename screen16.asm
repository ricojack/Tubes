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
***************************************************
* Create video screen with 16x16 tiles
*
		lib	screen16.mac
;
;
;
old_code	equ	$00


InitGameInfo	pshs	d,x,y,u,cc
		orcc	#$40
		clra
		ldx	#current_page
@a		clr	,x+
		cmpx	#endgamedata
		blo	@a
; Set up dirty region pool information
		ldd	#DirtyPool0_pos
		std	DirtyPool0_ptr
		std	DirtyPool_ptr
		ldd	#DirtyPool1_pos
		std	DirtyPool1_ptr
; Set map and player position
		lda	dmap_start_x	* get starting X position
		cmpa	#$0a				* Is it greater than 10
		blo	@b					* no, leave map_x_pos at 0
		suba	#$0a				* subtract 10 from starting pos
		cmpa	#$13
		bls	@aa
		lda	#$13
@aa	sta	map_x_pos		* Set map x position
		ldb	#$08				* 8 bytes per block
		mul						* multiply
		std	sc_vx_pos		* set virtual X position
@b		ldb	dmap_start_y
		cmpb	#$06				* Is the starting less than 6?
		bls	@e					* yes, do no adjustments
		subb	#$06				* yes subtract 6 from it
		cmpb	#$0c				* Is the startiny Y+12 past end of viewable screen?
		bls	@d					* Nope
		ldb	#$0c				* yes, set to 12
@d		stb	map_y_pos		* Set starting map position
		lda	#$10				* Multiply by 16 (pixel height)
		mul
		std	sc_vy_pos		* save in virtual offset
		lda	#$20
		mul
		std	sc_y_pos			* Set screen Y display offset
;
; Clear tile animations
;
@e		ldx	#xanim_tiles
@f		clr	,x+
		cmpx	#xend_tiles
		blo	@f
; Reset display information
		ldb	#$80
		stb	sc_x_pos
		stb	sc0_x_pos
		stb	sc1_x_pos
; Draw screens
		jsr   draw_screen
		jsr	switch_pages
		jsr   draw_screen
		lda   sc_mmu_start
		pshs	a
		lda	#BLOCK_BSC
		sta	sc_mmu_start
		jsr	draw_screen
		puls	a
		sta	sc_mmu_start
		puls	d,x,y,u,cc,pc
;
; Switch double buffer display pages
;
switch_pages	lda	current_page
			inca
			anda	#$01
			sta	current_page
			tsta
			bne	switch_pages5
* move to page 0
; Save all current information back into page 1 area
			lda	sc_x_pos					; Save screen x position
			sta	sc1_x_pos
			lda	DirtyPool_cnt			; Save dirty region information
			sta	DirtyPool1_cnt
			ldd	DirtyPool_ptr
			std	DirtyPool1_ptr
; Set page 0 information
			lda	#BLOCK_SC0				; set page 0 starting mmu block
			sta	sc_mmu_start
			lda	sc0_x_pos
			sta	sc_x_pos
			lda	DirtyPool0_cnt			; set dirty region information
			sta	DirtyPool_cnt
			ldd	#DirtyPool0_pos
			std	DirtyPool_pos
			ldd	DirtyPool0_ptr
			std	DirtyPool_ptr
			rts
* move to page 1
switch_pages5	lda	sc_x_pos					; Save screen x position
			sta	sc0_x_pos
			lda	DirtyPool_cnt			; save dirty region information
			sta	DirtyPool0_cnt
			ldd	DirtyPool_ptr
			std	DirtyPool0_ptr
			lda	#BLOCK_SC1				; set page 0 starting mmu block
			sta	sc_mmu_start
			lda	sc1_x_pos
			sta	sc_x_pos
			lda	DirtyPool1_cnt			; set dirty region information
			sta	DirtyPool_cnt
			ldd	#DirtyPool1_pos
			std	DirtyPool_pos
			ldd	DirtyPool1_ptr
			std	DirtyPool_ptr
			rts


* Display the screen based on the vertical refresh
sc_display	ldx	sc_y_pos				; Get current screen Y position
			tst	current_page		; Are we on page 0?
			beq	@a						; yes, go display it
			leax	$3000,x				; nope, adjust it
@a			ldb	sc_x_pos
; Wait for retrace
			lda	VSYNCIRQ				; Get current sync count
			sta	VSYNCSAVE			; Save it for later
@b			cmpa	VSYNCIRQ				; is it the same as the last?
			beq	@b						; yes, keep waiting
			inca							; nope, go to next one
fps_ctrl	cmpa	#$03					; are we at desired frame rate yet?
			blo	@b						; nope, keep waiting
			clr	VSYNCIRQ				; yes (or we are behind).  Clear count
; Update display
			stx	$ff9d					; Set vertical display address
			stb	$ff9f					; set horizontal [virtual] offset
			jsr	read_device			* Go read input device
			rts							; return


* Adjust screen display point to move screen left
sc_screen_left	lda	sc_x_pos
			inca
			ora	#$80
			sta	sc_x_pos
			rts

* Adjust screen display point to move screen right
sc_screen_right	lda	sc_x_pos
			deca
			ora	#$80
			sta	sc_x_pos
			rts

* Adjust screen display point to move screen up
sc_screen_up	ldd	sc_y_pos
			addd	#$80
			std	sc_y_pos
			ldd	sc_vy_pos
			addd	#$04
			std	sc_vy_pos
			rts

* Adjust screen display point to move screen down
sc_screen_down	ldd	sc_y_pos
			subd	#$80
			std	sc_y_pos
			ldd	sc_vy_pos
			subd	#$04
			std	sc_vy_pos
			rts



***************************************************
* Actually draw the screen
*
* Enter with:
*  A = X coordinates
*  B = Y coordinates
draw_screen	pshs  d,x,y,u
* Set MMU
				ldu   sc_mem_start	* Get memory location for buffer
				lda	map_y_pos		* Get Y Position
				lsra						* Was the low bit set?
				bcc	@a					* If low bit not set, do not adjust it
				leau	$1000,u			* Nope, adjust it
@a				adda  sc_mmu_start	* Set screen
				sta   MMU_SCREEN		* Set the MMU

				setmapmmu				* Set the map
* point to map based on map_x and map_y
				lda	map_y_pos		* Get map starting y coordinates
				ldb	#map_width		* Get map width (*3)
				mul						* Multiply
				pshs	d					* Save it
				lda	map_x_pos		* Get map starting X position
				ldb	#$3				* Multiply by 3
				mul						*
				addd	,s++				* Add to prev result
				addd	#MEM_MAP			* Add memory offset
				tfr	d,y				* move into y
*--------
				ldb   #$0c				* Draw 12 blocks
				pshs  d					* Save it
draw_sc10   lda   #$14				* Do 20 blocks per line
				sta   ,s					* save it
draw_sc20   lda   ,y+				* Get mmu block of tile
				ldx   ,y++				* Get offset of tile
				sta   MMU_TILES		* Set mmu block
				draw_block				* Go draw the block
				leau  -$ff8,u			* Go back up one line
				dec   ,s					* Done yet?
				bne   draw_sc20		* Nope
				leay  map_width-60,y	* Yes, adjust map pointer
				leau  $1000-160,u		* Adjust screen pointer
				cmpu  #$2000			* Done in this mmu block?
				blo   draw_sc30		* nope
				ldu   sc_mem_start	* Get memory location for buffer
;				leau -$2000,u			* Yes, adjust U pointer
				inc   MMU_SCREEN		* go to next mmu block
draw_sc30   dec   1,s				* done with entire screen yet?
				bne   draw_sc10		* No
				leas  2,s				* Adjust stack
				puls  d,x,y,u,pc  * restore registers and return
;
;
;
;
draw_left	pshs	d,x,y,u
* point to map based on map_x and map_y
* pos = (map_y_pos * map_width) + map_x + map_buffer;
				lda	map_y_pos		* Get map y coor
				ldb	#map_width		* Get map width
				mul						* Multiply
				pshs	d					* save result
				lda	map_x_pos		* Get map X
				ldb	#$3				* 3 bytes per block
				mul						* Multiple
				addd	,s++				* Add to prev result
				addd	#MEM_MAP			* Add memory offset of blocks
				tfr	d,y				* Move into Y (map src)
				setmapmmu				* Set map MMU segment (to be sure)
*--------
* Point to part of screen to draw on
				clra
				ldb	map_y_pos		* Get map Y position
				lsrb						* Only interested in MMU slot (3 bits)
				bcc	@a					* If low bit was not set do not set bit 4
				ora	#$10				* Set to middle of MMU block
@a				pshs	b					* Save MMU offset for BSC copy
				addb	sc_mmu_start	* Add to mmu start for this screen
				stb	bsc_mmu			* Set mmu background screen
				stb	MMU_SCREEN		* Set mmu start
				ldb	sc_x_pos			* get x position
				lslb						* mul by 2
				addd  sc_mem_start	* Add to offset of memory
				tfr	d,u				* Set in register
				bra	draw_right05

* point to map based on map_x and map_y
* pos = (map_y_pos * map_width) + map_x + map_buffer;
draw_right	pshs	d,x,y,u
				lda	map_y_pos		* Get map y coor
				ldb	#map_width		* Get map width
				mul						* Multiply
				pshs	d					* save result
				lda	map_x_pos		* Get map X
				adda	#$14				* Point to 1 past edge of screen
				ldb	#$3				* 3 bytes per block
				mul						* Multiple
				addd	,s++				* Add to prev result
				addd	#MEM_MAP			* Add memory offset of blocks
				tfr	d,y				* Move into Y (map src)
				setmapmmu				* Set map MMU segment (to be sure)
*--------
* Point to part of screen to draw on
; offset = ((y * 16 + yy) * 256) + 160
				clra
				ldb	map_y_pos		* Get map Y position
				lsrb						* Only interested in MMU slot (3 bits)
				bcc	@a					* If low bit was not set, skip
				ora	#$10				* Bit was set.  Set bit 4 of offset
@a				pshs	b					* Save MMU block offset for BSC copy
				addb	sc_mmu_start	* Add to mmu start for this screen
				stb	bsc_mmu			* Set mmu background screen
				stb	MMU_SCREEN		* Set mmu start
				ldb	sc_x_pos			* Get screen position
				lslb						* nul by 2
				addb	#$a0				* Add number of bytes that are displayed
				addd  sc_mem_start	* Add to offset of memory
				tfr	d,u				* Set in register
*
* U = where in memory to start blitting
* Y = map block to start blitting with
* MMU register has been set to point to screen and map data
draw_right05	stu	bsc_offset
				ldb	#$0c				* number of blocks to draw
				tst	map_yy_pos		* Check minor position
				beq	@b					* If 0 (even block boundry) do not inc count
				incb						* Odd block boundry, increment block count
@b				tfr	b,a				* Move into A so we can save it for BSC copy
				pshs	d					* Save for BSC copy and strip block copy
draw_right10	lda	,y					* Get mmu block
				sta	MMU_TILES		* Set mmu block
				ldx	1,y				* Get offset into block
				ldb	map_xx_pos
				abx
				if		old_code
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				draw_blockhline		* Draw 4 pixels and adjust tile and screen down
				endif
				ifn	old_code
				draw_blockhline	$00,$000
				draw_blockhline	$08,$100
				draw_blockhline	$10,$200
				draw_blockhline	$18,$300
				draw_blockhline	$20,$400
				draw_blockhline	$28,$500
				draw_blockhline	$30,$600
				draw_blockhline	$38,$700
				draw_blockhline	$40,$800
				draw_blockhline	$48,$900
				draw_blockhline	$50,$a00
				draw_blockhline	$58,$b00
				draw_blockhline	$60,$c00
				draw_blockhline	$68,$d00
				draw_blockhline	$70,$e00
				draw_blockhline	$78,$f00
				leau	$1000,u
				endif

				leay	map_width,y		* adjust down 1 block in map
				cmpu  #$2000			* Are we done with the MMU block (2 tiles)?
				blo   draw_right20	* Nope, keep going
				leau	-$2000,u			* Yes, adjust pointer
				inc   MMU_SCREEN		* go to next MMU block
draw_right20	dec	,s					* done with the screen?
				lbne	draw_right10	* No, keep going
				puls	a					* Clean stack

;
; Copy newly drawn area to backgroun (update) screen
;
				tst	update_bsc		* Should we update the update screen?
				lbne	@c					* no, skip it
				ldx	bsc_offset		* Get MMU offset to copy from
				leau	$2000,x
				lda	bsc_mmu			* Get MMU block to copy from
				ldb	#BLOCK_BSC		* Get MMU block of BSC
				addb	1,s				* Add MMU offset for BSC
				std	MMU_SCREEN		* Set mmu of display screen and BSC
; Update 3rd (updater) buffer
@a				BSCcopyblock			* Copy the block
				leau	$1000,u
				leax	$1000,x
				cmpx	#$2000
				blo	@b
				inc	MMU_SCREEN
				inc	MMU_SCREEN+1
				leax	-$2000,x
				leau	-$2000,u
@b				dec	,s
				lbne	@a
@c				puls	d					* clean stack
				puls	d,x,y,u,pc

;
; Draw top of the screen
;
draw_top		pshs	d,x,y,u
				lda	map_y_pos		* Get map y coor
				ldb	#map_width		* Get map width
				mul						* Multiply
				pshs	d					* save result
				lda	map_x_pos		* Get map X
				ldb	#$3				* 3 bytes per block
				mul						* Multiple
				addd	,s++				* Add to prev result
				addd	#MEM_MAP			* Add memory offset of blocks
				tfr	d,y				* Move into Y (map src)
				setmapmmu				* Set map MMU segment (to be sure)
*--------
* Point to part of screen to draw on
; offset = ((y * 16 + yy) * 256) + 160
				clra
				ldb	map_y_pos		* Get map Y position
				lsrb						* Only interested in MMU slot (3 bits)
				bcc	@a					* If low bit was not set, skip
				ora	#$10				* Bit was set.  Set bit 4 of offset
@a				stb	bsc_mmu			* Set mmu background screen
				addb	sc_mmu_start	* Add to mmu start for this screen
				stb	MMU_SCREEN				* Set mmu start
				ldb	map_x_pos		* Get map x coordinates
				lslb						* nul by 8
				lslb
				lslb
				ldb	sc_x_pos
				lslb
            andb	#$f8
				addd  sc_mem_start	* Add to offset of memory
				tfr	d,u				* Set in register
				lda	map_yy_pos		* Get minor Y position
				lsla						* multiply by 2
				clrb						* clear LSB
				leau	d,u				* adjust destination draw position
				bra	draw_vertical

;
; Draw bottom of screen
;
draw_bottom	pshs	d,x,y,u
				lda	map_y_pos		* Get map y coor
				adda	#$0c				* Point to block at bottom of screen
				ldb	#map_width		* Get map width
				mul						* Multiply
				pshs	d					* save result
				lda	map_x_pos		* Get map X
				ldb	#$3				* 3 bytes per block
				mul						* Multiple
				addd	,s++				* Add to prev result
				addd	#MEM_MAP			* Add memory offset of blocks
				tfr	d,y				* Move into Y (map src)
				setmapmmu				* Set map MMU segment (to be sure)
*--------
* Point to part of screen to draw on
; offset = ((y * 16 + yy) * 256) + 160
				clra
				ldb	map_y_pos		* Get map Y position
				addb	#$0c				* Point to directly below displayed screen
				lsrb						* Only interested in MMU slot (3 bits)
				bcc	@a					* If low bit was not set, skip
				ora	#$10				* Bit was set.  Set bit 4 of offset
@a				stb	bsc_mmu			* Set mmu background screen
				addb	sc_mmu_start	* Add to mmu start for this screen
				stb	MMU_SCREEN				* Set mmu start
				ldb	map_x_pos		* Get map x coordinates
				lslb						* nul by 8
				lslb
				lslb
				ldb	sc_x_pos
				lslb
				andb	#$f8
				addd  sc_mem_start	* Add to offset of memory
				adda	map_yy_pos		* Add map minor y position twict
				adda	map_yy_pos		*
				tfr	d,u				* Set in register
* Go into block yy number of lines
draw_vertical			lda	map_yy_pos		* Get map YY position
; @b				lda	map_yy_pos		* Get map YY position
				lsla                 * Multiply by 16
				lsla
				lsla
				lsla
				sta	temp0				* Save for later
* calculate number of blocks to draw on left/right for wrap around
;------------------------------------------------------------------------------
				if		old_code
				clrb						* clear second count
				lda	#$14				* draw twenty blocks
				tst	map_xx_pos		* even x boundry?
				beq	@d					* yes
				inca						* no, add 1 block (right most on screen)
@d				std	temp1				* save it
				ldb	map_x_pos		* Get map X position
				cmpb	#$0c				* 32-12=20
				blo	@l					* nope, not there yet
				subb	#$0c				* get left portion of screen
				tst	map_xx_pos
				beq	@e
				incb
@e				stb	temp1+1			* Save new blocks on right to blit
				lda	temp1				* Get old blocks on left
				suba	temp1+1			* subtract blocks on right
				sta	temp1				* Get new blocks on right
				endif
;------------------------------------------------------------------------------
				clrb
				lda	#$14				* draw twenty blocks
				tst	map_xx_pos		* even x boundry?
				beq	@d					* yes
				inca						* no, add 1 block (right most on screen)
@d				std	temp1				* save left/right draw info
; if( (b * 8) + (sc_x_pos * 2)) > 255)
				tfr	a,b
				lslb						* multiple by 8
				lslb
				lslb
				stb	@e+2
				ldb	sc_x_pos			* Get screen x display position
				lslb						* mul by 2 (2 bytes per position)
            andb	#$f8
				clra
@e				addd	#$0000			* add the value
; we now have the number of available blocks on the right side of the screen
				tsta						* did we overflow?
				beq	@l					* nope...no wrap around!
				lsrb						* divide by 8
				lsrb
				lsrb
;				tst	map_xx_pos
;				beq	@k
;				incb
@k				stb	temp1+1			* Save new blocks on right to blit
				lda	temp1				* Get old blocks on left
				suba	temp1+1			* subtract blocks on right
				sta	temp1				* Get new blocks on right
*
*
*
*
*
@l				ldd	temp1
				pshs	d					* save it for later
				stu	bsc_offset
				tsta
				beq	@ma
* temp0 = map_yy_pos * 8
@m				lda	,y+				* Get mmu block
				sta	MMU_TILES		* Set mmu block
				ldx	,y++				* Get offset into block
				ldb	temp0				* Get number of lines to skip in block
				abx						* and skip them
				draw_blockvline		* Draw a vertical line
				leax	$8,x
				leau	$fe,u
				draw_blockvline		* Draw a vertical line
				leax	$8,x
				leau	$fe,u
				draw_blockvline		* Draw a vertical line
				leax	$8,x
				leau	$fe,u
				draw_blockvline		* Draw a vertical line
				leau	-$2fa,u			* Go back up to top line
				dec	temp1				* Are we done with this line yet?
				bne	@m					* Nope, keep going
@ma			tst	temp1+1			* Is there more to blit?
				beq	@n					* Nope, keep going
				lda	temp1+1			* get next block to do
				sta	temp1				* set it
				clr	temp1+1			* clear next block do we don't do it again
				leau	-$100,u			* adjust up one line (for wrap around)
				bra	@m					* go to it
;
; Copy newly drawn area to background (update) screen
;
@n				puls	d				* clean stack and get temp1
				tst	update_bsc
				lbne	@p
				tsta
				lbeq	@oa
				std	temp1				* Set temp1
				ldx	bsc_offset		* Get MMU offset to copy from
				leau	$2000,x
				lda	bsc_mmu			* Get MMU block to copy from
				tfr	a,b
				adda	sc_mmu_start	* Add to mmu start for this screen
				addb	#BLOCK_BSC		* Get MMU block of BSC
				std	MMU_SCREEN		* Set mmu of background screen
@o				BSCcopyhline
				BSCcopyhline
				BSCcopyhline
				BSCcopyhline
				dec	temp1				* Are we done with this line yet?
				bne	@o					* Nope, keep going
@oa			tst	temp1+1			* Is there more to blit?
				beq	@p					* Nope, keep going
				lda	temp1+1			* get next block to do
				sta	temp1				* set it
				clr	temp1+1			* clear next block do we don't do it again
				leax	-$100,x
				leau	-$100,u			* adjust up one line (for wrap around)
				jmp	@o					* go to it
@p				puls	d,x,y,u,pc



