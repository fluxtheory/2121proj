

DeliverScreen:
 ;cli  //disable all input related interrupts during this time.
 
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

 rcall sleep_1000ms   ;spin motors for 3 seconds.
 rcall sleep_1000ms
 rcall sleep_1000ms

 clr temp1					; stops motors
 sts OCR3AH, temp1
 sts OCR3AL, temp1

 rjmp displaySelectScreen2  ;jump back to select screen.


 
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
 ld temp1, Z
 
 
 dec temp1
 //out PORTC, temp1
 st Z, temp1

 ret
 decrement2:
 
 ldi ZL, low(item2)
 ldi ZH, high(item2)
 ld temp1, Z
 
 //out PORTC, temp1
 
 dec temp1
 st Z, temp1
 ret
 
 decrement3:
 
 ldi ZL, low(item3)
 ldi ZH, high(item3)
 
 ld temp1, Z
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
