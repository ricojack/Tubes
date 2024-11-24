	org	$400
	fcc	"TUBES V.A17                     "
	fcc	"LOADING SFX...                  "
	fcc	"                                "
	fcc	"                                "
	fcc	"                                "
	fcc	"                                "
	fcc	"                                "
	fcc	"                                "
	fcc	"                                "
	fcc	"                                "
	fcc	"                                "
	fcc	"                                "
	fcc	"                                "
	fcc	"                                "
	fcc	"                                "
	fcc	"                                "
	
	org	$4000
start	equ	snd_clearline
;snd_clearline	includebin clearline.snd
snd_clearline	rmb	$a4
		includebin crunch.raw
snd_blockland	includebin blockland.snd
;snd_clearline	includebin crunch.raw
	rmb	1
	end	start
