
KeypadLoop:

	ldi cmask, INITCOLMASK ; initial column mask
	clr col ; initial column


colloop:

	cpi col, 4
	breq KeypadLoop ; If all keys are scanned, repeat.
	sts PORTL, cmask ; Otherwise, scan a column.
	ldi temp1, 0xFF ; Slow down the scan operation.
	delay: dec temp1
	brne delay  //assuming this counts down to 0 from 255, otherwise, idk.
	lds temp1, PINL ; Read PORTA
	andi temp1, ROWMASK ; Get the keypad output value
	cpi temp1, 0xF ; Check if any row is low??? 0b1101
	breq nextcol ; If yes, find which row is low
	ldi rmask, INITROWMASK ; Initialize for row check
	clr row ;


rowloop:

	cpi row, 4
	breq nextcol ; the row scan is over.
	mov temp2, temp1
	and temp2, rmask ; check un-masked bit
	breq convert ; if bit is clear, the key is pressed
	inc row ; else move to the next row
	lsl rmask
	jmp rowloop
	nextcol: ; if row scan is over
	lsl cmask
	inc cmask
	inc col ; increase column value
	jmp colloop ; go to the next column

SetZero:

	mov temp1, temp4
	subi temp1,-'0'
	
	rcall returnInventory

	clr temp1
	st Z, temp1

	mov temp1, temp4
	subi temp1, -'0'
	rcall sleep_100ms
	rcall adminMode
	rjmp KeypadLoop

convert:

	cpi col, 3 ; If the pressed key is in col.3
	breq letters ; we have a letter
	; If the key is not in col.3 and
	cpi row, 3 ; If the key is in row3,
	breq symbols ; we have a symbol or 0
	mov temp1, row ; Otherwise we have a number in 1-9
	lsl temp1
	add temp1, row
	add temp1, col ; temp1 = row*3 + col
	subi temp1, -'1' ; Add the value of character ‘1’    //key pressed is saved as ascii
	cpi r27,1
	breq Adminjmp
	jmp checkEmpty



letters:
	
	ldi temp1, 0b00110010
	add temp1, row

	cpi r27, 1
	brne convert_end
	
	cpi row,0
	breq IncreaseCost
	cpi row,1
	breq DecreaseCost
	cpi row,2
	breq SetZero

	rjmp KeypadLoop
	
IncreaseCost:
	
	mov temp1, temp4
	subi temp1,-'0'
	
	rcall returnInventory

	ld temp1, Y
	cpi temp1, 3
	breq convert_end

	inc temp1
	st Y, temp1

	mov temp1, temp4
	subi temp1, -'0'
	rcall sleep_100ms
	
	rcall adminMode
	rjmp KeypadLoop

DecreaseCost:
	
	mov temp1, temp4
	subi temp1,-'0'
	
	rcall returnInventory

	ld temp1, Y
	cpi temp1, 1
	breq convert_end

	dec temp1
	st Y, temp1

	mov temp1, temp4
	subi temp1, -'0'
	rcall sleep_100ms
	rcall adminMode
	rjmp KeypadLoop


symbols:

	cpi col, 0 ; Check if we have a star
	breq star
	cpi col, 1 ; or if we have zero
	breq zero
	ldi temp1, '#'
	cpi r27,1
	brne convert_end
	clr flag1
	clr r27
	rjmp DisplaySelectScreen2
	

star:

	;ldi temp1,'*'
	
	cpi flag1,1
	breq Flag2Check
	
	ldi flag1, 1
	
	ldi temp3, 1<<TOIE1 ;start timer.
	sts TIMSK1, temp3

	Flag2Check:
	cpi r26,1
	breq adminModeInitialJump ;this mode should clear r26 and flag1
	
	;out PORTC, temp1 ; Write value to PORTC
	jmp KeypadLoop
