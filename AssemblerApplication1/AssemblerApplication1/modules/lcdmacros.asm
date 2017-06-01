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
