	TITLE MASM Template						(main.asm)

; Description:
; 
; Revision date:

INCLUDE Irvine32.inc


.data
messageErro BYTE "Nao foi possivel carregar o arquivo desejado.", 0dh, 0ah, 0
message1 BYTE "- O tempo parou quando te conheci...", 0
message2 BYTE "- E o meu coracao parou quando voce foi embora...", 0
message3 BYTE "- Ela sumiu... me abandonou...", 0
message4 BYTE "- Serah mesmo que ela me abandonou?", 0
message5 BYTE "- O que eh isso no chao?", 0
message6 BYTE "- Pegadas?",	 0
message7 BYTE "- Para onde elas estao me levando?", 0
message8 BYTE "- Uma caverna...", 0
tamanhoX DWORD 64
tamanhoY DWORD 24
tamanhoM DWORD 1650 

mem1 BYTE 1650 DUP (0) ; 1650 = 25 linhas * 66 colunas
mem2 BYTE 1650 DUP (0) ; 1650 = 25 linhas * 66 colunas
mem3 BYTE 3650 DUP (0) 

nomeArqLore1 BYTE "c:/lore1.txt", 0
nomeArqLore2 BYTE "c:/lore2.txt", 0
nomeArqLore3 BYTE "c:/lore3t.txt", 0
.code

main PROC


call LoreInicial

exit
main ENDP

LoreInicial PROC USES edx eax esi
mov eax, 0

;primeira frase
mov eax, 50
mov esi, OFFSET message1
mov ecx, LENGTHOF message1
L11:
Call Delay
mov eax, [esi]
Call WriteChar
mov eax, 50
inc esi
Loop L11
call ReadChar
call Clrscr

;primeiro cenário
mov esi, OFFSET mem1
mov edx, OFFSET nomeArqLore1
call OpenInputFile
cmp eax, INVALID_HANDLE_VALUE
je fim
mov edx, OFFSET mem1
mov ecx, tamanhoM
call ReadFromFile


L1:
	mov ax, [esi]
	cmp ax, ';'
	je final
	call WriteChar
	inc esi
	final:
	Loop L1
	call ReadChar
	call Clrscr
fim:

;segunda frase
mov eax, 50
mov esi, OFFSET message2
mov ecx, LENGTHOF message2
L12:
Call Delay
mov eax, [esi]
Call WriteChar
mov eax, 50
inc esi
Loop L12
call ReadChar
call Clrscr

;segundo cenário
mov esi, OFFSET mem2
mov edx, OFFSET nomeArqLore2
call OpenInputFile
cmp eax, INVALID_HANDLE_VALUE
je fim2
mov edx, OFFSET mem2
mov ecx, tamanhoM
call ReadFromFile
mov ecx, tamanhoM

L2:
	mov ax, [esi]
	cmp ax, ';'
	je final2
	call WriteChar
	inc esi
	final2:
	Loop L2
	call ReadChar
	call clrscr
fim2:

;terceira frase
mov eax, 50
mov esi, OFFSET message3
mov ecx, LENGTHOF message3
L13:
Call Delay
mov eax, [esi]
Call WriteChar
mov eax, 50
inc esi
Loop L13
call ReadChar
call Crlf
call Crlf

;quarta frase
mov eax, 50
mov esi, OFFSET message4
mov ecx, LENGTHOF message4
L14:
Call Delay
mov eax, [esi]
Call WriteChar
mov eax, 50
inc esi
Loop L14
call ReadChar
call Crlf
call Crlf

;quinta frase
mov eax, 50
mov esi, OFFSET message5
mov ecx, LENGTHOF message5
L15:
Call Delay
mov eax, [esi]
Call WriteChar
mov eax, 50
inc esi
Loop L15
call ReadChar
call Crlf
call Crlf


;sexta frase
mov eax, 50
mov esi, OFFSET message6
mov ecx, LENGTHOF message6
L16:
Call Delay
mov eax, [esi]
Call WriteChar
mov eax, 50
inc esi
Loop L16
call ReadChar
call Crlf
call Crlf


;sétima frase
mov eax, 50
mov esi, OFFSET message7
mov ecx, LENGTHOF message7
L17:
Call Delay
mov eax, [esi]
Call WriteChar
mov eax, 50
inc esi
Loop L17
call ReadChar
call Crlf
call Crlf


;oitava frase
mov eax, 50
mov esi, OFFSET message8
mov ecx, LENGTHOF message8
L18:
Call Delay
mov eax, [esi]
Call WriteChar
mov eax, 50
inc esi
Loop L18
call ReadChar
call Crlf
call Crlf


;terceiro cenário
mov esi, OFFSET mem3
mov edx, OFFSET nomeArqLore3
call OpenInputFile
cmp eax, INVALID_HANDLE_VALUE
je fim3
mov edx, OFFSET mem3
mov ecx, tamanhoM
call ReadFromFile
mov ecx, 1650
L3:
	mov ax, [esi]
	call WriteChar
	inc esi
	Loop L3
	call ReadChar
	call Clrscr
fim3:

ret
LoreInicial ENDP

END main