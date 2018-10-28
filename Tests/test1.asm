;-------------------------------------
; This program tests printing characters
; Reference: pg 188 on the VIC-20 programmers reference guide
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
    
    lda #82                 ; R
    jsr $ffd2               ; print char
    
    lda #69                 ; E
    jsr $ffd2               ; print char

    lda #84                 ; T
    jsr $ffd2               ; print char
    
    lda #82                 ; R
    jsr $ffd2               ; print char
    
    lda #79                 ; O
    jsr $ffd2               ; print char
    
    rts
