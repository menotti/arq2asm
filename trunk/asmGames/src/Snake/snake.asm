.data
CIMA = 1
DIREITA = 2
BAIXO = 3
ESQUERDA = 4
YMAXIMO = 24
XMAXIMO = 79
quadrado BYTE 254, 0
cobraPrimeiroX BYTE 20
cobraPrimeiroY BYTE 5
cobraUltimoX BYTE 20
cobraUltimoY BYTE 5
espacoBranco BYTE " ",0
TempoInicial dWord ?
velocidade Dword 60
direcaoAtual DWORD DIREITA
colidiu DWORD 0 


.code
Snake PROC
	
	
		call GetMseconds
		mov tempoInicial, eax

	GameLoop:
	
		call GetMseconds
		sub eax, tempoInicial
		cmp eax, velocidade
		jb GameLoop
			call identificaDirecao
			call verificaColisao
			cmp colidiu, 1
				je FimDeJogo
			call movimenta
			call desenha

			call GetMseconds
			mov tempoInicial, eax
		
	jmp GameLoop

	FimDeJogo:
		call  clrscr
		mov colidiu,0
		mov direcaoAtual,DIREITA
		mov cobraPrimeiroX,20
		mov cobraPrimeiroY,5
		mov cobraUltimoX,20
		mov cobraUltimoY,5
		jmp GameLoop
ret
Snake ENDP

movimenta PROC
	mov bh, cobraPrimeiroY
	mov bl, cobraPrimeiroX
	mov cobraUltimoY, bh
	mov cobraUltimoX, bl
	cmp direcaoAtual, CIMA
		je direcaoCima
	cmp direcaoAtual, DIREITA
		je direcaoDireita
	cmp direcaoAtual, BAIXO
		je direcaoBaixo
	cmp direcaoAtual, ESQUERDA
		je direcaoESQUERDA
	ret
	
DirecaoCima:
		sub cobraPrimeiroY, 1
		ret
	DirecaoBaixo:
		add cobraPrimeiroY, 1
		ret
	DirecaoEsquerda:				
		sub cobraPrimeiroX, 1
		ret
	DirecaoDireita:
		add cobraPrimeiroX, 1
		ret
	
ret
movimenta ENDP

desenha PROC

	mov dh, cobraUltimoY
	mov dl, cobraUltimoX
	call gotoXY
	mov edx, OFFSET espacoBranco
	call writeString
	mov dh, cobraPrimeiroY
	mov dl, cobraPrimeiroX
	call gotoXY
	mov edx, OFFSET quadrado
	call writeString

ret
desenha ENDP

identificaDirecao PROC

	call ReadKey

	;Verifica quais teclas foram apertadas, pelo codigo em ax(retornado por ReadKey!)
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
	cmp quadradoY,0d
	je  PossivelColisaoCima
	cmp quadradoX,0d
	je  PossivelColisaoEsquerda
	cmp quadradoY, YMAXIMO
	je  PossivelColisaoBaixo
	cmp quadradoX, XMAXIMO
	je  PossivelColisaoDireita
	ret

PossivelColisaoCima:
		cmp direcaoAtual,CIMA
		jne NaoColidiu
		mov colidiu,1 ; colidiu no limite de cima
		ret
PossivelColisaoEsquerda:
		cmp direcaoAtual,ESQUERDA
		jne NaoColidiu
		mov colidiu,1 ; colidiu no limite da esquerda
		ret
PossivelColisaoBaixo:
		cmp direcaoAtual,BAIXO
		jne NaoColidiu
		mov colidiu,1 ; colidiu no limite de baixo
		ret
PossivelColisaoDireita:
		cmp direcaoAtual,DIREITA
		jne NaoColidiu
		mov colidiu,1 ; colidiu no limite da direita
		ret
NaoColidiu:
		ret
verificaColisao ENDP