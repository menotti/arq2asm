INCLUDE GeeckoGamesCharacterControl.asm
INCLUDE GeeckoGamesDrawing.asm
INCLUDE GeeckoGamesFileIO.asm
INCLUDE GeeckoGamesLogic.asm

.data
CursorInfoA DWORD 1 
CursorInfoB DWORD 0
mapFileName BYTE "src\\GeeckoGames\\Maps\\Map"
mapNumber BYTE "00", 0
currentMapBg BYTE 880 DUP (?)
currentMapFg BYTE 880 DUP (?)
best DWORD ?
moves DWORD ?

;//'Struct' holding the position of the character (X, Y)
charPos DWORD ?, ?

LEAVE_THE_GAME_FLAG = 1b
LEVEL_PLAY_FLAG = 10b
MAIN_MENU_ANTI_FLAG = 0FFFFFFFEh
RESTART_LEVEL_FLAG = 100b
NEXT_LEVEL_FLAG = 1000b
END_GAME_FLAG = 10000b

MAP_LINE_SIZE = 44

.code

;//This is the main PROC of the game, that's what is called to begin the game loop
GeeckoGamesSokoban PROC
	PUSHA
	;//We use an specific color scheme, so we set it here
	MOV AX, black + (white * 16)
	CALL SetTextColor
	;//Here we make the cursor invisible
	MOV CursorInfoA, 1
	MOV CursorInfoB, 0
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	INVOKE SetConsoleCursorInfo, EAX, ADDR CursorInfoA
	CALL ClrScr
	MOV EDX, OFFSET mapFileName

	;//Here's the main loop
MainScreen:
	MOV ECX, 0
	CALL DrawMainScreen
	CALL UpdateGame

	;//Testing if the games state changed
	TEST ECX, LEAVE_THE_GAME_FLAG
	JNZ LeaveGame
	TEST ECX, LEVEL_PLAY_FLAG
	JZ MainScreen

	;//This Part is designated to load the first map of the game
FirstMap:
	MOV AL, '0'
	MOV mapNumber, AL
	MOV mapNumber[1], AL ;//sets the map number to 00
	;//LOAD FIRST MAP AND START A NEW GAME
LoadMap: ;//Load the map designated by the mapFileName variable
	call ClrScr
	INVOKE ReadMap, SIZEOF currentMapBg, ADDR mapFileName, ADDR currentMapBg
	CMP EAX, INVALID_HANDLE_VALUE ;//if loaded map does not exist the game has been beated (automatic end game loop) 
	JE EndScreen

	MOV moves, 0
	MOV ECX, LEVEL_PLAY_FLAG
	;//After successfully loading a map we look at the foreground of the map to find the player's position
	INVOKE GetCharPos, ADDR currentMapFg, SIZEOF currentMapFg, MAP_LINE_SIZE, ADDR charPos

	;//This part of the game loop 
LevelPlay:
	INVOKE DrawBackground, ADDR currentMapBg, MAP_LINE_SIZE, SIZEOF currentMapBg
	INVOKE DrawInteractive, ADDR currentMapFg, ADDR currentMapBg, MAP_LINE_SIZE, SIZEOF currentMapFg
	;//Updates the game : waits for a key press and process the read input
	CALL UpdateGame

	;//Checks if all diamonds are at the right place
	INVOKE CheckMapState, ADDR currentMapBg, ADDR currentMapFg, SIZEOF currentMapBg

	;//Checks for state changes
	TEST ECX, LEAVE_THE_GAME_FLAG
	JNZ LeaveGame
	TEST ECX, LEVEL_PLAY_FLAG
	JZ MainScreen
	
	TEST ECX, RESTART_LEVEL_FLAG
	JNZ LoadMap

	TEST ECX, NEXT_LEVEL_FLAG
	JZ LevelPlay

	;//when a level is complete we check if the map's high score's been beated
	MOV EAX, moves
	CMP EAX, best
	JAE LOW_SCORE
	CMP EAX, "AAAA"
	JAE LOW_SCORE
	INVOKE SaveNewMapScore, ADDR mapFileName, EAX, SIZEOF currentMapBg
LOW_SCORE: ;//the high socre hasn't been beated
	CALL UpdateMapName
	JMP LoadMap

EndScreen: ;//draws the end game screen
	CALL DrawFinishedGame

	CALL UpdateGame

	TEST ECX, END_GAME_FLAG
	JNZ EndScreen

	TEST ECX, LEVEL_PLAY_FLAG
	JZ MainScreen
	JMP FirstMap

	TEST ECX, LEAVE_THE_GAME_FLAG
	JNZ LeaveGame
	JMP EndScreen
LeaveGame:
	;//Here we return the cursor and color scheme to their windows default settings
	MOV CursorInfoA, 25
	MOV CursorInfoB, 1
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	INVOKE SetConsoleCursorInfo, EAX, ADDR CursorInfoA

	MOV AX, lightgray + (black * 16)
	CALL SetTextColor
	POPA
	RET
GeeckoGamesSokoban ENDP

;//THIS FUNCTION UPDATES THE GAME LOOP
UpdateGame PROC USES EAX
CheckForInput:
	MOV EAX, 10
	CALL Delay
	CALL ReadKey

	;//Checks if a valid input has been received
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

	;//If no valid input has been received keep checking
	JMP CheckForInput

	;//Process inputs and sets flags
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
	OR ECX, RESTART_LEVEL_FLAG
	JMP LeaveProc
	;//If any movement key's been pressed process this input and try to move the character
	;//If the caracter moves increase the movement count, unless it's over "AAAA", which is considered
	;//an invalid score
PRESSED_W:
	INVOKE MoveChar, ADDR currentMapBg, ADDR currentMapFg, MAP_LINE_SIZE, ADDR charPos, 00b
	CMP EAX, 0
	JE LeaveProc
	CMP moves, "AAAA"
	JE LeaveProc
	INC moves
	JMP LeaveProc
PRESSED_A:
	INVOKE MoveChar, ADDR currentMapBg, ADDR currentMapFg, MAP_LINE_SIZE, ADDR charPos, 11b
	CMP EAX, 0
	JE LeaveProc
	CMP moves, "AAAA"
	JE LeaveProc
	INC moves
	JMP LeaveProc
PRESSED_S:
	INVOKE MoveChar, ADDR currentMapBg, ADDR currentMapFg, MAP_LINE_SIZE, ADDR charPos, 10b
	CMP EAX, 0
	JE LeaveProc
	CMP moves, "AAAA"
	JE LeaveProc
	INC moves
	JMP LeaveProc
PRESSED_D:
	INVOKE MoveChar, ADDR currentMapBg, ADDR currentMapFg, MAP_LINE_SIZE, ADDR charPos, 01b
	CMP EAX, 0
	JE LeaveProc
	CMP moves, "AAAA"
	JE LeaveProc
	INC moves
	JMP LeaveProc
LeaveProc:
	RET
UpdateGame ENDP