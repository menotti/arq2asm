.data
CIMA = 1
DIREITA = 2
BAIXO = 3
ESQUERDA = 4
YMAXIMO = 24
XMAXIMO = 79
quadrado BYTE 254, 0
quadradoX BYTE 20
quadradoY BYTE 5
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
		mov colidiu,0
		mov direcaoAtual,DIREITA
		mov quadradoX,20
		mov quadradoY,5
ret
Snake ENDP

movimenta PROC
	
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
		sub quadradoY, 1
		ret
	DirecaoBaixo:
		add quadradoY, 1
		ret
	DirecaoEsquerda:				
		sub quadradoX, 1
		ret
	DirecaoDireita:
		add quadradoX, 1
		ret
	
ret
movimenta ENDP

desenha PROC

	call clrscr
	mov dh, quadradoY
	mov dl, quadradoX
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