    processor 6502
    org $1001               ; Unexpanded VIC
    ; vic pages used (page 98-102, 175)

    ;this program displays our custom starfighter 


    ; BASIC stub (unexpanded vic)   
    dc.w $100b              ; Pointer to next BASIC line
    dc.w 1981               ; BASIC Line#
    dc.b $9e                ; BASIC SYS token
    dc.b $34,$31,$30,$39    ; 4109 (ML start)
    dc.b 0                  ; End of BASIC line
    dc.w 0                  ; End of BASIC program

    LDA #$FF                ;loading the value into $9005 makes the vic not look into the rom location for characters, instead the vico looks at memory starting at $1c00
    STA $9005               ;the above can be found on pages 85 and 86 of the vic 20 manual 

    LDA #$00                ;the next 8 load instructs load a byte representing 1 line of our starfighter 
    STA $1C00               ;together the 8 bytes will make a star fighter sprite character

    LDA #$08
    STA $1C01

    LDA #$1C
    STA $1C02

    LDA #$7f
    STA $1C03

    LDA #$7f
    STA $1C04

    LDA #$5d
    STA $1C05

    LDA #$08
    STA $1C06

    LDA #$00
    STA $1C07


    jsr $e55f       ; clear screen

    lda $00c5		 ; current key held down -> page 179 of vic20 manual, only prints with this and not sure why
    jsr $ffd2

spinloop:


    ;lda $00c5		 ; current key held down -> page 179 of vic20 manual
    ;jsr $ffd2

    ldx #0
    nop         ;nops used as busy work
    nop
    dex
    bne spinloop

