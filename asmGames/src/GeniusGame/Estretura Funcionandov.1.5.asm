TITLE Add and Subtract              (AddSub.asm)

; This program adds and subtracts 32-bit integers.
; Last update: 06/01/2006

INCLUDE Irvine32.inc

.data
	sequencia WORD 20 dup(?)
	fraseAbertura1 BYTE "Esse jogo eh conhecido como Genius!!", 0
	fraseAbertura2 BYTE "Ele eh composto em ver a sequencia que o computador ira gerar", 0
	fraseAbertura3 BYTE "e repeti-lo através das setas do teclado.", 0
	fraseAguarde  BYTE "Pressione qualquer tecla para continuar ...",0
	fraseInicio BYTE "Prepare-se.", 0
	fraseFim BYTE "Parabens voce passou por todas as fases.", 0
	fraseErro BYTE "Voce errou!", 0
	frasePassou BYTE "Level: ", 0
	fraseLeitura BYTE "Sua vez!", 0
	fraseDireita BYTE "Direita ", 0
	fraseEsquerda BYTE "Esquerda ", 0
	fraseCima BYTE "Cima ", 0
	fraseBaixo BYTE "Baixo ", 0
	Centro BYTE 'Genius!'

.code
main PROC
		call Menu
		call CriaSequencia
		call ImprimeJogo
		;Mostra sequencia do level	
		mov edx, 0 ;comeca no level 0
	next:
		cmp edx, 0
		jz primeiro
		cmp edx, 10
		jz fim ; chegou ao final do jogo
		push edx
		mov eax, edx
		mov edx, OFFSET frasePassou
		call WriteString
		call writeDec
		
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
		call ImprimeJogo
		pop edx
			
	confere: 
		call readChar ; coloca leitura em ax
		cmp ax, 4B00h ; esquerda
		je ESQUERDA
		
		cmp ax, 4800h ; cima
		je CIMA
		
		cmp ax, 4D00h ; direita
		je DIREITA
		
		cmp ax, 4D00h ; baixo
		je BAIXO
	ESQUERDA:
		call PiscaAzul
		jmp Verifica	

	CIMA:
		call PiscaAmarelo
		jmp Verifica

	DIREITA:
		call PiscaVerde
		jmp Verifica

	BAIXO:
		call PiscaVermelho
		jmp Verifica
	

	Verifica:
		cmp sequencia[esi], ax
		jnz ERRO ; se nao sao iguais ele errou
		add esi, TYPE sequencia
		loop confere
		call crlf
		inc edx
		call clrScr
		jmp next ; Passou de level
		
	ERRO:	; Fim do jogo por erro
		call ClrScr
		mov edx, OFFSET fraseErro
		call WriteString
		call crlf
		exit

	FIM: ; fim do jogo por Acabar os lvl
		call ClrScr
		mov edx, OFFSET fraseFim
		call WriteString
		
	
	
	exit
main ENDP


;---------------------------------------------
Menu Proc
;Mostra as frases do menu
;----------------------------------------------
		mov edx, offset fraseAbertura1
		call WriteString
		call Crlf
		call Crlf

		mov edx, offset fraseAbertura2
		call WriteString
		call Crlf
		
		mov edx, offset fraseAbertura3
		call WriteString
		call Crlf
		call Crlf
		call Crlf
		mov edx, offset fraseAguarde
		call WriteString

		call ReadChar
		call ClrScr
		call Crlf
		call Crlf
		call Crlf
		mov edx, offset fraseInicio
		call WriteString
		mov eax, 600h
		call delay
		call ClrScr
		ret
Menu ENDP

;-----------------------------------------------
 CriaSequencia PROC
;Cria a sequencia aleatoria de comandos
;-----------------------------------------------		
		mov esi, 0
		mov ecx, LENGTHOF sequencia
		mov eax, 4
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
			ret
CriaSequencia ENDP

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
		pushad
		call ImprimeJogo
		mov eax, 500h
		call Delay
		popad
	L2:	mov ax,sequencia[esi]
		cmp ax, 4D00h ; direita
		jnz K1
		push edx
		;;DIREITA
		call piscaverde
	
		pop edx
		jmp fimSequencia

	K1:	cmp ax, 4800h ; cima
		jnz K2
		push edx
		;;CIMA
		call piscaamarelo
		
		pop edx
		jmp fimSequencia

	k2:	cmp ax, 4D00h; baixo
		jnz K3
		push edx
		;;BAIXO
		call piscavermelho
		
		pop edx
		jmp fimSequencia
	
	K3:	cmp ax, 4B00h ; esquerda
		push edx
		;;ESQUERDA
		call piscaazul
		
		pop edx
		jmp fimSequencia
	
	
		;Chamada para a funcao piscar bloco
	fimSequencia:
		add esi, TYPE sequencia
		mov al, 10 ; 9 eh tab, 10 pula linha
		call WriteChar
		mov eax, 250h
		call delay
		mov eax, 0
		loop L2
		call clrscr
		ret
MostraSequencia ENDP

;------------------------------------

ImprimeAmarelo PROC USES EDX EAX ECX
		
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
		
		ret
ImprimeAmarelo ENDP

;-----------------------------------


ImprimeAzul PROC USES EDX EAX ECX
		
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
	
		ret
ImprimeAzul ENDP

;-----------------------------------

ImprimeVerde PROC USES EDX EAX ECX
	
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

	ret	
ImprimeVerde ENDP

;-----------------------------------


ImprimeVermelho PROC USES EAX ECX
	push edx
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
	pop edx
	mov edx, 0

	ret
ImprimeVermelho ENDP

;-----------------------------------

;
; Funções para piscar os blocos, armazenando X e Y do bloco desejado, piscando ele rapidamente para branco (300ms) e logo voltando-o para a cor original
;

Pisca PROC USES EDX EAX ECX
	
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
	call ImprimeJogo

	ret 
Pisca ENDP

;-----------------------------------

PiscaVermelho PROC USES EDX
	
	mov dl, 22
	mov dh, 25
	call Pisca
	;call ImprimeVermelho

	ret
PiscaVermelho ENDP

;-----------------------------------

PiscaVerde PROC USES EDX
	
	mov dl, 39
	mov dh, 15
	call Pisca
	;call ImprimeVerde
	ret
PiscaVerde ENDP

;-----------------------------------

PiscaAzul PROC USES EDX

	mov dl, 5
	mov dh, 15
	call Pisca
	;call ImprimeAzul

	ret
PiscaAzul ENDP

;-----------------------------------

PiscaAmarelo PROC USES EDX

	mov dl, 22
	mov dh, 5
	call Pisca
	;call ImprimeAmarelo

	ret
PiscaAmarelo ENDP

;-----------------------------------

ImprimeJogo PROC 
	call ImprimeAmarelo
	call ImprimeAzul
	call ImprimeVerde
	call ImprimeVermelho
	ret
ImprimeJogo ENDP

END main