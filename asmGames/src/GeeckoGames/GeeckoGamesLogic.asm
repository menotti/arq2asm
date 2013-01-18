
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
	MOV AL, [EDI]
	MOV AH, [ESI]
	CMP AH, "x"
	JE CompareD
	INC ESI
	INC EDI
	JMP	GetChar
CompareD:
	CMP AL, "+"
	JNE NotDone
	LOOP GetChar
	JMP Done
NotDone:
	POP ECX
	AND ECX, 0111b
Done:
	;next level ok = ECX
RET
CheckMapState ENDP