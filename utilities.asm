;-------------------------------------------------------
; Math utility subroutines and Random number generation
;
;-------------------------------------------------------
;-------------------------------------------------------
; Generate random number and store it
;-------------------------------------------------------
randgen:

	lda $9114		; Timer 1 low byte
	adc $9118		; Timer 2 low byte
	clc				; Clear carry
	sta rand_num

	rts

