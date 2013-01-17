
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
	SHL ECX, 2
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

	;Calculate the file size
	MOV ECX, mapSize
	SHL ECX, 2
	ADD ECX, 4

	SUB ESP, ECX
	PUSH ECX

	;Open the file
	MOV EDX, mapFileName
	CALL OpenInputFile

	CMP EAX, INVALID_HANDLE_VALUE
	JE ErrorOpenningFile

	PUSH EAX
	;Read the correct amount of data from the right file
	MOV EDX, EBP
	ADD EDX, 16
	CALL ReadFromFile
	
	POP EAX
	;Close the file
	CALL CloseFile

	;Change the score at the memory
	MOV ESI, newScore
	MOV DWORD PTR [ESP - 8], ESI

	;Write everything back to the file
	MOV EDX, mapFileName
	CALL OpenInputFile

	CMP EAX, INVALID_HANDLE_VALUE
	JE ErrorOpenningFile

	PUSH EAX
	;Read the correct amount of data from the right file
	MOV EDX, EBP
	ADD EDX, 16
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

	mov ax, WORD PTR mapNumber
	inc ah

	;If the first digit is over 10
	cmp ah, 3Ah
	jne Finish
	mov ah, 30h
	inc al	
Finish:
	mov WORD PTR mapNumber, ax
	ret
UpdateMapName ENDP