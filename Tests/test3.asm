;-------------------------------------
; This program tests drawing stuff to screen
; Reference: pg 175 on VIC-20 programmers reference guide
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

    lda $9005               ; load character memory (pg 175)
    pha                     ; push accumulator on stack
    ora #$0f                ; OR memory with accumulator (bits 0-3) (pg 175)
    sta $9005               ; store accumulator
    ldy #$43                ; draw '-' character
    sty $1e16               ; top left corner
    ldx #$00                ; the colour is black
    stx $9616               ; save that at the same location
    pla                     ; pull accumulator from stack
    sta $9005               ; store in char memory
    
    ldy #$00                ; loop counter

drawloop:    
    lda #$43                ; draw '-' character
    sta $1e16,x             ; store it on screen from top left
    lda #$00                ; the colour is black
    sta $9616,x             ; save that at the same location
    inx                     ; increment x by 1 to represent location as current location has moved 1
    iny
    cpy #$10                ; have we drawn 10 -'s?
    bne drawloop
    
infloop:                    ; infinite loop to keep the image displayed
    nop
    jmp infloop
