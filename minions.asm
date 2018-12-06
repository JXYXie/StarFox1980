;-----------------------------------------
; Handles minions spawning and movement
;-----------------------------------------

spawn_minions:
	jsr randgen					; Generate random number
	lsr RANDNUM					; shift bit 0
	bcc spawn_laser_minion		; If even number generate enemy type 1
	bcs spawn_rocket_minion		; If odd number generate enemy type 2

spawn_laser_minion:
	ldx MINION_IND				; Get the current index
	lda #$01					; 01 represents laser
	sta minion_status ,x		; Save the status
	inx							; Increment the index
	stx MINION_IND				; Save the new index
	cpx #$0a					; If not at the end of the index
	bne spawn_minions			; Keep spawning more minions
	rts

spawn_rocket_minion:
	ldx MINION_IND				; Get the current index
	lda #$02					; 02 represents rocket
	sta minion_status ,x		; Save the status
	inx							; Increment the index
	stx MINION_IND				; Save the new index
	cpx #$0a					; If not at the end of the index
	bne spawn_minions
	rts


draw_minions:
	ldx MINION_IND				; Get the current minion index
	ldy minion_status ,x		; Get the minion status
	cpy #$01					; Is it laser minion?
	beq draw_laser_minion		; If so draw it
	cpy #$02					; Is it rocket minion?
	beq draw_rocket_minion		; Draw it
	bne end_draw_minion			; Otherwise dont draw a thing
draw_laser_minion:
	ldx MINION_IND				; Get the current minion index
	ldy minion_pos ,x			; Get the position of the minion
	lda #$11					; Laser minion char
	sta $1e00 ,y				; At the location
	lda #$02
	sta $9600 ,y				; Color location
	jmp end_draw_minion			; Done drawing

draw_rocket_minion:
	ldx MINION_IND				; Get the current minion index
	ldy minion_pos ,x			; Get the position of the minion
	lda #$12					; Rocket minion char
	sta $1e00 ,y				; At the location
	lda #$05
	sta $9600 ,y				; Color location

end_draw_minion:
	inx							; Next minion
	stx MINION_IND				; store the new minion
	cpx #$0a					; Are we done drawing minions?
	bne draw_minions			; If not keep drawing

	rts

minion_ai:
	jsr randgen					; Generate random number
	lsr RANDNUM					; shift bit 0
	bcc minion_move_right		; If even
	bcs minion_move_left		; If odd
	rts

minion_move_left:
	ldx MINION_IND
	lda minion_pos ,x
	cmp #$6e
	beq minion_move_end
	cmp #$84
	beq minion_move_end
	cmp #$9a
	beq minion_move_end
	cmp #$b0
	beq minion_move_end
	cmp #$c6
	beq minion_move_end
	cmp #$dc
	beq minion_move_end

	ldx MINION_IND
	ldy minion_pos ,x
	dey
	lda $1e00 ,y
	cmp #$11
	beq minion_move_end
	cmp #$12
	beq minion_move_end
	dey
	lda $1e00 ,y
	cmp #$11
	beq minion_move_end
	cmp #$12
	beq minion_move_end

	dec minion_pos ,x
	jmp minion_move_end

minion_move_right:
	ldx MINION_IND
	lda minion_pos ,x
	cmp #$83
	beq minion_move_end
	cmp #$99
	beq minion_move_end
	cmp #$af
	beq minion_move_end
	cmp #$c5
	beq minion_move_end
	cmp #$db
	beq minion_move_end
	cmp #$f1
	beq minion_move_end

	ldx MINION_IND
	ldy minion_pos ,x
	iny
	lda $1e00 ,y
	cmp #$11
	beq minion_move_end
	cmp #$12
	beq minion_move_end
	iny
	lda $1e00 ,y
	cmp #$11
	beq minion_move_end
	cmp #$12
	beq minion_move_end

	inc minion_pos ,x

minion_move_end:
	inx
	stx MINION_IND

	cpx MINIONS
	beq minion_ai_end
	jsr minion_ai

minion_ai_end:
	rts

minion_shoot:

	rts

