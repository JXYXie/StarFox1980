;-------------------------------------
; This program tests user input
; Checks for WASD key press and prints the corresponding character to screen
; Press space to exit
; Reference: pg 179, 188 on the VIC-20 programmers reference guide
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

    jsr $e55f               ; clear the screen
    
    
loop:
    lda $00c5               ; get current pressed key (pg 179)
    cmp #9                  ; pressed w
    beq pressW
    
    cmp #17
    beq pressA              ; pressed a
    
    cmp #18
    beq pressD              ; pressed d
    
    cmp #41
    beq pressS              ; pressed s
    
    bne tail
    
pressW:
    
    lda #87                 ; W
    jsr $ffd2               ; print char
    jmp tail
    
pressA:
    lda #65                 ; A
    jsr $ffd2               ; print char
    jmp tail
    
pressD:
    lda #68                 ; D
    jsr $ffd2               ; print char
    jmp tail
    
pressS:
    lda #83                 ; S
    jsr $ffd2               ; print char
    jmp tail
    
tail:
    cmp #32                 ; Space to quit
    bne loop                ; loop if not pressed
    rts                     ; return
    
    