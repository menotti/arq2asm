MAX = 4096

.data

fBoneco BYTE  "src\forca\hangman.txt", 0
boneco BYTE MAX DUP(0),0

.code

forca PROC uses edx eax
	; abre arquivo e le conteudo
	mov edx, OFFSET fBoneco
	call OpenInputFile
	cmp eax, INVALID_HANDLE_VALUE
	je deadMan
	mov edx, OFFSET boneco
	mov ecx, MAX
	call ReadFromFile
	; POG: ecx deveria conter o numero de bytes lido
	mov ecx, MAX	
	mov esi, OFFSET boneco
l1:
	mov al, [esi]
	cmp al, '*'
	jne segue
	call ReadChar
	call Clrscr
segue:
	call WriteChar
	inc esi
	loop L1
	
	
deadMan:
	ret
forca ENDP