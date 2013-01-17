
DrawBackground PROTO, mapPtr:PTR BYTE, lineSize:BYTE, mapSize:DWORD
DrawInteractive PROTO, mapPtr:PTR BYTE, lineSize:BYTE, mapSize:DWORD
DrawMainScreen PROTO
DrawFinishedGame PROTO

.data


.code

DrawBackground PROC, mapPtr:PTR BYTE, lineSize:BYTE, mapSize:DWORD
	MOV ECX, mapSize
	MOV DX, 0
	MOV ESI, mapPtr	
WriteC:
	MOV EAX, [ESI]
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

DrawInteractive PROC, mapPtr:PTR BYTE, lineSize:BYTE, mapSize:DWORD	
	RET
DrawInteractive ENDP

DrawMainScreen PROC
	RET
DrawMainScreen ENDP

DrawFinishedGame PROC
	RET
DrawFinishedGame ENDP