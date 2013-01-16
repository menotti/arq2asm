TITLE Frogger ARC2 (main.asm)

; Descricao: projeto final da disciplina de Laboratorio de Arquitetura e Organizacao de computadores 2;
; O objetivo deste trabalho ee a implementacao de um jogo em ASM similar aos conhecidos "froggers"

; Data de criacao: 18/12/2012
; Grupo:
; Antonio Pedro Avanzi Nunes - 407852
; Lucas Oliveira David 		 - 407917
; Pedro Padoveze Barbosa 	 - 407895

INCLUDE Irvine32.inc
INCLUDE macros.inc

FROG_LINHAS	  = 15
FROG_COLUNAS  = 15

; Define a coordenadas (X,Y), onde o campo comecara a ser desenhado
FROG_CAMPO_INI_X 	  = 3
FROG_FROG_CAMPO_INI_Y = 5

.data
	;FROG_Campo word FROG_LINHAS *FROG_COLUNAS dup(0)
	FROG_Campo word 10*FROG_COLUNAS dup(0), 2 dup ( 0,0,0,4,1,3,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,2,0,0,0,5,5,5,6,0,), 15 dup (0)
	
	FROG_sapoX byte 0
	FROG_sapoY byte 0
	
	ganhouJogo byte 0
	perdeuJogo byte 0
	
	; Os quatro vetores seguintes sao utilizados pelo motor de movimentacao do cenario.
	; FROG_TransitoLinha:	armazena quais FROG_LINHAS da matriz contem elementos nocivos ao sapo;
	; TransitoVeloc:	armazena a velocidade com que os elementos contidos nas FROG_LINHAS
	;					referenciadas por FROG_TransitoLinha andam no cenario;
	; VelocAtual:		serve como contador para ajustar o delay de velocidade sem perder os
	;					valores de TransitoVeloc;
	; TransitoSentido:	armazena o sentido dos elementos contidos em FROG_TransitoLinha;
	
	FROG_TransitoLinha	word 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13
	TransitoVeloc		word 3, 4, 4, 3, 3, 3, 4, 4,  2,  3,  1,  4					
	VelocAtual			word 3, 4, 4, 3, 3, 3, 4, 4,  4,  3,  3,  4						
	TransitoSentido 	word 1, 0, 1, 1, 0, 1, 1, 0,  1,  0,  1,  0
	
.code


; ================================================
; PROCEDIMENTO PRINCIPAL.
; Executa um loop ate que o jogador ganhe, perca ou saia do jogo.
FROG_Clock proc
	mov edx, 0
	mov eax, 1
	
	Update:

		call FROG_VerificarVitoria
		movzx eax, ganhouJogo
		cmp eax, 1
		jne FROG_Clock_NaoGanhou
			call FROG_ExibirVitoria
			jmp FROG_Clock_Finally
		
		FROG_Clock_NaoGanhou:

		call FROG_DesenharCampo
		mov eax, 100
		call Delay

		call FROG_ControleMovimento
		
		call FROG_VerificarColisao
		mov ebx, perdeuJogo
		cmp ebx, 1
		jne ContinuaJogo

		call FROG_ExibirDerrota
		FROG_Clock_Finally

		ContinuaJogo:
		call FROG_AtualizarTransito
		
		cmp eax, 283
	jne Update
	
	FROG_Clock_Finally:
	ret
FROG_Clock endp

; Verifica se o sapo colidiu com um carro. Para isso, percorre a matriz inteira, verificando se existe
; algum elemento para qual o valor ee maior que o valor do sapo (considera-se que nenhum outro elemento tem
; valor maior que o sapo). Se sim, houve colisao e a variavel perdeuJogo = 1. Caso contrario, nada acontece.
FROG_VerificarColisao proc uses eax ebx ecx edx
	mov ecx, 0
	
	PercorreLin:
		mov ebx, 0
		
		PercorreCol:
			mov eax, FROG_COLUNAS
			mov edx, 0
			mul ecx
			add eax, ebx
			
			mov edx, 0
			mov ecx, type FROG_Campo
			mul ecx
			
			movzx eax, FROG_Campo[eax]
			cmp eax, 9
			jbe NaoColidiu
			
			mov perdeuJogo, 1
			
			NaoColidiu:
			
		inc ebx
		cmp ebx, FROG_COLUNAS
		je PercorreCol	
	
	inc ecx
	cmp ecx, FROG_LINHAS
	je PercorreLin
			
	ret
FROG_VerificarColisao endp

; Verifica se a posicao vertical do sapo ee 1.
; Se sim, ele esta na primeira linha, o que mostra que este atravessou todo o campo.
; A variavel ganhouJogo = 1. Caso contrario, nada acontece
FROG_VerificarVitoria proc uses eax ecx
	movzx eax, FROG_sapoY
	cmp eax, 1
	jne naoGanhou
	
	mov ganhoujogo, 1
	naoGanhou:
	
	ret
FROG_VerificarVitoria endp


; ===================================
; MOVIMENTACAO DO SAPO
;
; Le uma tecla pressionada pelo jogador e, caso essa 
; seja uma seta direcional, movimenta o sapo pelo campo.
;
FROG_ControleMovimento proc
	mov eax, 0
	call ReadKey
	
	call FROG_ExibirTeclaPress
	call FROG_ExibirCoordenada
	
	cmp eax, 19200
	jne OutLeft
		call FROG_MovimentaEsq
	OutLeft:
	
	cmp eax, 19712
	jne OutRight
		call FROG_MovimentaDir
	OutRight:
	
	cmp eax, 18432
	jne OutUp
		call FROG_MovimentaCima
	OutUp:
	
	cmp eax, 20480
	jne OutDown
		call FROG_MovimentaBaixo
	OutDown:

	ret
FROG_ControleMovimento endp

; Os procedimentos abaixo movimentam efetivamente o sapo do campo.
; Elas sao chamadas pelo procedimento FROG_ControleMovimento.
FROG_MovimentaEsq proc uses eax ecx esi

	movzx eax, FROG_sapoX
	movzx ecx, FROG_sapoY
	mov esi, 0
	
	l:
		add esi, FROG_LINHAS
	loop l

	add esi, eax
	shl esi, 1
	
	movzx ecx, FROG_sapoX
	cmp ecx, 1
	je skip
		mov FROG_Campo[esi], 0
		add FROG_Campo[esi - type FROG_Campo], 9

		dec FROG_sapoX
	skip:
	
	ret
FROG_MovimentaEsq endp

FROG_MovimentaDir proc uses eax ecx esi

	movzx eax, FROG_sapoX
	movzx ecx, FROG_sapoY
	mov esi, 0
	
	l:
		add esi, FROG_LINHAS
	loop l
	
	add esi, eax
	shl esi, 1
	
	movzx ecx, FROG_sapoX
	cmp ecx, FROG_COLUNAS - 2
	
	je skip
		mov FROG_Campo[esi], 0
		add FROG_Campo[esi + type FROG_Campo], 9

		inc FROG_sapoX
	skip:
		
	ret
FROG_MovimentaDir endp

FROG_MovimentaCima proc uses eax ecx esi

	movzx eax, FROG_sapoX
	movzx ecx, FROG_sapoY
	mov esi, 0
	
	l:
		add esi, FROG_LINHAS
	loop l

	add esi, eax
	shl esi, 1
	
	movzx ecx, FROG_sapoY
	cmp ecx, 1
	je skip
		mov FROG_Campo[esi], 0
		add FROG_Campo[esi - (type FROG_Campo)*FROG_LINHAS], 9
		
		dec FROG_sapoY
	skip:
		
	ret
FROG_MovimentaCima endp

FROG_MovimentaBaixo proc uses eax ecx esi

	movzx eax, FROG_sapoX
	movzx ecx, FROG_sapoY
	mov esi, 0
	
	l:
		add esi, FROG_LINHAS
	loop l
	
	add esi, eax
	shl esi, 1
	
	movzx ecx, FROG_sapoY
	cmp ecx, FROG_LINHAS - 1
	
	je skip
		mov FROG_Campo[esi], 0
		add FROG_Campo[esi + (type FROG_Campo)*FROG_LINHAS], 9
		
		inc FROG_sapoY
	skip:
		
	ret
FROG_MovimentaBaixo endp

; FIM DAS FUNCOES DE MOVIMENTACAO
; ===============================

FROG_AtualizarTransito proc uses eax ebx ecx edx esi
	mov ecx, 12
	mov esi, 0
	l:
		mov bx, FROG_TransitoLinha  [esi]		;determina qual linha do trânsito sofrerá rotação
		mov ax, TransitoSentido[esi]		;determina qual sentido o trânsito está orientado [1 <- / 0 ->]
		mov dx, VelocAtual[esi]				;determina o delay de ciclos para que a rotação seja efetuada
		cmp dx, 0
		jne skip
		call FROG_RotacionarTransito
		mov dx, TransitoVeloc[esi]
		mov VelocAtual[esi], dx
		skip:
		dec dx
		mov VelocAtual[esi], dx
		add esi, type FROG_TransitoLinha
	loop l
	
	ret
FROG_AtualizarTransito endp

FROG_RotacionarTransito proc uses eax ebx ecx edx esi
	movzx ecx, bx
	mov esi,0
	
	l0:
		add esi, FROG_COLUNAS
	loop l0
	
	mov ecx, FROG_COLUNAS - 1
	dec esi
	shl esi, 1
	
	cmp ax,1
	jne dir
	
		mov eax, esi

		l1:
			mov dx,FROG_Campo[esi + type FROG_Campo]
			mov FROG_Campo[esi + type FROG_Campo], 0
			cmp dx, 9
			
			jne skip1
				mov dx, 0
				mov FROG_Campo[esi + type FROG_Campo], 9
			skip1:
			
			add FROG_Campo[esi], dx
			mov dx, FROG_Campo[esi]
			cmp dx, 9
			
			jna skip2
				call FROG_ExibirDerrota
			skip2:
			
			add esi,type FROG_Campo
		loop l1
		
		add eax, type FROG_Campo
		mov dx,FROG_Campo[eax]
		mov FROG_Campo[eax], 0
		add FROG_Campo[esi], dx
		
	jmp skip
	dir:
		mov eax, esi

		add eax, FROG_COLUNAS*type FROG_Campo - type FROG_Campo
		mov dx,FROG_Campo[eax]
		mov FROG_Campo[eax], 0
		cmp dx, 9
		
		jne skip5
			mov dx, 0
			mov FROG_Campo[eax], 9
		skip5:
		
		add FROG_Campo[esi + type FROG_Campo], dx
		mov dx, FROG_Campo[esi + type FROG_Campo]
		cmp dx, 9
		
		jna skip6
			call FROG_ExibirDerrota
		skip6:
		
		add esi, FROG_COLUNAS*type FROG_Campo
		
		l2:
			mov dx,FROG_Campo[esi - type FROG_Campo]
			mov FROG_Campo[esi - type FROG_Campo], 0
			cmp dx, 9
			
			jne skip3
				mov dx, 0
				mov FROG_Campo[esi - type FROG_Campo], 9
			skip3:
			
			add FROG_Campo[esi], dx
			mov dx, FROG_Campo[esi]
			cmp dx, 9
			
			jna skip4
				call FROG_ExibirDerrota
			skip4:
			
			sub esi, type FROG_Campo
		loop l2	
	skip:

	ret
FROG_RotacionarTransito endp

FROG_DesenharCampo proc uses eax ebx ecx edx esi
	mov edx, 0
	mov dh, FROG_CAMPO_INI_X
	mov dl, FROG_FROG_CAMPO_INI_Y
	call Gotoxy

	mov esi, 0
	mov eax, 0
	
	mov ecx, FROG_LINHAS
	DesenharFROG_LINHAS:
		push ecx
		mov ecx, FROG_COLUNAS

		DesenharFROG_COLUNAS:
			mov ax, FROG_Campo[esi]
			
			call FROG_DesenharCaracteres
			add esi, type word

		loop DesenharFROG_COLUNAS
		pop ecx
		add dh, 1
		mov dl, FROG_FROG_CAMPO_INI_Y
		call Gotoxy
	loop DesenharFROG_LINHAS
	
	mov	al, white + (black * 16)
	call SetTextColor
			
	ret
FROG_DesenharCampo endp

FROG_DesenharCaracteres proc
	cmp ax, 9
	je DesenharSapo
	cmp ax, 0
	je DesenharChao
	cmp ax, 1
	je DesenharCarro0
	cmp ax, 2
	je DesenharCarro1
	cmp ax, 3
	je DesenharCarro2
	cmp ax, 4
	je DesenharCarro3
	cmp ax, 5
	je DesenharCarro4
	cmp ax, 6
	je DesenharCarro5
		
	DesenharSapo:
		mov	al, blue + (lightgreen * 16)
		call SetTextColor
		mWrite ":I"
		jmp D_Finally
	DesenharChao:
		mov	al, white + (lightgray * 16)
		call SetTextColor
		mWrite "  "
		jmp D_Finally
		DesenharCarro0:
		mov	al, white + (red * 16)
		call SetTextColor
		mWrite "ÍÍ"
		jmp D_Finally
	DesenharCarro1:
		mov	al, red + (white * 16)
		call SetTextColor
		mWrite "ÃÄ"
		jmp D_Finally
	DesenharCarro2:
		mov	al, white + (lightred * 16)
		call SetTextColor
		mWrite "ÌÑ"
		jmp D_Finally
	DesenharCarro3:
		mov	al, white + (lightred * 16)
		call SetTextColor
		mWrite "[´"
		jmp D_Finally
	DesenharCarro4:
		mov	al, gray + (black * 16)
		call SetTextColor
		mWrite "ÌÎ"
		jmp D_Finally
	DesenharCarro5:
		mov	al, black + (lightcyan * 16)
		call SetTextColor
		mWrite "Ìº"
		jmp D_Finally
	
	D_Finally:
			
	ret
FROG_DesenharCaracteres endp

FROG_ExibirTeclaPress proc uses eax edx
	cmp eax, 1
	je PTP_Finally

	mov edx, 0
	call Gotoxy
	mWrite "Tecla pressionada: "
	call WriteDec

	PTP_Finally:
	ret
FROG_ExibirTeclaPress endp

FROG_ExibirCoordenada proc uses eax edx
	mov dh, 0
	mov dl, 32
	call Gotoxy
	
	mWrite "X: "
	movzx eax, FROG_sapoX
	call WriteDec
	mWrite "  "
	
	mWrite "Y: "
	movzx eax, FROG_sapoY
	call WriteDec
	mWrite " "
	
	ret
FROG_ExibirCoordenada endp

FROG_ExibirVitoria proc
	call Clrscr
	
	mov dl, 7
	mov dh, 8
	call Gotoxy
	
	mov	ax, red + (white * 16)
	call SetTextColor
	
	mWrite " VOCE GANHOU!!!!!!!!!!!!! "	
	add dh, 2
	call Gotoxy
	mWrite " Parabens! O sapo conseguiu sobreviver aos terriveis humanos! "
	inc dh
	call Gotoxy
	mWrite " Pressione qualquer tecla para sair do jogo. "
	
	ret
FROG_ExibirVitoria endp

FROG_ExibirDerrota proc
	call Clrscr
	
	mov dl, 7
	mov dh, 8
	call Gotoxy
	
	mov	ax, red + (white * 16)
	call SetTextColor
	
	mWrite " VOCE PERDEU!!!!!!!!!!!!! "	
	add dh, 2
	call Gotoxy
	mWrite " Que pena! O sapo agora se encontra no plano espiritual. "
	inc dh
	call Gotoxy
	mWrite " Pressione qualquer tecla para tentar este incrivel desafio novamente. "
	call ReadChar
	
	ret
FROG_ExibirDerrota endp

FROG_ExibirIntro proc
	call Clrscr
	
	mov dl, 33
	mov dh, 3
	call Gotoxy
	
	mov	ax, black + white *16
	call SetTextColor
	
	mWrite " F R O G G E R "
	mov dl, 7
	mov dh, 8
	call Gotoxy
	mWrite " Pressione enter para iniciar o jogo. "
	add dh, 4
	call Gotoxy
	mWrite " Grupo: "
	add dh, 2
	call Gotoxy
	mWrite "   Antonio Pedro Avanzi Nunes - 407852 "
	inc dh
	call Gotoxy
	mWrite "   Lucas Oliveira David - 407917 "
	inc dh
	call Gotoxy
	mWrite "   Pedro Padoveze Barbosa - 407895 "
	
	call ReadChar
	
	mov ax, white +black *16
	call SetTextColor
	call Clrscr
	
	ret
FROG_ExibirIntro endp

FROG_InitJogo proc
	call Clrscr
	call FROG_ExibirIntro

    mov FROG_sapoX, 8
    mov FROG_sapoY, 14
    
    mov ganhouJogo, 0
    mov perdeuJogo, 0
    
    mov FROG_Campo[FROG_LINHAS*FROG_COLUNAS*(type FROG_Campo) - 14], 9 ; posiciona o sapo na ultima linha

    call FROG_Clock

endp FROG_InitJogo