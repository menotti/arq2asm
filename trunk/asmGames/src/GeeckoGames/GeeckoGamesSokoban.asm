LoadMap PROTO, destinationMap : PTR BYTE

.data
mapFileName BYTE "C:\\Irvine\\Examples\\ProjectoFinalArq2\\TestSokobanMap.map", 0
currentMap BYTE 438 DUP (?)
.code

GeeckoGamesSokoban PROC
menu:
	pusha
	call ClrScr
	mov EDX, OFFSET mapFileName

	INVOKE LoadMap, ADDR currentMap

	mov ESI, OFFSET currentMap
	mov ECX, 438

	call DrawMap

	call WaitMsg
	popa
	ret
GeeckoGamesSokoban ENDP

;RECEIVES THE ADDRESS OF THE MAP IN ESI AND THE NUMBER OF CHARS IN IT IN ECX
DrawMap PROC USES EAX EBX
L:	mov al, BYTE PTR [esi]
	call WriteChar
	inc ESI
L2:	loop L
	call Crlf
	ret 
DrawMap ENDP

;THIS FUNCTION TAKES A FILENAME IN EDX AND LOADS AN ARRAY
;IN THE ADDRESS PASSED AS AN ARGUMENT
LoadMap PROC USES EAX ECX, destinationMap : PTR BYTE
	call OpenInputFile
	push eax

	mov EDX, destinationMap
	mov ECX, 438
	call ReadFromFile

	pop eax
	
	call CloseFile
	ret
LoadMap ENDP