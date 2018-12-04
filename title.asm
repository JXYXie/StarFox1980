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
    cpy #104                ; 104 characters in the title screen
    bne titleloop
    
titlewait:
    jsr GETIN            ; pressing any input ends title screen
    beq titlewait
    jmp init

