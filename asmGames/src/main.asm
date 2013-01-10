TITLE MASM Games						(main.asm)

; Description: Menu para implementacao de jogos em assembly

INCLUDE Irvine32.inc

; Inclua um arquivo para implementacao do seu jogo aqui
INCLUDE forca/forca.asm
INCLUDE GeeckoGames/GeeckoGamesSokoban.asm
INCLUDE SpaceInvaders/Space_Invaders.asm

.data

myMenu	BYTE	80 dup ('='),
				'Laboratorio de Arquitetura e Organizacao de Computadores II', 13, 10,
				80 dup ('='),
				'Jogos em assembly do MASM para x86:', 13, 10,
				'1 - Forca', 13, 10,
				'2 - Sokoban', 13, 10,
				'3 - Space Invaders', 13, 10,
				'4 - Grupo...', 13, 10,
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
	jne Geecko
	call forca
Geecko:
	cmp eax, 2
	jne Grupo2
	call GeeckoGamesSokoban

Grupo2:
	cmp eax, 3
	jne SpaceInvaders
	call Space_Invaders
SpaceInvaders: 
	
	cmp eax, 4
	jne Grupo4
	;call Grupo4.asm 
Grupo4: ;seguir exemplo acima


	jmp menu

fim:
	exit
main ENDP

END main