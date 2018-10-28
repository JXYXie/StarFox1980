;-------------------------------------
; Intro splash screen
;-------------------------------------
    processor 6502
    org $1001               ; Unexpanded VIC

    ; BASIC stub (unexpanded vic)
    dc.w $100b              ; Pointer to next BASIC line
    dc.w 1981               ; BASIC Line#
    dc.b $9e                ; BASIC SYS token
    dc.b $34,$31,$30,$39    ; 4109 (ML start)
    dc.b 0                  ; End of BASIC line
    dc.w 0                  ; End of BASIC program
    ;---------------------------------------

CHROUT      equ $ffd2
RESET       equ $fd22
GETIN       equ $ffe4

    ;clear screen
    jsr $e55f               ; clear the screen
    
    lda #$40                ; load new colour
    sta $0286               ; change text colour
    
    lda #$cc                ; load new colour to acc register
    sta $900f               ; change background and border colours
    
    ; loop that iterates through characters
    ldy #00                 ; initalize at 0
intro_next_char:
    lda splashscreen,y
    jsr CHROUT
    iny
    cpy #105
    bne intro_next_char
    
intro_wait:
    jsr GETIN            ; keyboard input ends intro right now
    beq intro_wait
    
    lda #$ff                ; loading the value into $9005 makes the vic not look into the rom location for characters, instead the vico looks at memory starting at $1c00
    sta $9005               ; the above can be found on pages 85 and 86 of the vic 20 manual 

    lda #$00                ; the next 8 load instructs load a byte representing 1 line of our starfighter 
    sta $1c00               ; together the 8 bytes will make a star fighter sprite character

    lda #$08
    sta $1c01

    lda #$1c
    sta $1c02
    
    lda #$7f
    sta $1c03
    
    lda #$7f
    sta $1c04
    
    lda #$5d
    sta $1c05
    
    lda #$08
    sta $1c06
    
    lda #$00
    sta $1c07
    
    jsr $e55f               ; clear screen
    
    ldy #$00                ; draw custom character
    sty $1e21               ; top left corner with a bit of offset (corner is at 1e16)
    
    
spinloop:

    ldx #0
    nop         ;nops used as busy work
    nop
    dex
    bne spinloop
    
splashscreen:  
    dc.b    $0d
    dc.b    "S T A R F O X  1 9 8 0", $0d, $0d, $0d
    dc.b    "     XIN YAN XIE", $0d
    dc.b    "     MICHAEL QIU", $0d
    dc.b    "      ALAN FUNG", $0d, $0d, $0d
    dc.b    $0d, $0d, $0d, $0d, $0d, $0d
    dc.b    "   PRESS F1 TO START", $0d
        