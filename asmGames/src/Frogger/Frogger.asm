TITLE Frogger ARC2 (main.asm)

; Descricao: projeto final da disciplina de Laboratorio de Arquitetura e Organizacao de computadores 2;
; O objetivo deste trabalho ee a implementacao de um jogo em ASM similar aos conhecidos "froggers"

; Data de criacao: 18/12/2012
; Grupo:
; Antonio Pedro Avanzi Nunes - 407852
; Lucas Oliveira David 		 - 407917
; Pedro Padoveze Barbosa 	 - 407895

FROG_SAPO = 9 ; define numerico referente ao sapo!

; Tamanho do campo
FROG_LINHAS	  = 15
FROG_COLUNAS  = 15

; Define a coordenadas (X,Y), onde o campo comecara a ser desenhado
FROG_CAMPO_INI_X 	  = 3
FROG_FROG_CAMPO_INI_Y = 5

.data
	;FROG_Campo word FROG_LINHAS *FROG_COLUNAS dup(0)
	FROG_Campo word 10 *FROG_COLUNAS dup(0), 2 dup ( 0,0,0,4,1,3,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,2,0,0,0,5,5,5,6,0 ), 15 dup (0)
	
	; posicao do sapo
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
	
		call  FROG_VerificarVitoria
		movzx eax, ganhouJogo
		cmp eax, 1
		jne FROG_Clock_NaoGanhou
			call FROG_ExibirVitoria
			jmp  FROG_Clock_Finally
		
		FROG_Clock_NaoGanhou:

		call FROG_DesenharCampo
		mov  eax, 100
		call Delay

		call FROG_AtualizarTransito
		call FROG_ControleMovimento
		call FROG_VerificarColisao
		
		movzx ebx, perdeuJogo
		cmp   ebx, 1
		jne   ContinuaJogo
			call FROG_ExibirDerrota
			jmp  FROG_Clock_Finally

		ContinuaJogo:
		
		
		cmp eax, 283
		je FROG_Clock_Finally
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
			cmp eax, FROG_SAPO
			jb CampoNormal
			je NaoColidiu
			
			mov perdeuJogo, 1
			
			CampoNormal:
			
		inc ebx
		cmp ebx, FROG_COLUNAS
		je PercorreCol
	
	inc ecx
	cmp ecx, FROG_LINHAS
	je PercorreLin
			
	NaoColidiu:

	ret
FROG_VerificarColisao endp

; Verifica se a posicao vertical do sapo ee 1.
; Se sim, ele esta na primeira linha, o que mostra que este atravessou todo o campo.
; A variavel ganhouJogo = 1. Caso contrario, nada acontece
FROG_VerificarVitoria proc
	mov ecx, FROG_COLUNAS
	mov esi, 0
	PercorrePrimeiraLin:
		movzx eax, FROG_Campo[esi]
		cmp eax, FROG_SAPO
		
		jne Perc_Finally
			mov ganhoujogo, 1
			jmp VerificarVitoria_Finally
		Perc_Finally:

		add esi, type FROG_Campo
	loop PercorrePrimeiraLin
	
	VerificarVitoria_Finally:
	
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
FROG_MovimentaEsq proc
	movzx ecx, FROG_sapoX
	cmp ecx, 0
	je OFFSET_ESQ

	movzx eax, FROG_sapoX
	movzx ecx, FROG_sapoY
	mov esi, 0
	
	l:
		add esi, FROG_LINHAS
	loop l
	
	add esi, eax
	shl esi, 1
	
	mov FROG_Campo[esi], 0
	add FROG_Campo[esi -type FROG_Campo], FROG_SAPO

	dec FROG_sapoX

	OFFSET_ESQ:
	
	ret
FROG_MovimentaEsq endp

FROG_MovimentaDir proc
	movzx ecx, FROG_sapoX
	cmp ecx, FROG_COLUNAS - 1
	je OFFSET_DIR

	movzx eax, FROG_sapoX
	movzx ecx, FROG_sapoY
	mov esi, 0
	
	l:
		add esi, FROG_LINHAS
	loop l
	
	add esi, eax
	shl esi, 1
	
	mov FROG_Campo[esi], 0
	add FROG_Campo[esi + type FROG_Campo], FROG_SAPO
	inc FROG_sapoX
	
	OFFSET_DIR:
		
	ret
FROG_MovimentaDir endp

FROG_MovimentaCima proc
	movzx ecx, FROG_sapoY
	cmp ecx, 0
	je OFFSET_CIM

	movzx eax, FROG_sapoX
	movzx ecx, FROG_sapoY
	mov esi, 0
	
	l:
		add esi, FROG_LINHAS
	loop l

	add esi, eax
	shl esi, 1
	
	mov FROG_Campo[esi], 0
	add FROG_Campo[esi - (type FROG_Campo)*FROG_COLUNAS], FROG_SAPO
	dec FROG_sapoY
	
	OFFSET_CIM:
		
	ret
FROG_MovimentaCima endp

FROG_MovimentaBaixo proc
	movzx ecx, FROG_sapoY
	cmp ecx, FROG_LINHAS - 1
	je OFFSET_BAI

	movzx eax, FROG_sapoX
	movzx ecx, FROG_sapoY
	mov esi, 0
	
	l:
		add esi, FROG_LINHAS
	loop l
	
	add esi, eax
	shl esi, 1
	
	mov FROG_Campo[esi], 0
	add FROG_Campo[esi + (type FROG_Campo) *FROG_COLUNAS], FROG_SAPO
		
	inc FROG_sapoY
	
	OFFSET_BAI:
		
	ret
FROG_MovimentaBaixo endp

; FIM DAS FUNCOES DE MOVIMENTACAO
; ===============================

FROG_AtualizarTransito proc uses eax ebx ecx edx esi
	mov ecx, 12
	mov esi, 0
	
	Atualizar:
		mov bx, FROG_TransitoLinha[esi]		;#?determina qual linha do trânsito sofrerá rotação
		mov ax, TransitoSentido	  [esi]		;#?determina qual sentido o trânsito está orientado [1 <- / 0 ->]
		mov dx, VelocAtual        [esi]		;#?determina o delay de ciclos para que a rotação seja efetuada
		cmp dx, 0
		
		jne skip
			call FROG_RotacionarTransito
			mov dx, TransitoVeloc[esi]
			mov VelocAtual[esi], dx

		skip:
		dec dx
		mov VelocAtual[esi], dx
		add esi, type FROG_TransitoLinha
	loop Atualizar
	
	ret
FROG_AtualizarTransito endp

FROG_RotacionarTransito proc uses eax ebx ecx edx esi
	movzx ecx, bx
	mov esi, 0
	
	l0:
		add esi, FROG_COLUNAS
	loop l0
	
	mov ecx, FROG_COLUNAS -1
	dec esi
	shl esi, 1
	
	cmp ax, 1
	jne dir
		mov eax, esi

		l1:
			mov dx, FROG_Campo[esi + type FROG_Campo]
			cmp dx, FROG_SAPO
			je skip1

			mov FROG_Campo[esi + type FROG_Campo], 0
			add FROG_Campo[esi], dx
			
			skip1:
			add esi, type FROG_Campo
		loop l1
		
		; Envia o primeiro elemento da linha 
		; para o ultima posicao desta mesma.
		add eax, type FROG_Campo
		mov dx, FROG_Campo[eax]
		
		cmp dx, FROG_SAPO
		je skip2
			mov FROG_Campo[eax], 0
			add FROG_Campo[esi], dx
		skip2:

	jmp skip
	dir:
		mov eax, esi
		add eax, (FROG_COLUNAS) *type FROG_Campo
		
		mov dx,  FROG_Campo[eax]
		cmp dx, FROG_SAPO
		je skip5
			mov FROG_Campo[eax], 0
			add FROG_Campo[esi + type FROG_Campo], dx
		skip5:
		
		add esi, FROG_COLUNAS *type FROG_Campo
		
		l2:
			mov dx, FROG_Campo[esi -type FROG_Campo]
			cmp dx, FROG_SAPO
			
			jae skip3
				mov FROG_Campo[esi -type FROG_Campo], 0
				add FROG_Campo[esi], dx
			
			skip3:
			sub esi, type FROG_Campo
		loop l2
	skip:

	ret
FROG_RotacionarTransito endp

FROG_DesenharCampo proc
	pushad
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
	
	popad		
	ret
FROG_DesenharCampo endp

FROG_DesenharCaracteres proc
	cmp ax, FROG_SAPO
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

FROG_ExibirTeclaPress proc
	pushad

	cmp eax, 1
	je PTP_Finally

	mov edx, 0
	call Gotoxy
	mWrite "Tecla pressionada: "
	call WriteDec

	PTP_Finally:
	popad
	ret
FROG_ExibirTeclaPress endp

FROG_ExibirCoordenada proc
	pushad

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
	
	popad
	ret
FROG_ExibirCoordenada endp

FROG_ExibirVitoria proc
	mov	ax, red + (white * 16)
	call SetTextColor
	call Clrscr

	mov dl, 7
	mov dh, 8
	call Gotoxy
	
	mWrite " V O C E    G A N H O U ! ! ! ! ! ! ! ! ! ! ! ! ! "	
	add dh, 2
	call Gotoxy
	mWrite " Parabens! O sapo conseguiu sobreviver aos terriveis humanos! "
	inc dh
	call Gotoxy
	mWrite " Pressione qualquer tecla para voltar ao menu inicial. "

	call ReadChar
	
	ret
FROG_ExibirVitoria endp

FROG_ExibirDerrota proc
	mov	ax, red + (white * 16)
	call SetTextColor
	call Clrscr

	mov dl, 7
	mov dh, 8
	call Gotoxy
	
	mWrite " V O C E   P E R  D E U ! ! ! ! ! ! ! ! ! ! ! ! ! "	
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
	mov	ax, black + white *16
	call SetTextColor
	call Clrscr
	
	mov dl, 33
	mov dh, 3
	call Gotoxy
	
	mWrite " F R O G G E R"
	mov dl, 7
	mov dh, 8
	call Gotoxy
	mWrite " Pressione ENTER para iniciar ou ESQ para sair do jogo."
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
	
	mov eax, 0
	call ReadChar
	
	ret
FROG_ExibirIntro endp

FROG_InitJogo proc
	call FROG_ExibirIntro
	call Clrscr

	; o jogador quer sair do jogo, pois pressionou a tecla ESC na tela de intro.
	cmp eax, 283
	je FROG_InitJogo_Finally
	   
    mov ganhouJogo, 0
    mov perdeuJogo, 0

	mov eax, 0
	mov ebx, 0
	PercorreX:
		mov ebx, 0
		PercorreY:

			inc ebx
		cmp ebx, FROG_COLUNAS
		jl PercorreY

		inc eax
	cmp eax, FROG_LINHAS
	jl PercorreX
    
	; posiciona o sapo na ultima linha
	mov FROG_sapoX, (FROG_COLUNAS -1) /2
    mov FROG_sapoY,	FROG_LINHAS -1

	mov edx, 0
	movzx eax, FROG_sapoY
	mov ebx, FROG_COLUNAS
	mul ebx
	movzx ebx, FROG_sapoX
	add eax, ebx

    mov FROG_Campo[eax *type FROG_Campo], FROG_SAPO
	
    call FROG_Clock
    
	FROG_InitJogo_Finally:
	ret
FROG_InitJogo endp