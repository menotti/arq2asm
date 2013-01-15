TITLE MASM Template (main.asm)

; Description:
; 
; Revision date:


INCLUDE Irvine32.inc

.data
Centro BYTE 'Genius!'
.code

;
; Funções para criar os blocos, posicionando X e Y na tela e escrevendo o bloco a partir do cursor
;




main PROC
call ImprimeJogo

exit
main ENDP


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
; Funções para piscar os blocos, armazenando X e Y do bloco desejado, piscando ele rapidamente para branco (300ms) e logo voltando-o para a cor original
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

	call piscaAmarelo
	mov eax, 100h
	call delay

	call piscaVerde
	mov eax, 100h
	call delay

	call piscaAzul
	mov eax, 100h
	call delay

	call piscaVermelho
	mov eax, 100h
	call delay
	ret
	ImprimeJogo ENDP

END main