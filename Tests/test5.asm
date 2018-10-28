    processor 6502
    org $1001               ; Unexpanded VIC
    ; vic pages used (page 98-102, 175)

    ; BASIC stub (unexpanded vic)   
    dc.w $100b              ; Pointer to next BASIC line
    dc.w 1981               ; BASIC Line#
    dc.b $9e                ; BASIC SYS token
    dc.b $34,$31,$30,$39    ; 4109 (ML start)
    dc.b 0                  ; End of BASIC line
    dc.w 0                  ; End of BASIC program

    ; this program creates sound on the vic 20. it is an infinite loop

    lda #$0f		; 15 is the max volume the speakers can be set at. The 1-15 values can be found at p(95,96) of the vic 20 manual
    sta $900e		; 900e controls volume, is where the volume values are written to. this address can be found at p(95,96) of the vic 20 manual
    
 
spinloop:
    lda #$87	 ; C  (135) low C this value can be found at p(95,96) of the vic 20 manual
    sta $900b		 ; store sound


    ldx #0
    nop         ;nops used as busy work
    nop
    dex
    bne spinloop

    lda #$00    
    sta $900a		 ; store sound




