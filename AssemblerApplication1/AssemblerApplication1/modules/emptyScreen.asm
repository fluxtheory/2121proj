
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

 ser temp1                ; alternates flashing for 3 seconds.
 out PORTC, temp1
 ldi temp1, TopLED
 ori temp1, SecondLED
 out PORTG, temp1
 
 rcall sleep_500ms       ; alternates flashing for 3 seconds.
 clr temp1
 out PORTC, temp1
 out PORTG, temp1
 
 rcall sleep_500ms        ; alternates flashing for 3 seconds.
 ser temp1
 out PORTC, temp1
 ldi temp1, TopLED
 ori temp1, SecondLED
 out PORTG, temp1
 
 rcall sleep_500ms        ; alternates flashing for 3 seconds.
 clr temp1
 out PORTC, temp1
 out PORTG, temp1

 rcall sleep_500ms        ; alternates flashing for 3 seconds.
 ser temp1
 out PORTC, temp1
 ldi temp1, TopLED
 ori temp1, SecondLED
 out PORTG, temp1

 rcall sleep_500ms         ; alternates flashing for 3 seconds.
 clr temp1
 out PORTC, temp1
 out PORTG, temp1
 
 rcall sleep_500ms
 
 
 rjmp displaySelectScreen2
