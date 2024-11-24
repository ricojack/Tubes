	org	$440
	fcc	"LOADING FONTS..."
	
	org	$4000
start	equ	chrset_start_c
chrset_start_c	includebin chrset.raw
bignum_start_c	includebin bignum.raw
	rmb	1
	end	start