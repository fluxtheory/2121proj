
CoinScreen:  ; display screen
 
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

 

 .macro HashLoop   ; a modified version of keypad loop that ONLY listens for the '#' character. Nothing else.

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

InsertCoin:    ;coin screen that handles coin insertion.
 
 pop temp1

 rcall ReturnInventory
 ld temp2,Y

 push temp1

 clr temp4
 clr temp3
 out PORTC, temp3
 do_lcd_command 0b10101000
 
 mov temp1,temp2
 subi temp1,-'0'
 do_lcd_data_r temp1

 FirstZeroLoop:  ;listens for coin or hashkey inputs
 push temp1
 push temp2

 HashLoop Loop2c
 Loop2c:

 pop temp2 
 pop temp1 

 lds temp1, PINK
 andi temp1, 0b00000001
 

 cpi temp1, 0
 brne FirstZeroLoop  ; if no input is received, go back and listen again.
 rjmp SecondOneLoop ; if there is a coin inserted go to the second loop

 SecondOneLoop:  ;one coin has been inserted, listening for second coin or for abort instruction

 lds temp1, PINK
 
 push temp1
 push temp2

 HashLoop Loopc
 Loopc:
 
 pop temp2 
 pop temp1 

 andi temp1, 0b00000001
 cpi temp1, 1
 brne SecondOneLoop  ; no further input received, re-entering loop.
 rjmp ThirdZeroLoop  ; otherwise, enter third loop.

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
 
 ThirdZeroLoop: ; much like the first two loops, listens for input, but this time sends them to delivery screen.

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
