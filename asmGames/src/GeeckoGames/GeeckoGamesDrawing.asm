
DrawBackground PROTO, mapPtr:PTR BYTE, lineSize:BYTE, mapSize:DWORD
DrawInteractive PROTO, mapPtr:PTR BYTE, lineSize:BYTE, mapSize:DWORD
DrawMainScreen PROTO
DrawFinishedGame PROTO

.data
movesSTR BYTE "MOVES: ", 0
bestSTR BYTE "	BEST: ", 0

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
mainScreen13			BYTE		"*             ESC : leave game             *", 0Ah
mainScreen14			BYTE		"*                                          *", 0Ah
mainScreen15			BYTE		"*                                          *", 0Ah
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
endScreen9				BYTE		"*                                          *", 0Ah
endScreen10				BYTE		"*                                          *", 0Ah
endScreen11				BYTE		"*              Congratulation!!            *", 0Ah
endScreen12				BYTE		"*                                          *", 0Ah
endScreen13				BYTE		"*                                          *", 0Ah
endScreen14				BYTE		"*                                          *", 0Ah
endScreen15				BYTE		"*                                          *", 0Ah
endScreen16				BYTE		"*            You Finished the Game!!       *", 0Ah
endScreen17				BYTE		"*                                          *", 0Ah
endScreen18				BYTE		"*                                          *", 0Ah
endScreen19				BYTE		"*                                          *", 0Ah
endScreen20				BYTE		"*                                          *", 0Ah
endScreen21				BYTE		"*                                          *", 0Ah
endScreen22				BYTE		"*                                          *", 0Ah
endScreen23				BYTE		"********************************************",0

.code

DrawBackground PROC, mapPtr:PTR BYTE, lineSize:BYTE, mapSize:DWORD
	MOV ECX, mapSize
	MOV DX, 0
	MOV ESI, mapPtr	
WriteC:
	MOV AL, [ESI]
	call GoToXY
	CALL WriteChar
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

DrawInteractive PROC USES EDX, mapPtr:PTR BYTE, lineSize:BYTE, mapSize:DWORD	
	MOV ECX, mapSize
	MOV DX, 0
	MOV ESI, mapPtr	
WriteC:
	MOV AL, [ESI]
	CALL gotoXY
	CMP AL,'0'
	JNE DontWrite1
	CALL WriteChar
	JMP DontWrite2
DontWrite1:
	CMP AL, '+'
	JNE DontWrite2
	CALL WriteChar
DontWrite2:
	INC ESI
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
	CALL WriteDec
	MOV EDX, OFFSET bestSTR
	CALL WriteString
	MOV EAX, DWORD PTR [ESI]
	CALL WriteDec
RET
DrawInteractive ENDP

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
DrawFinishedGame ENDP