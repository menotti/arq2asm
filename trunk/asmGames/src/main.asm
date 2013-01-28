TITLE MASM Games						(main.asm)

; Description: Menu para implementacao de jogos em assembly

INCLUDE Irvine32.inc
INCLUDE macros.inc

; Inclua um arquivo para implementacao do seu jogo aqui
INCLUDE forca/forca.asm
INCLUDE SlidingPuzzle/PuzzleMain.asm
INCLUDE GeeckoGames/GeeckoGamesSokoban.asm
INCLUDE SpaceInvaders/Space_Invaders.asm
INCLUDE Labirinto/labirinto.asm
;INCLUDE LaserMan/lman_proc.asm
Include Snake/snake.asm
INCLUDE Frogger/Frogger.asm

.data

myMenu	BYTE	80 dup ('='),
				'Laboratorio de Arquitetura e Organizacao de Computadores II', 13, 10,
				80 dup ('='),
				'Jogos em assembly do MASM para x86:', 13, 10,
				'1 - Forca', 13, 10,
				'2 - Sokoban', 13, 10,
				'3 - Space Invaders', 13, 10,
				'4 - Labirinto da Morte', 13, 10,
				'5 - Frogger', 13, 10,
				'6 - Snake', 13, 10,
        '7 - Sliding Puzzle', 13, 10,
				'0 - Sair!', 13, 10, 13, 10,
				'Opcao: ', 0
.code

main PROC

menu:
	mov al, white + 16*black ; reseta cores iniciais.
	call SetTextColor
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
	jne SpaceInv
	call GeeckoGamesSokoban

SpaceInv:
	cmp eax, 3
	jne Labirinto
	call Space_Invaders

Labirinto: 	
	cmp eax, 4
	jne Frogger
	call jogaLabirinto 

Frogger:
	cmp eax, 5
	jne SnakeGame
	call FROG_InitJogo

SnakeGame:
	cmp eax, 6
	jne SPuzzle
	call snake
   
SPuzzle:
  cmp eax, 7
  jne menu
  call SlidingPuzzle

jmp menu			;Para retornar ao menu depois q acabar algum jogo

fim:
	exit
main ENDP

END main