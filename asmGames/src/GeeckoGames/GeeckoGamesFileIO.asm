
ReadMap PROTO,
	mapSize:DWORD, 
	mapFileName:PTR BYTE,
	mapAddress:PTR BYTE


SaveNewMapScore PROTO,
	mapFileName:PTR BYTE,
	newScore:DWORD,
	mapSize:DWORD

.data


.code

;numero de bytes de 1 mapa
;ponteiro para primeiro mapa
ReadMap PROC USES ecx edx,
	mapSize:DWORD, 
	mapFileName:PTR BYTE,
	mapAddress:PTR BYTE

	;Open the file
	MOV EDX, mapFileName
	CALL OpenInputFile

	CMP EAX, INVALID_HANDLE_VALUE
	JE ErrorOpenningFile

	PUSH EAX
	;Read the correct amount of data from the right file
	MOV EDX, mapAddress
	MOV ECX, mapSize
	SHL ECX, 1
	ADD ECX, 4
	CALL ReadFromFile
	
	POP EAX
	;Close the file
	CALL CloseFile
ErrorOpenningFile:
	RET
ReadMap ENDP

SaveNewMapScore PROC USES ECX EDX ESI,
	mapFileName:PTR BYTE,
	newScore:DWORD,
	mapSize:DWORD

	;Open the file
	MOV EDX, mapFileName
	CALL OpenInputFile

	CMP EAX, INVALID_HANDLE_VALUE
	JE ErrorOpenningFile

	;Calculate the file size
	MOV ECX, mapSize
	SHL ECX, 1
	ADD ECX, 4

	SUB ESP, ECX
	PUSH ECX

	PUSH EAX
	;Read the correct amount of data from the right file
	MOV EDX, ESP
	ADD EDX, 8
	CALL ReadFromFile
	
	POP EAX
	;Close the file
	CALL CloseFile

	;Change the score at the memory
	MOV ESI, newScore
	MOV DWORD PTR [EBP - 16], ESI

	;Write everything back to the file
	MOV EDX, mapFileName
	CALL CreateOutputFile

	CMP EAX, INVALID_HANDLE_VALUE
	JE ErrorOpenningFile

	PUSH EAX
	;Read the correct amount of data from the right file
	MOV EDX, ESP
	ADD EDX, 8
	CALL WriteToFile
	
	POP EAX
	;Close the file
	CALL CloseFile

	POP ECX
	ADD ESP, ECX

ErrorOpenningFile:
	RET
SaveNewMapScore ENDP

UpdateMapName PROC USES ax

	MOV AX, WORD PTR mapNumber
	INC AH

	;If the first digit is over 10
	CMP AH, 3Ah
	JNE Finish
	MOV AH, 30h
	INC AL	
Finish:
	MOV WORD PTR mapNumber, AX
	RET
UpdateMapName ENDP