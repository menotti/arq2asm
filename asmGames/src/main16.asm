TITLE MASM Games						(main.asm)

; Description: Menu para implementacao de jogos em assembly
; Versao 16 bits para execucao no processador Zet

INCLUDE Irvine16.inc

; Inclua um arquivo para implementacao do seu jogo aqui
;INCLUDE forca.asm

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
	mov dx, offset myMenu
	call WriteString
	call ReadInt
	cmp ax, 0
	jz fim

grupoX:
	; novas opcoes

	jmp menu
fim:

	exit
main ENDP

END main