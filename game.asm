;-----------------------------------------
; Work in progress demo for Star Fox 1980
;-----------------------------------------
;-----------------------------Macros-------------------------------
HEALTH      equ $fb
SCORE       equ $fc
PLAYERPOS   equ $fd
BOSSPOS     equ $fe

CHROUT      equ $ffd2
RESET       equ $fd22
GETIN       equ $ffe4
SOUND1      equ $900a
SOUND2      equ $900b
SOUND3      equ $900c
NOISE       equ $900d
VOLUME      equ $900e
SCRCOLOR    equ $900f
TXTCOLOR    equ $0286

SETTIM      equ $f767
;----------------------------End Macros----------------------------


;----------------------------Basic Stub----------------------------
    Processor 6502
    org $1001               ; Unexpanded VIC

    ; BASIC stub (unexpanded vic)
    dc.w $100b              ; Pointer to next BASIC line
    dc.w 1981               ; BASIC Line#
    dc.b $9e                ; BASIC SYS token
    dc.b $34,$31,$30,$39    ; 4109 (ML start)
    dc.b 0                  ; End of BASIC line
    dc.w 0                  ; End of BASIC program
;-----------------------------End Stub----------------------------
    
    include "title.asm"
    
    jmp title
    
;---------------------------Initialization-----------------------------------
init:

    

    lda #$08                ; load new black background colour
    sta SCRCOLOR            ; change background and border colours

    lda #$ff                ; loading the value into $9005 makes the VIC not look into the rom location for characters, instead the vic looks at memory starting at $1c00
    sta $9005               ; the above can be found on pages 85 and 86 of the VIC 20 manual 
    
    jsr $e55f               ; clear screen

    jsr refresh
    
    ; Draw hearts
    lda #$02                ; Heart character
    sta $1fe4
    sta $97e4
    sta $1fe5
    sta $97e5
    sta $1fe6
    sta $97e6
    
    ldy #$04                ; draw starfighter character
    sty $1f96               ; 8086
    
    ldy #$06                ; color code
    sty $9796               ; 38806
    
    ;ldy #$04                ; draw enemy character
    ;sty $1e0a               ;
    
    ;ldy #$02                ; color code
    ;sty $960a               ;
    
    


    
    lda #$96
    sta PLAYERPOS           ; we are treating this location as ram, it contains the offset to add to the screen



;----------------------------Variable initialization---------------------------
    ldy #$03
    sty HEALTH



;-------------------------------music loop loop-------------------------------

    lda #$0f		; 15 is the max volume the speakers can be set at. The 1-15 values can be found at p(95,96) of the vic 20 manual
    sta $900e		; 900e controls volume, is where the volume values are written to. this address can be found at p(95,96) of the vic 20 manual
    

    ;lda #$87	 ; C  (135) low C this value can be found at p(95,96) of the vic 20 manual
    ;sta $900b		 ; store sound

playMusic:

    ldy #$03 ;start of loop counter, music has 3 notes in it


  
loopMusic:

    LDA musicDuration,y

    TYA ; transferring y to a in prep to preserve it
    PHA
    PHA  ; the first thing in the stack is the duration of the music 
    ;TAX               ;X holds amount of time loop must run to make 1 second, assuming 3 jiffies as the loop delay, the A register is now free to hold stuff 
    
    
anotherLoop:
    LDA musicNote,y
    PHA  ;2 the music note to play
    LDA musicRegister,y ; the register in now in A
    TAX ; the music register is now in x
    pla ;2 the music note to play is now in a
    sta $9000,x ; the music note that needs to be played is now active in the indicated register 
delan:
    jsr gameloop
    jsr delay 
    pla ; pull the loop count to make a second from the stack
    TAX ; loop count now in x
    bne endd
    DEX ; x is decremented down
    TXA ; transfer x to a in preparation to do a push to preserve the decrement value in the stack
    pha ; push the decrement value into the stack
    jmp delan

endd:
    pla
    tay ; y now contains the index counter thing again
    
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

    lda $00c5               ; get current pressed key
    sta key_pressed

    jsr drawboss
    jsr moveplayer
    jsr delay
    jsr collisioncheck

    lda #64         ;reset the key pressed
    sta key_pressed

    ;jmp gameloop

    rts





delay:          ;(p 171 a0-a02 jiffy clock) p204 - 205 settim
    LDA #$f9    ; 4F1A01, the max value the clock can be at, goes back to 0 after 
    LDX #$19
    LDY #$4f
    JSR $f767
dosum:
   LDA $A0
   BNE dosum

   rts


collisioncheck:

    ldx PLAYERPOS
    cpx #$8c
    beq predecHealth

    ldx PLAYERPOS
    cpx #$a1
    beq predecHealth2

    jmp next3


predecHealth:
    lda #18         ;reset the key pressed
    jmp next2

predecHealth2:
    lda #17         ;reset the key pressed
next2:
    sta key_pressed
    jsr moveplayer


decrementHealth:
 
    jsr updateHealth
    ldy HEALTH
    cpy #$00
    bne next3
    jsr gameover

next3:
    RTS


updateHealth:
    ldx HEALTH
    dex
    lda #$00                ; blank
    sta $1fe4 ,x
    stx HEALTH
    rts


gameover:
    jsr $e55f               ; clear screen
    lda #$19                ; load new background colour
    sta SCRCOLOR            ; change background and border colours
    
    lda #$8                ; load new background colour
    sta SCRCOLOR            ; change background and border colours
    
    jmp gameover    

    rts


;----------------------------jraphics---------------------------


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


drawboss:

    ldy #$07                ; draw boss
    sty $1e60               ;
    ldy #$02
    sty $9660
    
    ldy #$08                ; draw boss
    sty $1e61               ;
    ldy #$02
    sty $9661
    
    ldy #$09                ; draw boss
    sty $1e62               ;
    ldy #$02
    sty $9662
    
    ldy #$0a                ; draw boss
    sty $1e63               ;
    ldy #$02
    sty $9663
    
    ldy #$0b                ; draw boss
    sty $1e64               ;
    ldy #$02
    sty $9664
    
    ldy #$0c                ; draw boss
    sty $1e65               ;
    ldy #$02
    sty $9665
    
    ldy #$0d                ; draw boss
    sty $1e76               ;
    ldy #$02
    sty $9676
    
    ldy #$0e                ; draw boss
    sty $1e77               ;
    ldy #$02
    sty $9677
    
    ldy #$0f                ; draw boss
    sty $1e78               ;
    ldy #$02
    sty $9678
    
    ldy #$10                ; draw boss
    sty $1e79               ;
    ldy #$02
    sty $9679
    
    ldy #$11                ; draw boss
    sty $1e7a               ;
    ldy #$02
    sty $967a
    
    ldy #$12                ; draw boss
    sty $1e7b               ;
    ldy #$02
    sty $967b

    rts    


moveplayer:

    ldx PLAYERPOS
    
    ;lda #$00                ; draw ' ' character
    ;ldx PLAYERPOS
    ;sta $1f00 ,x            ; store it on screen where ship used to be 

    lda key_pressed

    cmp #18
    beq increment   
    
    cmp #17
    beq decrement 

    jmp next

increment:
    inx                     ; increment x by 1 to represent location as current location has moved 1
    jmp next
decrement:
    dex 
next:

    stx PLAYERPOS    

    lda #$03                ; current starfighter character
    ldx PLAYERPOS
    sta $1f00 ,x            ; store it at the current location
    
    lda #$06                ; color code
    sta $9700 ,x

end:
    rts


    include     "charset.asm"
 
key_pressed: dc.b #64  ; set to default 64 for no key pressed

titlescreen:  
    dc.b    $0d
    dc.b    "S T A R F O X  1 9 8 0", $0d, $0d, $0d
    dc.b    "       JACK XIE", $0d
    dc.b    "     MICHAEL QIU", $0d
    dc.b    "      ALAN FUNG", $0d, $0d, $0d
    dc.b    $0d, $0d, $0d, $0d, $0d, $0d
    dc.b    "   PRESS F1 TO START", $0d


musicDuration:  
    dc.b    #$00, #$14, #$28, #$50

musicNote:  ;Plays A,B,C
    dc.b    #$00, #$b7, #$87, #$C3  ;bf replaced with 87

musicRegister:    ; this must correspond with the notes. for example if there are 20 notes then there are 20 values in this thing 
    dc.b    #$00, #$0a, #$0b, #$0c









