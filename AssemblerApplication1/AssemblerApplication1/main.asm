.include "m2560def.inc"

.include "modules/lcdmacros.asm"

.dseg

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


.equ TopLED = 0b00000010
.equ SecondLED = 0b00000001
.equ PORTADIR = 0xF0 ; PD7-4: output, PD3-0, input
.equ INITCOLMASK = 0xEF ; scan from the rightmost column,
.equ INITROWMASK = 0x01 ; scan from the top row
.equ ROWMASK = 0x0F ; for obtaining input from Port D



.org 0x0000
   jmp Main;          

 .org INT0addr     //for push button
jmp EXT_INT0

 .org INT1addr     //for push button
jmp EXT_INT1

.org OVF1addr
jmp Timer1


.org OVF0addr
jmp Timer0


jmp DEFAULT        
DEFAULT:  reti 

EXT_INT0:
	
	push temp1
	in temp1, SREG
	push temp1

	cpi r27, 1
	brne End
	
	mov temp1, temp4
	subi temp1,-'0'
	
	rcall returnInventory

	ld temp1, Z
	cpi temp1, 10
	breq End

	inc temp1
	st Z, temp1

	rcall sleep_250ms
	
	mov temp1, temp4
	subi temp1, -'0'
	rcall adminMode


	End:
	pop temp1
	out SREG, temp1
	pop temp1

	reti

EXT_INT1:
	
	push temp1
	in temp1, SREG
	push temp1

	
	cpi r27, 1
	brne End2

	mov temp1, temp4
	subi temp1,-'0'

	rcall returnInventory

	ld temp1, Z
	cpi temp1,0
	breq End2

	dec temp1
	st Z, temp1

	rcall sleep_250ms
	mov temp1, temp4
	subi temp1, -'0'
	rcall adminMode
	
	End2:
	pop temp1
	out SREG, temp1
	pop temp1
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
	out DDRG, temp1


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


.include "modules/keypad.asm"

Adminjmp:
	rcall adminMode
	rjmp KeypadLoop

zero:

	ldi temp1, '0' ; Set to zero

convert_end:

	;out PORTC, temp1 ; Write value to PORTC
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

	ldi flag1,1

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

	

	inc timerCounter


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

	inc timerCounter

	
	;out PORTC, TimerCounter
	
	cpi timerCounter, 25
	brlo Finish
		
	;ldi temp1, 0b11110000
	;out PORTC, temp1

	ldi r26,1
	clr temp3
	sts TIMSK1, temp3

	clr timerCounter

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

	clr timerCounter

	;ldi temp1, 0b11111111
	;out PORTC, temp1

	pop temp1
	out SREG, temp1
	pop temp2
	pop temp1
	pop rmask
	pop cmask
	
	reti

displaySelectScreen:

	clr timerCounter
	clr flag1

	clr r18 
	sts TIMSK0, r18 ; turn off timer.

	do_lcd_command 0b00000001
 ; clear display
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

.include "modules/emptyScreen.asm"


displaySelectScreen2:

clr temp1
out PORTC, temp1
out PORTG, temp1

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


.include "modules/coinInsert.asm"
 
.include "modules/deliverItem.asm"

.include "modules/admin.asm"
 
.include "modules/lcd.asm"

.include "modules/sleep.asm"
