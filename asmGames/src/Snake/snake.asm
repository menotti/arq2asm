.data
CIMA = 1
DIREITA = 2
BAIXO = 3
ESQUERDA = 4
quadrado BYTE 254, 0
quadradoX BYTE 20
quadradoY BYTE 5
TempoInicial dWord ?
velocidade Dword 60
direcaoAtual DWORD DIREITA

.code
Snake PROC
	
	
		call GetMseconds
		mov tempoInicial, eax

	GameLoop:
	
		
		call GetMseconds
		sub eax, tempoInicial
		cmp eax, velocidade
		jb GameLoop
			call clrscr
			call identificaDirecao
			call movimenta
			call desenha

			call GetMseconds
			mov tempoInicial, eax
		
	jmp GameLoop

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

	;call Clrscr
	mov dh, quadradoY
	mov dl, quadradoX
	call gotoXY
	mov edx, OFFSET quadrado
	call writeString

ret
desenha ENDP

identificaDirecao PROC

	;call ReadKeyFlush
	call ReadKey

	cmp ah, 48h
		je SetaCima
	cmp ah, 75				;Verifica quais teclas foram apertadas, pelo codigo em ax(retornado por ReadKey!)
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

