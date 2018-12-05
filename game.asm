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
RANDNUM			equ 60

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
	
	jsr $e55f					; clear screen

	jsr refresh
	
	; Draw hearts
	lda #$02					; Heart character
	sta $1fe4
	sta $97e4
	sta $1fe5
	sta $97e5
	sta $1fe6
	sta $97e6
	
	ldy #$04					; draw starfighter character
	sty $1f96					; 8086
	
	ldy #$06					; color code
	sty $9796					; 38806
	

init:
;------------------------------Game state/variable initialization-----------------------------	
	lda #$c2
	sta PLAYER_POS				; We are treating this location as ram, it contains the offset to add to the screen
	ldy #$03
	sty PLAYER_HEALTH

	jsr spawn_boss
	jsr spawn_minions

	ldx #$00
	stx SCORE
	stx HISCORE
	stx LEVEL
	stx MINION_IND
	ldx #$04
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
	;TAX						;X holds amount of time loop must run to make 1 second, assuming 3 jiffies as the loop delay, the A register is now free to hold stuff 
	
	
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

	jsr refresh

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
	jsr $e55f					; clear screen
	lda #$19					; load new background colour
	sta SCRCOLOR				; change background and border colours
	
	lda #$8						; load new background colour
	sta SCRCOLOR				; change background and border colours
	
	jmp gameover	

	rts


;----------------------------graphics---------------------------
refresh:

	lda #$00			   
	ldx #$ff

refreshloop1:

	sta $1e00 ,x				
	dex 
	bne refreshloop1
	sta $1e00 ,x 

	ldx #$f9

refreshloop2:
	sta $1f00 ,x				
	dex 
	bne refreshloop2
	sta $1f00 ,x 

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

	lda #$03				; current starfighter character
	ldx PLAYER_POS
	sta $1f00 ,x			; store it at the current location
	
	lda #$06				; color code
	sta $9700 ,x

end:
	rts


	include		"charset.asm"
 
key_pressed: dc.b #64  ; set to default 64 for no key pressed

titlescreen:  
	dc.b	$0d
	dc.b	"S T A R F O X  1 9 8 0", $0d, $0d, $0d
	dc.b	"      JACK XIE", $0d
	dc.b	"     MICHAEL QIU", $0d
	dc.b	"      ALAN FUNG", $0d, $0d, $0d
	dc.b	$0d, $0d, $0d, $0d, $0d, $0d
	dc.b	"   PRESS ANY BUTTON", $0d


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
	dc.b	#$00, #$00, #$00, #$00
minion_pos:
	dc.b	#$6f, #$81, #$87, #$89

