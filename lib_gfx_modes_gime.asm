
namespace libgime

GIME_INIT0_REG	equ	$ff90
GIME_INIT1_REG	equ	$ff91

GIME_TASK0_REG	equ	$ffa0
GIME_TASK1_REG	equ	$ffa1

GIME_TASK_BANK_SIZE	equ	$08
GIME_INIT1_TASK_BIT	equ	$01

; Initializes both task blocks based on the X reg pointing to 
; two banks worth of information
init_task_blocks 	ldy	#GIME_TASK0_REG
	ldb	#GIME_TASK_BANK_SIZE
@lp	ldu	,x++
	stu	,y++
	decb
	bne	@lp
	rts
	
ena_task0	lda $GIME_INIT1_REG
	anda #(~GIME_INIT1_TASK_BIT)
	sta GIME_INIT1_REG
	rts
	
ena_task1	lda	#GIME_INIT1_TASK_BIT
	ora	#GIME_INIT1_REG
	sta	GIME_INIT1_REG
	rts
	
endnamespace