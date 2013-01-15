TITLE Add and Subtract              (AddSub.asm)

; This program adds and subtracts 32-bit integers.
; Last update: 06/01/2006

INCLUDE Irvine32.inc

.data
	sequencia WORD 20 dup(?)
	fraseFim BYTE "Fim do jogo.", 0
	fraseErro BYTE "Voce errou!", 0
	frasePassou BYTE "Proximo level!", 0
	fraseLeitura BYTE "Sua vez!", 0
	fraseDireita BYTE "Direita ", 0
	fraseEsquerda BYTE "Esquerda ", 0
	fraseCima BYTE "Cima ", 0
	fraseBaixo BYTE "Baixo ", 0
	Centro BYTE 'Genius!'

.code
main PROC
	mov esi, 0
	mov ecx, LENGTHOF sequencia
	mov eax, 4

	;Criando a sequencia
	aleatorio:
		push eax
		call RandomRange
		cmp ax, 0
		jz cima
		cmp ax, 1
		jz direita
		cmp ax, 2
		jz baixo
		mov sequencia[esi] , 4B00h ; esquerda
		jmp volta
	
	
		cima:
			mov sequencia[esi] , 4800h ; cima
			jmp volta
	
		direita: 
			mov sequencia[esi], 4D00h ;direita
			jmp volta

		baixo:
			mov sequencia[esi], 4D00h; baixo		
		
		volta:	
			pop eax
			add esi, TYPE sequencia
			loop aleatorio


	;Mostra sequencia do level
		
		mov edx, 0
		next:
			cmp edx, 0
			jz primeiro
			cmp edx, 10
			jz fim ; chegou ao final do jogo
			push edx
			mov edx, OFFSET frasePassou
			call WriteString
			call crlf
			pop edx
		primeiro:	
			call MostraSequencia

	;Lendo Resposta
		mov ecx, edx
		mov esi, 0
		inc ecx
		push edx
		mov edx, OFFSET fraseLeitura
		call WriteString
		call crlf
		pop edx
	
	confere: 
		call readChar ; coloca leitura em ax
		cmp sequencia[esi], ax
		jnz ERRO ; se nao sao iguais ele errou
		add esi, TYPE sequencia
		loop confere
		call crlf
		inc edx
		jmp next ; Passou de level

	ERRO:	; Fim do jogo
		push edx
		mov edx, OFFSET fraseErro
		call WriteString
		call crlf
		pop edx
		exit

	FIM:
		push edx
		mov edx, OFFSET fraseFim
		call WriteString
		call crlf
		pop edx	
	
	
	exit
main ENDP

;--------------------------------------------------------------
MostraSequencia  PROC
;
; Mostra a sequencia do vetor cor da posicao 0 ate o limite
; Receives: EDX = limite
; Returns: AL = valor da posicao[i]
; Last update: 18/12/2012
;--------------------------------------------------------------
		mov esi, 0
		mov ecx, edx
		inc ecx
		mov eax, 0
	L2:	mov ax,sequencia[esi]
		cmp ax, 4D00h ; direita
		jnz K1
		push edx
		mov edx, OFFSET fraseDireita
		call WriteString
		pop edx
		jmp fimSequencia

	K1:	cmp ax, 4800h ; cima
		jnz K2
		push edx
		mov edx, OFFSET fraseCima
		call WriteString
		pop edx
		jmp fimSequencia

	k2:	cmp ax, 4D00h; baixo
		jnz K3
		push edx
		mov edx, OFFSET fraseBaixo
		call WriteString
		pop edx
		jmp fimSequencia
	
	K3:	cmp ax, 4B00h ; esquerda
		push edx
		mov edx, OFFSET fraseEsquerda
		call WriteString
		pop edx
		jmp fimSequencia
	
	
		;Chamada para a funcao piscar bloco
	fimSequencia:
		add esi, TYPE sequencia
		mov al, 10 ; 9 eh tab, 10 pula linha
		call WriteChar
		mov eax, 200h
		call delay
		mov eax, 0
		loop L2
		call clrscr
		ret
MostraSequencia ENDP

;------------------------------------

ImprimeAmarelo PROC
		push ecx
		push edx
		push eax
		mov dl, 22
		mov dh, 5
		call gotoxy
		mov ecx, 10
	COLUNA:
		push ecx
		mov ecx, 17
	LINHA:
		mov eax,yellow
		call SetTextColor
		mov al, 219
		call WriteChar
		loop LINHA
		inc dh
		call gotoxy
		pop ecx
		loop COLUNA
		pop eax
		pop edx
		pop ecx
		ret
ImprimeAmarelo ENDP

;-----------------------------------


ImprimeAzul PROC
		push ecx
		push edx
		push eax
		mov dl, 5
		mov dh, 15
		call gotoxy 
		mov ecx, 10
	COLUNA:
		push ecx
		mov ecx, 17
	LINHA:
		mov eax,lightblue
		call SetTextColor
		mov al, 219
		call WriteChar
		loop LINHA
		inc dh
		call gotoxy
		pop ecx
		loop COLUNA
		pop eax
		pop edx
		pop ecx
		ret
ImprimeAzul ENDP

;-----------------------------------

ImprimeVerde PROC
	push ecx
	push edx
	push eax
	mov dl, 39
	mov dh, 15
	call gotoxy
	mov ecx, 10
COLUNA:
	push ecx
	mov ecx, 17
LINHA:
	mov eax,lightgreen
	call SetTextColor
	mov al, 219
	call WriteChar
	loop LINHA
	inc dh
	call gotoxy
	pop ecx
	loop COLUNA
	pop eax
	pop edx
	pop ecx
	ret	
ImprimeVerde ENDP

;-----------------------------------


ImprimeVermelho PROC
	push ecx
	push edx
	push eax
	mov dl, 22
	mov dh, 25
	call gotoxy
	mov ecx, 10
COLUNA:
	push ecx
	mov ecx, 17
LINHA:
	mov eax,lightred
	call SetTextColor
	mov al, 219
	call WriteChar
	loop LINHA
	inc dh
	call gotoxy
	pop ecx
	loop COLUNA
	pop eax
	pop edx
	pop ecx
	ret
ImprimeVermelho ENDP

;-----------------------------------

;
; Fun��es para piscar os blocos, armazenando X e Y do bloco desejado, piscando ele rapidamente para branco (300ms) e logo voltando-o para a cor original
;

Pisca PROC
	push ecx
	push edx
	push eax
	call gotoxy
mov ecx, 10
	COLUNA:
	push ecx
	mov ecx, 17
LINHA:
	mov eax,white
	call SetTextColor
	mov al, 219
	call WriteChar
	loop LINHA
	inc dh
	call gotoxy
	pop ecx
	loop COLUNA
	push eax
	mov eax, 300h
	call Delay
	pop eax
	pop eax
	pop edx
	pop ecx
	ret 
Pisca ENDP

;-----------------------------------

PiscaVermelho PROC
	push edx
	mov dl, 22
	mov dh, 25
	call Pisca
	call ImprimeVermelho
	pop edx
	ret
PiscaVermelho ENDP

;-----------------------------------

PiscaVerde PROC
	push edx
	mov dl, 39
	mov dh, 15
	call Pisca
	call ImprimeVerde
	pop edx
	ret
PiscaVerde ENDP

;-----------------------------------

PiscaAzul PROC
	push edx
	mov dl, 5
	mov dh, 15
	call Pisca
	call ImprimeAzul
	pop edx
	ret
PiscaAzul ENDP

;-----------------------------------

PiscaAmarelo PROC
	push edx
	mov dl, 22
	mov dh, 5
	call Pisca
	call ImprimeAmarelo
	pop edx
	ret
PiscaAmarelo ENDP

;-----------------------------------

ImprimeJogo PROC

	mov dl, 27
	mov dh, 20
	call gotoxy
	mov	edx, OFFSET Centro
	call WriteString

	mov eax, 100h
	call delay

	call ImprimeAmarelo
	mov eax, 100h
	call delay

	call ImprimeAzul
	mov eax, 100h
	call delay

	call ImprimeVerde
	mov eax, 100h
	call delay

	call ImprimeVermelho
	mov eax, 100h
	call delay


ImprimeJogo ENDP

END main