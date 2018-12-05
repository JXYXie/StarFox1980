;-----------------------------------------
; Handles boss spawning and movement
;-----------------------------------------
;-----------------------------Macros-------------------------------

spawn_boss:


draw_boss:

	ldy #$07					; draw boss
	sty $1e61					;
	ldy #$02
	sty $9661
	
	ldy #$08					; draw boss
	sty $1e62					;
	ldy #$02
	sty $9662
	
	ldy #$09					; draw boss
	sty $1e63					;
	ldy #$02
	sty $9663
	
	ldy #$0a					; draw boss
	sty $1e64					;
	ldy #$02
	sty $9664
	
	ldy #$0b					; draw boss
	sty $1e77					;
	ldy #$02
	sty $9677
	
	ldy #$0c					; draw boss
	sty $1e78					;
	ldy #$02
	sty $9678
	
	ldy #$0d					; draw boss
	sty $1e79					;
	ldy #$02
	sty $9679
	
	ldy #$0e					; draw boss
	sty $1e7a					;
	ldy #$02
	sty $967a

	rts	   


