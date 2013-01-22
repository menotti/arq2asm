.data
lmanPosX byte 1h
lmanPosY byte 1h
lmanWalkingX byte 2
lmanWalkingY byte 2
lmanMatrixPos word 0

mapfile BYTE "mapa_0",0
mapBuffer BYTE 1000 dup("x")

lmanDeltaIterator word 0

.code

;--------------------------------------------------------
;GameStateProc
;Lucas Carvalhaes
;It runs the entire game
runGame PROC
;--------------------------------------------------------

;Inicialization
INVOKE LoadMap, OFFSET mapfile, OFFSET mapBuffer
call Clrscr
;INVOKE DrawMap, OFFSET mapBuffer, 28, 33, 0, 0
INVOKE DrawMap, OFFSET mapBuffer, 28, 33, 0, 0

;clear stuff
call ReadKeyFlush

GameLoop:

;Calc the lman pos in the file matrix
;movzx bx, lmanPosX
;movzx ecx, lmanPosY
;addBY:
;add bx, 33
;loop addBY
;mov lmanMatrixPos, bx

;Get input
mov eax, 10
call delay
call ReadKey

;React to input
cmp ah, Down
jne runGame_compare_down
	;cancela movimento horizontal
	mov lmanWalkingX, 2
	;Move para cima
	mov lmanWalkingY, 3
	jmp runGame_update
runGame_compare_down:
	cmp ah, Up
	jne runGame_compare_left
	;cancela movimento horizontal
	mov lmanWalkingX, 2
	;Move para baixo
	mov lmanWalkingY, 1
runGame_compare_left:
	cmp ah, Left
	jne runGame_compare_right
	;cancela movimento vertical
	mov lmanWalkingY, 2
	;Move para esquerda
	mov lmanWalkingX, 1
runGame_compare_right:
	cmp ah, Right
	jne runGame_update
	jne runGame_compare_right
	;cancela movimento vertical
	mov lmanWalkingY, 2
	;Move para esquerda
	mov lmanWalkingX, 3

runGame_update:
;wait 20 iterations
cmp lmanDeltaIterator, 20
jb runGame_draw

	;Mov the laserMan
	cmp lmanWalkingY,2
	je runGame_sides
	jb runGame_movdown

	;runGame_movup
		;mov ax, 2Eh
		;mov bx, lmanMatrixPos
		;sub bx, 33
		;cmp al, mapBuffer[bx]
		;jne runGame_resetIterator
	mov al, lmanPosY
	dec al
	jmp runGame_resetIteratorY

	runGame_movdown:
	mov al, lmanPosY
	inc al

	runGame_resetIteratorY:
	;clear curr pos
	mov dh,lmanPosY
	mov dl,lmanPosX
	call Gotoxy
	push eax
	mov eax, 32;space
	call WriteChar
	pop eax
	;move the laserman
	mov lmanPosY, al
	;Reset iterator
	mov bx, 0
	mov lmanDeltaIterator, bx
	jmp runGame_draw

	runGame_sides:
	;Mov the laserMan
	cmp lmanWalkingX,2
	je runGame_draw
	ja runGame_movright

	;Move left
	mov bl, lmanPosX
	dec bl
	jmp runGame_resetIteratorX

	runGame_movright:
	mov bl, lmanPosX
	inc bl

	runGame_resetIteratorX:
	;clear curr pos
	mov dh,lmanPosY
	mov dl,lmanPosX
	call Gotoxy
	push eax
	mov eax, 32;space
	call WriteChar
	pop eax
	;move the laserman
	mov lmanPosX, bl
	;Reset iterator
	mov bx, 0
	mov lmanDeltaIterator, bx

runGame_draw:
;Draw laser-man
INVOKE DrawLMan, lmanPosX, lmanPosY
;XposYposStateid:  X  Y   S  I
;INVOKE DrawGhost, 11, 15, 2, white, blue

;Increase iterators
mov bx, lmanDeltaIterator
inc bx
mov lmanDeltaIterator, bx

jmp GameLoop

ret
runGame ENDP