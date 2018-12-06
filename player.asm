;---------------------------------------------------
; Handles player movement, collision, life, and attacking
;---------------------------------------------------

spawn_player:
	ldy #$03
	sty PLAYER_HEALTH
	lda #$c2
	sta PLAYER_POS

	rts

draw_player:
	ldx PLAYER_POS					; Get player position
	lda #$03						; Load starfighter character
	sta $1f00 ,x					; Draw to screen
	lda #$06						; Color blue
	sta $9700 ,x
	rts

player_lose_health:


	rts

player_shoot:
	
	jsr writePlayerShot

	rts