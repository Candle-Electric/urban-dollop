;=======================;
;      Turtle Dove      ;
; DreamDisc '24 Version ;
;=======================;

;=======================;
;  Prepare Application  ;
;=======================;
	.org	$00
	jmpf	start

	.org	$03
	reti	

	.org	$0b
	reti	
	
	.org	$13
	reti	

	.org	$1b
	jmpf	t1int
	
	.org	$23
	reti	

	.org	$2b
	reti	
	
	.org	$33
	reti	

	.org	$3b
	reti	

	.org	$43
	reti	

	.org	$4b
	clr1	p3int,0
	clr1	p3int,1
	reti

	.org	$130	
t1int:
	push	ie
	clr1	ie,7
	not1	ext,0
	jmpf	t1int
	pop	ie
	reti

	.org	$1f0

goodbye:	
	not1	ext,0
	jmpf	goodbye

;=======================;
;VMU Application Header ;
;=======================;
.include "GameHeader.i"
.org	$680
    .byte   "  Turtle Dove   "
	.byte   " DreamDisc '24: "
    .byte   "  Dedicated To  "
	.byte	"     Mr. R.     "
	.byte   " Thanks To Many "
	.byte   "   Including:   "
    .byte   " Kresna Susila, "
    .byte   "Walter Tetzner, "
    .byte   " Falco Girgis,  "
    .byte   "Dmitry Grinberg,"
    .byte   "Marcus Comstedt,"
    .byte   "Sebastian Mihai,"
    .byte   "Tyco,Trent,Speud"
    .byte   "RetroOnyx,Ian M."
    .byte   "B.Leeto,NeoGeoF,"
	.byte   "Cypress,CBarpch,"
	.byte   " And Many More. "
	.byte	" Derek (ateam), "
    .byte   "BLCARLOA,STFEAIF"
    .byte   "HBD,+M.!GBRDDRAA"

;=======================;
;   Include Libraries   ;
;=======================;
.include "./lib/libperspective.asm"
.include "./lib/libkcommon.asm"
.include "./lib/sfr.i"

;=======================;
;     Include Images    ;
;=======================;
.include		"./img/Blank_BackGround.asm"
; .include		"./img/Example_Sprite.asm"
.include		"./img/Example_Sprite_Mask.asm"
.include		"./img/Obstacle_Sprite_Mask.asm"
.include		"./img/Birdy_Sprite_Mask.asm"
.include		"./img/Birdy_Sprite_Mask_2_R.asm"
.include		"./img/Birdy_Sprite_Mask_3_R.asm"
.include		"./img/Birdy_Sprite_Mask_1_L.asm"
.include		"./img/Birdy_Sprite_Mask_2_L.asm"
.include		"./img/Birdy_Sprite_Mask_3_L.asm"
.include		"./img/Birdy_Stunned_Mask_1.asm"
.include		"./img/AllBlack.asm"
.include		"./img/AllWhite.asm"
.include		"./img/Dotted.asm"
.include		"./img/Congratulations_BackGround.asm"
.include		"./img/Title_Screen_Graphic.asm"
.include		"./img/Title_Screen_Graphic_Directive.asm"
; .include		"./img/Example_Sprite_HeroChao_Mask.asm"
; .include		"./img/ExampleBG_City.asm"
; .include		"./img/Obstacle_Sprite_Mask.asm"
; .include		"./img/Main_Menu_BG.asm"
; .include		"./img/Menu_Text_Character_1.asm"
; .include		"./img/Menu_Text_Character_1_Highlighted.asm"
; .include		"./img/Menu_Text_Character_2_Smiley.asm"
; .include		"./img/Menu_Text_Character_2_Smiley_Highlighted.asm"
; .include		"./img/Menu_Text_Character_3.asm"
; .include		"./img/Menu_Text_Character_3_Highlighted.asm"
; .include		"./img/Menu_Text_Stage_1.asm"
; .include		"./img/Menu_Text_Stage_1_Highlighted.asm"
; .include		"./img/Menu_Text_Stage_2.asm"
; .include		"./img/Menu_Text_Stage_2_Highlighted.asm"
; .include		"./img/Menu_Text_Stage_3.asm"
; .include		"./img/Menu_Text_Stage_3_Highlighted.asm"
; .include		"./img/Menu_Text_OK_Button_Start.asm"
; .include		"./img/Menu_Text_OK_Button_Start_Highlighted.asm"
; .include		"./img/Menu_Text_OK_Button_Resume.asm"
; .include		"./img/Menu_Text_OK_Button_Resume_Highlighted.asm"
; .include		"./img/Menu_Text_Welcome_Message.asm"
; .include		"./img/Menu_Text_Stage_1_City.asm"
; .include		"./img/Menu_Text_Stage_1_City_Highlighted.asm"
; .include		"./img/Menu_Text_Stage_2_Jungle.asm"
; .include		"./img/Menu_Text_Stage_2_Jungle_Highlighted.asm"
.include		"./img/Digit_0.asm"
.include		"./img/Digit_1.asm"
.include		"./img/Digit_2.asm"
.include		"./img/Digit_3.asm"
.include		"./img/Digit_4.asm"
.include		"./img/Digit_5.asm"
.include		"./img/Digit_6.asm"
.include		"./img/Digit_7.asm"
.include		"./img/Digit_8.asm"
.include		"./img/Digit_9.asm"

;=======================;
;  Include  Code Files  ;
;=======================;
.include		"./src/Gameplay.asm"
.include		"./src/Title_Screen.asm"

;=======================;
;   Define Variables:   ;
;=======================;
p3_pressed				=		$4	; 1 Byte (For LibKCommon)
p3_last_input			=		$5	; 1 Byte (For LibKCommon)
; character_flags			=		$17	; 1 Byte
; stage_flags				=		$18	; 1 Byte

;=======================;
; Initialize Variables: ;
;=======================;
; mov #0, character_flags
; mov #0, stage_flags

;=======================;
;       Constants       ;
;=======================;
T_BTN_SLEEP				equ		7
T_BTN_MODE				equ		6
T_BTN_B1				equ		5
T_BTN_A1				equ		4
T_BTN_RIGHT1			equ		3
T_BTN_LEFT1				equ		2
T_BTN_DOWN1				equ		1
T_BTN_UP1				equ		0

;=======================;
;     Main Program      ;
;=======================;
start:
	clr1 ie,7
	mov #$a1,ocr
	mov #$09,mcr
	mov #$80,vccr
	clr1 p3int,0
	clr1 p1,7
	mov #$ff,p3
	set1 ie,7

Main_Loop:
	callf	Title_Screen ; callf	Main_Menu
	callf	Runner_Gameplay
	jmpf Main_Loop

	.cnop	0,$200		; Pad To An Even Number Of Blocks
