
CheckMapState PROTO, mapPtrX:PTR BYTE, mapPtrD:PTR BYTE, mapSize:DWORD

.data


.code

CheckMapState PROC USES EBX ESI EDI EAX, mapPtrX:PTR BYTE, mapPtrD:PTR BYTE, mapSize:DWORD
	OR ECX, 1000b
	PUSH ECX
	MOV ECX, mapSize
	MOV ESI, mapPtrX
	MOV EDI, mapPtrD
GetChar:
	MOV AL, BYTE PTR[EDI]
	MOV AH, BYTE PTR[ESI]
	CMP AH, 'x'
	JE CompareD
	INC ESI
	INC EDI
	LOOP GetChar
	POP ECX
	JMP Done
CompareD:
	CMP AL, '+'
	JNE NotDone
	INC ESI
	INC EDI
	LOOP GetChar
	POP ECX
	JMP Done
NotDone:
	POP ECX
	AND ECX, 0FFFFFFF7h
Done:
	;next level ok = ECX
RET
CheckMapState ENDP