TITLE LASERMAN

; Description: Jogo pac man re-escrito em assembly com lasers!
; Grupo: Lucas carvalhaes, Guilherme perego

; Inclui bibliotecas necessárias
INCLUDE Irvine32.inc
INCLUDE Macros.inc

; INICIO DA ZONA DE DADOS=================================================
.data
;Constantes
NAP = "000"

; Funções externas de ajuda
draw_matrix PROTO,
	matrix_ptr:DWORD, dimension:WORD, position:WORD, color:BYTE

; Funções
DesenhaMenu PROTO,
	selecao:BYTE, startx:BYTE, starty:BYTE
SlowWrite PROTO,
	text:DWORD, cdelay:BYTE, startx:BYTE, starty:BYTE
DrawGameTitle PROTO, cdelay:DWORD

; Controles
Up	  byte 50h
Down  byte 48h
E_key byte 13
Left  byte 4Bh
Right byte 4Dh

; O seletor do menu
Selector byte 0

; Textos
ByeMessage byte "Adeus! =)",0

NoGameMessage byte "There is no game =)",0

HistoryT1 byte "A muito muito tempo atras...",0
HistoryT2 byte "Pac man era sucesso nos fliperamas...",0
HistoryT3 byte "Foi um dos mais jogados da sua epoca...",0
HistoryT4 byte "Mas com a evolucao dos games ele caiu no esquecimento...",0
HistoryT5 byte "O pac man comecou a ficar deprimido com os anos...      ",0
HistoryT6 byte "Ele comecou a usar drogas e alcool...             ",0
HistoryT7 byte "Ate que um dia...                    ",0

HistorySnap1 byte "    __________ ",
				  "   / /= /_   /|",
                  "  |  _____  | |",
                  "  | |pac  | | |",
                  "  | |__man| | |",
                  "  /---------/ |",
                  " / o oo  p /  |",
                  " ---------    |",
                  "|         |   |",
                  "|         |   |",
                  "|         |  / ",
                  "|_________|./  ",0

HistorySnap2 byte " ________________________ ",
                  "|      /          \      |",
                  "|     /            \     |",
                  "|    | PLAYSTATION  |    |",
                  "|    |              |    |",
                  "|     \            /     |",
                  "|__O|__\__________/___|O_|",
				  "|________________________|",0

HistorySnap3 byte  "    ..:+++/:-..`       ",
                   " ./ymmmmmddddmmdo:     ",
                   " sddmmmmdoo  hmmmm:`   ",
                   "   ..:osyhdmmddmmmmhy  ",
                   "          .+sydmmmmmh  ",
                   "              :mmmmmy  ",
                   " ```   ``     hmmmd:   ",
                   " hdhhhhhdh+::smmmd/    ",
                   " /oydmmmmmmmmmmdo.     ",
                   "   `-::::::::-.        ",0

HistorySnap4 byte  "    ..:+++/:-..`       ",
                   " ./ymmm....X..mdo:     ",
                   " sddm....XXXXX...m:`   ",
                   "   ..:os...X....mmmhy  ",
                   "          .+sydmmmmmh  ",
                   "              :mmmmmy  ",
                   " ```   ``     hmmmd:   ",
                   " hdhhhhhdh+::smmmd/    ",
                   " /oydmmmmmmmmmmdo.     ",
                   "   `-::::::::-.        ",0

GameTitle byte "   __                                             ",
               "  / /  __ _ ___  ___ _ __       /\/\   __ _ _ __  ",
               " / /  / _` / __|/ _ \ '__|____ /    \ / _` | '_ \ ",
               "/ /__| (_| \__ \  __/ | |_____/ /\/\ \ (_| | | | |",
               "\____/\__,_|___/\___|_|       \/    \/\__,_|_| |_|",0

HelpTitle byte "=Ajuda==================",0
HelpL1 byte    "| Para jogar utilize as|",0
HelpL2 byte    "|teclas W,A,S,D.       |",0
HelpL3 byte    "| O objetivo e escapar |",0
HelpL4 byte    "|dos monstros e comer  |",0
HelpL5 byte    "|os pontos brancos.    |",0
HelpL6 byte    "|Pontos maiores o tor- |",0
HelpL7 byte    "|nam invulneravel.     |",0
HelpL8 byte    "=Ajuda==================",0

;Files
infofile BYTE "gamereg",0
rankfile BYTE "rankreg",0
maptag BYTE "map_"
defaultFileInfo BYTE "0000",0
fileBuffer BYTE 4 dup(?)

;Organização
;cada registro será: 3 bytes iniciais 1 byte separador x bytes de pontos 1 byte terminal
rankBuffer BYTE 150 dup(0)

;Game info
currPlayer byte "0000" ;not a player
currLevel byte 0;default

;Master helper
fhandle dword ?

; FIM DA ZONA DE DADOS===================================================
.code
main PROC

mov eax,white+(black*16)
call SetTextColor

;Call the game registry
call LoadGameReg

;Break level and player
movzx eax, fileBuffer

;Pede as iniciais do jogador
call getInicials
call clrscr

;Compare player
movzx eax, fileBuffer
and eax, 0fffh
movzx ebx, currPlayer
cmp ebx, eax
je nointro

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
	
	mov eax,white+(black*16)
	call SetTextColor
	;Desenha o nome do jogador e o level atual
	;Seta a posição
	mov dh,24
	mov dl,1
	call Gotoxy
	mWrite "Jogador: "
	push edx
	mov edx, offset currPlayer
	call writeString
	pop edx
	mWrite " fase atual: "
	push eax
	movzx eax, currLevel
	call writeDec
	pop eax

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
	INVOKE SlowWrite, OFFSET NoGameMessage, 35, 1, 1

	;Recebe input
	call readChar

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

exit
main ENDP

;--------------------------------------------------------
;SHOW RANK
;Lucas carvalhaes
;Mostra o rank salvo no arquivo
showRank PROC uses edx ecx eax
;--------------------------------------------------------
	;Create or open the input file
	mov edx, OFFSET rankfile

	;Call the open
	call OpenInputFile

	;Prepare params
	mov edx, OFFSET rankBuffer
	mov ecx,150

	;Read
	call ReadFromFile

	;Clear the screen
	call Clrscr

	;Prepare again
	mov edx, OFFSET rankBuffer

	;Show the buffer nice in the screen
	mov ecx,1 ;zera contador
	showRank_showEntries:
		mov al, [edx]
		cmp al, ';' ;end of file
		je showRank_sair
		cmp ecx, 11
		je showRank_sair

		mov eax,white+(black*16)
	    call SetTextColor

		;Print the position
		mov eax,ecx
		call WriteDec
		mWrite "/ lugar - *"
		inc ecx ;avança contador

			;Desenha as iniciais
			mov eax,lightblue+(black*16)
			call SetTextColor
			push ecx
			mov ecx,3
			iniciais:
			mov al, [edx]
			call writeChar
			inc edx
			loop iniciais
			pop ecx

			;Desenha a pontuação
			mov eax,white+(black*16)
			call SetTextColor
			mWrite "* - Pontos: "
			mov eax,yellow+(black*16)
			call SetTextColor
			pontos:
			mov al,[edx]
			cmp al,';'
			je showRank_sair
			cmp al,'@'
			je pulaLinha
			call WriteChar
			inc edx
			mov eax,60
			call delay
			jmp pontos

			pulaLinha:
			call crlf
			inc edx
		jmp showRank_showEntries
	showRank_sair:
	ret
showRank ENDP

;--------------------------------------------------------
;SAVE REGISTRY
;Lucas carvalhaes
;Salva o registro do jogo - as iniciasi do usuario e o
;level que ele está
saveRegistry PROC uses edx ecx eax
;--------------------------------------------------------

	;open for write
	mov edx, offset infofile
	call CreateOutputFile
	mov fhandle,eax

	;prepare params
	mov ecx,4
	mov edx, OFFSET currPlayer

	;try to write because the file is supposed to be open
	call WriteToFile

	;Check if was a success
	cmp eax,0
	jne saveRegistry_leave

	;File failed to write! must quit!
	call crlf
	mWrite "Problem writing to file!"
	mov eax, 5000
	call delay
	exit

	saveRegistry_leave:

	;Close the file
	mov eax,fhandle
	call closeFile

	ret
saveRegistry ENDP

;--------------------------------------------------------
;GET INICIALS
;Lucas carvalhaes
;le as iniciais do usuario
getInicials PROC uses edx ecx eax
;--------------------------------------------------------
	;Seta a posição
	mov dh,8
	mov dl,24
	call Gotoxy

	;Draw info
	mWrite "Digite suas iniciais (3 letras):"
	;Seta a posição
	mov dh,9
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
;DRAW TITLE
;Lucas carvalhaes
DrawGameTitle PROC uses ecx ebx eax,
	cdelay:dword
;--------------------------------------------------------

	mov ecx, 32h
	mov bl, 05h
	mov bh, 0h
	mov eax, cdelay
	PrintTitle:
		inc bh
		INVOKE draw_matrix, OFFSET GameTitle, bx, 0h, lightred+(black*16)
		call delay
	loop PrintTitle

	ret
DrawGameTitle ENDP

;--------------------------------------------------------
;LOAD GAME REGISTRY
;Lucas Carvalhaes
LoadGameReg PROC uses eax edx ecx
;--------------------------------------------------------
	;Pass the file pos
	mov edx, OFFSET infofile
	;Try to open the file
	call OpenInputFile
	;check if file exists
	cmp eax,INVALID_HANDLE_VALUE
	jne LoadGameReg_file_exisits
	;invalid file
	;This means the file doesn't exists so we create one
	call CreateGameReg
	jmp LoadGameReg_exit

	;valid file
	LoadGameReg_file_exisits:
	;store the file handle
	mov fhandle, eax

	;Stor params for read
	mov edx, offset fileBuffer ;Store at fileBuffer
	mov ecx,4 ; 3 bytes are inicials 1 is level

	;Try to read
	mWrite "Reading file to buffer..."
	call ReadFromFile
	jnc LoadGameReg_safeRead0
	mWrite "Error reading file: buffer!"
	mov eax, 10000
	call delay
	exit

	;Read was safe
	LoadGameReg_safeRead0:
	mWrite "Done."

	;Close the file
	mov eax,fhandle
	call closeFile

	LoadGameReg_exit:
	ret
LoadGameReg ENDP

;--------------------------------------------------------
;CREATE GAME REGISTRY
;Lucas Carvalhaes
;This will destroy EAX with the handle
CreateGameReg PROC
;--------------------------------------------------------

	mov edx, offset infofile
	call CreateOutputFile
	cmp eax, INVALID_HANDLE_VALUE
	jne CreateGameReg_fileok
	mWrite "Error creating reg file!"
	mov eax, 10000
	call delay
	exit

	CreateGameReg_fileok:
	mov fhandle, eax

	;write defaultinfo
	mov edx, OFFSET defaultFileInfo
	mov ecx, 4
	call writeToFile

	;close the file
	mov eax, fhandle
	call closeFile

	ret
CreateGameReg ENDP

;--------------------------------------------------------
;SLOW WRITE
;Lucas Carvalhaes
SlowWrite PROC uses esi eax ebx,
	text:DWORD, cdelay:BYTE, startx:BYTE, starty:BYTE
;--------------------------------------------------------

	;Seta a posição
	mov dh,starty
	mov dl,startx
	call Gotoxy

	mov eax, 0
	mov esi, text
	SlowWrite_Check:
	mov bl, [esi]
	cmp bl, 0
	je SlowWrite_Complete
		mov al, bl
		call WriteChar
		mov al, cdelay
		call Delay
		inc esi
		jmp SlowWrite_Check
	SlowWrite_Complete:
	ret
SlowWrite ENDP

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

;--------------------------------------------------------
;INTRO
;Parte da modularização do programa
;Lucas Carvalhaes
Intro PROC uses edx
;--------------------------------------------------------

	;Desenha intro story text
	INVOKE SlowWrite, OFFSET HistoryT1, 35, 1, 1
	mov eax, 3000d
	call Delay

	INVOKE SlowWrite, OFFSET HistoryT2, 35, 1, 1
	INVOKE draw_matrix, OFFSET HistorySnap1, 0F0Ch, 0302h, white+(black*16)
	mov eax, 3000d
	call Delay

	INVOKE SlowWrite, OFFSET HistoryT3, 35, 1, 18
	mov eax, 3700d
	call Delay

	call Clrscr

	INVOKE SlowWrite, OFFSET HistoryT4, 35, 1, 1
	INVOKE draw_matrix, OFFSET HistorySnap2, 1A08h, 0302h, white+(black*16)
	mov eax, 3400d
	call Delay

	call Clrscr

	INVOKE SlowWrite, OFFSET HistoryT5, 35, 1, 1
	INVOKE draw_matrix, OFFSET HistorySnap3, 170Ah, 0302h, yellow+(black*16)
	mov eax, 3400d
	call Delay

	INVOKE SlowWrite, OFFSET HistoryT6, 35, 1, 1
	INVOKE draw_matrix, OFFSET HistorySnap4, 170Ah, 0302h, red+(black*16)

	mov ecx, 17
	Drugz:
		mov eax, 40d
		call Delay
		INVOKE draw_matrix, OFFSET HistorySnap4, 170Ah, 0302h, blue+(black*16)
		call Delay
		INVOKE draw_matrix, OFFSET HistorySnap4, 170Ah, 0402h, gray+(black*16)
		call Delay
		INVOKE draw_matrix, OFFSET HistorySnap4, 170Ah, 0301h, green+(black*16)
		call Delay
		INVOKE draw_matrix, OFFSET HistorySnap4, 170Ah, 0202h, lightred+(black*16)
		call Delay
	loop Drugz

	mov eax, 1000d
	call Delay

	call Clrscr

	INVOKE SlowWrite, OFFSET HistoryT7, 50, 1, 1

	ret
Intro ENDP

;--------------------------------------------------------
;MENU DRAW
;Lucas Carvalhaes
;
;Descrição: Esse procedure é especifico a este programa e serve apenas
;para modularizar o codigo do jogo facilitando o desenvolvimento
DesenhaMenu PROC uses edx,
	selecao:BYTE, startx:BYTE, starty:BYTE
;--------------------------------------------------------

	;Seta a posição
	mov dh,starty
	mov dl,startx
	call Gotoxy

	;***********************Seta a cor padrao
	mov eax,white+(black*16)
	call SetTextColor
	
	;Desenha opcao 1
	;Checa a selecao
	cmp selecao, 0d
	jne op_1_draw

	;Draw selection stuff
	call DesenhaSeletor
	;Set selected color
	mov eax,yellow+(black*16)
	call SetTextColor

	op_1_draw:
	mWrite "Jogo    "

	;***********************Seta a cor padrao
	mov eax,white+(black*16)
	call SetTextColor

	;Seta a posição
	inc dh
	call Gotoxy

	;Desenha opcao 2
	;Checa a selecao
	cmp selecao, 1d
	jne op_2_draw

	;Draw selection stuff
	call DesenhaSeletor
	;Set selected color
	mov eax,yellow+(black*16)
	call SetTextColor

	op_2_draw:
	mWrite "Ajuda    "

	;***********************Seta a cor padrao
	mov eax,white+(black*16)
	call SetTextColor

	;Seta a posição
	inc dh
	call Gotoxy

	;Desenha opcao 3
	;Checa a selecao
	cmp selecao, 2d
	jne op_3_draw

	;Draw selection stuff
	call DesenhaSeletor
	;Set selected color
	mov eax,yellow+(black*16)
	call SetTextColor

	op_3_draw:
	mWrite "Rank    "

	;***********************Seta a cor padrao
	mov eax,white+(black*16)
	call SetTextColor

	;Seta a posição
	inc dh
	call Gotoxy

	;Desenha opcao 4
	;Checa a selecao
	cmp selecao, 3d
	jne op_4_draw

	;Draw selection stuff
	call DesenhaSeletor
	;Set selected color
	mov eax,yellow+(black*16)
	call SetTextColor

	op_4_draw:
	mWrite "Sair    "
ret
DesenhaMenu ENDP

;--------------------------------------------------------
;SELECTOR DRAW
;Lucas Carvalhaes
;Esse procedure pinta um seletor na região atual
;da tela
DesenhaSeletor PROC uses eax
;--------------------------------------------------------

	;Espera 45ms
	mov eax, 45d
	call Delay

	;Seta a cor
	mov eax,lightred+(black*16)
	call SetTextColor

	;Caracteres bloco: 1 - 178 - 177 - 176
	mov al, 1d
	call WriteChar

	;Espera 45ms
	mov eax, 45d
	call Delay

		;Espera 45ms
	mov eax, 45d
	call Delay

	;Seta a cor
	mov eax,lightred+(black*16)
	call SetTextColor

	;Caracteres bloco: 178 - 177 - 176
	mov al, 178d
	call WriteChar

	;Espera 45ms
	mov eax, 45d
	call Delay

	;Seta a cor
	mov eax,red+(black*16)
	call SetTextColor

	;Caracteres bloco: 177 - 176
	mov al, 177d
	call WriteChar

	;Espera 45ms
	mov eax, 45d
	call Delay

	;Caracteres bloco: 176
	mov al, 176d
	call WriteChar

ret
DesenhaSeletor ENDP

;------------------------------------------------------------------
;DRAW MATRIX
draw_matrix PROC USES eax ebx ecx edx esi,
	matrix_ptr:DWORD, dimension:WORD, position:WORD, color:BYTE
; Desenha uma matriz na tela com a cor especificada. 0FFh significa
; que, naquela posicao, o programa devera pular o caractere.
;
;Recebe: matrix_ptr: endereco do vetor contendo a matriz
;		 dimension: dimensoes da matriz, parte alta recebe width
;		 position: posicao na tela, parte alta recebe a coord Y
;		 color: cores escolhidas. Ex: BLACK + (WHITE*16)
;
;AUTOR: LUCAS Y
;------------------------------------------------------------------
;passa os parametros para registradores
mov esi, matrix_ptr
mov bx, dimension
mov dx, position
movzx ax, color

call SetTextColor	;muda as cores da letra e do fundo para as escolhidas

mov eax, 0
mov ecx, 0
call Gotoxy			;vai para a posicao guardada em dx
P01L1:
	cmp cl, bl
	jae P01SAIRLOOPEXTERNO
	push dx
	P01L2:
		cmp ch, bh
		jae P01SAIRLOOPINTERNO
		inc dx

		movzx ax, bh
		mul cl
		add al, ch
		jnc dmx_NAOAJUSTA
		inc ah
		dmx_NAOAJUSTA:
		mov al, [esi + eax * TYPE BYTE]
		cmp al, 0FFh
		jne P01CHARNAOVAZIO
			call Gotoxy
			jmp P01FIMLOOP
		P01CHARNAOVAZIO:
			call WriteChar
		P01FIMLOOP:
		inc ch
		jmp P01L2
	P01SAIRLOOPINTERNO:
	pop dx
	mov ch, 0
	inc dh

	call Gotoxy

	inc cl
	jmp P01L1
P01SAIRLOOPEXTERNO:
mov ax, WHITE + (BLACK*16)
call SetTextColor
ret
draw_matrix ENDP
;--------------------------------------------------------------

END main
