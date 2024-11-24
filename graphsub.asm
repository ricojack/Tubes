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
***************************
* Graphics routines
*
*
*****************************************************************
* set 320x192 graphics screen
* enter with ACCA as the page to set
*
hscreen        pshs  d        * save page indicator and display type
               lda   #$4c
					sta   $ff90
					if		USE_199MODE
					ldd	#$803e
					endif
					ifn	USE_199MODE
					ldd   #$801e	* Use 1a for 256x192
					endif
					std   $FF98
					ldd   #$0000
					std   $FF9B
					puls  a        * restore page indicator
               ldb   #$04       * multiple by 8k
               mul
               exg   a,b
               clrb
               std   $FF9D
               clra
               tst   ,s+
               beq   hscreen10
               lda   #$80
hscreen10      sta   $ff9f
               rts


vsync				pshs	a
					lda	VSYNCIRQ
@a					cmpa	VSYNCIRQ
					beq	@a
               puls	a,pc

;vsync          tst   $ff02
;vsync1         tst   $ff03
;               bpl   vsync1
;					rts

refresh  jsr   vsync
			decb
			bne   refresh
			rts

width40		pshs	d,x
		ldd		#$030d
		std		CCVMR             * Set video mode register
		clr		CCVSR             * Set video scroll register
		ldd		#$c400
		std		CCVOR0            * Set vertical offset register
		clr		CCHOR             * Set horizontal offset register
		clr		CCBRDR            * Set boarder color
		clr		$00
		clr		$ff9f
		lda		#BLOCK_CREDIT
		sta		MMU_CREDITS
		ldx		#MEM_CREDITS
		ldd		#$2000
@a		std		,x++
		cmpx	#MEM_CREDITS+1920
		blo		@a
		puls	d,x,pc

print_text 	lda	,x+
		tsta
		beq	@b
		sta	,u++
		bra	print_text
@b		rts

