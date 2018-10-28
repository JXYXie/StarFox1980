;-------------------------------------
; This program tests user input and animation
; Checks for left right movement and moves object based on user input
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
    ldy #$00                ; draw '@' character
    sty $1e16               ; top left corner
    ldx #$00                ; the colour is black
    stx $9616               ; save that at the same location
    pla                     ; pull accumulator from stack
    sta $9005               ; store in char memory
    
loop:
    lda $9005               ; load character memory
    pha
    
    lda $00c5               ; get current pressed key
    
    cmp #17
    beq pressA              ; pressed a
    
    cmp #18
    beq pressD              ; pressed d
    
    bne tail
    
pressA:
    lda #$43                ; draw '-' character
    sta $1e16,x             ; store it on screen from top left
    lda #$00                ; the colour is black
    sta $9616,x             ; save that at the same location
    dex                     ; decrement x by 1 to represent location as current location has moved 1
    
    lda #$00                ; current '@' character
    sta $1e16,x             ; store it at the current location
    lda #$00                ; colour is black
    sta $9616,x             ; same location
    
    jsr delay
    jmp tail
    
pressD:
    lda #$43
    sta $1e16,x
    lda #$00
    sta $9616,x
    inx                     ; same as above but increment by 1
    
    lda #$00
    sta $1e16,x
    lda #$00
    sta $9616,x
    
    jsr delay
    
tail:
    lda #$00c5              ; current key press
    cmp #32                 ; Space to quit
    bne loop                ; loop if not pressed
    rts                     ; return
    
delay:
    ldy #$00                ; loop counter
    bne delay               ; if not keep checking
delayloop:
    iny                     ; increment by 1
    cpy #$ff
    bne delayloop           ; repeat
    rts
