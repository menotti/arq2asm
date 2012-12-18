TITLE MASM Games						(main.asm)

; Description: Menu para implementacao de jogos em assembly

INCLUDE Irvine32.inc

; Inclua um arquivo para implementacao do seu jogo aqui
INCLUDE forca.asm

.data

myMenu	BYTE	80 dup ('='),
				'Laboratorio de Arquitetura e Organizacao de Computadores 2', 13, 10,
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

mforca:
	cmp eax, 1
	jne mforca
	call forca
grupo1:

	jmp menu
fim:
	exit
main ENDP

END main