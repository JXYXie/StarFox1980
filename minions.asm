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


	ldx MINION_IND
	lda minion_pos ,x
	sta laser_pos
	jsr writeEnemyShot

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

	; Compare tiles near minion
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


check_laser:
	lda MINION_IND
	ldy #$10
minion_loop:
	lda playerShots ,y ;the "first" thing holds 1e, 1f or 00. if it is 00 we want to write to it
	cmp #$1e
	bne minion_loop_next
	dey
	lda playerShots ,y
	ldx minion_pos, MINION_IND
	stx TMP2
	cmp TMP2
	bne minion_loop_next1
	lda MINION_IND
	jsr kill_minion
	
	rts

minion_loop_next1:
	dey
	bne minion_loop
	rts


minion_loop_next:
	dey
	dey
	bne minion_loop

	rts


minion_collision:
	ldx MINION_IND
	lda minion_status ,x
	cmp #$00						; Check if the minion is already dead
	beq minion_collision_next
	jsr check_laser
	ldx MINION_IND

minion_collision_next:
	inx								; Increment minion index
	stx MINION_IND					; Save it

	cpx MINIONS						; At the end of minions?
	beq minion_collision_end
	bne minion_collision

minion_collision_end:
	rts

kill_minion:
	tax
	ldy minion_pos ,x				; Get the position
	lda #$13						; Death animation
	sta $1e00 ,y
	lda #$02
	sta $9600 ,y					; Color location

	ldx MINION_IND
	lda #$00						; death status
	sta minion_status ,x			; Update minion status

	rts

