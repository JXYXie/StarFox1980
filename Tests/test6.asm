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


    ; this program will give you a migrane when you hold a. release a to help alleviate migrane symptoms 

    lda #$0f		; 15 is the max volume the speakers can be set at. The 1-15 values can be found at p(95,96) of the vic 20 manual
    sta $900e		; 900e controls volume, is where the volume values are written to. These values are 1-15 p(95,96)
    


read:
    lda $00c5		 ; current key held down -> page 179 of vic20 manual
    cmp #17		 ;a pressed  -> page 179 of the vic 20 manual
    beq sound		 
    bne off


sound:
    ldx #80      
;toploop:
    lda #$87	 ; C  (135) low C this value can be found at p(95,96) of the vic 20 manual
    sta $900b		 ; store sound
    ;nop             ;nops used as busy work
    ;nop
    ;dex
    ;bne toploop
    jmp read


off:
    lda #$00         ; 00 produces no sound, it is outside the range of valid values. This is documented on p96 of the vic 20 manual
    sta $900a		 ; store sound
    sta $900b		 ; store sound
    jmp read



