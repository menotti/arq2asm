
DrawBackground PROTO, mapPtr:PTR BYTE, lineSize:BYTE, mapSize:DWORD
DrawInteractive PROTO, mapPtr:PTR BYTE, mapBgPtr: PTR BYTE, lineSize:BYTE, mapSize:DWORD
DrawMainScreen PROTO
DrawFinishedGame PROTO

.data
movesSTR BYTE "MOVES: ", 0
bestSTR BYTE "	BEST: ", 0
scoreTooHigh BYTE "----", 0

;//Main and Endscreen
mainScreen1				BYTE		"********************************************", 0Ah
mainScreen2				BYTE		"*                                          *", 0Ah
mainScreen3				BYTE		"*                                          *", 0Ah
mainScreen4				BYTE		"*               S O K O B A N              *", 0Ah
mainScreen5				BYTE		"*                                          *", 0Ah
mainScreen6				BYTE		"*             by: Geeecko Games            *", 0Ah
mainScreen7				BYTE		"*                                          *", 0Ah
mainScreen8				BYTE		"*                                          *", 0Ah
mainScreen9				BYTE		"*     w: UP s : DOWN a : LEFT d : RIGHT    *", 0Ah
mainScreen10			BYTE		"*                                          *", 0Ah
mainScreen11			BYTE		"*            x : go to game menu           *", 0Ah
mainScreen12			BYTE		"*                                          *", 0Ah
mainScreen13			BYTE		"*             r : restart level            *", 0Ah
mainScreen14			BYTE		"*                                          *", 0Ah
mainScreen15			BYTE		"*             ESC : leave game             *", 0Ah
mainScreen16			BYTE		"*                                          *", 0Ah
mainScreen17			BYTE		"*           PRESS ENTER TO START           *", 0Ah
mainScreen18			BYTE		"*                                          *", 0Ah
mainScreen19			BYTE		"*                                          *", 0Ah
mainScreen20			BYTE		"*                                          *", 0Ah
mainScreen21			BYTE		"*                                          *", 0Ah
mainScreen22			BYTE		"*                                          *", 0Ah
mainScreen23			BYTE		"********************************************",0


endScreen1				BYTE		"********************************************", 0Ah
endScreen2				BYTE		"*                                          *", 0Ah
endScreen3				BYTE		"*                                          *", 0Ah
endScreen4				BYTE		"*               S O K O B A N              *", 0Ah
endScreen5				BYTE		"*                                          *", 0Ah
endScreen6				BYTE		"*             by: Geeecko Games            *", 0Ah
endScreen7				BYTE		"*                                          *", 0Ah
endScreen8				BYTE		"*                                          *", 0Ah
endScreen9				BYTE		"*     Congratulations you have beaten      *", 0Ah
endScreen10				BYTE		"*                                          *", 0Ah
endScreen11				BYTE		"*           our game, now try to           *", 0Ah
endScreen12				BYTE		"*                                          *", 0Ah
endScreen13				BYTE		"*           do it again beating            *", 0Ah
endScreen14				BYTE		"*                                          *", 0Ah
endScreen15				BYTE		"*       the best score on every map        *", 0Ah
endScreen16				BYTE		"*                                          *", 0Ah
endScreen17				BYTE		"*         PRESS ENTER TO GO AGAIN          *", 0Ah
endScreen18				BYTE		"*                                          *", 0Ah
endScreen19				BYTE		"*                                          *", 0Ah
endScreen20				BYTE		"*                                          *", 0Ah
endScreen21				BYTE		"*                                          *", 0Ah
endScreen22				BYTE		"*                                          *", 0Ah
endScreen23				BYTE		"********************************************",0

.code

;//Draws the background map
DrawBackground PROC USES ECX, mapPtr:PTR BYTE, lineSize:BYTE, mapSize:DWORD
	MOV ECX, mapSize
	MOV DX, 0
	MOV ESI, mapPtr	
WriteC: ;//Here we check if we have a wall char (*) or a target char (x), and if we do we draw an
		;//special character in its palce
	MOV AL, [ESI]
	call GoToXY
	CMP AL, '*'
	JNE DRW1
	MOV AL, 0B1h
DRW1:
	CMP AL, 'x'
	JNE DRW2
	MOV AX, gray + (white * 16) ;//changes the color for target characters
	CALL SetTextColor
	MOV AL, 0F0h
DRW2:
	CALL WriteChar
	MOV AX, black + (white * 16) ;//changes the color back to the default
	CALL SetTextColor
	INC ESI
	INC DL
	CMP DL, lineSize
	JL NextC
	MOV DL, 0	
	INC DH		;new line
NextC:
	LOOP WriteC
RET
DrawBackground ENDP

DrawInteractive PROC USES EDX ECX ESI EDI, mapPtr:PTR BYTE, mapBgPtr:PTR BYTE, lineSize:BYTE, mapSize:DWORD	
	MOV ECX, mapSize
	MOV DX, 0
	MOV ESI, mapPtr	
	MOV EDI, mapBgPtr
WriteC: ;//Here we check for character characters (0) and diamond characters (+) and exchange them for
		;//special characters
	MOV AL, [ESI]
	CALL gotoXY
	CMP AL,'0'
	JNE DontWrite1

	MOV AX, lightblue + (white * 16)
	CALL SetTextColor
	MOV AL, 01h
	CALL WriteChar
	MOV AX, black + (white * 16)
	CALL SetTextColor

	JMP DontWrite2
DontWrite1:
	CMP AL, '+'
	JNE DontWrite2
	MOV AL, BYTE PTR [EDI] ;//If we have a diamond character we check if it's over a target to decide its color
	CMP AL, 'x'
	JE DarkRed
	MOV AX, lightred + (white * 16)
	CALL SetTextColor
	JMP DRAW
DarkRed:
	MOV AX, red + (white * 16)
	CALL SetTextColor
DRAW: ;//We just write characters corresponding to players or diamonds
	MOV AL, 04h
	CALL WriteChar
	MOV AX, black + (white * 16)
	CALL SetTextColor
DontWrite2:
	INC ESI
	INC EDI
	INC DL
	CMP DL, lineSize
	JL NextC
	MOV DL, 0	
	INC DH		;new line
NextC:
	LOOP WriteC
	MOV DL, 0	
	INC DH
	CALL gotoXY
	MOV EDX, OFFSET movesSTR
	CALL WriteString
	MOV EAX, DWORD PTR [ESI + 4]

	;//Here we write the map's best score and the current number of movements of the character
	;//If the score is above "AAAA" we just write "----" instead, because it's our logical infinite
CMP EAX, "AAAA"
	JAE NOT_GOOD_ENOUGH
	CALL WriteDec
	JMP BST
NOT_GOOD_ENOUGH:
	MOV EDX, OFFSET scoreTooHigh
	CALL WriteString
BST:
	MOV EDX, OFFSET bestSTR
	CALL WriteString
	MOV EAX, DWORD PTR [ESI]
	CMP EAX, "AAAA"
	JAE NO_HIGH_DETECTED
	CALL WriteDec
	JMP FIN
NO_HIGH_DETECTED:
	MOV EDX, OFFSET scoreTooHigh
	CALL WriteString
FIN:
	RET
DrawInteractive ENDP

;//Just two methods that draw the main and end screens

DrawMainScreen PROC USES EDX
	CALL ClrScr
	MOV EDX, OFFSET mainScreen1
	CALL WriteString
	RET
DrawMainScreen ENDP

DrawFinishedGame PROC
	CALL ClrScr
	MOV EDX, OFFSET endScreen1
	CALL WriteString
	RET
	RET
DrawFinishedGame ENDP