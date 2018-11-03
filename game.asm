;-----------------------------------------
; Work in progress demo for Star Fox 1980
;-----------------------------------------
;-----------------------------Macros-------------------------------
HEALTH      equ $fb
SCORE       equ $fc
PLAYERPOS   equ $fd
BOSSPOS     equ $fe


CHROUT      equ $ffd2
RESET       equ $fd22
GETIN       equ $ffe4
SOUND1      equ $900a
SOUND2      equ $900b
SOUND3      equ $900c
NOISE       equ $900d
VOLUME      equ $900e
SCRCOLOR    equ $900f
TXTCOLOR    equ $0286

;----------------------------End Macros----------------------------
;----------------------------Basic Stub----------------------------
    Processor 6502
    org $1001               ; Unexpanded VIC

    ; BASIC stub (unexpanded vic)
    dc.w $100b              ; Pointer to next BASIC line
    dc.w 1981               ; BASIC Line#
    dc.b $9e                ; BASIC SYS token
    dc.b $34,$31,$30,$39    ; 4109 (ML start)
    dc.b 0                  ; End of BASIC line
    dc.w 0                  ; End of BASIC program
;-----------------------------End Stub----------------------------
    
    include "title.asm"
    
    jmp title
    
;---------------------------Initialization-----------------------------------
init:
    lda #$08                ; load new black background colour
    sta SCRCOLOR            ; change background and border colours

    lda #$ff                ; loading the value into $9005 makes the VIC not look into the rom location for characters, instead the vic looks at memory starting at $1c00
    sta $9005               ; the above can be found on pages 85 and 86 of the VIC 20 manual 
    
    jsr $e55f               ; clear screen
    
    ; Draw hearts
    lda #$02                ; Heart character
    sta $1fe4
    sta $97e4
    sta $1fe5
    sta $97e5
    sta $1fe6
    sta $97e6
    
    ldy #$04                ; draw starfighter character
    sty $1f96               ; 8086
    
    ldy #$06                ; color code
    sty $9796               ; 38806
    
    ;ldy #$04                ; draw enemy character
    ;sty $1e0a               ;
    
    ;ldy #$02                ; color code
    ;sty $960a               ;
    
    ldy #$05                ; draw laser
    sty $1e8e               ;
    ldy #$04                ; color code
    sty $968e               ;
    
    ldy #$05                ; draw laser
    sty $1ea4               ; 8086
    ldy #$04                ; color code
    sty $96a4               ; 38806
    
    ldy #$05                ; draw laser
    sty $1eba               ; 8086
    ldy #$04                ; color code
    sty $96ba               ; 38806
    
    ldy #$05                ; draw laser
    sty $1ed0               ; 8086
    ldy #$04                ; color code
    sty $96d0               ; 38806
    
    ldy #$05                ; draw laser
    sty $1ee6               ; 8086
    ldy #$04                ; color code
    sty $96e6               ; 38806
    
    ldy #$05                ; draw laser
    sty $1efc               ; 8086
    ldy #$04                ; color code
    sty $96fc               ; 38806
    
    ldy #$05                ; draw laser
    sty $1f12               ; 8086
    ldy #$04                ; color code
    sty $9712               ; 38806
    
    ldy #$05                ; draw laser
    sty $1f28               ; 8086
    ldy #$04                ; color code
    sty $9728               ; 38806
    
    ldy #$05                ; draw laser
    sty $1f3e               ; 8086
    ldy #$04                ; color code
    sty $973e               ; 38806
    
    ldy #$05                ; draw laser
    sty $1f54               ; 8086
    ldy #$04                ; color code
    sty $9754               ; 38806
    
    ldy #$05                ; draw laser
    sty $1f6a               ; 8086
    ldy #$04                ; color code
    sty $976a               ; 38806
    
    ldy #$05                ; draw laser
    sty $1f80               ; 8086
    ldy #$04                ; color code
    sty $9780               ; 38806
    
    ldy #$07                ; draw boss
    sty $1e60               ;
    ldy #$02
    sty $9660
    
    ldy #$08                ; draw boss
    sty $1e61               ;
    ldy #$02
    sty $9661
    
    ldy #$09                ; draw boss
    sty $1e62               ;
    ldy #$02
    sty $9662
    
    ldy #$0a                ; draw boss
    sty $1e63               ;
    ldy #$02
    sty $9663
    
    ldy #$0b                ; draw boss
    sty $1e64               ;
    ldy #$02
    sty $9664
    
    ldy #$0c                ; draw boss
    sty $1e65               ;
    ldy #$02
    sty $9665
    
    ldy #$0d                ; draw boss
    sty $1e76               ;
    ldy #$02
    sty $9676
    
    ldy #$0e                ; draw boss
    sty $1e77               ;
    ldy #$02
    sty $9677
    
    ldy #$0f                ; draw boss
    sty $1e78               ;
    ldy #$02
    sty $9678
    
    ldy #$10                ; draw boss
    sty $1e79               ;
    ldy #$02
    sty $9679
    
    ldy #$11                ; draw boss
    sty $1e7a               ;
    ldy #$02
    sty $967a
    
    ldy #$12                ; draw boss
    sty $1e7b               ;
    ldy #$02
    sty $967b
    
    lda #$96
    sta PLAYERPOS           ; we are treating this location as ram, it contains the offset to add to the screen
    
;----------------------------Variable initialization---------------------------
    ldy #$03
    sty HEALTH
    
;-------------------------------Main game loop-------------------------------
gameloop:
    lda $00c5               ; get current pressed key
    
    cmp #17
    beq pressA              ; pressed a
    
    cmp #18
    beq pressD              ; pressed d
    
    ;cmp #9
    ;beq pressW              ; pressed w
    
    ;cmp #41
    ;beq pressS              ; pressed s
    
    cmp #32
    beq pressbar            ; pressed space bar
    
    
    jmp gameloop
    
    
drawBoss:
    
    
drawLoop:
    
    
decrementHealth:
    
    jsr updateHealth
    ldy HEALTH
    cpy #$00
    bne delay
    beq gameover
    
pressA:
    
    ldx PLAYERPOS
    cpx #$8c
    beq decrementHealth
    
    lda #$09                ; sounds
    sta VOLUME              ; volume
    
    lda #$ca                ; sounds
    sta SOUND3
    
    lda #$00                ; draw ' ' character
    ldx PLAYERPOS
    
    cpx #$00
    sta $1f00 ,x            ; store it on screen where ship used to be 
    
    ldx PLAYERPOS
    dex                     ; decrement x by 1 to represent location as current location has moved 1
    stx PLAYERPOS
    
    lda #$03                ; current star fighter character
    ldx PLAYERPOS
    sta $1f00 ,x            ; store it at the current location
    
    lda #$06
    sta $9700 ,x
    
    jmp delay
    
pressD:
    
    ldx PLAYERPOS
    cpx #$a1
    beq decrementHealth
    
    
    lda #$09
    sta VOLUME
    
    lda #$ca
    sta SOUND3
    
    lda #$00                ; draw ' ' character
    ldx PLAYERPOS
    sta $1f00 ,x            ; store it on screen where ship used to be 
    
    ldx PLAYERPOS
    inx                     ; increment x by 1 to represent location as current location has moved 1
    stx PLAYERPOS    

    lda #$03                ; current starfighter character
    ldx PLAYERPOS
    sta $1f00 ,x            ; store it at the current location
    
    lda #$06                ; color code
    sta $9700 ,x
    
    jmp delay
    
pressbar:
    
    lda #$0f
    sta VOLUME

    lda #$e2
    sta SOUND3
    
    
    jmp delay

    
delay:
    
    lda $00c5               ; get current pressed key
    
    cmp #64
    bne delay               ; will not progress until the key help down is let go, 64 is the default value
    
    lda #$00                ; this value stops sounds
    sta SOUND1              ; 
    sta SOUND3              ; 
    
    jmp gameloop    
    
spinloop:

    ldx #0
    nop                     ; nops used as busy work
    nop
    dex
    bne spinloop
    
    
gameover:
    jsr $e55f               ; clear screen
    lda #$19                ; load new background colour
    sta SCRCOLOR            ; change background and border colours
    
    lda #$8                ; load new background colour
    sta SCRCOLOR            ; change background and border colours
    
    jmp gameover    
    
;updateHealthInit:
    ;ldx HEALTH
    ;tya                     
    ;tax                     
    
updateHealth:
    ldx HEALTH
    dex
    lda #$00                ; blank
    sta $1fe4 ,x
    stx HEALTH
    rts
    
    include     "charset.asm"
    
titlescreen:  
    dc.b    $0d
    dc.b    "S T A R F O X  1 9 8 0", $0d, $0d, $0d
    dc.b    "       JACK XIE", $0d
    dc.b    "     MICHAEL QIU", $0d
    dc.b    "      ALAN FUNG", $0d, $0d, $0d
    dc.b    $0d, $0d, $0d, $0d, $0d, $0d
    dc.b    "   PRESS F1 TO START", $0d
