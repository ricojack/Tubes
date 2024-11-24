DSKREG	equ $ff40

PIA1	equ $ff00
PIA2	equ $ff20

;JoyYTable	fcb 5,10,15,20,25,30
;JoyYTableMid	fcb 35,40,45,50,55,60

;JoyXTable	fcb 12,22
;JoyXTableMid	fcb 32,42,52

;These values must be shifted
JoyYTable	fcb 5,10,15,20,25,30
JoyYTableMid	fcb 35,40,45,50,55,60

JoyXTable	fcb 12,22
JoyXTableMid	fcb 32,42,52

YtableEnd	equ JoyXTable
XtableEnd	equ JoyXTableMid+3

sound_mmu	equ $35
font_mmu	equ $36
sprite_mmu	equ $3a

bra_operand_c	equ	$20
brn_operand_c	equ	$21

small_font_height_c	equ 7
small_font_width_c	equ 3
small_font_size_c	equ (small_font_width_c*small_font_height_c)

big_font_height_c	equ 12
big_font_width_c	equ 4
big_font_size_c		equ (big_font_width_c*big_font_height_c)

;score_scrnloc_c	equ	$1d45
score_scrnloc_c	equ	$1cd5
round_scrnloc_c	equ	$2d60
round_bgloc_c	equ	round_scrnloc_c+$0081
remn_scrnloc_c	equ	$415c
remn_bgloc_c	equ	remn_scrnloc_c+$0081

font_start_c	equ	$4000
bignum_start_c	equ	font_start_c+$4d7
;Temporary, for testing
;joyystart	equ $14
;joyystep	equ $14
;joyyend		equ $f0
;joyxstart	equ $30
;joyxstep	equ $28
;joyxend		equ $d0
joyystart	equ $54
joyystep	equ $54
joyyend		equ $a8
joyxstart	equ $54
joyxstep	equ $54
joyxend		equ $a8

leftarrowcode	equ $df
rightarrowcode	equ $bf
uparrowcode	equ $f7
downarrowcode	equ $ef
arrowretcode	equ $f7

firq_bit	equ $40
irq_bit		equ $10
intr_bits	equ $50

sound_bit	equ $08
blkland_snd_c	equ $01
clrline_snd_c	equ $00

xstart_c	equ $02
ystart_c	equ $0a
xystart_c	equ ((ystart_c*256)|(xstart_c))
absstart_c	equ 62

lastrow_index_c	equ 72
well_width_c	equ 6
seed_start_c	equ 11
seed_inc_c	equ seed_start_c+1

dragmax		equ 45	;speed when the player is dragging
movestartmax	equ 30	;speed when the player goes from stopped to moving
movecontmax	equ 15	;speed when the player is already moving the cursor
 
screenstart	equ $8000
screenwidth	equ $80	;in bytes
;ts_screenwidth	equ $a0
ts_screenwidth	equ $80
spritetable	equ $5000

task0blks	fcb $38,$39,$3a,$3b,$3c,$3d,$3e,$3f
task1blks	fcb $38,$39,$3a,$35,$30,$31,$32,$33

cent_vert_c	equ 1
cent_horz_c	equ 1

bonus_max	equ	$75	; max 75
line_max	equ	$07	; equivalent to 700

;text constants
gameover_ln1_c	equ	$301c
gameover_ln2_c	equ	$341c
gameover_ln3_c	equ	$381c

pressfire_c	equ	$4420
tocontinue_c	equ	$481e

levelclr_c	equ	$341e

;copyright_msg_c	equ	$5024
;hiscore_msg_c	equ	$5a2c
;hiscore_scrnloc_c equ	$5a5c

copyright_msg_c	equ	$4014
hiscore_msg_c	equ	$481c
hiscore_scrnloc_c equ	$484c

;constants
left_bitmask	equ $08
right_bitmask	equ $02
up_bitmask	equ $01
down_bitmask	equ $04
dirty_bitmask	equ $40
charge_bitmask	equ $10
legal_bits	equ $0f
lf1_mask	equ $01
lf2_mask	equ $04
rotleftmask	equ $fb
rotrightmask	equ $fe
;sprite list
blank		equ $00
explode3	equ $01
explode2	equ $02
botleft		equ $03
explode1	equ $04
updown		equ $05
topleft		equ $06
triright	equ $07
explode0	equ $08
botright	equ $09
leftright	equ $0a
triup		equ $0b
topright	equ $0c
trileft		equ $0d
tridown		equ $0e
plus		equ $0f
reserve0	equ $10
reserve1	equ $11
reserve2	equ $12
chg_botleft	equ $13
reserve3	equ $14
chg_updown	equ $15
chg_topleft	equ $16
chg_triright	equ $17
reserve4	equ $18
chg_botright	equ $19
chg_leftright	equ $1a
chg_triup	equ $1b
chg_topright	equ $1c
chg_trileft	equ $1d
chg_tridown	equ $1e
chg_plus	equ $1f
