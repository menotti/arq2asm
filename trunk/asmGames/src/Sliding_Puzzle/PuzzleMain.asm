TITLE MASM Template						(main.asm)

; Description:
; 
; Revision date:

INCLUDE Irvine32.inc
.data
draw_matrix PROTO,
	matrixAddr:PTR DWORD, dimension:WORD, position:WORD

baixo	byte 115d ; tecla para descer na lista 
cima		byte 119d ; tecla para subir na lista 

selecionado byte 0 ; diz qual das opçoes está selecionado

;textos  usados para fazer o menu
titulo	byte "Sliding Puzzle!!!",0
jogar	byte "Jogar",0
controles byte "Controles",0
creditos	byte "Desenvolvimento",0
pontuacao byte "High Scores",0
 
.code

main PROC

mov ebx,0

l1:
Call ReadKeyFlush

;Escreve o tiulo
mov dh,0
mov dl,30d
Call Gotoxy
mov edx, OFFSET titulo
Call WriteString


;checagem para ver se essa opção está selecionada, se estiver ele fica colorido
cmp ebx,0
jne primeiro
mov eax,black+(lightblue*16)
Call SetTextColor
primeiro:

;Escreve jogar
mov dh,9
mov dl,35d
Call Gotoxy
mov edx, OFFSET jogar
Call WriteString

;volta a cor pro padrao
mov eax,white+(black*16)
Call SetTextColor

;checagem para ver se essa opção está selecionada, se estiver ele fica colorido
cmp ebx,1
jne segundo
mov eax,black+(lightblue*16)
Call SetTextColor
segundo:

;Escreve controles
mov dh,11
mov dl,33d
Call Gotoxy
mov edx, OFFSET controles
Call WriteString

;volta a cor pro padrao
mov eax,white+(black*16)
Call SetTextColor

;checagem para ver se essa opção está selecionada, se estiver ele fica colorido
cmp ebx,2
jne terceiro
mov eax,black+(lightblue*16)
Call SetTextColor
terceiro:

;Escreve a pontuação
mov dh,13
mov dl,32d
Call Gotoxy
mov edx, OFFSET pontuacao
Call WriteString

;volta a cor pro padrao
mov eax,white+(black*16)
Call SetTextColor

;checagem para ver se essa opção está selecionada, se estiver ele fica colorido
cmp ebx,3
jne quarto
mov eax,black+(lightblue*16)
Call SetTextColor
quarto:

;Escreve creditos
mov dh,15
mov dl,30d
Call Gotoxy
mov edx, OFFSET creditos
Call WriteString

;volta a cor pro padrao
mov eax,white+(black*16)
Call SetTextColor


;coloca o cursor em um lugar q ninguem ve
mov dh,24
mov dl,40d
Call Gotoxy

push ebx
;loop para receber input do teclado 
l2:	
	Call ReadKey	;le uma entrada do teclado

	cmp al,baixo	;checa se a entrada foi s 
	je descer
	cmp al,cima	;checa se a entrada foi w
	je subir
jmp l2


descer:
pop ebx
cmp ebx,3
je l1
inc ebx
jmp l1


subir:
pop ebx
cmp ebx,0
je l1
dec ebx
jmp l1


exit
main ENDP

;OBS: Custo alto, pois escreve caracter por caracter
;-------------------------------------------------------
draw_matrix PROC USES eax ebx ecx edx esi,
	matrixPtr:PTR DWORD, dimension:WORD, position:WORD
; Este procedimento eh utilizado para desenhar na tela.
; Deve-se passar como parametros o endereco da matriz de
; WORDS e o tamanho dela (largura e comprimento).
; A parte alta da WORD sera utilizada como ascii desejado,
; e a parte baixa como a cor de letra e de fundo.
; O parametro position recebera a posicao para desenhar 
; na tela, a coordenada x estara na parte alta e a y na
; parte baixa da WORD.
;-------------------------------------------------------
.code
mov esi, matrixPtr									;armazena o endereco da matriz
mov eax, 0									
mov bx, dimension									;guarda as dimensoes da matriz no registrador bh
mov ecx, 0											;zera o registrador ecx
mov dx, position									;guarda a posicao para desenhar a matriz
call Gotoxy											;aponta o cursor para a posicao desejada

L1: cmp cl, bl										;while (cl < m_height)
	jae SAIRLOOPEXTERNO
	push dx
	L2: cmp ch, bh									;while(ch < m_width)
		jae SAIRLOOPINTERNO
		inc dx

		movzx ax, bh
		mul cl
		add al, ch
		mov ax, [esi + eax * TYPE WORD]		;ax recebe o valor da matriz correspondente
		cmp ax, 0FFFFh
		jne CHARNAOVAZIO
			call Gotoxy						;se os dados forem "nulos" (FFFFh) pula-se um espaco
			jmp FIMLOOP
		CHARNAOVAZIO:
			shl eax, 8									;joga o caracter para a parte alta de eax
			shr ax, 8									;o que sobra em ax (os dados das cores) eh jogado para o comeco do registrador
			call SetTextColor							;as cores sao alteradas
			shr eax, 16									;o caracter eh rotacionado para o comeco do registrador (al)
			call WriteChar								;al eh escrito na tela
		FIMLOOP:
		inc ch
		jmp L2
	SAIRLOOPINTERNO:
	pop dx
	mov ch, 0
	inc dh
	call Gotoxy								;muda o cursor para a linha de baixo, na coordenada x correta.

	inc cl
	jmp L1
SAIRLOOPEXTERNO:

ret
draw_matrix ENDP


END main

