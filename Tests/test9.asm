;-------------------------------------
; This program tests changing text and background colours
; Reference: pg 173,175 on the VIC-20 programmers reference guide
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
    
    lda #$42                ; load new colour to acc register
    sta $0286               ; change text colour
    
    lda #$cc                ; load new colour to acc register
    sta $900f               ; change background and border colours
    
    rts                     ; return
