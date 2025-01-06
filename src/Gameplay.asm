;=======================;
;       Gameplay        ;
;=======================;
Runner_Gameplay:
	player_sprite_x					=		$6		; 1 Byte
	player_sprite_y					=		$7		; 1 Byte
	player_sprite_sprite_address	=		$8		; 2 Bytes
	player_acceleration				=		$11 	; 1 Byre
	frame_counter 					=		$10 	; 1 Byte
	digit_sprite_address_m			=		$c		; 2 Bytes
	digit_sprite_address_p			=		$e		; 2 Bytes
	digit_sprite_address_temp		=		$1e		; 2 Bytes
	score_low						=		$13		; 1 Byte
	score_high						=		$14		; 1 Byte
	player_height 					=		$15		; 1 Byte
	player_height_high				=		$16		; 1 Byte
	line_offset						=		$17		; 1 Byte
	ones_digit						=		$18		; 1 Byte
	tens_digit						=		$19		; 1 Byte
	digit_temp						=		$1a		; 1 Byte
	vrmad1var						=		$1b
	fc								=		$1c		; 1 Byte
	obstacle_sprite_x				=		$2d		; 1 Byte
	obstacle_sprite_y				=		$2e		; 1 Byte
	obstacle_sprite_address			=		$2f		; 2 Bytes
	obstacle_direction				=		$31		; 1 Byte
	obstacle2_sprite_x				=		$32		; 1 Byte
	obstacle2_sprite_y				=		$33		; 1 Byte
	obstacle2_sprite_address		=		$34		; 2 Bytes
	obstacle2_speed					=		$36		; 1 Byte
	seventh_bit_previous			=		$37		; 1 Byte
	congratulations_bool			=		$38		; 1 Byte
	game_timer_low					=		$39		; 1 Byte
	game_timer_high					=		$3a		; 1 Byte
	game_timer_127_bool				=		$3b		; 1 Byte
	player_stunned_bool				=		$3c		; 1 Byte
	collision_flags					=		$3d		; 1 Byte
	stun_timer						=		$3e		; 1 Byte
	hundreds_digit					=		$3f		; 1 Byte
	thousands_digit					=		$40     ; 1 Byte
	tenthousands_digit				=		$41     ; 1 Byte
	player_direction				=		$42		; 1 Byte
	backtotitle_timer				=		$43		; 1 Byte

; Set Sprite Addresses
	mov	#20, player_sprite_x
	mov	#14, player_sprite_y
.Draw_Example_Character
	mov	#<Birdy_Sprite_Mask, player_sprite_sprite_address
	mov	#>Birdy_Sprite_Mask, player_sprite_sprite_address+1
; Set Values
	mov #0, player_acceleration
	mov #0, frame_counter
	mov #0, player_height
	mov #0, line_offset
	mov #0, vrmad1var
	mov #0, fc
	mov #0, obstacle_sprite_x
	mov #0, obstacle_sprite_y
	mov #<Obstacle_Sprite_Mask, obstacle_sprite_address
	mov #>Obstacle_Sprite_Mask, obstacle_sprite_address+1
	mov #23, obstacle2_sprite_x
	mov #0, obstacle2_sprite_y
	mov #<Obstacle_Sprite_Mask, obstacle2_sprite_address
	mov #>Obstacle_Sprite_Mask, obstacle2_sprite_address+1
	mov #2, obstacle_direction
	mov #2, obstacle2_speed
	mov #0, seventh_bit_previous
	mov #0, congratulations_bool
	mov #0, game_timer_low
	mov #0, game_timer_high
	mov #0, game_timer_127_bool
	mov #0, player_stunned_bool
	mov #128, backtotitle_timer
	mov #0, score_high
	mov #0, score_low
Gameplay_Loop:
.Check_For_Game_Over
	bp score_high, 7, .Continue_Playing
	bn score_high, 1, .Continue_Playing
	mov #1, congratulations_bool
	P_Draw_Background_Constant Congratulations_BackGround
	callf Draw_Final_Time
	ld backtotitle_timer
	bz .Allow_Input_On_Congratulations_Screen
	dec backtotitle_timer
	jmpf .Blit_And_Draw_Screen
.Allow_Input_On_Congratulations_Screen	
	callf Get_Input
	ld p3
	bn acc, T_BTN_A1, .ReturnToTitle
	bn acc, T_BTN_B1, .ReturnToTitle
	jmpf .Blit_And_Draw_Screen ; .Skip_Debugging_Graphics
.ReturnToTitle	
	ret
.Continue_Playing
	callf Tick_Timer
.Check_Input
	ld stun_timer
	bnz .A_Depressed
	callf Get_Input ; This Function Is Via LibKCommon.ASM
	ld p3
.Check_Up
	ld p3
	bp acc, T_BTN_UP1, .Check_Down
	; inc score_low ; player_height
.Check_Down
	ld p3
	bp acc, T_BTN_DOWN1, .Check_Left
	; dec score_low ; player_height
.Check_Left
	ld p3
	bp acc, T_BTN_LEFT1, .Check_Right
	; dec vrmad1var
	ld player_sprite_x
	sub #2
	bp acc, 7, .Check_Right
	dec player_sprite_x
	mov #0, player_direction
.Check_Right
	ld p3
	bp acc, T_BTN_RIGHT1, .Check_Buttons
	; inc vrmad1var
	ld player_sprite_x
	sub #40
	bn acc, 7, .Check_Buttons
	inc player_sprite_x
	mov #1, player_direction
.Check_Buttons
	mov #Button_A, acc
	callf 	Check_Button_Pressed
	bn 	acc, 4, .A_Depressed
.A_Pressed
	ld player_acceleration
	sub #2
	bz .A_Depressed ; Cap Upward Acceleration At "3"
	inc player_acceleration
	mov #2, frame_counter
	jmpf .Calculate_Position
.A_Depressed
	bn frame_counter, 3, .B_Pressed
	ld player_acceleration
	add #2
	bp acc, 7, .B_Pressed ; Cap Downward Acceleration At "-2"
	dec player_acceleration
.B_Pressed
	mov #Button_B, acc
	callf 	Check_Button_Pressed
	bn 	acc, 5, .B_Depressed
	; mov #0, vrmad1var
	ld player_acceleration
	sub #2
	bz .B_Depressed ; Cap Upward Acceleration At "3"
	inc player_acceleration
	mov #2, frame_counter
.B_Depressed
	bn frame_counter, 3, .Calculate_Position
	ld player_acceleration
	add #2
	bp acc, 7, .Calculate_Position ; Cap Downward Acceleration At "-2"
	dec player_acceleration
.Calculate_Position
.Set_Previous_Seventh_Bit
.Seventh_Was_Set
	bn score_low, 7, .Seventh_Was_Cleared
	mov #1, seventh_bit_previous
	jmpf .Check_Ground
.Seventh_Was_Cleared
	bp score_low, 7, .Check_Ground
	mov #0, seventh_bit_previous
.Check_Ground
	ld player_height
	add player_acceleration
	st player_height
	st score_low
	callf Handle_16Bit_Score
	bn score_high, 7, .Skip_Grounded
	mov #0, player_acceleration
	mov #0, player_height
	mov #0, score_low
	mov #0, score_high
.Skip_Grounded
.Move_Obstacle_1_Left
	bp obstacle_direction, 0, .Move_Obstacle_1_Right
	dec obstacle_sprite_x
	ld obstacle_sprite_x
	sub #1
	bn acc, 7, .Move_Obstacle_1_Y
	set1 obstacle_direction, 0
	jmpf .Move_Obstacle_1_Y
.Move_Obstacle_1_Right
	bn obstacle_direction, 0, .Move_Obstacle_1_Y
	inc obstacle_sprite_x
	ld obstacle_sprite_x
	sub #43; sub #11 ; add #5
	bp acc, 7, .Move_Obstacle_1_Y
	clr1 obstacle_direction, 0
.Move_Obstacle_1_Y
	ld player_height
	st obstacle_sprite_y
	clr1 obstacle_sprite_y, 7
	clr1 obstacle_sprite_y, 6
	clr1 obstacle_sprite_y, 5
.Move_Obstacle_2_Left
	bp obstacle_direction, 1, .Move_Obstacle_2_Right
	ld obstacle2_sprite_x
	sub #2
	st obstacle2_sprite_x
	sub #3
	bn acc, 7, .Move_Obstacle_2_Y
	set1 obstacle_direction, 1
	jmpf .Move_Obstacle_2_Y
.Move_Obstacle_2_Right
	bn obstacle_direction, 1, .Move_Obstacle_2_Y
	ld obstacle2_sprite_x
	add #2
	st obstacle2_sprite_x
	sub #43
	bp acc, 7, .Move_Obstacle_2_Y
	clr1 obstacle_direction, 1
.Move_Obstacle_2_Y
	ld obstacle_sprite_y
	add #16
	st obstacle2_sprite_y
	bn obstacle2_sprite_y, 5, .Check_Collision
	sub #32 ; Move Obstacle #2 Back In-Bounds Of The Screen
	st obstacle2_sprite_y
.Check_Collision
	; ld stun_timer
	; bnz .Collision_Done
	mov #1, player_stunned_bool
.Check_Obstacle_1_Collision
.Check_O1_Up
	ld obstacle_sprite_y
	sub #10
	bn acc, 7, .Check_O1_Down
	jmpf .Check_Obstacle_2_Collision
.Check_O1_Down
	ld obstacle_sprite_y
	sub #18
	bp acc, 7, .Check_O1_Left ; .Check_Sides
	jmpf .Check_Obstacle_2_Collision
.Check_O1_Left

;ld test_sprite_x
;		sub obstacle_sprite_x
;		add #5 ; obstacle_size_x
;		bp acc, 7, .Collision_Done
;.Check_Right_Collision
;		ld obstacle_sprite_x
;		add #8
;		sub test_sprite_x
;		bp acc, 7, .Collision_Done
;		set1 collision_flags, 1		; Set The Collision Flag

	ld player_sprite_x
	sub obstacle_sprite_x
	add #2 ; obstacle_size_x
	bp acc, 7, .Check_Obstacle_2_Collision ; .Check_O1_Right
	; jmpf .Check_Obstacle_2_Collision
.Check_O1_Right
	ld obstacle_sprite_x
	add #4
	sub player_sprite_x
	bp acc, 7, .Check_Obstacle_2_Collision ; .Collision_Done
	mov #0, player_stunned_bool ; Set The Collision Flag
	mov #10, stun_timer
.Check_Obstacle_2_Collision
	ld score_high
	bz .Check_O2_Ground_Skip
	jmpf .Check_O2_Up
.Check_O2_Ground_Skip
	ld player_height
	bz .Skip_O2_Collision_On_Ground
	sub #1
	bz .Skip_O2_Collision_On_Ground
	sub #1
	bz .Skip_O2_Collision_On_Ground
	sub #1
	bz .Skip_O2_Collision_On_Ground
	sub #1
	bz .Skip_O2_Collision_On_Ground
	sub #1
	bz .Skip_O2_Collision_On_Ground
	sub #1
	bz .Skip_O2_Collision_On_Ground
	sub #1
	bz .Skip_O2_Collision_On_Ground
	jmpf .Check_O2_Up
.Skip_O2_Collision_On_Ground
	jmpf .Collision_Done
.Check_O2_Up
	ld obstacle2_sprite_y
	sub #10
	bn acc, 7, .Check_O2_Down
	jmpf .Collision_Done
.Check_O2_Down
	ld obstacle2_sprite_y
	sub #18
	bp acc, 7, .Check_O2_Left ; .Check_Sides
	jmpf .Collision_Done
.Check_O2_Left

;ld test_sprite_x
;		sub obstacle_sprite_x
;		add #5 ; obstacle_size_x
;		bp acc, 7, .Collision_Done
;.Check_Right_Collision
;		ld obstacle_sprite_x
;		add #8
;		sub test_sprite_x
;		bp acc, 7, .Collision_Done
;		set1 collision_flags, 1		; Set The Collision Flag

	ld player_sprite_x
	sub obstacle2_sprite_x
	add #2 ; obstacle_size_x
	bp acc, 7, .Collision_Done ; .Check_O1_Right
	; jmpf .Check_Obstacle_2_Collision
.Check_O2_Right
	ld obstacle2_sprite_x
	add #4
	sub player_sprite_x
	bp acc, 7, .Collision_Done
	mov #0, player_stunned_bool ; Set The Collision Flag
	mov #10, stun_timer

.Collision_Done

.Handle_Stun_Timer
	; bp player_stunned_bool, 0, .Draw_Screen
	ld stun_timer
	bz .Reset_Stun ; bp player_stunned_bool, 0, .Draw_Screen
	dec stun_timer
	; bn stun_timer, 0, .Draw_Screen
	ld stun_timer
	bp acc, 7, .Reset_Stun
	jmpf .Draw_Screen
.Reset_Stun
	mov #1, player_stunned_bool
	mov #0, stun_timer
.Draw_Screen
	P_Draw_Background_Constant Blank_Background
.Draw_Lines
	callf Draw_Lines
	inc fc
	ld fc
	sub #4
	bp acc, 7, .Draw_Characters
	mov #0, fc
.Draw_Characters
.Draw_Test_Obstacle
	P_Draw_Sprite_Mask obstacle_sprite_address, obstacle_sprite_x, obstacle_sprite_y
.Check_If_Skipping_O2_Draw_On_Ground
	ld score_high
	bz .Check_O2_Ground_Draw
	jmpf .Draw_Obstacle_2
.Check_O2_Ground_Draw
	ld player_height
	bz .Draw_Player
	sub #1
	bz .Draw_Player
	sub #1
	bz .Draw_Player
	sub #1
	bz .Draw_Player
	sub #1
	bz .Draw_Player
	sub #1
	bz .Draw_Player
	sub #1
	bz .Draw_Player
	sub #1
	bz .Draw_Player
	sub #1
	bz .Draw_Player
	sub #1
	bz .Draw_Player
	sub #1
	bz .Draw_Player
	sub #1
	bz .Draw_Player
	sub #1
	bz .Draw_Player
.Draw_Obstacle_2	
	P_Draw_Sprite_Mask obstacle2_sprite_address, obstacle2_sprite_x, obstacle2_sprite_y
.Draw_Player
.Stunned
	ld stun_timer
	bz .Frame1_L
	mov #<Birdy_Stunned_Mask_1, player_sprite_sprite_address
	mov #>Birdy_Stunned_Mask_1, player_sprite_sprite_address+1
	jmpf .Frame_Decided
.Frame1_L
	ld player_direction
	bnz .Frame1_R
	bn fc, 1, .Frame2_L
	mov	#<Birdy_Sprite_Mask_1_L, player_sprite_sprite_address
	mov	#>Birdy_Sprite_Mask_1_L, player_sprite_sprite_address+1
	jmpf .Frame_Decided
.Frame2_L
	bn fc, 0, .Frame3_L
	mov	#<Birdy_Sprite_Mask_2_L, player_sprite_sprite_address
	mov	#>Birdy_Sprite_Mask_2_L, player_sprite_sprite_address+1
	jmpf .Frame_Decided
.Frame3_L
	bp fc, 0, .Frame_Decided
	mov	#<Birdy_Sprite_Mask_3_L, player_sprite_sprite_address
	mov	#>Birdy_Sprite_Mask_3_L, player_sprite_sprite_address+1
	jmpf .Frame_Decided
.Frame1_R
	ld player_direction
	bz .Frame_Decided
	bn fc, 1, .Frame2_R
	mov	#<Birdy_Sprite_Mask, player_sprite_sprite_address
	mov	#>Birdy_Sprite_Mask, player_sprite_sprite_address+1
	jmpf .Frame_Decided
.Frame2_R
	bn fc, 0, .Frame3_R
	mov	#<Birdy_Sprite_Mask_2_R, player_sprite_sprite_address
	mov	#>Birdy_Sprite_Mask_2_R, player_sprite_sprite_address+1
	jmpf .Frame_Decided
.Frame3_R
	bp fc, 0, .Frame_Decided
	mov	#<Birdy_Sprite_Mask_3_R, player_sprite_sprite_address
	mov	#>Birdy_Sprite_Mask_3_R, player_sprite_sprite_address+1
.Frame_Decided
	P_Draw_Sprite_Mask player_sprite_sprite_address, player_sprite_x, player_sprite_y
.Draw_Debugging_Info
	; callf Draw_Debugging_Info
.Skip_Debugging_Graphics	

; .we_stunned
; 	ld player_stunned_bool
; 	bnz .we_not_stunned
; 	mov #0, b
; 	mov #0, c
; 	P_Draw_Sprite_Mask player_sprite_sprite_address, b, c
; .we_not_stunned
.Blit_And_Draw_Screen
	; callf Draw_Ground
	P_Blit_Screen
	inc frame_counter
	jmpf Gameplay_Loop
	
random:
	; ld test_sprite_x
	; XOR frame_counter
	; st dropping_obstacle_x ; obstacle_sprite_x
	ret

Draw_Digit: ; c = the Number
.Digit_0  
	ld c
	bnz .Digit_1
	mov #<Digit_0, digit_sprite_address_temp
	mov #>Digit_0, digit_sprite_address_temp+1
	jmpf .Digit_Decided
.Digit_1
	ld c
	sub #1
	bnz .Digit_2
	mov #<Digit_1, digit_sprite_address_temp
	mov #>Digit_1, digit_sprite_address_temp+1
	jmpf .Digit_Decided
.Digit_2
	ld c
	sub #2
	bnz .Digit_3
	mov #<Digit_2, digit_sprite_address_temp
	mov #>Digit_2, digit_sprite_address_temp+1
	jmpf .Digit_Decided
.Digit_3
	ld c
	sub #3
	bnz .Digit_4
	mov #<Digit_3, digit_sprite_address_temp
	mov #>Digit_3, digit_sprite_address_temp+1
	jmpf .Digit_Decided
.Digit_4
	ld c
	sub #4
	bnz .Digit_5
	mov #<Digit_4, digit_sprite_address_temp
	mov #>Digit_4, digit_sprite_address_temp+1
	jmpf .Digit_Decided
.Digit_5
	ld c
	sub #5
	bnz .Digit_6
	mov #<Digit_5, digit_sprite_address_temp
	mov #>Digit_5, digit_sprite_address_temp+1
	jmpf .Digit_Decided
.Digit_6
	ld c
	sub #6
	bnz .Digit_7
	mov #<Digit_6, digit_sprite_address_temp
	mov #>Digit_6, digit_sprite_address_temp+1
	jmpf .Digit_Decided
.Digit_7
	ld c
	sub #7
	bnz .Digit_8
	mov #<Digit_7, digit_sprite_address_temp
	mov #>Digit_7, digit_sprite_address_temp+1
	jmpf .Digit_Decided
.Digit_8
	ld c
	sub #8
	bnz .Digit_9
	mov #<Digit_8, digit_sprite_address_temp
	mov #>Digit_8, digit_sprite_address_temp+1
	jmpf .Digit_Decided
.Digit_9
	ld c
	sub #9
	bnz .Digit_Decided
	mov #<Digit_9, digit_sprite_address_temp
	mov #>Digit_9, digit_sprite_address_temp+1
	jmpf .Digit_Decided
.Digit_Decided
	ret
	
; 	
%macro Draw_Score
; 	mov #16, b
; 	ld ones_digit
; 	st c
; 	callf Draw_Digit
; 	mov #24, b
; 	ld tens_digit
; 	st c
; 	callf Draw_Digit
; 	mov #32, b
; 	ld hundreds_digit
; 	st c
; 	callf Draw_Digit
; 	mov #40, b
; 	ld thousands_digit
; 	st c
; 	callf Draw_Digit
%end	

%macro  P_Draw_Horizontal_Line %ypos, %bgaddr
        callf    _P_Draw_Horizontal_Line
%end

_P_Draw_Horizontal_Line:
        clr1    ocr, 5
        ; Prepare the frame buffer address
        ; mov     #P_WRAM_BANK, vrmad2
        ; mov     #P_WRAM_ADDR, vrmad1
        ; mov     #%00010000, vsel ; Make this 0 for interesting. First Chunk or so is Filled?
        ; mov #31, c ; ld      c
.loopabc
        ld  c
        ldc
        st      vtrbf
        inc     c
        ld      c
        sub b
        bnz .loopabc ; dec vrmad1var
        set1    ocr, 5
        ret		
		
Draw_Lines:
	ld player_height
	st c
	mov #0, acc
	mov #10, b
	div
	ld b
	st line_offset
	add line_offset
	add line_offset
	add line_offset
	add line_offset
	add line_offset
	; add vrmad1var
	st vrmad1
	mov     #<AllBlack, trl
	mov     #>AllBlack, trh
	mov #0, c
	mov #6, b
	P_Draw_Horizontal_Line b, c	
.Line2	
	ld line_offset
	add #10
	st b
	clr1    ocr, 5
	mov #<AllWhite, trl
	mov #>AllWhite, trh
.loopLine2
	ld  c
	ldc
	st      vtrbf
	inc     c
	ld      c
	; sub vrmad1var
	sub #12
	bnz .loopLine2
	set1    ocr, 5
	ld vrmad1
	add #48
	st vrmad1
	mov     #<AllBlack, trl
	mov     #>AllBlack, trh
	mov #0, c
	mov #6, b ; b / 6 = Thickenss
	P_Draw_Horizontal_Line b, c
.Line3
	ld line_offset
	add #20
	st b
	clr1    ocr, 5
	mov #<AllWhite, trl
	mov #>AllWhite, trh
.loopLine3
	ld  c
	ldc
	st      vtrbf
	inc     c
	ld      c
	sub #12
	bnz .loopLine3
	set1    ocr, 5
	ld vrmad1
	add #48
	st vrmad1
.Choose_Line3_Graphic
	ld score_high
	bnz .Line3_Solid
.Line3_DottedGroundTexture
	ld player_height
	bz .Line3_GroundTexture
	sub #1
	bz .Line3_GroundTexture
	sub #1
	bz .Line3_GroundTexture
	sub #1
	bz .Line3_GroundTexture
	sub #1
	bz .Line3_GroundTexture
	sub #1
	bz .Line3_GroundTexture
	sub #1
	bz .Line3_GroundTexture
	sub #1
	bz .Line3_GroundTexture
	sub #1
	bz .Line3_GroundTexture
	jmpf .Line3_Solid
.Line3_GroundTexture	
	mov     #<Dotted, trl
	mov     #>Dotted, trh
	mov #0, c
	jmpf .Choose_Line3_Style	
.Line3_Solid	
	mov     #<AllBlack, trl
	mov     #>AllBlack, trh
	mov #0, c
.Choose_Line3_Style	
	ld score_high
	bnz .Draw_Regular_Line3
	ld player_height
	bz .Draw_Ground_Line3
	sub #1
	bz .Draw_Ground_Line3
	sub #1
	bz .Draw_Ground_Line3
	sub #1
	bz .Draw_Ground_Line3
	sub #1
	bz .Draw_Ground_Line3
	sub #1
	bz .Draw_Ground_Line3
	sub #1
	bz .Draw_Ground_Line3
	sub #1
	bz .Draw_Ground_Line3
	sub #1
	bz .Draw_Ground_Line3
	sub #1
	bz .Draw_Ground_Line3
	jmpf .Draw_Regular_Line3
.Draw_Ground_Line3	
	mov #72, b
	jmpf .Line3_Chosen
.Draw_Regular_Line3	
	mov #6, b
.Line3_Chosen	
	P_Draw_Horizontal_Line b, c	
.Line4
	ld line_offset
	bz .Draw_Line_4
	sub #1
	bz .Draw_Line_4
	jmpf .Lines_Done
.Draw_Line_4
	ld line_offset
	add #30
	st b
	clr1    ocr, 5
	mov #<AllWhite, trl
	mov #>AllWhite, trh
.loopLine4
	ld  c
	ldc
	st      vtrbf
	inc     c
	ld      c
	sub #12
	bnz .loopLine4
	set1    ocr, 5
	ld vrmad1
	add #48
	st vrmad1
	mov     #<AllBlack, trl
	mov     #>AllBlack, trh
	mov #0, c
	mov #6, b
	P_Draw_Horizontal_Line b, c	
.Lines_Done	
	ret
	
Draw_Debugging_Info:
	ld player_height
	st c
	mov #0, acc
	mov #10, b
	div
	st digit_temp ; ones_digit
	mov #10, b
	div
	ld b
	st tens_digit
	; ld player_acceleration_minus
	; ld player_height
	st c
	callf Draw_Digit
	ld digit_sprite_address_temp
	st digit_sprite_address_m
	ld digit_sprite_address_temp+1
	st digit_sprite_address_m+1
	mov #0, c
	mov #24, b
	; P_Draw_Sprite digit_sprite_address_m, b, c
	ld player_acceleration
	ld line_offset
	ld stun_timer
	st c
	callf Draw_Digit
	ld digit_sprite_address_temp
	st digit_sprite_address_p
	ld digit_sprite_address_temp+1
	st digit_sprite_address_p+1
	; ld digit_sprite_address_temp
	; st digit_sprite_address_p
	mov #0, c
	mov #32, b
	P_Draw_Sprite digit_sprite_address_p, b, c	
	ret

Handle_16Bit_Score:
.Rollover_Check
.Seventh_Bit_Was_Cleared
	ld seventh_bit_previous
	bnz .Seventh_Bit_Was_Set
	bp score_low, 7, .Score_Rollunder
	jmpf .Seventh_Bit_Check_Done
.Seventh_Bit_Was_Set
	ld seventh_bit_previous
	bz .Roll_Score_High
	bn score_low, 7, .Score_Rollover
	jmpf .Seventh_Bit_Check_Done
.Roll_Score_High	
.Score_Rollunder
	bn score_low, 6, .Seventh_Bit_Check_Done
	bn score_low, 5, .Seventh_Bit_Check_Done
	bn score_low, 4, .Seventh_Bit_Check_Done
	dec score_high
	jmpf .Seventh_Bit_Check_Done	
.Score_Rollover
	bp score_low, 6, .Seventh_Bit_Check_Done
	bp score_low, 5, .Seventh_Bit_Check_Done
	bp score_low, 4, .Seventh_Bit_Check_Done
	inc score_high
	jmpf .Seventh_Bit_Check_Done
.Seventh_Bit_Check_Done
	ret
	
Tick_Timer:
	bp game_timer_high, 7, .dont_set_overflow ; Max Time
	inc game_timer_low
	ld	game_timer_127_bool
	bnz	.over_127
.under_127
	bn	game_timer_low, 7, .dont_set_overflow
	mov	#1, game_timer_127_bool
	jmpf .dont_set_overflow
.over_127
	bp	game_timer_low, 7, .dont_set_overflow
	inc	game_timer_high
	mov	#0, game_timer_127_bool
.dont_set_overflow
	ret
	
Draw_Final_Time:
	ld	game_timer_low
	st	c
	ld	game_timer_high
	mov	#10, b
	div
	st	digit_temp ; This Should Actually Be Score_High_Temp
	ld	b ; mov	b, score_ones_digit
	st	ones_digit
	ld	digit_temp
	mov	#10, b
	div
	st	digit_temp ;
	ld	b
	st	tens_digit
	ld	digit_temp
	mov	#10, b
	div
	st	digit_temp ;
	ld	b
	st	hundreds_digit
	ld	digit_temp
	mov	#10, b
	div
	st	digit_temp ;
	ld	b
	st	thousands_digit
	ld	digit_temp
	mov	#10, b
	div
	st	digit_temp ;
	ld	b
	st	tenthousands_digit
	
	
	ld tenthousands_digit
	st c
	callf Draw_Digit
	ld digit_sprite_address_temp
	st digit_sprite_address_p
	ld digit_sprite_address_temp+1
	st digit_sprite_address_p+1
	; ld digit_sprite_address_temp
	; st digit_sprite_address_p
	mov #16, c
	mov #0, b
	P_Draw_Sprite digit_sprite_address_p, b, c	
	
	ld thousands_digit
	st c
	callf Draw_Digit
	ld digit_sprite_address_temp
	st digit_sprite_address_p
	ld digit_sprite_address_temp+1
	st digit_sprite_address_p+1
	; ld digit_sprite_address_temp
	; st digit_sprite_address_p
	mov #16, c
	mov #8, b
	P_Draw_Sprite digit_sprite_address_p, b, c	
	
	
	ld hundreds_digit
	st c
	callf Draw_Digit
	ld digit_sprite_address_temp
	st digit_sprite_address_p
	ld digit_sprite_address_temp+1
	st digit_sprite_address_p+1
	; ld digit_sprite_address_temp
	; st digit_sprite_address_p
	mov #16, c
	mov #16, b
	P_Draw_Sprite digit_sprite_address_p, b, c	
	
	ld tens_digit
	st c
	callf Draw_Digit
	ld digit_sprite_address_temp
	st digit_sprite_address_p
	ld digit_sprite_address_temp+1
	st digit_sprite_address_p+1
	; ld digit_sprite_address_temp
	; st digit_sprite_address_p
	mov #16, c
	mov #24, b
	P_Draw_Sprite digit_sprite_address_p, b, c	
	
	ld ones_digit
	st c
	callf Draw_Digit
	ld digit_sprite_address_temp
	st digit_sprite_address_p
	ld digit_sprite_address_temp+1
	st digit_sprite_address_p+1
	; ld digit_sprite_address_temp
	; st digit_sprite_address_p
	mov #16, c
	mov #32, b
	P_Draw_Sprite digit_sprite_address_p, b, c	
	ret
	
Draw_Ground:
	clr1    ocr, 5
	ld player_sprite_y
	add line_offset
	st c
.loopGround
	ld  c
	ldc
	st      vtrbf
	inc     c
	ld      c
	sub b
	bnz .loopGround ; dec vrmad1var
	set1    ocr, 5
	ret	
; clr1    ocr, 5
; 	; Prepare the frame buffer address
; 	mov     #P_WRAM_BANK, vrmad2
; 	mov     #P_WRAM_ADDR, vrmad1
; 	mov     #%00010000, vsel
; 	ld player_sprite_y
; 	add line_offset
; 	st c ; mov     #96, c
; .loop2
; 	ld      c
; 	ldc
; 	st      vtrbf
; 	inc     c
; 	ld      c
; 	ldc
; 	st      vtrbf
; 	inc     c
; 	ld      c
; 	ldc
; 	st      vtrbf
; 	inc     c
; 	ld      c
; 	ldc
; 	st      vtrbf
; 	inc     c
; 	ld      c
; 	ldc
; 	st      vtrbf
; 	inc     c
; 	ld      c
; 	ldc
; 	st      vtrbf
; 	inc     c
; 	ld      c
; 	sub     #192
; 	; sub     #96
; 	bnz     .loop2
; 	set1    ocr, 5
;;
;	ld line_offset
;	add player_height
;	st c
;	mov #0, acc
;	mov #10, b
;	div
;	ld b
;	st line_offset
;	add line_offset
;	add line_offset
;	add line_offset
;	add line_offset
;	add line_offset
;	; add vrmad1var
;	st vrmad1
;	mov     #<AllBlack, trl
;	mov     #>AllBlack, trh
;	mov #0, c
;	mov #6, b
;	P_Draw_Horizontal_Line b, c	
;.Ground	
;	ld line_offset
;	add #10
;	st b
;	clr1    ocr, 5
;	mov #<AllBlack, trl
;	mov #>AllBlack, trh
;.loopGround
;	ld  c
;	ldc
;	st      vtrbf
;	inc     c
;	ld      c
;	; sub vrmad1var
;	sub #12
;	bnz .loopGround
;	set1    ocr, 5
;	ld vrmad1
;	add #48
;	st vrmad1
;	mov     #<AllBlack, trl
;	mov     #>AllBlack, trh
;	mov #0, c
;	mov #6, b ; b / 6 = Thickenss
;	P_Draw_Horizontal_Line b, c	
	ret