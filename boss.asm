;-----------------------------------------
; Handles boss spawning and movement
;-----------------------------------------

spawn_boss:
	ldx #$05					; Initialize boss health
	stx BOSS_HEALTH
	ldx #$1f					; Boss position
	stx BOSS_POS				;
	
	rts

draw_boss:

	ldx BOSS_POS
	lda #$07					; Boss top left character
	sta $1e00 ,x				; Store it at the right locatin
	lda #$02					; Colour
	sta $9600 ,x
	
	inx
	lda #$08					; Boss top mid-left character
	sta $1e00 ,x				; Store it at the right locatin
	lda #$02					; Colour
	sta $9600 ,x
	
	inx
	lda #$09					; Boss top mid-right character
	sta $1e00 ,x				; Store it at the right locatin
	lda #$02					; Colour
	sta $9600 ,x
	
	inx
	lda #$0a					; Boss top right character
	sta $1e00 ,x				; Store it at the right locatin
	lda #$02					; Colour
	sta $9600 ,x
	
	lda BOSS_POS				; Get boss position
	clc
	adc #$16					; Get the bottom row
	tax							; Transfer it to x register
	lda #$0b					; Boss bottom left character
	sta $1e00 ,x				; Store it at the right locatin
	lda #$02					; Colour
	sta $9600 ,x
	
	inx
	lda #$0c					; Boss bottom mid-left character
	sta $1e00 ,x				; Store it at the right locatin
	lda #$02					; Colour
	sta $9600 ,x
	
	inx
	lda #$0d					; Boss bottom mid-right character
	sta $1e00 ,x				; Store it at the right locatin
	lda #$02					; Colour
	sta $9600 ,x
	
	inx
	lda #$0e					; Boss bottom right character
	sta $1e00 ,x				; Store it at the right locatin
	lda #$02					; Colour
	sta $9600 ,x

	rts

boss_move_left:
	ldx BOSS_POS				; Get current boss location
	cpx #$16					; is it touching the left boundary
	beq boss_move_right			; if so move right instead
	dex							; if not move left
	stx BOSS_POS				; and update new location
	rts

boss_move_right:
	ldx BOSS_POS				; Get current boss location
	cpx #$28					; is it touching right boundary
	beq boss_move_left			; if so move left instead
	inx							; if not move right
	stx BOSS_POS				; and update new location
	rts

boss_ai:
	lda BOSS_POS				; Get the boss position
	adc #$a2					; Add an offset
	cmp PLAYER_POS				; Compare it with player position
	beq boss_ai_shoot			; If the boss is where the player boss ai determine when to shoot
	bcc boss_move_right			; If player is to the right of boss move right
	bcs boss_move_left			; If player to the left of boss move left

boss_ai_shoot:
	lda BOSS_POS				; Get the boss location
	sta laser_pos				; Shoot the left laser at this location
	jsr writeEnemyShot
	tax
	inx
	inx
	txa							; Get the right laser location
	sta laser_pos
	jsr writeEnemyShot
	rts


