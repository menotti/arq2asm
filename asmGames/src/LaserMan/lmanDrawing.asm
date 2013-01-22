.data
; Funções externas de ajuda
draw_matrix PROTO,
	matrix_ptr:DWORD, dimension:WORD, position:WORD, color:BYTE

; Funções
DesenhaMenu PROTO,
	selecao:BYTE, startx:BYTE, starty:BYTE
SlowWrite PROTO,
	text:DWORD, cdelay:BYTE, startx:BYTE, starty:BYTE
DrawGameTitle PROTO, cdelay:DWORD

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

laserManIterator word 0
ghostIterator word 0

.code
;--------------------------------------------------------
;DRAW LASERMANCHARACTER
;Parte da modularização do programa
;y then x
;Lucas Carvalhaes
DrawLMan PROC uses edx eax ebx,
	y:BYTE, x:BYTE
;--------------------------------------------------------
	;Set selected color
	mov eax,yellow+(black*16)
	call SetTextColor

	;Seta a posição
	mov dh,x
	mov dl,y
	call Gotoxy

	;Check the iterator
	mov bx, laserManIterator
	;Reset counter >=80h
	cmp bx, 80h
	jae DrawLMan_Reset
	;Fourth 60h - 80h
	cmp bx, 60h
	ja DrawLMan_Fourth
	;Third 40h - 60h
	cmp bx, 40h
	ja DrawLMan_Third
	;Second 20h - 40h
	cmp bx, 20h
	ja DrawLMan_Second
	;First 0 - 20h

	DrawLMan_First:
	mov ax, 28h ;(
	call WriteChar
	jmp DrawLMan_animend

	DrawLMan_Second:
	;Second anim step
	mov ax, 43h ;C
	call WriteChar
	jmp DrawLMan_animend

	DrawLMan_Third:
	;Third anim step
	mov ax, 4Fh ;o
	call WriteChar
	jmp DrawLMan_animend
	
	DrawLMan_Fourth:
	mov ax, 43h ;C
	call WriteChar
	jmp DrawLMan_animend
	
	DrawLMan_Reset:
	mov bx, 0
	
	DrawLMan_animend:
	;inc the counter
	inc bx
	mov laserManIterator, bx
ret
DrawLMan ENDP

;--------------------------------------------------------
;DRAW DrawGhost
;Parte da modularização do programa
;y then x
;state can be 2 for dangerous and 1 for eatable
;ID is the id of this ghost for color setup
;iD is 1-5
;Lucas Carvalhaes
DrawGhost PROC uses edx eax ebx,
	y:BYTE, x:BYTE, state:BYTE, ColourA:DWORD, ColourB:DWORD
;--------------------------------------------------------
	;Seta a posição
	mov dh,x
	mov dl,y
	call Gotoxy

	;Anim for ghosts is 2 step
	;Check the iterator
	mov bx, ghostIterator
	;Reset counter >=666h
	cmp bx, 1000h
	jae DrawGhost_Reset
	;Step1
	cmp bx, 500h
	ja DrawGhost_Step1
	
	;step 0
	mov eax, ColourA+(black*16)
	call SetTextColor
	jmp DrawGhost_animend
	
	DrawGhost_Step1:
	mov eax, ColourB+(black*16)
	call SetTextColor
	jmp DrawGhost_animend
	
	DrawGhost_Reset:
	mov bx,0
	
	;End of the state based colors
	DrawGhost_animend:
	;Draw the ghost
	mov al, state;ghost face
	call WriteChar
	;inc the counter
	inc bx
	mov ghostIterator, bx
ret
DrawGhost ENDP

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
;DRAW THE MAP
;Guilherme Perego (Baseado no draw_matrix de Lucas Yamanaka)
;Draw the map in blue and dots in white
DrawMap PROC uses eax esi ebx ecx edx,
	mapFileOffset:DWORD,
	mHeight:BYTE,
	mWidth:BYTE,
	posX:BYTE,
	posY:BYTE
;--------------------------------------------------------
	mov esi, mapFileOffset
	mov bl, mHeight
	mov bh, mWidth
	mov dl, posX
	mov dh, posY
	
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
				push ax
				mov ax, WHITE
				call SetTextColor
				pop ax
				cmp al, 2Eh
				jne NAOPONTO
				
				call WriteChar
				jmp P01FIMLOOP
				
			NAOPONTO:
				cmp al, 6Fh
				jne NoPtNoO
				
				call WriteChar
				jmp P01FIMLOOP
			
			NoPtNoO:
				push ax
				mov ax, lightblue
				call SetTextColor
				pop ax
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
DrawMap ENDP