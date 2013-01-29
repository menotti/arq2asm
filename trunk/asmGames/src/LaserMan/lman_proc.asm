; Description: Jogo pac man re-escrito em assembly com lasers!
; Grupo: Lucas carvalhaes, Guilherme perego

;Arquivos do jogo
INCLUDE lmanKeysDef.asm
INCLUDE lmanIO.asm
INCLUDE lmanDrawing.asm
INCLUDE lmanGame.asm
INCLUDE Macros.inc

; INICIO DA ZONA DE DADOS=================================================
.data
;Constantes
NAP = "000"

; O seletor do menu
Selector byte 0

; Textos
ByeMessage byte "Adeus! =)",0
UserInfopt1 byte "Jogador: ",0
UserInfopt2 byte " fase atual: ",0

NoGameMessage byte "There is no game =)",0

;Game info
currPlayer byte "0000" ;not a player
currLevel byte 0;default

;Files
defaultFileInfo BYTE "0000",0
fileBuffer BYTE 4 dup(?)

;No cursor - two dword combined for the method
nocursor DWORD 100 ;The cursor size (0 - 100% of the cell)
nocursorb DWORD 0 ;The cursor visibility (1 or 0)

;Agradeço ao grupo do space invaders por esse incrível trecho de conhecimento!
windowRectLMan SMALL_RECT <0,0,79,29> ; left,top,right,bottom

; FIM DA ZONA DE DADOS===================================================
.code
LMAN PROC
;Method to vanish the anoying cursor
;This technique is described here: http://msdn.microsoft.com/pt-br/library/windows/desktop/ms682068(v=vs.85).aspx
;GetStdHandle is a WinAPI method to get the HANDLE to the console screen
;STD_OUTPUT_HANDLE is from WinAPI
;SetConsoleCursorInfo is a WinAPI proc to set flags for the cursor info
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
INVOKE SetConsoleCursorInfo, EAX, ADDR nocursor
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
INVOKE SetConsoleWindowInfo,EAX,TRUE,ADDR windowRect

;This will run among various other projects
pusha

mov eax,white+(black*16)
call SetTextColor

;Call the game registry
call LoadGameReg

;Pede as iniciais do jogador
;Limpa a tela
call Clrscr
call getInicials
call clrscr

;Compare last player for 'save'
mov al, currPlayer
xor al, fileBuffer
add bl, al
mov al, currPlayer+1
xor al, fileBuffer+1
add bl, al
mov al, currPlayer+2
xor al, fileBuffer+2
add bl, al
jz nointro

;No player was here, we then show the game intro
mov eax, 500
call delay
call clrscr
call Intro

nointro:

;clear stuff
call ReadKeyFlush

;Desenha o titulo do jogo
INVOKE DrawGameTitle, 40

MenuState:
	;Desenha o menu na tela
	INVOKE DesenhaMenu, Selector, 2, 7
	
	;Desenha o nome do jogador e o level atual
	mov eax,white+(black*16)
	call SetTextColor
	push edx
	push eax
	;Seta a posição
	mov dh,29
	mov dl,1
	call Gotoxy
	mov edx, offset UserInfopt1
	call writeString
	mov edx, offset currPlayer
	call writeString
	mov edx, offset UserInfopt2
	call writeString
	movzx eax, currLevel
	call writeDec
	pop eax
	pop edx

	;Recebe input
	call readChar

	;Move para cima
	cmp ah, Up
	jne compare_down
		call SelUp
	compare_down:
	;Move para baixo
	cmp ah, Down
	jne compare_select
		call SelDown
	;Seleciona estado
	compare_select:
	cmp al, E_key
	jne leave_input
		
		;Usuario apertou enter
		;Selecionar o estado
		cmp Selector, 0d
		je GameState
		cmp Selector, 1d
		je HelpState
		cmp Selector, 2d
		je RankState
		cmp Selector, 3d
		je ExitState

		leave_input:
	jmp MenuState

GameState:
	
	;Go to the game
	call runGame
	
	;Limpa a tela
	call Clrscr

	;Volta o title
	INVOKE DrawGameTitle, 10

	;Volta para o menu
	jmp MenuState
	
HelpState:
	;Limpa a tela
	call Clrscr

	;Escreve o menu de ajuda de maneira legal =)
	INVOKE SlowWrite, OFFSET HelpTitle, 15, 28, 7
	INVOKE SlowWrite, OFFSET HelpL1, 15, 28, 8
	INVOKE SlowWrite, OFFSET HelpL2, 15, 28, 9
	INVOKE SlowWrite, OFFSET HelpL3, 15, 28, 10
	INVOKE SlowWrite, OFFSET HelpL4, 15, 28, 11 
	INVOKE SlowWrite, OFFSET HelpL5, 15, 28, 12
	INVOKE SlowWrite, OFFSET HelpL6, 15, 28, 13
	INVOKE SlowWrite, OFFSET HelpL7, 15, 28, 14
	INVOKE SlowWrite, OFFSET HelpL8, 15, 28, 15

	;Recebe input
	call readChar

	;Limpa a tela
	call Clrscr
	
	;Volta o title
	INVOKE DrawGameTitle, 10

	;Volta para o menu
	jmp MenuState

RankState:
	call showRank

	;Recebe input
	call readChar

	;Limpa a tela
	call Clrscr

	;Volta o title
	INVOKE DrawGameTitle, 10

	;Volta para o menu
	jmp MenuState

ExitState:
	;Clear the screen
	call Clrscr
	INVOKE SlowWrite, OFFSET ByeMessage, 50, 36, 11
	call saveRegistry

	;This will run among various other projects
	popa
	ret
LMAN ENDP

;--------------------------------------------------------
;GET INICIALS
;Lucas carvalhaes
;le as iniciais do usuario
getInicials PROC uses edx ecx eax
;--------------------------------------------------------
	;Seta a posição
	mov dh,12
	mov dl,24
	call Gotoxy

	;Draw info
	mWrite "Digite suas iniciais (3 letras):"
	;Seta a posição
	mov dh,13
	mov dl,38
	call Gotoxy
	
	;Prepare params
	mov edx, OFFSET currPlayer
	mov ecx, 4

	;Call the read and store
	call ReadString

	ret
getInicials ENDP

;--------------------------------------------------------
;SELECTOR UP
;Parte da modularização do programa
;Lucas Carvalhaes
;Selector usando eax
SelUp PROC uses eax
;--------------------------------------------------------

	cmp Selector, 2d
	jna proc_selup
	mov Selector, -1d
	proc_selup:
	mov al, Selector
	inc al
	mov Selector,al

	ret
SelUp ENDP

;--------------------------------------------------------
;SELECTOR DOWN
;Parte da modularização do programa
;Lucas Carvalhaes
;Selector usando eax
SelDown PROC uses eax
;--------------------------------------------------------

	cmp Selector, 1d
	jnb proc_seldown
	mov Selector, 4d
	proc_seldown:
	mov al, Selector
	dec al
	mov Selector,al

	ret
SelDown ENDP
