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

.cseg

.org 0x0000
   jmp Main;
   jmp DEFAULT          ; No handling for IRQ0.
   jmp DEFAULT


.org OVF0addr
jmp MyISRHandler

jmp DEFAULT        
DEFAULT:  reti 


Main:

clr r17
clr r18
clr r19
clr r20
clr r21
clr r22
clr r23

ser r16
out DDRC, r16

ldi r16, low(RAMEND)
out SPL, r16
ldi r16, high(RAMEND)
out SPH, r16

ser r16
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

ldi r18, 0b00000000 ;Timer setup
out TCCR0A, r18
ldi r18, 0b00000101   
out TCCR0B, r18
ldi r18, 1<<TOIE0
sts TIMSK0, r18
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

halt:
rjmp halt




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


MyISRHandler: ;Timer overflow 0

reti

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