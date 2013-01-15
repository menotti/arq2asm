TITLE Frogger ARC2 (main.asm)

; Descricao: projeto final da disciplina de Laboratorio de Arquitetura e Organizacao de computadores 2;
; O objetivo deste trabalho ee a implementacao de um jogo em ASM similar aos conhecidos "froggers"

; Data de criacao: 18/12/2012
; Grupo:
;   Antonio Pedro Avanzi Nunes - 407852
;   Lucas Oliveira David - 407917
;   Pedro Padoveze Barbosa - 407895

INCLUDE Irvine32.inc
INCLUDE macros.inc

LINHAS	 = 15
COLUNAS  = 15
CAMPO_X = 3
CAMPO_Y = 5

.data
	;Campo word LINHAS *COLUNAS dup(0)
	Campo word 10*COLUNAS dup(0), 2 dup ( 0,0,0,4,1,3,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,2,0,0,0,5,5,5,6,0,), 15 dup (0)
	
	Sapox byte 8
	Sapoy byte 14
	
	ganhouJogo byte 0
	
	; Os quatro vetores seguintes sao utilizados pelo motor de movimentacao do cenario.
	; TransitoLinha:	armazena quais linhas da matriz contem elementos nocivos ao sapo;
	; TransitoVeloc:	armazena a velocidade com que os elementos contidos nas linhas
	;					referenciadas por TransitoLinha andam no cenario;
	; VelocAtual:		serve como contador para ajustar o delay de velocidade sem perder os
	;					valores de TransitoVeloc;
	; TransitoSentido:	armazena o sentido dos elementos contidos em TransitoLinha;
	
	TransitoLinha   word 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13
	TransitoVeloc	word 3,4,4,3,3,3,4,4,2,3,1,4					
	VelocAtual	word 3,4,4,3,3,3,4,4,4,3,3,4						
	TransitoSentido word 1, 0, 1, 1, 0, 1, 1, 0, 1,  0,  1,  0
	



.code

clock proc
	mov edx, 0
	mov eax, 1
	
	Update:
		call VerificarVitoria
		movzx eax, ganhouJogo
		cmp eax, 1
		jne CLOCK_NaoGanhou
			call ExibirVitoria
			jmp CLOCK_Finally
		
		CLOCK_NaoGanhou:
		call PrintarCampo
		mov eax, 100
		call Delay

		mov eax, 0
		call ReadKey
		
		call PrintaTecla
		call PrintarCoordenada
		
		cmp eax, 19200
		jne OutLeft
			call MoveEsq
		OutLeft:
		
		cmp eax, 19712
		jne OutRight
			call MoveDir
		OutRight:
		
		cmp eax, 18432
		jne OutUp
			call MoveUp
		OutUp:
		
		cmp eax, 20480
		jne OutDown
			call MoveDown
		OutDown:
		
		call UpdateTransito
		
		cmp eax, 283
	jne Update
	
	CLOCK_Finally:
	ret
clock endp

PrintaTecla proc uses eax edx
	cmp eax, 1
	je PTP_Finally

	mov edx, 0
	call Gotoxy
	mWrite "Tecla pressionada: "
	call WriteDec

	PTP_Finally:
	ret
PrintaTecla endp

PrintarCoordenada proc uses eax edx
	mov dh, 0
	mov dl, 32
	call Gotoxy
	
	mWrite "X: "
	movzx eax, Sapox
	call WriteDec
	mWrite "  "
	
	mWrite "Y: "
	movzx eax, Sapoy
	call WriteDec
	mWrite " "
	
	ret
PrintarCoordenada endp

MoveEsq proc uses eax ebx ecx edx esi

	movzx eax, Sapox
	movzx ecx, Sapoy
	mov esi, 0
	l:
	add esi, LINHAS
	loop l
	add esi, eax
	shl esi, 1
	
	movzx ecx, Sapox
	cmp ecx, 1
	je skip
	mov Campo[esi], 0
	add Campo[esi - type Campo], 9
	mov dx, Campo[esi - type Campo]
	cmp dx, 9
	jna escape
	call ExibirGameOver
	escape:
	mov al, Sapox
	dec al
	mov Sapox, al
	skip:
	
	ret
MoveEsq endp

MoveDir proc uses eax ebx ecx edx esi

	movzx eax, Sapox
	movzx ecx, Sapoy
	mov esi, 0
	l:
	add esi, LINHAS
	loop l
	add esi, eax
	shl esi, 1
	
	movzx ecx, Sapox
	cmp ecx, COLUNAS - 2
	je skip
	mov Campo[esi], 0
	add Campo[esi + type Campo], 9
	mov dx, Campo[esi + type Campo]
	cmp dx, 9
	jna escape
	call ExibirGameOver
	escape:
	mov al, Sapox
	inc al
	mov Sapox, al
	skip:
		
	ret
MoveDir endp

MoveUp proc uses eax ebx ecx edx esi

	movzx eax, Sapox
	movzx ecx, Sapoy
	mov esi, 0
	l:
	add esi, LINHAS
	loop l
	add esi, eax
	shl esi, 1
	
	movzx ecx, Sapoy
	cmp ecx, 1
	je skip
	mov Campo[esi], 0
	add Campo[esi - (type Campo)*LINHAS], 9
	mov dx, Campo[esi - (type Campo)*LINHAS]
	cmp dx, 9
	jna escape
	call ExibirGameOver
	escape:
	mov al, Sapoy
	dec al
	mov Sapoy, al
	skip:
		
	ret
MoveUp endp

MoveDown proc uses eax ebx ecx edx esi

	movzx eax, Sapox
	movzx ecx, Sapoy
	mov esi, 0
	l:
	add esi, LINHAS
	loop l
	add esi, eax
	shl esi, 1
	
	movzx ecx, Sapoy
	cmp ecx, LINHAS - 1
	je skip
	mov Campo[esi], 0
	add Campo[esi + (type Campo)*LINHAS], 9
	mov dx, Campo[esi + (type Campo)*LINHAS]
	cmp dx, 9
	jna escape
	call ExibirGameOver
	escape:
	mov al, Sapoy
	inc al
	mov Sapoy, al
	skip:
		
	ret
MoveDown endp

UpdateTransito proc uses eax ebx ecx edx esi
	mov ecx, 12
	mov esi, 0
	l:
	
	mov bx, TransitoLinha  [esi]		;determina qual linha do trânsito sofrerá rotação
	mov ax, TransitoSentido[esi]		;determina qual sentido o trânsito está orientado [1 <- / 0 ->]
	mov dx, VelocAtual[esi]				;determina o delay de ciclos para que a rotação seja efetuada
	cmp dx, 0
	jne skip
	call RotateTransito
	mov dx, TransitoVeloc[esi]
	mov VelocAtual[esi], dx
	skip:
	dec dx
	mov VelocAtual[esi], dx
	add esi, type TransitoLinha
	
	loop l
	
	ret
UpdateTransito endp

RotateTransito proc uses eax ebx ecx edx esi
	movzx ecx, bx
	mov esi,0
	l0:
	add esi, COLUNAS
	loop l0
	mov ecx, COLUNAS - 1
	dec esi
	shl esi, 1
	
	cmp ax,1
	jne dir
	
	mov eax, esi

	l1:
	mov dx,Campo[esi + type Campo]
	mov Campo[esi + type Campo], 0
	cmp dx, 9
	jne skip1
	mov dx, 0
	mov Campo[esi + type Campo], 9
	skip1:
	add Campo[esi], dx
	mov dx, Campo[esi]
	cmp dx, 9
	jna skip2
	call ExibirGameOver
	skip2:
	add esi,type Campo
	loop l1
	
	add eax, type Campo
	mov dx,Campo[eax]
	mov Campo[eax], 0
	add Campo[esi], dx
	
	
	jmp skip
	
	dir:
	
	mov eax, esi

	add eax, COLUNAS*type Campo - type Campo
	mov dx,Campo[eax]
	mov Campo[eax], 0
	cmp dx, 9
	jne skip5
	mov dx, 0
	mov Campo[eax], 9
	skip5:
	add Campo[esi + type Campo], dx
	mov dx, Campo[esi + type Campo]
	cmp dx, 9
	jna skip6
	call ExibirGameOver
	skip6:
	add esi, COLUNAS*type Campo
	
	
	l2:
	
	mov dx,Campo[esi - type Campo]
	mov Campo[esi - type Campo], 0
	cmp dx, 9
	jne skip3
	mov dx, 0
	mov Campo[esi - type Campo], 9
	skip3:
	add Campo[esi], dx
	mov dx, Campo[esi]
	cmp dx, 9
	jna skip4
	call ExibirGameOver
	skip4:
	sub esi, type Campo
	loop l2
	

	
	
	skip:

	ret
RotateTransito endp

PrintaCampo proc uses eax ebx ecx edx esi
	mov edx, 0
	mov dh, CAMPO_X
	mov dl, CAMPO_Y
	call Gotoxy

	mov esi, 0
	mov eax, 0
	
	mov ecx, LINHAS
	DesenharLinhas:
		push ecx
		mov ecx, COLUNAS

		DesenharColunas:
			mov ax, Campo[esi]
			call WriteDec
			
			add esi, type word

		loop DesenharColunas
		pop ecx
		add dh, 1
		mov dl, CAMPO_Y
		call Gotoxy
	loop DesenharLinhas
		
	ret
PrintaCampo endp

PrintarCampo proc uses eax ebx ecx edx esi
	mov edx, 0
	mov dh, CAMPO_X
	mov dl, CAMPO_Y
	call Gotoxy

	mov esi, 0
	mov eax, 0
	
	mov ecx, LINHAS
	DesenharLinhas:
		push ecx
		mov ecx, COLUNAS

		DesenharColunas:
			mov ax, Campo[esi]
			
			call DesenhaCaracteres
			add esi, type word

		loop DesenharColunas
		pop ecx
		add dh, 1
		mov dl, CAMPO_Y
		call Gotoxy
	loop DesenharLinhas
	
	mov	al, white + (black * 16)
	call SetTextColor
			
	ret
PrintarCampo endp

DesenhaCaracteres proc
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
DesenhaCaracteres endp

VerificarColisao proc uses eax ebx ecx edx
	mov ecx, 0
	
	PercorreLin:
		mov ebx, 0
		
		PercorreCol:
			mov eax, COLUNAS
			mov edx, 0
			mul ecx
			add eax, ebx
			
			mov edx, 0
			mov ecx, type Campo
			mul ecx
			
			movzx eax, Campo[eax]
			cmp eax, 9
			jbe NaoColidiu
			
			; // Aqui houve uma colisao
			call ExibirGameOver
			
			NaoColidiu:
			
		inc ebx
		cmp ebx, COLUNAS
		je PercorreCol	
	
	inc ecx
	cmp ecx, LINHAS
	je PercorreLin
			
	ret
VerificarColisao endp

VerificarVitoria proc uses eax ecx
	movzx eax, Sapoy
	cmp eax, 1
	jne naoGanhou
	call ExibirVitoria
	mov ganhoujogo, 1
	naoGanhou:
	
	ret
VerificarVitoria endp

ExibirVitoria proc
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
ExibirVitoria endp

ExibirGameOver proc
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
ExibirGameOver endp

ExibirIntro proc
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
	call Clock
	
	ret
ExibirIntro endp

main PROC
	mov Campo[LINHAS*COLUNAS*(type Campo) - 14], 9 ; posiciona o jogador na ultima linha
	call ExibirIntro
	call ReadChar
	exit
main ENDP

END main