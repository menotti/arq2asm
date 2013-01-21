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

FROG_SAPO = 9 ; define numerico referente ao sapo!
FROG_CAMPO_TAM = 283
FROG_INTRO_TAM = 1600

; Tamanho do campo
FROG_LINHAS	  = 15
FROG_COLUNAS  = 15

; Define a coordenadas (X,Y), onde o campo comecara a ser desenhado
FROG_CAMPO_INI_X 	  = 3
FROG_FROG_CAMPO_INI_Y = 5

.data
	FROG_Campo word FROG_LINHAS *FROG_COLUNAS dup(0)
	FROG_Campo_Temp byte FROG_CAMPO_TAM dup(0)
	FROG_Intro byte FROG_INTRO_TAM dup(0)
	
	; posicao do sapo
	FROG_sapoX byte 0
	FROG_sapoY byte 0
	
	FROG_ganhouJogo byte 0
	FROG_perdeuJogo byte 0

	FROG_fCampo BYTE "src/Frogger/campo.txt", 0
	FROG_IntroFile BYTE "src/Frogger/frogger.txt",0
	FROG_Handle DWORD ?

	FROG_respiracao byte 0
	
	; Os quatro vetores seguintes sao utilizados pelo motor de movimentacao do cenario.
	; FROG_TransitoLinha:	armazena quais FROG_LINHAS da matriz contem elementos nocivos ao sapo;
	; FROG_TransitoVeloc:	armazena a velocidade com que os elementos contidos nas FROG_LINHAS
	;					referenciadas por FROG_TransitoLinha andam no cenario;
	; FROG_VelocAtual:		serve como contador para ajustar o delay de velocidade sem perder os
	;					valores de FROG_TransitoVeloc;
	; FROG_TransitoSentido:	armazena o sentido dos elementos contidos em FROG_TransitoLinha;
	
	FROG_TransitoLinha	 word 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13
	FROG_TransitoVeloc	 word 3, 4, 4, 3, 3, 3, 4, 4,  2,  3,  1,  4					
	FROG_VelocAtual		 word 3, 4, 4, 3, 3, 3, 4, 4,  4,  3,  3,  4						
	FROG_TransitoSentido word 1, 0, 1, 1, 0, 1, 1, 0,  1,  0,  1,  0
	
.code


; ================================================
; PROCEDIMENTO PRINCIPAL.
; Executa um loop ate que o jogador ganhe, perca ou saia do jogo.
FROG_Clock proc
	mov edx, 0
	mov eax, 1
	
	Update:
	
		call  FROG_VerificarVitoria
		movzx eax, FROG_ganhouJogo
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
		
		movzx ebx, FROG_perdeuJogo
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
; valor maior que o sapo). Se sim, houve colisao e a variavel FROG_perdeuJogo = 1. Caso contrario, nada acontece.
FROG_VerificarColisao proc uses eax ebx ecx edx
	mov ecx, FROG_LINHAS *FROG_COLUNAS
	mov esi, 0

	PercorreCampo:
		movzx eax, FROG_Campo[esi]
		cmp eax, FROG_SAPO
		jbe CampoNormal
			
		; um valor maior que o valor definido para o sapo foi encontrado. 
		; Dessa forma, ele colidiu com alguma coisa. Jogador perde o jogo.
		mov FROG_perdeuJogo, 1
			
		CampoNormal:
		add esi, type FROG_Campo
	loop PercorreCampo


	cmp FROG_sapox, 1
	jb Borda
	cmp FROG_sapox, 13
	jna skip
	Borda:
		mov FROG_perdeuJogo, 1
	skip:

	
	ret
FROG_VerificarColisao endp

; Verifica se a posicao vertical do sapo ee 1.
; Se sim, ele esta na primeira linha, o que mostra que este atravessou todo o campo.
; A variavel FROG_ganhouJogo = 1. Caso contrario, nada acontece
FROG_VerificarVitoria proc
	mov ecx, FROG_COLUNAS
	mov esi, 0
	PercorrePrimeiraLin:
		movzx eax, FROG_Campo[esi]
		cmp eax, FROG_SAPO
		
		jne Perc_Finally
			mov FROG_ganhouJogo, 1
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
	cmp ecx, 1
	je OFFSET_ESQ

	movzx eax, FROG_sapoX
	movzx ecx, FROG_sapoY
	mov esi, eax
	
	l:
		add esi, FROG_LINHAS
	loop l
	
	shl esi, 1
	
	mov FROG_Campo[esi], 0
	add FROG_Campo[esi -type FROG_Campo], FROG_SAPO

	dec FROG_sapoX

	OFFSET_ESQ:
	
	ret
FROG_MovimentaEsq endp

FROG_MovimentaDir proc
	movzx ecx, FROG_sapoX
	cmp ecx, FROG_COLUNAS - 2
	je OFFSET_DIR

	movzx eax, FROG_sapoX
	movzx ecx, FROG_sapoY
	mov esi, eax
	
	l:
		add esi, FROG_LINHAS
	loop l
	
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
	mov esi, eax
	
	l:
		add esi, FROG_LINHAS
	loop l

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
	mov esi, eax
	
	l:
		add esi, FROG_LINHAS
	loop l
	
	shl esi, 1
	
	mov FROG_Campo[esi], 0
	add FROG_Campo[esi + (type FROG_Campo) *FROG_COLUNAS], FROG_SAPO
		
	inc FROG_sapoY
	
	OFFSET_BAI:
		
	ret
FROG_MovimentaBaixo endp

; FIM DAS FUNCOES DE MOVIMENTACAO
; ===============================

FROG_AtualizarTransito proc
	pushad
	mov ecx, 12
	mov esi, 0
	
	Atualizar:
		mov dx, FROG_VelocAtual        [esi]		;#?determina o delay de ciclos para que a rotaÁ„o seja efetuada
		cmp dx, 0
		
		jne skip
			mov bx, FROG_TransitoLinha[esi]		;#?determina qual linha do tr‚nsito sofrer· rotaÁ„o
			mov ax, FROG_TransitoSentido	  [esi]		;#?determina qual sentido o tr‚nsito est· orientado [1 <- / 0 ->]
			cmp bx, 6
			jna Agua
			call FROG_RotacionarTransito
			jmp QualLinha
		Agua:
			call FROG_RotacionarAgua
		QualLinha:
			mov dx, FROG_TransitoVeloc[esi]
			mov FROG_VelocAtual[esi], dx

		skip:
		dec dx
		mov FROG_VelocAtual[esi], dx
		add esi, type FROG_TransitoLinha
	loop Atualizar
	
	popad
	ret
FROG_AtualizarTransito endp

FROG_RotacionarTransito proc
	pushad
	movzx ecx, bx
	mov esi, 0
	
	l0:
		add esi, FROG_COLUNAS
	loop l0
	shl esi, 1

	mov ecx, FROG_COLUNAS -1
	
	cmp ax, 1
	jne dir
		add esi, type FROG_Campo
		mov eax, esi
		add eax, (FROG_COLUNAS -2) *type FROG_Campo 

		; Envia o primeiro elemento da linha 
		; para o ultima posicao desta mesma.
		mov dx, FROG_Campo[esi]
		cmp dx, FROG_SAPO
		je AchouSapo_2
			mov FROG_Campo[esi], 0
			add FROG_Campo[eax], dx
		AchouSapo_2:
		
		add esi, type FROG_Campo

		LP_RotEsquerda:
			mov dx, FROG_Campo[esi]
			cmp dx, FROG_SAPO
			je AchouSapo_1

			mov FROG_Campo[esi], 0
			add FROG_Campo[esi -type FROG_Campo], dx
			
			AchouSapo_1:
			add esi, type FROG_Campo
		loop LP_RotEsquerda
		

	jmp ROT_Finally
	dir:
		mov eax, esi
		add eax, (FROG_COLUNAS -2) *type FROG_Campo
		
		mov dx, FROG_Campo[eax]
		cmp dx, FROG_SAPO
		je AchouSapo_3
			mov FROG_Campo[eax], 0
			add FROG_Campo[esi], dx
		AchouSapo_3:
		
		add esi, (FROG_COLUNAS -2) *type FROG_Campo
		
		LP_RotDireita:
			mov dx, FROG_Campo[esi -type FROG_Campo]
			cmp dx, FROG_SAPO
			jae AchouSapo_4
				mov FROG_Campo[esi -type FROG_Campo], 0
				add FROG_Campo[esi], dx
			AchouSapo_4:
			sub esi, type FROG_Campo
		loop LP_RotDireita
	
	ROT_Finally:
	popad
	ret
FROG_RotacionarTransito endp

FROG_RotacionarAgua proc
	pushad
	movzx ecx, bx
	mov esi, 0
	
	l0:
		add esi, FROG_COLUNAS
	loop l0
	shl esi, 1

	mov ecx, FROG_COLUNAS -1
	
	cmp ax, 1
	jne dir
		add esi, type FROG_Campo
		mov eax, esi
		add eax, (FROG_COLUNAS -2) *type FROG_Campo 

		; Envia o primeiro elemento da linha 
		; para o ultima posicao desta mesma.
		mov dx, FROG_Campo[esi]
		cmp dx, FROG_SAPO
		jne NAchouSapo2

		dec FROG_sapox

		NAchouSapo2:

			mov FROG_Campo[esi], 0
			add FROG_Campo[eax], dx
		
		add esi, type FROG_Campo

		LP_RotEsquerda:
			mov dx, FROG_Campo[esi]
			cmp dx, FROG_SAPO

			jne NAchouSapo1
			dec FROG_sapox

			NAchouSapo1:

			mov FROG_Campo[esi], 0
			add FROG_Campo[esi -type FROG_Campo], dx

			add esi, type FROG_Campo
		loop LP_RotEsquerda
		

	jmp ROT_Finally
	dir:
		mov eax, esi
		add eax, (FROG_COLUNAS -2) *type FROG_Campo
		
		mov dx, FROG_Campo[eax]
		cmp dx, FROG_SAPO

			jne NAchouSapo3
			inc FROG_sapox

			NAchouSapo3:

			mov FROG_Campo[eax], 0
			add FROG_Campo[esi], dx
		add esi, (FROG_COLUNAS -2) *type FROG_Campo
		
		LP_RotDireita:
			mov dx, FROG_Campo[esi -type FROG_Campo]
			cmp dx, FROG_SAPO

				jne NAchouSapo4
				inc FROG_sapox

				NAchouSapo4:
				
				mov FROG_Campo[esi -type FROG_Campo], 0
				add FROG_Campo[esi], dx

			sub esi, type FROG_Campo
		loop LP_RotDireita
	
	ROT_Finally:
	popad
	ret
FROG_RotacionarAgua endp


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
		mov bx, 0

		DesenharFROG_COLUNAS:
			mov ax, FROG_Campo[esi]
			call FROG_DesenharCaracteres
			add esi, type word

		loop DesenharFROG_COLUNAS

		add dh, 1
		mov dl, FROG_FROG_CAMPO_INI_Y
		call Gotoxy
		sub esi, 30
		mov ecx, FROG_COLUNAS
		mov bx, 1

		DesenharFROG_COLUNAS_B:
			mov ax, FROG_Campo[esi]
			call FROG_DesenharCaracteres
			add esi, type word

		loop DesenharFROG_COLUNAS_B

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
	cmp bx, 1

	je SegundaLinha
	cmp ax, FROG_SAPO
	je DesenharSapoA
	cmp ax, 0
	je DesenharChao0A
	cmp ax, 1
	je DesenharCarro0A
	cmp ax, 2
	je DesenharCarro1A
	cmp ax, 3
	je DesenharCarro2A
	cmp ax, 4
	je DesenharCarro3A
	cmp ax, 5
	je DesenharCarro4A
	cmp ax, 6
	je DesenharCarro5A
	cmp ax, 7
	je DesenharAgua0A
	cmp ax, FROG_SAPO
	ja DesenharMortoA
	
	SegundaLinha:
		
	cmp ax, FROG_SAPO
	je DesenharSapoB
	cmp ax, 0
	je DesenharChao0B
	cmp ax, 1
	je DesenharCarro0B
	cmp ax, 2
	je DesenharCarro1B
	cmp ax, 3
	je DesenharCarro2B
	cmp ax, 4
	je DesenharCarro3B
	cmp ax, 5
	je DesenharCarro4B
	cmp ax, 6
	je DesenharCarro5B
	cmp ax, 7
	je DesenharAgua0B
	cmp ax, FROG_SAPO
	ja DesenharMortoB

;------- Sapo --------
	DesenharSapoA:
		mov	al, blue + (lightgreen * 16)
		call SetTextColor
		mWrite "ï ¢"
		jmp D_Finally
	DesenharSapoB:
		mov	al, blue + (lightgreen * 16)
		call SetTextColor
		cmp FROG_respiracao, 3
		ja SapoFROG_respiracao
			mWrite ")î("
			inc FROG_respiracao
			jmp D_Finally
		SapoFROG_respiracao:
			mWrite ")ô("
			inc FROG_respiracao
			cmp FROG_respiracao, 6
			jne D_Finally
			mov FROG_respiracao, 0
			jmp D_Finally
;------- Chao --------
	DesenharChao0A:
		cmp esi, 28*15 - 2
		jna DesenharRuaA
		mov	al, lightgray + (white * 16)
		call SetTextColor
		mWrite "±∞ "
		jmp D_Finally

	DesenharRuaA:
		cmp esi, 16*15 - 2
		jna DesenharChao1A
		mov	al, lightgray + (gray * 16)
		call SetTextColor
		mWrite "±∞≤"
		jmp D_Finally

	DesenharChao1A:
		cmp esi, 14*15 - 2
		jna DesenharMadeira
		mov	al, lightgray + (white * 16)
		call SetTextColor
		mWrite "±∞ "
		jmp D_Finally

	DesenharMadeira:
		cmp esi, 2*15 - 2
		jna DesenharGrama
		mov	al, black + (brown * 16)
		call SetTextColor
		mWrite "ÕÕÕ"
		jmp D_Finally

	DesenharGrama:
		mov	al, Green + (brown * 16)
		call SetTextColor
		mWrite "±∞±"
		jmp D_Finally

	DesenharChao0B:
		cmp esi, 28*15 - 2
		jna DesenharRuaB
		mov	al, lightgray + (white * 16)
		call SetTextColor
		mWrite "∞ ∞"
		jmp D_Finally

	DesenharRuaB:
		cmp esi, 16*15 - 2
		jna DesenharChao1B
		mov	al, lightgray + (gray * 16)
		call SetTextColor
		mWrite "≤±∞"
		jmp D_Finally

	DesenharChao1B:
		cmp esi, 14*15 - 2
		jna DesenharMadeira
		mov	al, lightgray + (white * 16)
		call SetTextColor
		mWrite "∞ ∞"
		jmp D_Finally


;------- Carro 0 --------
	DesenharCarro0A:
		mov	al, white + (blue * 16)
		call SetTextColor
		mWrite "…Õª"
		jmp D_Finally
	DesenharCarro0B:
		mov	al, white + (black * 16)
		call SetTextColor
		mWrite "ÕÕÕ"
		jmp D_Finally
;------- Carro 1 --------
	DesenharCarro1A:
		mov	al, white + (blue * 16)
		call SetTextColor
		mWrite "…Õª"
		jmp D_Finally
	DesenharCarro1B:
		mov	al, white + (black * 16)
		call SetTextColor
		mWrite "»©©"
		jmp D_Finally
;------- Carro 2 --------
	DesenharCarro2A:
		mov	al, blue + (white * 16)
		call SetTextColor
		mWrite "…ÀÕ"
		jmp D_Finally
	DesenharCarro2B:
		mov	al, white + (blue * 16)
		call SetTextColor
		mWrite "Õ∏Õ"
		jmp D_Finally
;------- Carro 3 --------
	DesenharCarro3A:
		mov	al, blue + (white * 16)
		call SetTextColor
		mWrite "ÕÕª"
		jmp D_Finally
	DesenharCarro3B:
		mov	al, white + (blue * 16)
		call SetTextColor
		mWrite "Õ∏ "
		jmp D_Finally
;------- Carro 4 --------
	DesenharCarro4A:
		mov	al,  red + (white * 16)
		call SetTextColor
		mWrite "ÕÕÕ"
		jmp D_Finally
	DesenharCarro4B:
		mov	al, black + (red * 16)
		call SetTextColor
		mWrite "ÕÕÕ"
		jmp D_Finally
;------- Carro 5 --------
	DesenharCarro5A:
		mov	al, gray + (lightcyan * 16)
		call SetTextColor
		mWrite "ÀÕª"
		jmp D_Finally
	DesenharCarro5B:
		mov	al, white + (black * 16)
		call SetTextColor
		mWrite "©©Œ"
		jmp D_Finally
;------- Agua 0 --------
	DesenharAgua0A:
		mov al, cyan +(blue * 16)
		call SetTextColor
	cmp FROG_respiracao, 3
	ja Agua0AChange
		mWrite "∞±∞"
	jmp D_Finally
	Agua0AChange:
		mWrite "±∞∞"
	jmp D_Finally

	DesenharAgua0B:
		mov al, cyan +(blue * 16)
		call SetTextColor
	cmp FROG_respiracao, 3
	ja Agua0BChange
		mWrite "±∞∞"
	jmp D_Finally
	Agua0BChange:
		mWrite "∞±∞"
	jmp D_Finally

	;------- Sapo Morti --------
	DesenharMortoA:
		mov	al, white + (magenta * 16)
		call SetTextColor
		mWrite "X X"
		jmp D_Finally
	DesenharMortoB:
		mov	al, white + (magenta * 16)
		call SetTextColor
		mWrite ")ô("


	D_Finally:
			
	ret
FROG_DesenharCaracteres endp

FROG_DefinirCampo PROC

	mov edx, OFFSET FROG_fCampo
	call OpenInputFile
	mov FROG_Handle, eax
	cmp eax, INVALID_HANDLE_VALUE
	jne Definir_Cont
	ret
	Definir_Cont:
	mov edx, OFFSET FROG_Campo_Temp
	mov ecx, FROG_CAMPO_TAM
	call ReadFromFile
	mov eax, FROG_Handle
	call CloseFile

	mov ecx, 15
	mov esi, 0
	mov eax, 0
	TESTE2:
	push ecx
	mov ecx, 15
	mov ebx, 0
	TESTE:
	mov bl, FROG_Campo_Temp[esi]
	sub bl, 48
	mov FROG_Campo[eax], bx
	inc esi
	add eax, 2
	loop TESTE
	add esi, 2
	pop ecx
	loop TESTE2

	ret
FROG_DefinirCampo ENDP

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
	call FROG_DesenharCampo
	mov	ax, red + (white * 16)
	call SetTextColor

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
	call FROG_DesenharCampo
	mov	ax, red + (white * 16)
	call SetTextColor
	

	mov dl, 7
	mov dh, 8
	call Gotoxy
	
	mWrite " V O C E   P E R D E U ! ! ! ! ! ! ! ! ! ! ! ! ! "	
	add dh, 2
	call Gotoxy
	mWrite " Que pena! O sapo agora se encontra no plano espiritual. "
	inc dh
	call Gotoxy
	
	mWrite " Pressione qualquer tecla para tentar este incrivel desafio novamente. "
	call ReadChar
	
	ret
FROG_ExibirDerrota endp

FROG_ExibirIntro PROC

	mov edx, OFFSET FROG_IntroFile
	call OpenInputFile
	cmp eax, INVALID_HANDLE_VALUE
	jne Intro_Cont
	ret
	Intro_Cont:
	mov FROG_Handle, eax
	mov edx, OFFSET FROG_Intro
	mov ecx, FROG_INTRO_TAM
	call ReadFromFile
	mov eax, FROG_Handle
	call CloseFile
	;mov al, FROG_Intro

	mov al, black + 16*white
	call SetTextColor

	mov ecx, FROG_INTRO_TAM
	mov esi, 0
	Intro_L:
	mov al, FROG_Intro[esi]
	call WriteChar
	inc esi
	loop Intro_L

	mov eax, 0
	call ReadChar
	
	ret
FROG_ExibirIntro ENDP

FROG_InitJogo proc
	call FROG_ExibirIntro
	call Clrscr

	; o jogador quer sair do jogo, pois pressionou a tecla ESC na tela de intro.
	cmp eax, 283
	je FROG_InitJogo_Finally
	   
	call FROG_DefinirCampo

    mov FROG_ganhouJogo, 0
    mov FROG_perdeuJogo, 0

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

main PROC
    call FROG_InitJogo

    exit
main ENDP

END main