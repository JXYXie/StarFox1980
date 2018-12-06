;-----------------------------------------
; Work in progress demo for Star Fox 1980
;-----------------------------------------
;-----------------------------Macros-------------------------------
PLAYER_HEALTH	equ $57
PLAYER_POS		equ $58
BOSS_POS		equ $59
BOSS_HEALTH		equ $5a
SCORE			equ $5b
HISCORE			equ $5c
MINIONS			equ $5d
MINION_IND		equ $5e
LEVEL			equ $5f
RANDNUM			equ $60
SEED			equ $61					; 61 to 62 is 16 bit SEED

CHROUT			equ $ffd2
RESET			equ $fd22
GETIN			equ $ffe4
SOUND1			equ $900a
SOUND2			equ $900b
SOUND3			equ $900c
NOISE			equ $900d
VOLUME			equ $900e
SCRCOLOR		equ $900f
TXTCOLOR		equ $0286
CLRSCRN			equ $e55f

SETTIM			equ $f767
;----------------------------End Macros----------------------------


;----------------------------Basic Stub----------------------------
	Processor 6502
	org $1001					; Unexpanded VIC

	; BASIC stub (unexpanded vic)
	dc.w $100b					; Pointer to next BASIC line
	dc.w 1981					; BASIC Line#
	dc.b $9e					; BASIC SYS token
	dc.b $34,$31,$30,$39		; 4109 (ML start)
	dc.b 0						; End of BASIC line
	dc.w 0						; End of BASIC program
;-----------------------------End Stub----------------------------
	
	include "title.asm"
	include "player.asm"
	include "boss.asm"
	include "minions.asm"
	include "utilities.asm"

	jmp title
	
;---------------------------Initialization-----------------------------------
draw_init:

	lda #$08					; load new black background colour
	sta SCRCOLOR				; change background and border colours

	lda #$ff					; loading the value into $9005 makes the VIC not look into the rom location for characters, instead the vic looks at memory starting at $1c00
	sta $9005					; the above can be found on pages 85 and 86 of the VIC 20 manual 
	
	jsr CLRSCRN					; clear screen
	
	; Draw hearts
	lda #$02					; Heart character
	sta $1fe4
	sta $97e4
	sta $1fe5
	sta $97e5
	sta $1fe6
	sta $97e6
	

init:
;------------------------------Game state/variable initialization-----------------------------	
	lda #$c2
	sta PLAYER_POS				; We are treating this location as ram, it contains the offset to add to the screen
	ldy #$03
	sty PLAYER_HEALTH

	jsr seedgen
	jsr spawn_boss
	jsr spawn_minions

	ldx #$00
	stx SCORE
	stx HISCORE
	stx LEVEL
	stx MINION_IND
	ldx #$0a
	stx MINIONS

;----------------------------------music loop----------------------------------

	lda #$0f					; 15 is the max volume the speakers can be set at. The 1-15 values can be found at p(95,96) of the vic 20 manual
	sta $900e					; 900e controls volume, is where the volume values are written to. this address can be found at p(95,96) of the vic 20 manual

playMusic:

	ldy #$23					;start of loop counter, music has 35 notes in it (23 in hex)
  
loopMusic:

	lda #$01
	tya							; transferring y to a in prep to preserve it
	pha
	pha							; the first thing in the stack is the duration of the music 

anotherLoop:
	lda main_notes,y
	pha							; the music note to play
	lda main_music_registers,y 	; the register in now in A
	tax 						; the music register is now in x
	pla 						; the music note to play is now in a
	sta $9000,x 				; the music note that needs to be played is now active in the indicated register 
delan:
	jsr gameloop
	jsr delay 
	pla 						; pull the loop count to make a second from the stack
	tax 						; loop count now in x
	bne endd
	dex 						; x is decremented down
	txa 						; transfer x to a in preparation to do a push to preserve the decrement value in the stack
	pha 						; push the decrement value into the stack
	jmp delan

endd:
	pla
	tay 						; y now contains the index counter thing again
	
	lda #$00
	sta SOUND1
	sta SOUND2
	sta SOUND3
	dey
	cpy #$01
	beq endd2

	jmp loopMusic

endd2:
	jmp playMusic

;-------------------------------Main game loop-------------------------------

gameloop:

	jsr CLRSCRN

	lda $00c5					; get current pressed key
	sta key_pressed

	jsr draw_boss
	ldx #$00					; Reset minion index counter
	stx MINION_IND
	jsr draw_minions
	jsr moveplayer
	jsr boss_ai
	ldx #$00					; Reset minion index counter
	stx MINION_IND
	jsr minion_ai
	jsr delay
	jsr collisioncheck

	lda #64						; reset the key pressed
	sta key_pressed


    lda #$05 ;load the character of the laser
    ldx #$00
    sta #$1f00,x ; the laser is now stored here, 1f00 + 30,000 = 9430

    jsr writePlayerShot
    jsr drawPlayerShot

    jsr writeEnemyShot
    jsr drawEnemyShot


	rts


delay:							; (p 171 a0-a02 jiffy clock) p204 - 205 settim
	LDA #$f9					; 4F1A01, the max value the clock can be at, goes back to 0 after 
	LDX #$19
	LDY #$4f
	JSR $f767
dosum:
	LDA $A0
	BNE dosum
	rts


collisioncheck:

	ldx PLAYER_POS
	cpx #$b8
	beq predec_player_health

	ldx PLAYER_POS
	cpx #$cd
	beq predec_player_health2

	jmp next3


predec_player_health:
	lda #18						; reset the key pressed
	jmp next2

predec_player_health2:
	lda #17						; reset the key pressed
next2:
	sta key_pressed
	jsr moveplayer


decr_player_health:
 
	jsr update_player_health
	ldy PLAYER_HEALTH
	cpy #$00
	bne next3
	jsr gameover

next3:
	rts


update_player_health:
	ldx PLAYER_HEALTH
	dex
	lda #$00					; blank
	sta $1fe4 ,x
	stx PLAYER_HEALTH
	rts


gameover:
	jsr CLRSCRN					; clear screen
	lda #$19					; load new background colour
	sta SCRCOLOR				; change background and border colours
	
	lda #$8						; load new background colour
	sta SCRCOLOR				; change background and border colours
	
	jmp gameover	

	rts


moveplayer:

	ldx PLAYER_POS
	lda key_pressed

	cmp #18
	beq increment
	
	cmp #17
	beq decrement

	jmp next

increment:
	inx						; increment x by 1 to represent location as current location has moved 1
	jmp next
decrement:
	dex 
next:
	stx PLAYER_POS
	jsr draw_player

end:
	rts



writeEnemyShot:
    ; find the first available space that is #$00
    ;write #$1e to first value, then the players x position but shifted down 1 on the grid
    ; calls another subroutine to draw the shot
    ldy #$08    ; this is 2x the number of shots we are allowing to be on screen, the max num is currently 4
    
wesLoop:
    LDA enemyShots,y ;the "first" thing holds 1e, 1f or 00. if it is 00 we want to write to it
    cmp #$00
    beq exitwesLoop
    dey     ; dec y so it points to the "suffix" of 1e or 1f
    dey     ; dec again so it is pointing to the next prefix of 1e or 1f
    bne wesLoop
    jmp endwesLoop  ;if the loop finishes without triggering exit, then no #$00 was found


exitwesLoop: ;the y register now contains the offset we need to write to for either 1f or 1e 
    LDA #$1e
    STA enemyShots,y
    dey ;decrement to prepare for storing the suffix to the appropriate area in data
    TYA ; prep y to be pushed to stack for storage
    PHA ; the y index is now in the stack
    
    lda boss_laser

    ;LDA BOSS_POS ;temp placeholder value, replace with boss position
    ; minion_pos  with location
    clc
    adc #$16


    TAX ; X is temporarily holding the player pos value 
    PLA ; pull the y value into a
    TAY ;transfer value back to y
    TXA ;transfer the player pos back into A
    sta enemyShots ,y ; now the suffix should be properly stored 

endwesLoop:
    rts 



;writeenemyshot should be good




drawEnemyShot:
    ;pull the first thing from the list that is not 00, draw laser to the specified location, then iterate through the location and repeat 
    ;also need a backstop subroutine to stop the fire from going past the screen in both directions, will likely need 2
    ;the shot is "incremented up" in this. if it were to hit a backstop then it is reset to 00

    ldy #$08    ; this is 2x the number of shots we are allowing to be on screen, the max num is currently 4  
    
desLoop: 
    LDA enemyShots,y ;the "first" thing holds 1e, 1f or 00. if it is 00 we want to write to it
    cmp #$00
    beq enddesLoop

    ;cpy #$02
    ;bne skip
    ;jsr spinloop



    cmp #$1e
    bne nextdes 
    ;draw the laser then shift it up one
    dey ; the gets  the address ready for the suffix value for the laser
    LDA enemyShots,y 
    TAX ;transfer a to x to get ready for another aaaa ,x to write the laser to memory
    lda #$0f ;load the character of the laser
    sta #$1e00 ,x ; the laser is now stored here, 1f00 + 30,000 = 9430

    ;cpy #$02
    ;bne skip
    ;jsr spinloop


    TYA 
    PHA
    jsr shiftupfordes ;x will contain the value that was shifted 
    pla
    tay ;need to retrieve the y value corresponding to the list

    ;cpx #$f2
    ;bne skip
    ;jsr spinloop

    jsr shiftupfordes2
    



   ; lda #$05 ;load the character of the laser;debug
    ;sta #$1f00 ,x ; the laser is now stored here, 1f00 + 30,000 = 9430 ;debug


    ;cpx #$08
    ;bne skip
    ;jsr spinloop



    TXA ; the offset of x calculated is now in a for a aaaa,y address
    STA enemyShots ,y

    jmp enddesLoop2
skip:
nextdes:

    dey ; the gets  the address ready for the suffix value for the laser
    LDA enemyShots ,y 
    TAX ;transfer a to x to get ready for another aaaa ,x to write the laser to memory
    lda #$0f ;load the character of the laser

    sta #$1f00 ,x ; the laser is now stored here, 1f00 + 30,000 = 9430
    ;lda #$04 ;color code
    ;sta 9430 ,x ; x currently contains the offset we want to shift up

    ;cpx #$08
    ;bne skip
    ;jsr spinloop

    TYA 
    PHA
    jsr shiftupfordes ;x will contain the value that was shifted up 


    pla
    tay ;need to retrieve the y value corresponding to the list
    jsr shiftupfordes3
    
    TXA ; the offset of x calculated is now in a for a aaaa,y address
    STA enemyShots ,y



enddesLoop2:

    dey ; the two deys prep for the next cycle 
    bne desLoop
    rts


enddesLoop:


    dey
    dey ; the two deys prep for the next cycle 
    bne desLoop
    rts
















shiftupfordes3: ; the x register contains the value to be compared

    TYA
    PHA

    ldy #$fc ; need add 22 to shift something 1 char up

shiftupdesloop3:
    
    sty temp

    cpx temp
    beq suldesnext1

    dey
    cpy #$ce ;maybe take out
    bne shiftupdesloop3 ; don't want to run the alg when x = 0

    cpx #$ce
    bne suldesend3

    ldx #$00
    jmp suldesend1
    ;the branch should end here

suldesnext1:  ;now the x register contains how much we want to add to 234, x must be at least1

    ;ldy #$00

sndeslooptop1:

    ;iny
    ;dex 
    ;bne sndeslooptop1 ;y contains the offset of x after this, move it back to x

    TYA
    TAX ; value now back in x

suldesend1:

    pla
    tay

    iny

    LDA #$00
    STA enemyShots ,y


    dey
    
    TYA
    PHA

suldesend3:

    pla
    tay

    rts














shiftupfordes:;actually decrements, but shifts stuff up the screen

    ;ldy #$16 ; need add 22 to shift something 1 char up



shiftupdesloop1:
    cpx #$ff
    beq enddessul1
    txa
    clc
    adc #$16
    tax 

    ;dex
    ;cpx #$00
    ;beq enddessul1
    ;dey
    ;bne shiftupdesloop1
enddessul1:
    RTS


shiftupfordes2: ; the x register contains the value to be compared

    TYA
    PHA

    ldy #$ff ; need add 22 to shift something 1 char up

    cpx #$ea
    beq endendenddes


shiftupdesloop2:
    
    sty temp

    cpx temp
    
    beq suldesnext

    dey
    cpy #$ea ;maybe take out
    bne shiftupdesloop2 ; don't want to run the alg when x = 0

    cpx #$EA
    bne suldesend2

    ldx #$ea
    jmp suldesend
    ;the branch should end here

suldesnext:  ;now the x register contains how much we want to subtract EA from

    ;ldy #$00 
    txa  
    sbc #$EA

    
;sndeslooptop:

    ;iny
    ;dex 
    ;bne sndeslooptop ;y contains the offset of x after this, move it back to x

    ;TYA
    TAX ; value now back in x

suldesend:

    pla
    tay

    iny

    LDA #$1f
    STA enemyShots ,y


    dey
    
    TYA
    PHA

suldesend2:

    pla
    tay

    rts
     
endendenddes:
    ldx #$00

    jmp suldesend












;-----------player laser subroutines

writePlayerShot:
    ; find the first available space that is #$00
    ;write #$1f to first value, then the players x position but shifted up 1 on the grid
    ; calls another subroutine to draw the shot

    ldy #$08    ; this is 2x the number of shots we are allowing to be on screen, the max num is currently 4
    
wpsLoop:
    LDA playerShots,y ;the "first" thing holds 1e, 1f or 00. if it is 00 we want to write to it
    cmp #$00
    beq exitWpsLoop
    dey     ; dec y so it points to the "suffix" of 1e or 1f
    dey     ; dec again so it is pointing to the next prefix of 1e or 1f
    bne wpsLoop
    jmp endwpsLoop  ;if the loop finishes without triggering exit, then no #$00 was found


exitWpsLoop: ;the y register now contains the offset we need to write to for either 1f or 1e 
    lda #$1f
    sta playerShots,y
    dey ;decrement to prepare for storing the suffix to the appropriate area in data
    tya ; prep y to be pushed to stack for storage
    PHA ; the y index is now in the stack
    LDA PLAYER_POS
    jsr shiftUp
    TAX ; X is temporarily holding the player pos value 
    PLA ; pull the y value into a
    TAY ;transfer value back to y
    TXA ;transfer the player pos back into A
    sta playerShots ,y ; now the suffix should be properly stored 

endwpsLoop:
    rts 

drawPlayerShot:
    ;pull the first thing from the list that is not 00, draw laser to the specified location, then iterate through the location and repeat 
    ;also need a backstop subroutine to stop the fire from going past the screen in both directions, will likely need 2
    ;the shot is "incremented up" in this. if it were to hit a backstop then it is reset to 00

    ldy #$08    ; this is 2x the number of shots we are allowing to be on screen, the max num is currently 4  
    
dpsLoop: 
    LDA playerShots,y ;the "first" thing holds 1e, 1f or 00. if it is 00 we want to write to it
    cmp #$00
    beq enddpsloop

    cmp #$1f
    bne nextdps 
    ;draw the laser then shift it up one
    dey ; the gets  the address ready for the suffix value for the laser
    lda playerShots,y 
    tax ;transfer a to x to get ready for another aaaa ,x to write the laser to memory
    lda #$0f ;load the character of the laser

    sta #$1f00,x ; the laser is now stored here, 1f00 + 30,000 = 9430
    ;lda #$04 ;color code
    ;sta 9430 ,x ; x currently contains the offset we want to shift up

    tya
    pha
    jsr shiftupfordps ;x will contain the value that was shifted up 
    pla
    tay ;need to retrieve the y value corresponding to the list
    jsr shiftupfordps2
    
    txa ; the offset of x calculated is now in a for a aaaa,y address
    sta playerShots ,y

    
    jmp enddpsloop2


nextdps: ; this assumes that the prefix is 1e


    dey ; the gets  the address ready for the suffix value for the laser
    LDA playerShots ,y 
    TAX ;transfer a to x to get ready for another aaaa ,x to write the laser to memory
    lda #$0f ;load the character of the laser

    sta #$1e00 ,x ; the laser is now stored here, 1f00 + 30,000 = 9430
    lda #$04 ;color code
    sta 9430 ,x ; x currently contains the offset we want to shift up

    tya
    pha
    jsr shiftupfordps ;x will contain the value that was shifted up 

    pla
    tay ;need to retrieve the y value corresponding to the list
    jsr shiftupfordps3
    
    txa ; the offset of x calculated is now in a for a aaaa,y address
    sta playerShots ,y


enddpsloop2:
    dey ; the two deys prep for the next cycle 
    bne dpsLoop
    rts


enddpsloop: ; this ends it for a 00 value , need another 1 for non 00 values 
    dey
    dey ; the two deys prep for the next cycle 
    bne dpsLoop
    rts


shiftupfordps3: ; the x register contains the value to be compared

    tya
    pha

    ldy #$16 ; need add 22 to shift something 1 char up

shiftuploop3:
    
    sty temp

    cpx temp
    beq sulnext1

    dey
    bne shiftuploop3 ; don't want to run the alg when x = 0

    cpx #$00
    bne sulend3

    ldx #$ea
    jmp sulend1
    ;the branch should end here

sulnext1:  ;now the x register contains how much we want to add to 234, x must be at least1

    ldy #$ea

snlooptop1:

    iny
    dex 
    bne snlooptop1 ;y contains the offset of x after this, move it back to x

    TYA
    TAX ; value now back in x

sulend1:

    pla
    tay

    iny

    LDA #$00
    STA playerShots ,y


    dey
    
    TYA
    PHA

sulend3:

    pla
    tay

    rts



shiftupfordps2: ; the x register contains the value to be compared

    TYA
    PHA

    ldy #$15 ; need add 22 to shift something 1 char up

    cpx #$00
    beq endendend


shiftuploop2:
    
    sty temp

    cpx temp
    beq sulnext

    dey
    ;cpy #$01
    bne shiftuploop2 ; don't want to run the alg when x = 0

    cpx #$00
    bne sulend2

    ldx #$ea
    jmp sulend
    ;the branch should end here

sulnext:  ;now the x register contains how much we want to add to 234, x must be at least1

    ldy #$ea 

snlooptop:

    iny
    dex 
    bne snlooptop ;y contains the offset of x after this, move it back to x

    TYA
    TAX ; value now back in x

sulend:

    pla
    tay

    iny

    LDA #$1e
    STA playerShots ,y


    dey
    
    TYA
    PHA

sulend2:

    pla
    tay

    rts
     
endendend:
    ldx #$ea

    jmp sulend




shiftupfordps:;actually decrements, but shifts stuff up the screen

    ;ldy #$16 ; need add 22 to shift something 1 char up

shiftuploop1:
    cpx #$00
    beq endsul1
    txa
    sbc #$16
    tax 

    ;dex
    ;cpx #$00
    ;beq endsul1
    ;dey
    ;bne shiftuploop1
endsul1:
    RTS




spinloop:


    ;lda $00c5		 ; current key held down -> page 179 of vic20 manual
    ;jsr $ffd2

    ldx #0
    nop         ;nops used as busy work
    nop
    dex
    bne spinloop

    rts



shiftUp: ;actually decrements, but shifts stuff up the screen

;    ldx #$16 ; need add 22 to shift something 1 char up
;    TAY ; transfer a to y for decrement(moves stuff higher) 
    sec
    sbc #$16

;shiftuploop:
;    dey
;    dex
;    bne shiftuploop
;    TYA
    rts

	echo "Bytes remaining in program"
	echo $1c00-.
 
key_pressed: dc.b #64  ; set to default 64 for no key pressed

titlescreen:  
	dc.b	$0d
	dc.b	"S T A R F O X  1 9 8 0", $0d, $0d, $0d
	dc.b	"      JACK XIE", $0d
	dc.b	"     MICHAEL QIU", $0d
	dc.b	"      ALAN FUNG", $0d, $0d, $0d
	dc.b	$0d, $0d, $0d, $0d, $0d, $0d
	dc.b	"   PRESS ANY BUTTON", $0d

temp:
    dc.b:   #$00

;---------------------------------------------------position tracking--------------------------------------------

;limit of 4 "shots" for now

playerShots: 
    dc.b    #$00, #$00, #$00, #$00, #$00, #$00, #$00, #$00, #$00

enemyShots:
    dc.b    #$00, #$00, #$00, #$00, #$00, #$00, #$00, #$00, #$00

main_notes:				; Music notes in hex in order of last note to first note
	dc.b	#$00, #$93, #$a3, #$93, #$af, #$93, #$b7, #$93, #$9f, #$91, #$93, #$a3, #$93, #$af, #$93, #$b7, #$93, #$a3, #$9f, #$93, #$b7, #$93, #$97, #$93, #$00, #$93, #$a3, #$93, #$00, #$93, #$af, #$93, #$00, #$93, #$b7, #$93

main_music_registers:	; this must correspond with the notes. for example if there are 20 notes then there are 20 values in this thing 
	dc.b	#$00, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c

gameover_notes:			; Game over tune notes (12)
	dc.b	#$00, #$00, #$00, #$b7, #$b7, #$b7, #$b7, #$bf, #$c3, #$c9, #$cf, #$d1, #$d7, #$db
	
victory_notes:			; Victory tune notes (12)
	dc.b	#$00, #$cb, #$cb, #$cb, #$c9, #$bb, #$c3, #$b4, #$00, #$b4, #$b7, #$a8, #$93, #$83

tune_registers:
	dc.b	#$00, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c, #$0c

laser_sound:
	dc.b	#$00, #$109, #$109, #$121

minion_status:
	dc.b	#$00, #$00, #$00, #$00, #$00, #$00, #$00, #$00, #$00, #$00

minion_pos:
	dc.b	#$71, #$81, #$87, #$89, #$9d, #$a2, #$b2, #$b8, #$c9, #$ca

boss_laser:
    dc.b    #$00

	echo "Bytes remaining in character set"
	echo $1e00-.

	include		"charset.asm"

