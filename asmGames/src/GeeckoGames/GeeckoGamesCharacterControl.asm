LoadMap PROTO, destinationMap : PTR BYTE


.data
CursorInfoA DWORD 1 
CursorInfoB DWORD 0
useArrows BYTE "Use the w,a,s,d keys to move your character."
mapFileName BYTE "Code\\GeeckoGames\\Maps\\Map"
mapNumber BYTE "00", 0
moves DWORD ?
best DWORD ?
movesSTR BYTE "MOVES: ", 0
bestSTR BYTE "\tBEST: ", 0
currentMap BYTE 400 DUP (?), 0

.code

GeeckoGamesSokoban PROC
menu:
	pusha
	mov CursorInfoA, 1
	mov CursorInfoB, 0
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	INVOKE SetConsoleCursorInfo, EAX, ADDR CursorInfoA
	call ClrScr
	;call updateMapName
	mov EDX, OFFSET mapFileName
	INVOKE LoadMap, ADDR currentMap
	
	mov ECX, 1
	;Enter game loop
	; ECX[0] = leave game if 0
	; ECX[1] = menu = 0, game = 1
	; ECX[2] = restart level if 1
	; ECX[3] = end game screen
GL:	TEST ECX, 1
	JZ LV
	
	push ECX
	mov ESI, OFFSET currentMap
	mov ECX, 400
	call DrawMap
	pop ECX

	;mov EDX, OFFSET currentMap
	
	;push OFFSET pstr
	;push OFFSET currentMap
	;call WriteString

	call UpdateGame
	call updateMapName
	mov EDX, OFFSET mapFileName
	INVOKE LoadMap, ADDR currentMap
	jmp GL
LV:
	mov CursorInfoA, 25
	mov CursorInfoB, 1
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	INVOKE SetConsoleCursorInfo, EAX, ADDR CursorInfoA
	popa

	ret
GeeckoGamesSokoban ENDP

;RECEIVES THE ADDRESS OF THE MAP IN ESI AND THE NUMBER OF CHARS IN IT IN ECX
DrawMap PROC USES EAX EBX EDX
	mov dx, 0
L:	mov al, BYTE PTR [esi]
	call gotoXY
	call WriteChar
	inc ESI
	inc dl
	cmp dl, 20
	jl L2
	mov dl, 0
	inc dh
L2:	loop L
	;call Crlf
	ret 
DrawMap ENDP

;THIS FUNCTION TAKES A FILENAME IN EDX AND LOADS AN ARRAY
;IN THE ADDRESS PASSED AS AN ARGUMENT
LoadMap PROC USES EAX ECX, destinationMap : PTR BYTE
	call OpenInputFile
	push eax

	mov EDX, destinationMap
	mov ECX, 400
	call ReadFromFile

	pop eax
	
	call CloseFile
	ret
LoadMap ENDP

;THIS FUNCTION UPDATES THE GAME LOOP
UpdateGame PROC USES EAX
BG:	call ReadKey
	cmp al, 'w';
	je W
	cmp al, 'a';
	je A
	cmp al, 's';
	je S
	cmp al, 'd';
	je D
	cmp al, 'x';
	je X
	jmp BG
W:	jmp LV
A:	jmp LV
S:	jmp LV
D:	jmp LV
X:  and cl, 0FEh
	jmp LV
LV:	ret
UpdateGame ENDP

updateMapName PROC USES ax

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
updateMapName ENDP