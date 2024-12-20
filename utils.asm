RVSEED	fcb	$80
RND	fcb	$4f,$c7,$52,$59

* THIS IS A FAST MEDIUM GRADE RANDOM NUMBER GENERATOR
* LENGTH OF NON-REPEATING SEQUENCE = 16,777,215
* INTERMEDIATE OUTPUT 0 - 255 OR 0 - .996078431 STEPS OF .003921568
* ENTER: REG.B = N+1
* EXIT:  REG.A = 0 TO N
*        REG.B = FRACTIONAL PART OF N

RAND	LDA	RND+2	GET 19TH BIT
 	ANDA	#%00100000
 	LSLA		ALIGN IT WITH 24TH BIT
 	LSLA		  FASTER THAN SHIFTING TO RIGHT
 	LSLA
 	ROLA
 	EORA	RND+2	XOR BITS 19&24
 	LSRA		RESULT TO CARRY
 	ROR	RND	FEED RESULT INTO RANDOM NUMBER
 	ROR	RND+1		AND SHIFT TO THE RIGHT
 	ROR	RND+2
 	LDA	RND
 	MUL
 	RTS