
DrawBackground PROTO, mapPtr:PTR BYTE, lineSize:BYTE, mapSize:DWORD
DrawInteractive PROTO, mapPtr:PTR BYTE, lineSize:BYTE, mapSize:DWORD
DrawMainScreen PROTO
DrawFinishedGame PROTO

.data
movesSTR BYTE "MOVES: ", 0
bestSTR BYTE "	BEST: ", 0

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
	MOV EAX, DWORD PTR [ESI]
	CALL WriteDec
	MOV EDX, OFFSET bestSTR
	CALL WriteString
	MOV EAX, DWORD PTR [ESI + 4]
	CALL WriteDec
RET
DrawInteractive ENDP

DrawMainScreen PROC
	RET
DrawMainScreen ENDP

DrawFinishedGame PROC
	RET
DrawFinishedGame ENDP