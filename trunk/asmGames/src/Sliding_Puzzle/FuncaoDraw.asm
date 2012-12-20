TITLE sliding_puzzle
INCLUDE Irvine32.inc
.data
matrix_dim WORD 0608h
matrix WORD 0FFFFh, 4100h, 4101h, 4102h, 4103h, 4104h,	;8 is gray, 0 is black, F is white
			4215h, 2016h, 4217h, 3318h, 4219h, 421Ah,	;first byte is color, second byte has the value
			432Bh, 482Dh, 42DEh, 432Fh, 432Fh, 432Fh,
			4430h, 448Fh, 448Fh, 448Fh, 448Fh, 4480h,
			45AFh, 20EFh, 458Fh, 0FFFFh, 458Fh, 458Fh,
			20BFh, 21FFh, 458Fh, 458Fh, 458Fh, 458Fh,
			46CFh, 218Fh, 218Fh, 46BAh, 0FFFFh, 0FFFFh,
			46DFh, 468Fh, 468Fh, 468Fh, 0FFFFh, 0FFFFh

				

m_test WORD 0C998h, 0CD98h, 0BB98h, 0BA98h, 02098h, 0BA98h, 0C898h, 0CD98h, 0BC98h
m_size WORD 0303h
m_pos WORD 0A0Ah

draw_matrix PROTO,
	matrixAddr:PTR DWORD, dimension:WORD, position:WORD

.code

main PROC
	call Clrscr
	mov ax, 0000h
	INVOKE draw_matrix, OFFSET matrix, matrix_dim, ax

	mov ax, m_pos
	INVOKE draw_matrix, OFFSET m_test, m_size, ax

	mov eax, 0
	
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