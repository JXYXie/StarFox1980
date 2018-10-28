;-------------------------------------
; This program does some wonky stuff
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
    
loop:
    jsr $e55f       ; clear screen [IMPORTANT]
    lda #$00
    sta $900f
    lda #$00
    sta $3679
    lda #$05
    sta $900f
    lda #$05
    sta $3679
    
    ldx #0
    dex
    bne loop
