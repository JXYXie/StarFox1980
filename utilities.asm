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


victoryTheme:

;music goes here

	lda #$0f					; 15 is the max volume the speakers can be set at. The 1-15 values can be found at p(95,96) of the vic 20 manual
	sta $900e				

playMusicstart:


	ldy #$0d 					;start of loop counter, music has 12(or 13 notes, dunno ask jack) notes notes in it (c in hex)

loopMusicStart:

	lda #$1e
	tya							; transferring y to a in prep to preserve it
	pha
	pha							; the first thing in the stack is the duration of the music 


anotherStartLoop:
	lda victory_notes,y
	pha							; the music note to play
	lda tune_registers,y 		; the register in now in A
	tax 						; the music register is now in x
	pla 						; the music note to play is now in a
	sta $9000,x 				; the music note that needs to be played is now active in the indicated register 


delanStart:
	jsr delay 
	pla 						; pull the loop count to make a second from the stack
	tax 						; loop count now in x
	bne enddStart
	dex 						; x is decremented down
	txa 						; transfer x to a in preparation to do a push to preserve the decrement value in the stack
	pha 						; push the decrement value into the stack
	jmp delanStart

enddStart:
	pla
	tay 						; y now contains the index counter thing again

	lda #$00
	sta SOUND1
	sta SOUND2
	sta SOUND3
	dey
	cpy #$01
	beq endd2Start

	jmp loopMusicStart

endd2Start:
	;jmp playMusicGainzOver
	rts
		

