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
CHROUTPUT       equ $ffd2
GETINPUT        equ $ffe4
SCRVER          equ $9001
JCLOCKL         equ $00a2

intro:

    ;clear screen
    jsr $e55f               ; clear the screen
    
    ;setup vetrical scroll from bottom
    lda #$a0       ;position to the bottom of the screen
    sta SCRVER
    
    lda #44
    sta $0286               ; change text colour
    
    lda #$cc                ; load new colour to acc register
    sta $900f               ; change background and border colours
    
    ;display text
    ldy #00
intro_next_char:
    lda title,y
    jsr CHROUTPUT
    iny
    cpy #105
    bne intro_next_char

intro_loop:       
    
    sta $FE
    
    ;move screen
    dec SCRVER
    lda #$25        ;standard screen position
    cmp SCRVER
    bne intro_loop
    
intro_wait:
    jsr GETINPUT       ;keyboard input ends intro right now
    beq intro_wait
    rts
    
title:  dc.b    $0d
        dc.b    "S T A R F O X  Z E R O", $0d, $0d, $0d
        dc.b    "     XIN YAN XIE", $0d
        dc.b    "     MICHAEL QIU", $0d
        dc.b    "      ALAN FUNG", $0d, $0d, $0d
        dc.b    $0d, $0d, $0d, $0d, $0d, $0d
        dc.b    "   PRESS F1 TO START", $0d