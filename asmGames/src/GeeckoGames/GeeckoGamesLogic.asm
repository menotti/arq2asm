
CheckMapState PROTO, mapPtrX:PTR BYTE, mapPtrD:PTR BYTE, mapSize:DWORD

.data


.code

CheckMapState PROC USES EBX ESI EDI EAX, mapPtrX:PTR BYTE, mapPtrD:PTR BYTE, mapSize:DWORD
	OR ECX, 1000b ;//starts assuming the map is complete
	PUSH ECX
	MOV ECX, mapSize
	MOV ESI, mapPtrX
	MOV EDI, mapPtrD
GetChar: ;//Read the next character in the background map
	MOV AL, BYTE PTR[EDI]
	MOV AH, BYTE PTR[ESI]
	CMP AH, 'x' ;//If the character is a target char then we have to check if there's a diamond above it
	JE CompareD
	INC ESI
	INC EDI
	LOOP GetChar
	POP ECX
	JMP Done
CompareD:
	CMP AL, '+' ;//If there's no diamond above the target the map is not complete, we're done checking
	JNE NotDone
	INC ESI
	INC EDI
	LOOP GetChar
	POP ECX
	JMP Done
NotDone: ;//Resets the flag to it's original state
	POP ECX
	AND ECX, 0FFFFFFF7h
Done:
	;//next level ok = ECX
RET
CheckMapState ENDP