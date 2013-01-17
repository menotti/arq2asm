INCLUDE GeeckoGamesCharacterControl.asm
INCLUDE GeeckoGamesDrawing.asm
INCLUDE GeeckoGamesFileIO.asm
INCLUDE GeeckoGamesLogic.asm

.data
CursorInfoA DWORD 1 
CursorInfoB DWORD 0
mapFileName BYTE "Code\\GeeckoGames\\Maps\\Map"
mapNumber BYTE "00", 0
currentMapBg BYTE 880 DUP (?)
currentMapFg BYTE 880 DUP (?)
best DWORD ?
moves DWORD ?

LEAVE_THE_GAME_FLAG = 1b
LEVEL_PLAY_FLAG = 10b
MAIN_MENU_ANTI_FLAG = 0FFFEh
RESTART_LEVEL_FLAG = 100b
NEXT_LEVEL_FLAG = 1000b
END_GAME_FLAG = 10000b

MAP_LINE_SIZE = 44

.code

GeeckoGamesSokoban PROC
menu:
	PUSHA
	MOV CursorInfoA, 1
	MOV CursorInfoB, 0
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	INVOKE SetConsoleCursorInfo, EAX, ADDR CursorInfoA
	CALL ClrScr
	MOV EDX, OFFSET mapFileName
	
	MOV ECX, 0

MainScreen:
	CALL DrawMainScreen
	CALL UpdateGame
	TEST ECX, LEAVE_THE_GAME_FLAG
	JNZ LeaveGame
	TEST ECX, LEVEL_PLAY_FLAG
	JZ MainScreen

	;LOAD FIRST MAP AND START A NEW GAME
LoadMap:
	call ClrScr
	INVOKE ReadMap, SIZEOF currentMapBg, ADDR mapFileName, ADDR currentMapBg
	CMP EAX, INVALID_HANDLE_VALUE ; if loaded map does not exist the game has been beated
	MOV moves, 0
	JE EndScreen
LevelPlay:
	INVOKE DrawBackground, ADDR currentMapBg, MAP_LINE_SIZE, SIZEOF currentMapBg
	INVOKE DrawInteractive, ADDR currentMapFg, MAP_LINE_SIZE, SIZEOF currentMapFg
	CALL UpdateGame

	TEST ECX, LEAVE_THE_GAME_FLAG
	JNZ LeaveGame
	TEST ECX, LEVEL_PLAY_FLAG
	JZ MainScreen
	
	TEST ECX, RESTART_LEVEL_FLAG
	JNZ LoadMap

	OR ECX, NEXT_LEVEL_FLAG
	MOV moves, 0

	TEST ECX, NEXT_LEVEL_FLAG
	JZ LevelPlay
	MOV EAX, moves
	CMP EAX, best
	JAE LoadMap
	INVOKE SaveNewMapScore, ADDR mapFileName, EAX, SIZEOF currentMapBg
	CALL UpdateMapName
	JMP LoadMap
EndScreen:
	CALL DrawFinishedGame

	CALL UpdateGame

	TEST ECX, LEAVE_THE_GAME_FLAG
	JNZ LeaveGame
	JMP EndScreen
LeaveGame:
	MOV CursorInfoA, 25
	MOV CursorInfoB, 1
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	INVOKE SetConsoleCursorInfo, EAX, ADDR CursorInfoA

	POPA
	RET
GeeckoGamesSokoban ENDP

;RECEIVES THE ADDRESS OF THE MAP IN ESI AND THE NUMBER OF CHARS IN IT IN ECX
DrawMap PROC USES EAX EBX EDX
	mov dx, 0
L:	mov al, BYTE PTR [esi]
	call gotoXY
	call WriteChar
	inc ESI
	inc dl
	cmp dl, 44
	jl L2
	mov dl, 0
	inc dh
L2:	loop L
	;call Crlf
	ret 
DrawMap ENDP

;THIS FUNCTION UPDATES THE GAME LOOP
UpdateGame PROC USES EAX
CheckForInput:
	MOV EAX, 10
	CALL Delay
	CALL ReadKey
	;JZ CheckForInput ;no keys pressed

	CMP AH, 01h ;ESC
	JE ESC_PRESSED
	CMP AH, 1Ch ;ENTER
	JE ENTER_PRESSED
	CMP AH, 2Dh ;X
	JE X_PRESSED
	CMP AH, 13h ;R
	JE R_PRESSED
	CMP AH, 11h ;W
	JE PRESSED_W
	CMP AH, 1Eh ;A
	JE PRESSED_A
	CMP AH, 1Fh ;S
	JE PRESSED_S
	CMP AH, 20h ;D
	JE PRESSED_D
	JMP CheckForInput

ESC_PRESSED:
	OR ECX, LEAVE_THE_GAME_FLAG
	JMP LeaveProc
ENTER_PRESSED:
	OR ECX, LEVEL_PLAY_FLAG
	JMP LeaveProc
X_PRESSED:
	MOV ECX, 0
	JMP LeaveProc
R_PRESSED:
	JMP CheckForInput
PRESSED_W:
	JMP CheckForInput
PRESSED_A:
	JMP CheckForInput
PRESSED_S:
	JMP CheckForInput
PRESSED_D:
	JMP CheckForInput
LeaveProc:
	RET
UpdateGame ENDP