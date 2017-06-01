;admin mode
;
;


.macro LEDcount   ;a macro that transforms decimal to number of LED blocks.
	push @0
	push temp2
	push temp3
	clr temp2
	out PORTG, temp2

	cpi @0, 10   ;if the item has 10 in inventory, we want the top 2 orange-red LEDs to be on.
	breq TWO
	cpi @0, 9    ; if it has only 9, then only the orange one.
	breq ONE
	rjmp mainloop

	TWO:
		
		ldi temp3, TopLED
		ori temp3, SecondLED
		out PORTG, temp3
		rjmp mainloop

	ONE:
		ldi temp3, SecondLED
		out PORTG, temp3

	mainloop:
	cpi @0, 0
	breq endmacro

	lsl temp2
	ori temp2, 0b00000001
	
	dec @0

	rjmp mainloop
	endmacro:

	out PORTC, temp2




	pop temp3
	pop temp2
	pop @0
.endmacro

adminModeInitial:    ;the default screen for admin mode always displays the information for item1

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
	;displaying inventory
	push temp1
	ldi ZL, low(item1)   //z holds pointer to item1's inventory. 
	ldi ZH, high(item1)
	ld temp1, Z
	
	LEDcount temp1

	subi temp1, -'0'
	do_lcd_data_r temp1 
	//out PORTC, temp1    //since item 1 will initially have only 1 item, no conversion is needed
	
	;displaying cost
	do_lcd_command 0b10110110
	do_lcd_data '$'
	ldi ZL, low(item1Cost)
	ldi ZH, high(item1Cost)
	ld temp1, Z
	subi temp1, -'0'
	do_lcd_data_r temp1 
	pop temp1


	ldi temp4, 1
	ldi r27,1
	ldi flag1,1

	rjmp KeypadLoop



returnInventory:  ;this function stores the inventory and cost information for the selected item in registers Y and Z
	 
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
		;ldi temp1, 0b00000001
		;out PORTC, temp1
		pop temp1
		ret
	return2:
		ldi ZL, low(item2)   
		ldi ZH, high(item2)
		ldi YL, low(item2Cost) 	//item cost
		ldi YH, high(item2Cost)
		;ldi temp1, 0b00000011
		;out PORTC, temp1
		pop temp1
		ret
	return3:
		ldi ZL, low(item3)   
		ldi ZH, high(item3)
		ldi YL, low(item3Cost) 	//item cost
		ldi YH, high(item3Cost)
		;ldi temp1, 0b00000111
		;out PORTC, temp1
		pop temp1
		ret
	return4:
		ldi ZL, low(item4)   
		ldi ZH, high(item4)
		ldi YL, low(item4Cost) 	//item cost
		ldi YH, high(item4Cost)
		;ldi temp1, 0b00001111
		;out PORTC, temp1
		pop temp1
		ret
	return5:
		ldi ZL, low(item5)   
		ldi ZH, high(item5)
		ldi YL, low(item5Cost) 	//item cost
 		ldi YH, high(item5Cost)
 		;ldi temp1, 0b00011111
 		;out PORTC, temp1
 		pop temp1
 		ret
 	return6:
 		ldi ZL, low(item6) 
 		ldi ZH, high(item6)
 		ldi YL, low(item6Cost) 	//item cost
 		ldi YH, high(item6Cost)
 		;ldi temp1, 0b00111111
 		;out PORTC, temp1
 		pop temp1
 		ret
 	return7:
 		ldi ZL, low(item7) 
 		ldi ZH, high(item7)
 		ldi YL, low(item7Cost) 	//item cost
 		ldi YH, high(item7Cost)
 		;ldi temp1, 0b01111111
 		;out PORTC, temp1
 		pop temp1
 		ret
	 return8:
		ldi ZL, low(item8) 
 		ldi ZH, high(item8)
 		ldi YL, low(item8Cost) 	//item cost
 		ldi YH, high(item8Cost)
 		;ldi temp1, 0b11111111
 		;out PORTC, temp1
 		pop temp1
 		ret
 	return9:
 		ldi ZL, low(item9) 
 		ldi ZH, high(item9)
 		ldi YL, low(item9Cost) 	//item cost
 		ldi YH, high(item9Cost)
 		pop temp1
 		ret

 
adminMode:
 

 rcall sleep_100ms
 

 push temp1
 rcall returnInventory  

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
 pop temp1
 
 mov temp4, temp1
 subi temp4, '0'

 do_lcd_data_r temp1 

 do_lcd_command 0b10101000

 ld temp1, Z

 LEDcount temp1

 subi temp1,-'0'

 do_lcd_data_r temp1   //displays inventory of selected item
 
 do_lcd_command 0b10110110
 do_lcd_data '$'		//displays cost of selected item
 ld temp1, Y
 subi temp1,-'0'
 do_lcd_data_r temp1 


 ret 
 
