.include "m2560def.inc"

.dseg
.macro do_lcd_command
ldi r16, @0
rcall lcd_command
rcall lcd_wait
.endmacro


.macro do_lcd_data
ldi r16, @0
rcall lcd_data
rcall lcd_wait
.endmacro

.macro do_lcd_data_r
mov r16, @0
rcall lcd_data
rcall lcd_wait
.endmacro


item1: .byte 1
item1Cost: .byte 1
item2: .byte 1
item2Cost: .byte 1
item3: .byte 1
item3Cost: .byte 1
item4: .byte 1
item4Cost: .byte 1
item5: .byte 1
item5Cost: .byte 1
item6: .byte 1
item6Cost: .byte 1
item7: .byte 1
item7Cost: .byte 1
item8: .byte 1
item8Cost: .byte 1
item9: .byte 1
item9Cost: .byte 1

.cseg

 

.def temp1 = r16
.def timerCounter = r17
.def rmask = r18 ; mask for current row during scan
.def cmask = r19 ; mask for current column during scan
.def row = r20 ; current row number
.def col = r21 ; current column number
.def temp2 = r22
.def temp3 = r23
.def temp4 = r24
.def flag1 = r25



.equ PORTADIR = 0xF0 ; PD7-4: output, PD3-0, input
.equ INITCOLMASK = 0xEF ; scan from the rightmost column,
.equ INITROWMASK = 0x01 ; scan from the top row
.equ ROWMASK = 0x0F ; for obtaining input from Port D

.org 0x0000
   jmp Main;
   jmp DEFAULT          ; No handling for IRQ0.
   jmp DEFAULT

.org OVF1addr
jmp Timer1





.org OVF0addr
jmp Timer0


jmp DEFAULT        
DEFAULT:  reti 

EXT_INT0:
	reti

Main:

	clr r17
	clr r18
	clr r19
	clr r20
	clr r21
	clr r22
	clr flag1
	clr r26 //flag2
	clr r27 //admin flag
	
	sts DDRK, r22

	ldi YH,high(item1)
	ldi YL,low(item1)
	ldi temp1, 1
	st y, temp1

	ldi YH,high(item1Cost)
	ldi YL,low(item1Cost)
	ldi temp1,1
	st y, temp1

	ldi YH,high(item2)
	ldi YL,low(item2)
	ldi temp1, 2
	st y, temp1

	ldi YH,high(item2Cost)
	ldi YL,low(item2Cost)
	ldi temp1,2
	st y, temp1

	ldi YH,high(item3)
	ldi YL,low(item3)
	ldi temp1, 3
	st y, temp1

	ldi YH,high(item3Cost)
	ldi YL,low(item3Cost)
	ldi temp1,1
	st y, temp1

	ldi YH,high(item4)
	ldi YL,low(item4)
	ldi temp1, 4
	st y, temp1

	ldi YH,high(item4Cost)
	ldi YL,low(item4Cost)
	ldi temp1,2
	st y, temp1

	ldi YH,high(item5)
	ldi YL,low(item5)
	ldi temp1, 5
	st y, temp1

	ldi YH,high(item5Cost)
	ldi YL,low(item5Cost)
	ldi temp1,1
	st y, temp1

	ldi YH,high(item6)
	ldi YL,low(item6)
	ldi temp1, 6
	st y, temp1

	ldi YH,high(item6Cost)
	ldi YL,low(item6Cost)
	ldi temp1,2
	st y, temp1

	ldi YH,high(item7)
	ldi YL,low(item7)
	ldi temp1, 7
	st y, temp1

	ldi YH,high(item7Cost)
	ldi YL,low(item7Cost)
	ldi temp1,1
	st y, temp1

	ldi YH,high(item8)
	ldi YL,low(item8)
	ldi temp1, 8
	st y, temp1

	ldi YH,high(item8Cost)
	ldi YL,low(item8Cost)
	ldi temp1,2
	st y, temp1

	ldi YH,high(item9)
	ldi YL,low(item9)
	ldi temp1, 9
	st y, temp1

	ldi YH,high(item9Cost)
	ldi YL,low(item9Cost)
	ldi temp1,1
	st y, temp1


	clr temp1					; connected to PE4 (externally labelled PE2)
	sts OCR3AH, temp1
	sts OCR3AL, temp1

	ldi temp1, (1 << CS30) 		; set the Timer3 to Phase Correct PWM mode. 
	sts TCCR3B, temp1
	ldi temp1, (1 << WGM31)|(1<< WGM30)|(1<<COM3B1)|(1<<COM3A1)
	sts TCCR3A, temp1

	ser r16
	out DDRC, r16
	out DDRE, temp1

	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16

	ser r16 ; LCD setup
	out DDRF, r16
	out DDRA, r16
	clr r16
	out PORTF, r16
	out PORTA, r16

	do_lcd_command 0b00111000 ; 2x5x7
	rcall sleep_5ms
	do_lcd_command 0b00111000 ; 2x5x7
	rcall sleep_1ms
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00001000 ; display off?
	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b00000110 ; increment, no display shift
	do_lcd_command 0b00001110 ; Cursor on, bar, no blink
	do_lcd_command 0b10000000

	ldi r18, 0b00000000 ;Timer setup for start screen 3 second wait
	out TCCR0A, r18
	ldi r18, 0b00000101   
	out TCCR0B, r18
	ldi r18, 1<<TOIE0
	sts TIMSK0, r18

	ldi r18, 0b00000000 ;Timer setup for start screen 3 second wait
	sts TCCR1A, r18
	ldi r18, 0b00000011   
	sts TCCR1B, r18
	;ldi r18, 1<<TOIE1
	clr r18
	sts TIMSK1, r18

	ldi temp1, PORTADIR ;keypad setup
	sts DDRL, temp1 ; PA7:4/PA3:0, out/in

	sei

	do_lcd_data '2'
	do_lcd_data '1'
	do_lcd_data '2'
	do_lcd_data '1'
	do_lcd_data ' '
	do_lcd_data '1'
	do_lcd_data '7'
	do_lcd_data 's'
	do_lcd_data '1'
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data ' '
	do_lcd_data 'E'
	do_lcd_data '4'

	do_lcd_command 0b10101000

	do_lcd_data 'V'
	do_lcd_data 'e'
	do_lcd_data 'n'
	do_lcd_data 'd'
	do_lcd_data 'i'
	do_lcd_data 'n'
	do_lcd_data 'g'
	do_lcd_data ' '
	do_lcd_data 'M'
	do_lcd_data 'a'
	do_lcd_data 'c'
	do_lcd_data 'h'
	do_lcd_data 'i'
	do_lcd_data 'n'
	do_lcd_data 'e'

	rjmp KeypadLoop

halt:
	rjmp halt

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
	jmp checkEmpty

letters:

	ldi temp1, 0b00110010
	add temp1, row ; Get the ASCII value for the key
	jmp convert_end

symbols:

	cpi col, 0 ; Check if we have a star
	breq star
	cpi col, 1 ; or if we have zero
	breq zero
	ldi temp1, '#'
	cpi r27,1
	brne convert_end
	 ; if not we have hash
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
	breq adminModeInitialJump ;this mode though clear r26 and flag1
	
	;out PORTC, temp1 ; Write value to PORTC
	jmp KeypadLoop

zero:

	ldi temp1, '0' ; Set to zero

convert_end:

	out PORTC, temp1 ; Write value to PORTC
	jmp KeypadLoop ; Restart KeypadLoop loop

.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4

.macro lcd_set
sbi PORTA, @0
.endmacro
.macro lcd_clr
cbi PORTA, @0
.endmacro

adminModeInitialJump:
	
	clr temp3
	sts TIMSK1, temp3
	clr flag1
	clr r26
	jmp adminModeInitial

Timer0: ;Timer overflow 0

	in temp1, SREG
	push temp1

	inc timerCounter

	cpi timerCounter,192
	breq displaySelectScreen

	pop temp1
	out SREG, temp1

	reti

Timer1:

	push cmask
	push rmask
	push temp1
	push temp2
	in temp1,SREG
	push temp1

	

	inc TimerCounter


	ldi cmask, INITCOLMASK ; initial column mask

	sts PORTL, cmask ; Otherwise, scan a column.
	
	ldi temp1, 0xFF ; Slow down the scan operation.
	Hashdelay: dec temp1
	brne Hashdelay  //assuming this counts down to 0 from 255, otherwise, idk.
	
	lds temp1, PINL ; Read PORTA
	andi temp1, ROWMASK ; Get the keypad output value
	cpi temp1, 0xF ; Check if any row is low???
	breq Released ; If yes, find which row is low
	
	ldi rmask, INITROWMASK ; Initialize for row check

	lsl rmask
	lsl rmask
	lsl rmask

	mov temp2, temp1
	and temp2, rmask
	breq StillPressed 

	rjmp Released
	
StillPressed:

	inc TimerCounter

	ldi temp1, 0b10101010
	out PORTC, temp1
	
	cpi TimerCounter, 25
	brlo Finish
		
	ldi temp1, 0b11110000
	out PORTC, temp1

	ldi r26,1
	clr temp3
	sts TIMSK1, temp3

	Finish:

	pop temp1
	out SREG, temp1
	pop temp2
	pop temp1
	pop rmask
	pop cmask

	reti

Released:
	
	clr temp3
	sts TIMSK1, temp3
	clr flag1

	ldi temp1, 0b11111111
	out PORTC, temp1

	pop temp1
	out SREG, temp1
	pop temp2
	pop temp1
	pop rmask
	pop cmask
	
	reti

displaySelectScreen:

	clr timerCounter

	clr r18 
	sts TIMSK0, r18 ; turn off timer.

	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b10000000 ;set cursor to addr 0 on LCD

	do_lcd_data 'S'
	do_lcd_data 'e'
	do_lcd_data 'l'
	do_lcd_data 'e'
	do_lcd_data 'c'
	do_lcd_data 't'
	do_lcd_data ' '
	do_lcd_data 'i'
	do_lcd_data 't'
	do_lcd_data 'e'
	do_lcd_data 'm'

	pop temp1
	out SREG, temp1

	reti


checkEmpty:
//temp1 is ascii
	push temp1
	subi temp1, '0'
	cpi temp1, 1
	breq check1
	cpi temp1, 2
	breq check2
	cpi temp1, 3
	breq check3
	cpi temp1, 4
	breq check4
	cpi temp1, 5
	breq check5
	cpi temp1, 6
	breq check6
	cpi temp1, 7
	breq check7
	cpi temp1, 8
	breq check8
	cpi temp1, 9
	breq check9

	check1:
		ldi ZL, low(item1)
		ldi ZH, high(item1)
		ld temp2, Z
		pop temp1
		cpi temp2, 0
		breq EmptyScreen
		rjmp CoinScreen
	check2:
		ldi ZL, low(item2)
		ldi ZH, high(item2)
		ld temp2, Z
		pop temp1
		cpi temp2, 0
		breq EmptyScreen
		rjmp CoinScreen
	check3:
		ldi ZL, low(item3)
		ldi ZH, high(item3)
		ld temp2, Z
		pop temp1
		cpi temp2, 0
		breq EmptyScreen
		rjmp CoinScreen
	check4:
		ldi ZL, low(item4)
		ldi ZH, high(item4)
		ld temp2, Z
		pop temp1
		cpi temp2, 0
		breq EmptyScreen
		rjmp CoinScreen
	check5:
		ldi ZL, low(item5)
		ldi ZH, high(item5)
		ld temp2, Z
		pop temp1
		cpi temp2, 0
		breq EmptyScreen
		rjmp CoinScreen
	check6:
		ldi ZL, low(item6)
		ldi ZH, high(item6)
		ld temp2, Z
		pop temp1
		cpi temp2, 0
		breq EmptyScreen
		rjmp CoinScreen
	check7:
		ldi ZL, low(item7)
		ldi ZH, high(item7)
		ld temp2, Z
		pop temp1
		cpi temp2, 0
		breq EmptyScreen
		rjmp CoinScreen
	check8:
		ldi ZL, low(item8)
		ldi ZH, high(item8)
		ld temp2, Z
		pop temp1
		cpi temp2, 0
		breq EmptyScreen
		rjmp CoinScreen
	check9:
		ldi ZL, low(item9)
		ldi ZH, high(item9)
		ld temp2, Z
		pop temp1
		cpi temp2, 0
		breq EmptyScreen
		rjmp CoinScreen

	
EmptyScreen:
		
		push temp1

		do_lcd_command 0b00000001
		do_lcd_data 'O'
		do_lcd_data 'u'
		do_lcd_data 't'
		do_lcd_data ' '
		do_lcd_data 'o'
		do_lcd_data 'f'
		do_lcd_data ' '
		do_lcd_data 's'
		do_lcd_data 't'
		do_lcd_data 'o'
		do_lcd_data 'c'
		do_lcd_data 'k'

		do_lcd_command 0b10101000
		pop temp1
		do_lcd_data_r temp1

		ser temp1
		out PORTC, temp1
		rcall sleep_500ms
		clr temp1
		out PORTC, temp1
		rcall sleep_500ms
		ser temp1
		out PORTC, temp1
		rcall sleep_500ms
		clr temp1
		out PORTC, temp1
		rcall sleep_500ms
		
		ser temp1
		out PORTC, temp1
		rcall sleep_500ms
		clr temp1
		out PORTC, temp1
		rcall sleep_500ms
		
		
		rjmp displaySelectScreen2


displaySelectScreen2:


	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b10000000 ;set cursor to addr 0 on LCD

	do_lcd_data 'S'
	do_lcd_data 'e'
	do_lcd_data 'l'
	do_lcd_data 'e'
	do_lcd_data 'c'
	do_lcd_data 't'
	do_lcd_data ' '
	do_lcd_data 'i'
	do_lcd_data 't'
	do_lcd_data 'e'
	do_lcd_data 'm'

	rcall sleep_500ms

	rjmp KeypadLoop


CoinScreen:
	
	push temp1
	clr r18 
	sts TIMSK0, r18 ; turn off timer.

	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b10000000 ;set cursor to addr 0 on LCD

	do_lcd_data 'I'
	do_lcd_data 'n'
	do_lcd_data 's'
	do_lcd_data 'e'
	do_lcd_data 'r'
	do_lcd_data 't'
	do_lcd_data ' '
	do_lcd_data 'c'
	do_lcd_data 'o'
	do_lcd_data 'i'
	do_lcd_data 'n'
	do_lcd_data 's'
	do_lcd_data ' '
	do_lcd_data '#'
	;subi temp1, -'1'
	pop temp1
	mov temp2,temp1
	push temp1
	do_lcd_data_r temp2
	
	do_lcd_command 0b10101000
	rjmp InsertCoin

	

	.macro HashLoop

	ldi cmask, INITCOLMASK ; initial column mask
	lsl cmask
	lsl cmask  //third column

	sts PORTL, cmask ; Otherwise, scan a column.
	
	ldi temp1, 0xFF ; Slow down the scan operation.
	Hashdelay: dec temp1
	brne Hashdelay  //assuming this counts down to 0 from 255, otherwise, idk.
	
	lds temp1, PINL ; Read PORTA
	andi temp1, ROWMASK ; Get the keypad output value
	cpi temp1, 0xF ; Check if any row is low???
	breq @0 ; If yes, find which row is low
	
	ldi rmask, INITROWMASK ; Initialize for row check

	lsl rmask
	lsl rmask
	lsl rmask

	mov temp2, temp1
	and temp2, rmask 
	breq CoinReturn
	
	rjmp @0
	.endmacro

InsertCoin:
	
	clr temp4
	ldi temp2, 2
	clr temp3
	out PORTC, temp3
	do_lcd_command 0b10101000
	
	mov temp1,temp2
	subi temp1,-'0'
	do_lcd_data_r temp1

	FirstZeroLoop:
		push temp1
		push temp2

		HashLoop Loop2c
		Loop2c:

		pop temp2 
		pop temp1 

		lds temp1, PINK
		andi temp1, 0b00000001
		

		cpi temp1, 0
		brne FirstZeroLoop
		rjmp SecondOneLoop

	SecondOneLoop:

		lds temp1, PINK
		
		push temp1
		push temp2

		HashLoop Loopc
		Loopc:
		
		pop temp2 
		pop temp1 

		andi temp1, 0b00000001
		cpi temp1, 1
		brne SecondOneLoop
		rjmp ThirdZeroLoop 

	CoinReturn:

		cpi temp4,0
		breq JumpDisplay
		dec temp4
	
		ser temp1					
		sts OCR3AH, temp1
		sts OCR3AL, temp1
	
		rcall sleep_250ms

		clr temp1					
		sts OCR3AH, temp1
		sts OCR3AL, temp1
	
		rcall sleep_250ms
		rjmp CoinReturn

		JumpDisplay:
		rjmp displaySelectScreen2
		
	ThirdZeroLoop:

		push temp1
		push temp2
			
		HashLoop Loop3c
		Loop3c:
			
		pop temp2
		pop temp1 

		lds temp1, PINK
		andi temp1, 0b00000001
		

		cpi temp1, 0
		brne ThirdZeroLoop
		
		inc temp4
		
		dec temp2
		
		mov temp1,temp2
		subi temp1,-'0'
		lsl temp3
		ori temp3, 0b00000001

		push temp1

		out PORTC, temp3
		do_lcd_command 0b10101000
		
		pop temp1
		do_lcd_data_r temp1
		cpi temp2, 0
		breq DeliverScreen
		rjmp FirstZeroLoop
		 


DeliverScreen:
	;cli  //disable all input related interrupts
	
	ser temp1
	out DDRE, temp1
	out DDRC, temp1
	
	;ldi temp1,0b10101010
	;out PORTC, temp1
	do_lcd_command 0b00000001
	do_lcd_data 'D'
	do_lcd_data 'e'
	do_lcd_data 'l'
	do_lcd_data 'i'
	do_lcd_data 'v'
	do_lcd_data 'e'
	do_lcd_data 'r'
	do_lcd_data 'i'
	do_lcd_data 'n'
	do_lcd_data 'g'
	do_lcd_data ' '
	do_lcd_data 'I'
	do_lcd_data 't'
	do_lcd_data 'e'
	do_lcd_data 'm'

	pop temp2
	subi temp2, '0'

	rcall decrementInventory

	ser temp1					; connected to PE4 (externally labelled PE2)
	sts OCR3AH, temp1
	sts OCR3AL, temp1

	rcall sleep_1000ms
	rcall sleep_1000ms
	rcall sleep_1000ms

	clr temp1					; connected to PE4 (externally labelled PE2)
	sts OCR3AH, temp1
	sts OCR3AL, temp1

	rjmp displaySelectScreen2


	
decrementInventory:
	
	cpi temp2, 1
	breq decrement1
	cpi temp2, 2
	breq decrement2
	cpi temp2, 3
	breq decrement3
	cpi temp2, 4
	breq decrement4
	cpi temp2, 5
	breq decrement5
	cpi temp2, 6
	breq decrement6
	cpi temp2, 7
	breq decrement7
	cpi temp2, 8
	breq decrement8
	cpi temp2, 9
	breq decrement9
	ret
	
	decrement1:
		
		ldi ZL, low(item1)
		ldi ZH, high(item1)
		lds temp1, 0x0200
		
		
		dec temp1
		//out PORTC, temp1
		st Z, temp1

		ret
	decrement2:
		
		ldi ZL, low(item2)
		ldi ZH, high(item2)
		lds temp1, 0x0201
		
		//out PORTC, temp1
		
		dec temp1
		st Z, temp1
		ret
	
	decrement3:
		
		ldi ZL, low(item3)
		ldi ZH, high(item3)
		
		lds temp1, 0x0202
		//out PORTC, temp1
		dec temp1

		st Z, temp1
		ret
	
	decrement4:
		ldi ZL, low(item4)
		ldi ZH, high(item4)
		ld temp1, Z
		
		dec temp1
		//out PORTC, temp1
		st Z, temp1
		ret

	decrement5:
		ldi ZL, low(item5)
		ldi ZH, high(item5)
		ld temp1, Z
		
		dec temp1
		//out PORTC, temp1
		st Z, temp1
		ret
	
	decrement6:
		
		ldi ZL, low(item6)
		ldi ZH, high(item6)
		ld temp1, Z
		
		//out PORTC, temp1
		dec temp1
		st Z, temp1
		ret
	
	decrement7:
		
		ldi ZL, low(item7)
		ldi ZH, high(item7)
		ld temp1, Z
		//out PORTC, temp1

		dec temp1
		st Z, temp1
		ret
	
	decrement8:
		ldi ZL, low(item8)
		ldi ZH, high(item8)
		ld temp1, Z
		//out PORTC, temp1

		dec temp1
		st Z, temp1
		ret
	
	decrement9:
		ldi ZL, low(item9)
		ldi ZH, high(item9)
		ld temp1, Z
		//out PORTC, temp1

		dec temp1
		st Z, temp1
		ret

adminModeInitial:
	do_lcd_command 0b00000001
	do_lcd_data 'A'
	do_lcd_data 'd'
	do_lcd_data 'm'
	do_lcd_data 'i'
	do_lcd_data 'n'
	do_lcd_data ' '
	do_lcd_data 'm'
	do_lcd_data 'o'
	do_lcd_data 'd'
	do_lcd_data 'e'
	do_lcd_data ' '
	do_lcd_data '1'
	
	do_lcd_command 0b10101000

	push temp1
	ldi ZL, low(item1)   //z holds pointer to item1's inventory.
	ldi ZH, high(item1)
	ld temp1, Z
	subi temp1, -'0'
	do_lcd_data_r temp1 
	out PORTC, temp1    //since item 1 will initially have only 1 item, no conversion is needed
	
	do_lcd_command 0b10110110
	do_lcd_data '$'
	ldi ZL, low(item1Cost)
	ldi ZH, high(item1Cost)
	ld temp1, Z
	subi temp1, -'0'
	do_lcd_data_r temp1 
	pop temp1

	ldi r27,1

	rjmp adminMode


returnInventory:
	 
	push temp1
	subi temp1, '0'
	cpi temp1, 1
	breq return1
	cpi temp1, 2
	breq return2
	cpi temp1, 3
	breq return3
	cpi temp1, 4
	breq return4
	cpi temp1, 5
	breq return5
	cpi temp1, 6
	breq return6
	cpi temp1, 7
	breq return7
	cpi temp1, 8
	breq return8
	rjmp return9

	return1:
		ldi ZL, low(item1)    //inventory amount
		ldi ZH, high(item1)
		ldi YL, low(item1Cost) 	//item cost
		ldi YH, high(item1Cost)	
		ldi temp1, 0b00000001
		out PORTC, temp1
		pop temp1
		rjmp adminMode
	return2:
		ldi ZL, low(item2)   
		ldi ZH, high(item2)
		ldi YL, low(item2Cost) 	//item cost
		ldi YH, high(item2Cost)
		ldi temp1, 0b00000011
		out PORTC, temp1
		pop temp1
		rjmp adminMode
	return3:
		ldi ZL, low(item3)   
		ldi ZH, high(item3)
		ldi YL, low(item3Cost) 	//item cost
		ldi YH, high(item3Cost)
		ldi temp1, 0b00000111
		out PORTC, temp1
		pop temp1
		rjmp adminMode
	return4:
		ldi ZL, low(item4)   
		ldi ZH, high(item4)
		ldi YL, low(item4Cost) 	//item cost
		ldi YH, high(item4Cost)
		ldi temp1, 0b00001111
		out PORTC, temp1
		pop temp1
		rjmp adminMode
	return5:
		ldi ZL, low(item5)   
		ldi ZH, high(item5)
		ldi YL, low(item5Cost) 	//item cost
		ldi YH, high(item5Cost)
		ldi temp1, 0b00011111
		out PORTC, temp1
		pop temp1
		rjmp adminMode
	return6:
		ldi ZL, low(item6)   
		ldi ZH, high(item6)
		ldi YL, low(item6Cost) 	//item cost
		ldi YH, high(item6Cost)
		ldi temp1, 0b00111111
		out PORTC, temp1
		pop temp1
		rjmp adminMode
	return7:
		ldi ZL, low(item7)   
		ldi ZH, high(item7)
		ldi YL, low(item7Cost) 	//item cost
		ldi YH, high(item7Cost)
		ldi temp1, 0b01111111
		out PORTC, temp1
		pop temp1
		rjmp adminMode
	return8:
		ldi ZL, low(item8)   
		ldi ZH, high(item8)
		ldi YL, low(item8Cost) 	//item cost
		ldi YH, high(item8Cost)
		ldi temp1, 0b11111111
		out PORTC, temp1
		pop temp1
		rjmp adminMode
	return9:
		ldi ZL, low(item9)   
		ldi ZH, high(item9)
		ldi YL, low(item9Cost) 	//item cost
		ldi YH, high(item9Cost)
		pop temp1
		rjmp adminMode

	

adminMode:
	//how does the program get here?
	;rjmp returnInventory  //itll get stuck in a loop here.

	do_lcd_command 0b00000001
	do_lcd_data 'A'
	do_lcd_data 'd'
	do_lcd_data 'm'
	do_lcd_data 'i'
	do_lcd_data 'n'
	do_lcd_data ' '
	do_lcd_data 'm'
	do_lcd_data 'o'
	do_lcd_data 'd'
	do_lcd_data 'e'
	do_lcd_data ' '
	do_lcd_data_r temp1 

	do_lcd_command 0b10101000
	push temp1
	push temp2

	ld temp1, Z
	subi temp1,-'0'
	do_lcd_data_r temp1   //displays inventory of selected item
	
	do_lcd_command 0b10110110
	do_lcd_data '$'		//displays cost of selected item
	ld temp1, Y
	do_lcd_data_r temp1 
	
	pop temp2
	pop temp1

	jmp KeypadLoop   
	
	

lcd_command: ; Send a command to the LCD (r16)

	out PORTF, r16
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	lcd_clr LCD_E
	rcall sleep_1ms
	ret

lcd_data:

	out PORTF, r16
	lcd_set LCD_RS
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	lcd_clr LCD_E
	rcall sleep_1ms
	lcd_clr LCD_RS
	ret

lcd_wait:

	push r16
	clr r16
	out DDRF, r16
	out PORTF, r16
	lcd_set LCD_RW
	lcd_wait_loop:
	rcall sleep_1ms
	lcd_set LCD_E
	rcall sleep_1ms
	in r16, PINF
	lcd_clr LCD_E
	sbrc r16, 7
	rjmp lcd_wait_loop
	lcd_clr LCD_RW
	ser r16
	out DDRF, r16
	pop r16
	ret

.equ F_CPU = 16000000
.equ DELAY_1MS = F_CPU / 4 / 1000 - 4
; 4 cycles per iteration - setup/call-return overhead

sleep_1ms:
	
	push r24
	push r25
	ldi r25, high(DELAY_1MS)
	ldi r24, low(DELAY_1MS)

delayloop_1ms:
	
	sbiw r25:r24, 1
	brne delayloop_1ms
	pop r25
	pop r24
	ret

sleep_5ms:

	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	ret

sleep_20ms:

	rcall sleep_5ms
	rcall sleep_5ms
	rcall sleep_5ms
	rcall sleep_5ms
	ret

sleep_100ms:
	
	rcall sleep_20ms
	rcall sleep_20ms
	rcall sleep_20ms
	rcall sleep_20ms
	rcall sleep_20ms
	ret

sleep_250ms:
	rcall sleep_100ms
	rcall sleep_100ms
	rcall sleep_20ms
	rcall sleep_20ms
	rcall sleep_5ms
	rcall sleep_5ms
	ret
sleep_500ms:
	
	rcall sleep_100ms
	rcall sleep_100ms
	rcall sleep_100ms
	rcall sleep_100ms
	rcall sleep_100ms
	ret

sleep_1000ms:

	rcall sleep_500ms
	rcall sleep_500ms
	ret
