TITLE MASM Games						(main.asm)

; Description:
; 
; Revision date:

INCLUDE Irvine32.inc
INCLUDE Grupo0forca.asm

.data

myMenu	BYTE	80 dup ('='),
				'Laboratorio de Arquitetura e Organizacao de Computadores II', 13, 10,
				80 dup ('='),
				'Jogos em assembly do MASM para x86:', 13, 10,
				'1 - Forca', 13, 10,
				'0 - Sair!', 13, 10,
				'Opcao:', 0
.code

main PROC

menu:
	call Clrscr
	mov edx, offset myMenu
	call WriteString
	call ReadInt
	cmp eax, 0
	jz fim

grupo0:
	cmp eax, 1
	jne grupo1
	call forca
grupo1:

	jmp menu
fim:
	exit
main ENDP

END main