.data
CIMA = 1
DIREITA = 2
BAIXO = 3
ESQUERDA = 4
YMAXIMO = 22
XMAXIMO = 79
quadrado BYTE 254, 0
cobraPontosX BYTE 20, 21, 22, 1700 dup (?)
cobraPontosY BYTE 5, 5, 5, 1700 dup (?)
contPontosCobra WORD 3
cobraIndiceUltimo WORD 0
;espacoBranco BYTE " ",0
TempoInicial dWord ?
velocidade Dword 60
direcaoAtual DWORD DIREITA
colidiu DWORD 0 


.code
Snake PROC
	
		call  clrscr
		call GetMseconds
		mov tempoInicial, eax

	GameLoop:
	
		call GetMseconds
		sub eax, tempoInicial
		cmp eax, velocidade
		jb GameLoop
			call GetMseconds
			mov tempoInicial, eax
			call identificaDirecao
			call verificaColisao
			cmp colidiu, 1
				je FimDeJogo
			call movimentaEdesenha
			;call desenha
		
	jmp GameLoop

	FimDeJogo:
		;REINICIA PARÂMETROS PARA RECOMEÇAR O JOGO
		mov colidiu,0
		mov direcaoAtual,DIREITA
		Mov cobraPontosX, 20
		mov cobraPontosX[1], 21
		mov cobraPontosX[2], 22
		mov cobraPontosY, 5
		mov cobraPontosY[1], 5
		mov cobraPontosY[2], 5
		mov contPontosCobra, 3
		
ret
Snake ENDP

movimentaEdesenha PROC
	pushad

	;ESCREVE UM CARACTER EM BRANCO NO LUGAR DO ULTIMO PONTO DA COBRA
	movsx ebp, cobraIndiceUltimo
	mov dh, cobraPontosY[ebp]			;Parâmetros para gotXY
	mov dl, cobraPontosX[ebp]			;Parâmetros para gotXY
	mov al, 255							;Caracter em branco
	call gotoXY
	call WriteChar

	mov esi, ebp			;guarda posição do ultimo ponto da cobra em esi

	;ATUALIZA ebp PARA APONTAR PARA O PRIMEIRO PONTO DA COBRA
	dec ebp
	cmp ebp, -1					
	jne NaoAtualizaIndice
		movzx ebp, contPontosCobra
		dec ebp
	NaoAtualizaIndice:

	cmp direcaoAtual, CIMA
		je direcaoCima
	cmp direcaoAtual, DIREITA
		je direcaoDireita
	cmp direcaoAtual, BAIXO
		je direcaoBaixo
	cmp direcaoAtual, ESQUERDA
		je direcaoESQUERDA
	jmp Retorna
	
	;PEGA O ULTIMO PONTO E COLOCA NA FRENTE DO PRIMEIRO
	DirecaoCima:
		mov al, cobraPontosY[ebp]
		dec al
		mov cobraPontosY[esi], al
		mov al, cobraPontosX[ebp]
		mov cobraPontosX[esi], al
		jmp Retorna
	DirecaoBaixo:
		mov al, cobraPontosY[ebp]
		inc al
		mov cobraPontosY[esi], al
		mov al, cobraPontosX[ebp]
		mov cobraPontosX[esi], al
		jmp Retorna
	DirecaoEsquerda:				
		mov al, cobraPontosX[ebp]
		dec al
		mov cobraPontosX[esi], al
		mov al, cobraPontosY[ebp]
		mov cobraPontosY[esi], al
		jmp Retorna
	DirecaoDireita:
		mov al, cobraPontosX[ebp]
		inc al
		mov cobraPontosX[esi], al
		mov al, cobraPontosY[ebp]
		mov cobraPontosY[esi], al
		jmp Retorna
	
	Retorna:
	;ESCREVE NOVO PRIMEIRO PONTO DA COBRA NA TELA
	mov dh, cobraPontosY[esi]			;Parâmetros para gotXY
	mov dl, cobraPontosX[esi]			;Parâmetros para gotXY
	mov al, 254 						;Caracter em branco
	call gotoXY
	call WriteChar

	;ATUALIZA O PONTEIRO PARA O ÚLTIMO PONTO DA COBRA
	inc esi
	mov eax, esi
	cmp ax, contPontosCobra
	jne NaoATualizaUltimo
		mov ax, 0
	NaoAtualizaUltimo:
	mov cobraIndiceUltimo, ax

	popad
	ret
movimentaEdesenha ENDP

identificaDirecao PROC

	call ReadKey

	;VERIFICA QUAIS TECLAS FORAM APERTADAS, PELO CODIGO EM AX(RETORNADO POR READKEY!)
	cmp ah, 48h		
		je SetaCima
	cmp ah, 75				
		je SetaEsquerda
	cmp ah, 4Dh
		je SetaDireita
	cmp ah, 50h
		je SetaBaixo
	ret
	
	SetaCima:
		mov direcaoAtual, CIMA
		ret
	SetaEsquerda:
		mov direcaoAtual, ESQUERDA
		ret
	SetaDireita:
		mov direcaoAtual, DIREITA
		ret
	SetaBaixo:
		mov direcaoAtual, BAIXO
		ret

ret
identificaDirecao ENDP


verificaColisao PROC
	pushad
	movsx ebp, cobraIndiceUltimo

	;ATUALIZA ebp PARA APONTAR PARA O PRIMEIRO PONTO DA COBRA
	dec ebp
	cmp ebp, -1					
	jne NaoAtualizaIndice
		movsx ebp, contPontosCobra
		dec ebp
	NaoAtualizaIndice:

	cmp cobraPontosY[ebp],0d
	je  PossivelColisaoCima
	cmp cobraPontosX[ebp],0d
	je  PossivelColisaoEsquerda
	cmp cobraPontosY[ebp], YMAXIMO
	je  PossivelColisaoBaixo
	cmp cobraPontosX[ebp], XMAXIMO
	je  PossivelColisaoDireita
	jmp NaoColidiu

	PossivelColisaoCima:
			cmp direcaoAtual,CIMA
			jne NaoColidiu
			mov colidiu,1 ; colidiu no limite de cima
			jmp NaoColidiu
	PossivelColisaoEsquerda:
			cmp direcaoAtual,ESQUERDA
			jne NaoColidiu
			mov colidiu,1 ; colidiu no limite da esquerda
			jmp NaoColidiu
	PossivelColisaoBaixo:
			cmp direcaoAtual,BAIXO
			jne NaoColidiu
			mov colidiu,1 ; colidiu no limite de baixo
			jmp NaoColidiu
	PossivelColisaoDireita:
			cmp direcaoAtual,DIREITA
			jne NaoColidiu
			mov colidiu,1 ; colidiu no limite da direita
			jmp NaoColidiu
	NaoColidiu:
	popad
	ret
verificaColisao ENDP