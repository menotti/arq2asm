
ReadMap PROTO,
	mapSize:DWORD, 
	mapFileName:PTR BYTE,
	mapAddress:PTR BYTE


SaveNewMapScore PROTO

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

	;Read the correct amount of data from the right file
	MOV EDX, mapAddress
	MOV ECX, mapSize
	SHL ECX, 2
	ADD ECX, 4
	CALL ReadFromFile
	
	;Close the file
	CALL CloseFile
ErrorOpenningFile:
	ret
ReadMap ENDP

SaveNewMapScore PROC

SaveNewMapScore ENDP