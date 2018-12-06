;-------------------------------------------------------
; Math utility subroutines and Random number generation
;
;-------------------------------------------------------
seedgen:
	lda $8b			; Get rnd seed 1 from kernel
	eor $9114		; Exclusive or it with timer 1 low byte
	sta SEED+0		; store it in the 1st byte of SEED
	lda #$8c		; Get rnd seed 2 from kernel
	eor #$8d		; Exclusive or it with rnd seed 3 from kernel
	eor $9118		; Exclusive or it with timer 2 low byte
	sta SEED+1		; Store it in 2nd byte of SEED
	rts
;-------------------------------------------------------
; Linear Feedback shift register
; Generate pseudo random number from seed and store it
; Returns 0 to ff number in RANDNUM
;-------------------------------------------------------
randgen:
	ldx #8			; Loop counter
	lda SEED+0		; Load the 1st byte of the seed
rand1:
	asl				; Arithmetic shift left
	rol SEED+1		; Rotate left 2nd byte of SEED
	bcc rand2		; If the bit is cleared (no bit is shifted out) go to rand2
	eor #$2d		; If a bit is shfited out exlusive or feedback
rand2:
	dex				; Decrement loop counter
	bne rand1		; Loop if not at 0
	sta SEED+0		; 
	cmp #0			;
	sta RANDNUM		; Store the resulting random number
	rts

