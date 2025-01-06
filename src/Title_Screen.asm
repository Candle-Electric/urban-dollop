Title_Screen:

B_Button_Presses = $9  ; 1 Byte
Title_Timer		 = $10 ; 1 Byte
mov #0, B_Button_Presses
mov #0, Title_Timer

.main_title_loop
	inc Title_Timer
	callf	Get_Input
	mov #Button_B, acc
	callf Check_Button_Pressed
	bn acc, 5, .Check_A
	inc B_Button_Presses
.Check_A	
	ld p3
	bn acc, T_BTN_A1, .Check_B
	jmpf .Not_B
.Check_B		
	; ld p3
	bp acc, T_BTN_B1, .Not_B
	ret
.Not_B
	ld B_Button_Presses
	sub #23
	bz .draw_old_title_screen
	add #23
	sub #96
	bz .draw_old_title_screen
.Title_Frame_1	
	bp title_timer, 6, .Title_Frame_2
	P_Draw_Background_Constant Title_Screen_Graphic
.Title_Frame_2
	bn title_timer, 6, .Draw_Title_Screen
	P_Draw_Background_Constant Title_Screen_Graphic_Directive
.Draw_Title_Screen
	P_Blit_Screen
	jmp .main_title_loop
.draw_old_title_screen
	; P_Draw_Background_Constant MPG_TSBG ; Show The Original + Place-Holder Title Screen, As An Easter Egg. :-)
	P_Blit_Screen
	jmp .main_title_loop
	