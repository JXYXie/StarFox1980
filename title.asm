;---------------------------Main Title Screen------------------------------
title:
    jsr $e55f               ; clear the screen
    
    lda #$40                ; load new text colour
    sta TXTCOLOR            ; change text colour
    
    lda #$19                ; load new background colour
    sta SCRCOLOR            ; change background and border colours
    
    ; loop that iterates through title characters
    ldy #00                 ; initialize counter at 0
    
titleloop:
    lda titlescreen,y
    jsr CHROUT
    iny
    cpy #101                ; 101 characters in the title screen
    bne titleloop
    




;--------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------

;music goes here

	lda #$0f					; 15 is the max volume the speakers can be set at. The 1-15 values can be found at p(95,96) of the vic 20 manual
	sta $900e				

playMusicstart:





	ldy #$0d 					;start of loop counter, music has 12(or 13 notes, dunno ask jack) notes notes in it (c in hex)


loopMusicStart:


	lda #$01
	tya							; transferring y to a in prep to preserve it
	pha
	pha							; the first thing in the stack is the duration of the music 



anotherStartLoop:
	lda victory_notes,y
	pha							; the music note to play
	lda tune_registers,y 	; the register in now in A
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


;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------











titlewait:
    jsr GETIN            ; pressing any input ends title screen
    beq titlewait
    jmp draw_init
