;-----------------------------------------
; Work in progress demo for Star Fox 1980
;-----------------------------------------
    Processor 6502
    org $1001               ; Unexpanded VIC

    ; BASIC stub (unexpanded vic)
    dc.w $100b              ; Pointer to next BASIC line
    dc.w 1981               ; BASIC Line#
    dc.b $9e                ; BASIC SYS token
    dc.b $34,$31,$30,$39    ; 4109 (ML start)
    dc.b 0                  ; End of BASIC line
    dc.w 0                  ; End of BASIC program
    
    
;-----------------------------Macros-------------------------------
XOFFSET     equ $fb
YOFFSET     equ $fc

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

;----------------------------End Macros----------------------------
    
    
;---------------------------Main Title Screen------------------------------
    
    jsr $e55f               ; clear the screen
    
    lda #$40                ; load new text colour
    sta TXTCOLOR            ; change text colour
    
    lda #$19                ; load new background colour
    sta SCRCOLOR            ; change background and border colours
    
    ; loop that iterates through title characters
    ldy #00                 ; initialize counter at 0
titleloop:
    lda splashscreen,y
    jsr CHROUT
    iny
    cpy #104                ; 104 characters in the title screen
    bne titleloop
    
titlewait:
    jsr GETIN            ; pressing any input ends title screen
    beq titlewait

;----------------------------End Tile Screen-------------------------------
    
    lda #$08                ; load new black background colour
    sta SCRCOLOR            ; change background and border colours

    lda #$ff                ; loading the value into $9005 makes the VIC not look into the rom location for characters, instead the vic looks at memory starting at $1c00
    sta $9005               ; the above can be found on pages 85 and 86 of the VIC 20 manual 
    
    
;--------------------start of first character in memory--------------------
    lda #$08                ; the next 8 load instructs load a byte representing 1 line of the starfighter 
    sta $1c00               ; together the 8 bytes will make a star fighter sprite character

    lda #$08
    sta $1c01

    lda #$08
    sta $1c02
    
    lda #$1c
    sta $1c03
    
    lda #$3e
    sta $1c04
    
    lda #$3e
    sta $1c05
    
    lda #$49
    sta $1c06
    
    lda #$08
    sta $1c07
    
;--------------------start of second character in memory--------------------
    lda #$00                ; the next 8 load instructs load a byte representing a blank character square
    sta $1c08               ; together the 8 bytes will make a empty char square

    lda #$00
    sta $1c09

    lda #$00
    sta $1c0a
    
    lda #$00
    sta $1c0b
    
    lda #$00
    sta $1c0c
    
    lda #$00
    sta $1c0d
    
    lda #$00
    sta $1c0e
    
    lda #$00
    sta $1c0f
    
;--------------------start of third character in memory---------------------
    lda #$00                ; the next 8 load instructs load a byte representing a blank character square
    sta $1c10               ; together the 8 bytes will make a empty char square

    lda #$18
    sta $1c11

    lda #$3c
    sta $1c12
    
    lda #$ff
    sta $1c13
    
    lda #$ff
    sta $1c14
    
    lda #$3c
    sta $1c15
    
    lda #$18
    sta $1c16
    
    lda #$00
    sta $1c17
    
;---------------------------------------------------------------------------
    
    jsr $e55f               ; clear screen
    
    ldy #$00                ; draw custom character
    sty $1f96               ; 8086
    
    ldy #$06                ; color code
    sty $9796               ; 38806
    
    
    ldy #$02                ; draw custom character
    sty $1e0a               ; 8086
    
    ldy #$02                ; color code
    sty $960a               ; 38806
    
    
    lda #$96
    sta XOFFSET             ; we are treating this location as ram, it contains the offset to add to the screen
    
;-------------------------------Main game loop-------------------------------
gameloop:
    lda $00c5               ; get current pressed key
    
    cmp #17
    beq pressA              ; pressed a
    
    cmp #18
    beq pressD              ; pressed d
    
    ;cmp #9
    ;beq pressW              ; pressed w
    
    ;cmp #41
    ;beq pressS              ; pressed s
    
    cmp #32
    beq pressbar            ; pressed space bar
    
    jmp gameloop
    
    
pressA:
    
    ldx XOFFSET
    cpx #$8c
    beq delay
    
    lda #$09                ; sounds
    sta VOLUME              ; volume
    
    lda #$ca                ; sounds
    sta SOUND3
    
    lda #$01                ; draw ' ' character
    ldx XOFFSET
    
    cpx #$00
    sta $1f00 ,x            ; store it on screen where ship used to be 
    
    ldx XOFFSET
    dex                     ; decrement x by 1 to represent location as current location has moved 1
    stx XOFFSET
    
    lda #$00                ; current star fighter character
    ldx XOFFSET
    sta $1f00 ,x            ; store it at the current location
    
    lda #$06
    sta $9700 ,x
    
    jmp delay
    
pressD:
    
    ldx XOFFSET
    cpx #$a1
    beq delay
    
    lda #$09
    sta VOLUME
    
    lda #$ca
    sta SOUND3
    
    lda #$01                ; draw ' ' character
    ldx XOFFSET
    sta $1f00 ,x            ; store it on screen where ship used to be 
    
    ldx XOFFSET
    inx                     ; increment x by 1 to represent location as current location has moved 1
    stx XOFFSET    

    lda #$00                ; current starfighter character
    ldx XOFFSET
    sta $1f00 ,x            ; store it at the current location
    
    lda #$06                ; color code
    sta $9700 ,x
    
    jmp delay
    
pressbar:
    lda #$0f
    sta VOLUME

    lda #$e2
    sta SOUND3
    
    
    jmp delay

delay:
    
    lda $00c5               ; get current pressed key
    
    cmp #64
    bne delay               ; will not progress until the key help down is let go, 64 is the default value
    
    lda #$00                ; this value stops sounds
    sta SOUND1              ; 
    sta SOUND3              ; 
    
    jmp gameloop    
    
spinloop:

    ldx #0
    nop                     ; nops used as busy work
    nop
    dex
    bne spinloop
    
playsound:
    
    
    
splashscreen:  
    dc.b    $0d
    dc.b    "S T A R F O X  1 9 8 0", $0d, $0d, $0d
    dc.b    "       JACK XIE", $0d
    dc.b    "     MICHAEL QIU", $0d
    dc.b    "      ALAN FUNG", $0d, $0d, $0d
    dc.b    $0d, $0d, $0d, $0d, $0d, $0d
    dc.b    "   PRESS F1 TO START", $0d


