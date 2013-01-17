MAX = 4096

.data

; mensagens
msgErroBoneco	BYTE "Nao foi possivel carregar o arquivo boneco.txt", 13, 10, 0
msgErroPalavras	BYTE "Nao foi possivel carregar o arquivo palavras.txt", 13, 10, 0
msgForca		BYTE "Forca!!!", 13, 10, 0
msgVenceu		BYTE "Parabens, voce venceu!!!", 13, 10, 0

; nomes dos arquivos auxiliares
fBoneco BYTE  "src\forca\boneco.txt", 0
fPalavras BYTE "src\forca\palavras.txt", 0

; handler dos arquivos auxiliares
hBoneco DWORD ?
hPalavras DWORD ?

; boneco na memoria
; '*' separa os frames
boneco BYTE MAX DUP(0),0

; palavras na memoria
; primeira linha contem o numero de palavras do arquivo
; necessita de uma linha em branco no final do arquivo
palavras BYTE MAX DUP(0),0

; numero de tentativas restantes: 7 (default)
tentativas BYTE ?

.code

; abre arquivo do boneco e le conteudo seu conteudo
; eax = 0 (ok)
carregaBoneco PROC uses edx
	mov edx, OFFSET fBoneco
	call OpenInputFile
	cmp eax, INVALID_HANDLE_VALUE
	je erroBoneco
	mov hBoneco, eax
	mov edx, OFFSET boneco
	mov ecx, MAX
	call ReadFromFile
	; fecha arquivo
	mov eax, hBoneco
	call CloseFile
	mov eax, 0
	ret
erroBoneco:
	mov eax, -1
	ret
carregaBoneco ENDP

carregaPalavras PROC uses edx
	; abre arquivo e le conteudo
	mov edx, OFFSET fPalavras
	call OpenInputFile
	cmp eax, INVALID_HANDLE_VALUE
	je erroPalavras
	mov hPalavras, eax
	mov edx, OFFSET palavras
	mov ecx, MAX
	call ReadFromFile
	; fecha arquivo
	mov eax, hPalavras
	call CloseFile
	mov eax, 0
	ret
erroPalavras:
	mov eax, -1
	ret
carregaPalavras ENDP

forca PROC uses edx eax
	call Clrscr
	mov tentativas, 7

	mov edx, OFFSET msgErroBoneco
	call carregaBoneco
	cmp eax, 0
	jne terminaForca

	mov edx, OFFSET msgErroPalavras
	call carregaPalavras
	cmp eax, 0
	jne terminaForca

	; desenha boneco passo a passo
	mov edx, OFFSET msgForca
	mov esi, OFFSET boneco
desenhaForca:
	mov al, [esi]
	cmp al, '@'
	je terminaForca
	cmp al, '*'
	jne segueForca
	call ReadChar
	call Clrscr
segueForca:
	call WriteChar
	inc esi
	jmp desenhaForca


terminaForca:
	call WriteString
	call WaitMsg
	ret
forca ENDP