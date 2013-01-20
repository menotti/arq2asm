IntParaString PROTO,buffer_B:PTR BYTE

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
bufferPontuacoes BYTE 4096 DUP(0)
pontuacao BYTE 12 DUP(0),0
melhoresPontuacoes DWORD 0,0,0,0,0
nomePontuacao1 BYTE 20 DUP(0)
nomePontuacao2 BYTE 20 DUP(0)
nomePontuacao3 BYTE 20 DUP(0)
nomePontuacao4 BYTE 20 DUP(0)
nomePontuacao5 BYTE 20 DUP(0)
pontuacaoAtual DWORD 0
countLinhaPontuacao BYTE 5
arquivoPontuacoes BYTE "src/Snake/melhoresPontuacoes.txt",0
handlePontuacoes DWORD ?
topoPontuacoes2 BYTE "			Pontuacao	Nome",0
snakeInicio BYTE " ***************************** SNAKE GAME ****************************",0
topoPontuacoes BYTE " ######################## MELHORES PONTUACOES ########################",0
fimPontuacoes BYTE " #####################################################################",0
mensagemComecarJogo BYTE "Pressione ENTER para comecar o jogo",0
mensagemErroArquivo BYTE "Erro ao abrir o arquivo de pontuações!",13, 10, 0
espacoBranco BYTE " ",0
TempoInicial dWord ?
velocidade Dword 60
direcaoAtual DWORD DIREITA
colidiu DWORD 0 


.code


Snake PROC
	
		call  clrscr
		call exibeMelhoresPontuacoes
leTecla:
		call ReadKey
		cmp ah, 1Ch
		jne leTecla
		call clrscr
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
		mov cobraPrimeiroX,20
		mov cobraPrimeiroY,5
		mov cobraUltimoX,20
		mov cobraUltimoY,5
		call escreveArquivoPontuacao
		
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
	cmp cobraPrimeiroY,0d
	je  PossivelColisaoCima
	cmp cobraPrimeiroX,0d
	je  PossivelColisaoEsquerda
	cmp cobraPrimeiroY, YMAXIMO
	je  PossivelColisaoBaixo
	cmp cobraPrimeiroX, XMAXIMO
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

exibeMelhoresPontuacoes PROC
	mov edx,OFFSET snakeInicio
	call WriteString
	mov dh,2
	mov dl,0
	call GotoXY
	mov edx, OFFSET topoPontuacoes
	call WriteString
	call Crlf
	mov edx, OFFSET topoPontuacoes2
	call WriteString
	call Crlf
	mov ebx,0
	mov edx,OFFSET arquivoPontuacoes
	call OpenInputFile
	cmp eax,INVALID_HANDLE_VALUE
	jne abriuArquivo
	call exibeMensagemErroArquivo
	mov ebx,-1
abriuArquivo:
		mov handlePontuacoes,eax
		mov ecx,4096 
		mov edx,OFFSET bufferPontuacoes
		call ReadFromFile
		mov eax,handlePontuacoes
		call CloseFile

		mov ecx, 5
		mov esi, OFFSET bufferPontuacoes
		mov edi, OFFSET pontuacao
		mov ebx, OFFSET melhoresPontuacoes
LoopPontuacoes:
		mov al, [esi]
		cmp al,'/'
		je achouPontuacao
		mov BYTE PTR [edi],al
		inc edi
		inc esi
		jmp LoopPontuacoes
achouPontuacao:
		mov al, 'K'
		mov BYTE PTR [edi], al
		mov edx, OFFSET pontuacao
		push ecx
		mov ecx, SIZEOF pontuacao
		call ParseDecimal32
		pop ecx
		mov [ebx],eax
		add ebx,4
		mov dh, countLinhaPontuacao
		mov dl, 24
		inc countLinhaPontuacao
		call GotoXY
		call WriteInt
		call Crlf
		inc esi
		mov edi, OFFSET pontuacao
		loop LoopPontuacoes

		mov ecx, 5
		mov countLinhaPontuacao,5
		mov eax,6
		sub eax,ecx
		call offsetNomePontuacao
LoopNomePontuacoes:
		mov al, [esi]
		cmp al,'/'
		je achouNomePontuacao
		mov BYTE PTR [edx],al
		inc edx
		inc esi
		jmp LoopNomePontuacoes
achouNomePontuacao:
		mov al, 0
		mov BYTE PTR [edx], al
		add ebx,4
		mov dh, countLinhaPontuacao
		mov dl, 40
		inc countLinhaPontuacao
		call GotoXY
		mov eax,6
		sub eax,ecx
		call offsetNomePontuacao
		call WriteString
		call Crlf
		inc esi
		mov eax,6
		mov ebx,ecx
		sub ebx,1
		sub eax,ebx
		call offsetNomePontuacao
		loop LoopNomePontuacoes
		mov dh,11
		mov dl,20
		call GotoXY
		mov countLinhaPontuacao,5
		mov edx, OFFSET mensagemComecarJogo
		call WriteString
		call Crlf
		mov edx, OFFSET fimPontuacoes
		call WriteString
	ret
exibeMelhoresPontuacoes ENDP

exibeMensagemErroArquivo PROC
	mov edx, OFFSET mensagemErroArquivo
	call WriteString
	call WaitMsg
	ret
exibeMensagemErroArquivo ENDP

offsetNomePontuacao PROC
	cmp eax,1
	jne COMP2
	mov edx, OFFSET nomePontuacao1
	ret
COMP2:
		cmp eax,2
		jne COMP3
		mov edx, OFFSET nomePontuacao2
		ret
COMP3:
		cmp eax,3
		jne COMP4
		mov edx, OFFSET nomePontuacao3
		ret
COMP4:
		cmp eax,4
		jne COMP5
		mov edx, OFFSET nomePontuacao4
		ret
COMP5:
		cmp eax,5
		jne RetornaSemValor
		mov edx, OFFSET nomePontuacao5
		ret
RetornaSemValor:
		mov edx,-1
ret
offsetNomePontuacao ENDP

escreveArquivoPontuacao PROC
	mov edx,OFFSET arquivoPontuacoes
	call CreateOutputFile
	mov ecx,5
	mov esi, OFFSET melhoresPontuacoes
	mov edi, OFFSET bufferPontuacoes
	push eax
LOOP_NUMEROS_PONT:
	push ecx
	mov eax,[esi]
	invoke IntParaString,OFFSET pontuacao
LOOP_NUMEROS_PONT2:
	mov bl,[edx]
	mov BYTE PTR [edi],bl
	inc edx
	inc edi
	loop LOOP_NUMEROS_PONT2
EscreveProximaPontuacao:
	pop ecx
	add esi,4
	mov BYTE PTR [edi],'/'
	inc edi
	loop LOOP_NUMEROS_PONT
	
	mov ebx,0
LOOP_NOMES_PONT:
	inc ebx
	mov eax,ebx
	call offsetNomePontuacao
	invoke Str_length,edx
	mov ecx,eax
	mov esi, edx
LOOP_INTERNO_NOMES_PONT:

	mov dl,[esi]
	mov BYTE PTR [edi],dl
	inc esi
	inc edi
	loop LOOP_INTERNO_NOMES_PONT

	mov BYTE PTR [edi],'/'
	inc edi
	cmp ebx,5
	jb LOOP_NOMES_PONT
	mov BYTE PTR [edi],0
	mov edx,OFFSET bufferPontuacoes
	invoke Str_length,edx
	mov ecx,eax
	pop eax
	push eax
	call WriteToFile
	
	pop eax
	call CloseFile
	ret
escreveArquivoPontuacao ENDP

;-----------------------------------------------------
IntParaString PROC USES edi,
		buffer_B:PTR BYTE
		LOCAL neg_flag:BYTE
; Escreve inteiro em uma string
; em ASCII decimal.
; Receives: EAX = o inteiro e buffer_B um ponteiro a uma string que tem 12 posicoes
; Returns:  EDX = o endereço p/ a string, ECX = o tamanho da string
;-----------------------------------------------------
WI_Bufsize = 12
true  =   1
false =   0


	mov   neg_flag,false    ; assume neg_flag is false
	or    eax,eax             ; is AX positive?
	jns   WIS1              ; yes: jump to B1
	neg   eax                ; no: make it positive
	mov   neg_flag,true     ; set neg_flag to true

WIS1:
	mov   ecx,0              ; digit count = 0
	mov   edi,buffer_B
	add   edi,(WI_Bufsize-1)
	mov   ebx,10             ; will divide by 10

WIS2:
	mov   edx,0              ; set dividend to 0
	div   ebx                ; divide AX by 10
	or    dl,30h            ; convert remainder to ASCII
	dec   edi                ; reverse through the buffer
	mov   [edi],dl           ; store ASCII digit
	inc   ecx                ; increment digit count
	or    eax,eax             ; quotient > 0?
	jnz   WIS2              ; yes: divide again

	; Insert the sign.
	cmp   neg_flag,false    	; was the number positive?
	jz    WIS3              	; yes
	dec   edi	; back up in the buffer
	inc   ecx               	; increment counter
	mov   BYTE PTR [edi],'-' 	; no: insert negative sign

WIS3:	; retorna numero
	mov  edx,edi

	ret
IntParaString ENDP