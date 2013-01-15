TITLE MASM Template						(main.asm)

; Description:
; 
; Revision date:

INCLUDE Irvine32.inc
INCLUDE Macros.inc
.data

;lista de procedimentos desenvolvidos
write_title PROTO
draw_matrix PROTO,
	matrix_ptr:DWORD, dimension:WORD, position:WORD, color:BYTE

;lista de estados
intro_state PROTO
menu_state PROTO
jogo_state PROTO
controles_state PROTO
egendary_logs_state PROTO 
desenvolvimento_state PROTO


baixo		byte 50h	; tecla para descer
cima			byte 48h ; tecla para subir 
esquerda		byte	4bh	; tecla para esquerda
direita		byte	4dh	; tecla para direita

escolha		byte 1ch	; tecla para entrar

saida		byte	1h	; tecla para voltar ao menu 

estadoAtual	byte 0	; estado em que o jogo se encontra	
selecionado	byte 0	; diz qual das opçoes está selecionado


pontuacoes	byte		"pontos.txt",0
buffer		byte		100 DUP(?),0

 
.code

main PROC

;call intro_state

mov ebx,0

LoopPrincipal:


cmp estadoAtual,0
jne jogo
Call menu_state

jogo:
cmp estadoAtual,1
jne controles
Call jogo_state


controles:
cmp estadoAtual,2
jne highscores
call controles_state

highscores:
cmp estadoAtual,3
jne desenvolvimento
call egendary_logs_state

desenvolvimento:
cmp estadoAtual,4
jne sair
call desenvolvimento_state
 
sair:
cmp estadoAtual,5
je encerrarPrograma
jmp LoopPrincipal

encerrarPrograma:
exit
main ENDP


;-------------------------------------------------------
; ID DO ESTADO: 0
menu_state PROC USES eax edx 
; Esse procedimento chama o menu, ele desenha o menu na
; tela e se encarrega da manipulação e escolha de opções
; no menu, tambem troca o estado no qual se encontra o 
; jogo.
;
;AUTOR: THIAGO FARIA
;-------------------------------------------------------
.code
Call Clrscr

mov ebx, 0

P021:

Call write_title

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
mWrite <"Jogar">

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
mWrite <"Controles">

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
mWrite <"High Scores">

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
mWrite <"Desenvolvimento">

;volta a cor pro padrao
mov eax,white+(black*16)
Call SetTextColor


;checagem para ver se essa opção está selecionada, se estiver ele fica colorido
cmp ebx,4
jne quinto
mov eax,black+(lightblue*16)
Call SetTextColor
quinto:

;Escreve saida
mov dh,17
mov dl,35d
Call Gotoxy
mWrite <"Saida">

;volta a cor pro padrao
mov eax,white+(black*16)
Call SetTextColor

;coloca o cursor em um lugar q ninguem ve
mov dh,24
mov dl,79d
Call Gotoxy

Call ReadChar


cmp ah,baixo
jne subir
cmp ebx,4
je P021
inc ebx
jmp P021


subir:
cmp ah,cima
jne escolher
cmp ebx,0
je P021
dec ebx
jmp P021

escolher:
cmp ah,escolha
jne P021
inc bl
mov estadoAtual,bl


fim:
ret
menu_state ENDP
;-------------------------------------------------------


;-------------------------------------------------------
; ID DO ESTADO: 1
jogo_state PROC
; Esse procedimento chama faz com que você possa apreciar
; essa obra-prima como um jogo, e não apenas uma história
; épica sobre um personagem épico
;
;AUTOR: THIAGO FARIA
;-------------------------------------------------------
.code
pushfd

Call clrscr

;Escreve instruções de saida
mov dh,8
mov dl,47d
Call Gotoxy
mWrite <"Pressione ESC para voltar ao menu">


Call ReadChar
cmp ah,saida
jne voltarMenu
mov estadoAtual,0

voltarMenu:
popfd
ret
jogo_state ENDP



;-------------------------------------------------------
; ID DO ESTADO: 2
controles_state PROC  
; Esse procedimento exibe os controles necessario para 
; poder jogar TioGuedes de Egend
;
;AUTOR: THIAGO FARIA
;-------------------------------------------------------
.code
pushfd
Call Clrscr

;Coloca o ponteiro no começo da tela
mov dh,0
mov dl,0d
Call Gotoxy

Call write_title

;Coloca o ponteiro em uma posição especifica para escrever as instruções
mov dh,11
mov dl,16d
Call Gotoxy
mWrite<"Use as setas direcionais para mover as EG's">
mov dh,12
Call Gotoxy
mWrite<"Use as teclas < e > para trocar a EG selecionada">
mov dh,13
Call Gotoxy
mWrite<"Ao final de cada fase, você pode salvar sua Epicness">


;Coloca o ponteiro em uma posição especifica para escrever as instruções
mov dh,24
mov dl,0d
Call Gotoxy
mWrite<"Pressione qualquer tecla para voltar para o Menu">

Call ReadChar

mov estadoAtual, 0
popfd
ret
controles_state ENDP
;-------------------------------------------------------

;-------------------------------------------------------
; ID DO ESTADO: 3
egendary_logs_state PROC USES eax ecx edx
; Nesta tela sera exibido a EPICNESS dos melhores
; jogadores, selecionados pessoalmente por TIOGAEDES,
;
; THE EGEND
;
;AUTOR: LUCAS Y e THIAGO FARIA
;-------------------------------------------------------
pushfd
call Clrscr

;abre o arquivo em que as pontuações estão salvas
mov edx, OFFSET pontuacoes
Call OpenInputFile

;grava tudo que está no arquivo em um local da memória
mov edx, OFFSET buffer
mov ecx,100
Call ReadFromFile

;passa para edx o Offset do buffer e para ecx a contagem de melhores colocados
mov edx, OFFSET buffer
mov ecx,1

;coloca na tela toda a lista de colocados
colocacao:
	mov al,[edx]
	cmp al,';'
	je listaTerminada
	cmp ecx,20
	je listaTerminada
	;numero da colocação
	mov eax,ecx
	call WriteDec
	mWrite<"º - ">
	inc ecx
		;nome e pontuação do jogador
		pontuacao:
		mov al,[edx]
		cmp al,'/'
		je proximaLinha
		cmp al,';'
		je listaTerminada		
		Call WriteChar
		inc edx
		jmp pontuacao
		proximaLinha:
		call crlf
		inc edx
jmp colocacao

listaTerminada:
;Coloca o ponteiro em uma posição especifica para escrever as instruções
mov dh,24
mov dl,0d
Call Gotoxy
mWrite<"Pressione qualquer tecla para voltar para o Menu">
call ReadChar

mov estadoAtual, 0

popfd
ret
egendary_logs_state ENDP
;-------------------------------------------------------

;-------------------------------------------------------
; ID DO ESTADO: 4
desenvolvimento_state PROC  
; Esse procedimento exibe as pessoas que tornaram 
; TioGuedes the Egend possivel
;
;AUTOR: THIAGO FARIA
;-------------------------------------------------------
.code
pushfd
Call Clrscr

;Coloca o ponteiro no começo da tela
mov dh,0
mov dl,0d
Call Gotoxy

Call write_title

;Coloca o ponteiro em uma posição especifica para escrever as instruções
mov dh,11
mov dl,16d
Call Gotoxy
mWrite<"Thiago Faria, o cara da interface">
mov dh,12
Call Gotoxy
mWrite<"Nicolas Oe, mestre da logica dos jogos">
mov dh,13
Call Gotoxy
mWrite<"Lucas Yamanaka, programador tier +9000">


;Coloca o ponteiro em uma posição especifica para escrever as instruções
mov dh,24
mov dl,0d
Call Gotoxy
mWrite<"Pressione qualquer tecla para voltar para o Menu">

Call ReadChar

mov estadoAtual, 0
popfd
ret
desenvolvimento_state ENDP
;-------------------------------------------------------


;-------------------------------------------------------
write_title PROC USES eax ebx
; Esse procedimento escreve o titulo épico do jogo de 
; uma forma legal
;
;AUTOR: THIAGO FARIA e LUCAS Y
;-------------------------------------------------------
.data
egendary_menu_title BYTE "___ _ ____ ____ ____ ____ ___  ____ ____",
						 " |  | |  | | __ |__| |___ |  \ |___ [__ ",
						 " |  | |__| |__] |  | |___ |__/ |___ ___]",
						 "___ _  _ ____   ____ ____ ____ _  _ ___ ",
						 " |  |__| |___   |___ | __ |___ |\ | |  \",
						 " |  |  | |___   |___ |__] |___ | \| |__/"
.code
call Randomize
call GetTextColor
mov bx, ax
call Random32
shr al, 4

INVOKE draw_matrix, OFFSET egendary_menu_title, 2806h, 0214h, al

mov ax, bx
call SetTextColor

ret
write_title ENDP
;-------------------------------------------------------


;------------------------------------------------------------------
draw_matrix PROC USES eax ebx ecx edx esi,
	matrix_ptr:DWORD, dimension:WORD, position:WORD, color:BYTE
; Desenha uma matriz na tela com a cor especificada. 0FFh significa
; que, naquela posicao, o programa devera pular o caractere.
;
;Recebe: matrix_ptr: endereco do vetor contendo a matriz
;		 dimension: dimensoes da matriz, parte alta recebe width
;		 position: posicao na tela, parte alta recebe a coord Y
;		 color: cores escolhidas. Ex: BLACK + (WHITE*16)
;
;AUTOR: LUCAS Y
;------------------------------------------------------------------
;passa os parametros para registradores
mov esi, matrix_ptr
mov bx, dimension
mov dx, position
movzx ax, color

call SetTextColor	;muda as cores da letra e do fundo para as escolhidas

mov eax, 0
mov ecx, 0
call Gotoxy			;vai para a posicao guardada em dx
P01L1:
	cmp cl, bl
	jae P01SAIRLOOPEXTERNO
	push dx
	P01L2:
		cmp ch, bh
		jae P01SAIRLOOPINTERNO
		inc dx

		movzx ax, bh
		mul cl
		add al, ch
		mov al, [esi + eax * TYPE BYTE]
		cmp al, 0FFh
		jne P01CHARNAOVAZIO
			call Gotoxy
			jmp P01FIMLOOP
		P01CHARNAOVAZIO:
			call WriteChar
		P01FIMLOOP:
		inc ch
		jmp P01L2
	P01SAIRLOOPINTERNO:
	pop dx
	mov ch, 0
	inc dh

	call Gotoxy

	inc cl
	jmp P01L1
P01SAIRLOOPEXTERNO:
mov ax, WHITE + (BLACK*16)
call SetTextColor
ret
draw_matrix ENDP
;--------------------------------------------------------------


;------------------------------------------------------------------------
intro_state PROC USES ecx
;animacao inicial do jogo, apenas para deixar o jogo um pouco mais EGEND
;
;AUTOR: LUCAS Y
;------------------------------------------------------------------------
.data
;aqui estao armazenadas as coisas que serao desenhadas na tela

t_letter_dim WORD 0B07h
t_letter BYTE " _________ |  _   _  ||_/ | | \_|    | |       _| |_     |_____|             "

i_letter_dim WORD 0507h
i_letter BYTE "  _   (_)  __  [  |  | | [___]     "

o_letter_dim WORD 0807h
o_letter BYTE "                  .--.  / .'`\ \| \__. | '.__.'         "

g_letter_dim WORD 0B07h
g_letter BYTE "   ______   .' ___  | / .'   \_| | |   ____ \ `.___]  | `._____.'            "

a_letter_dim WORD 0707h
a_letter BYTE "               ,--.  `'_\ : // | |,\'-;__/       "

e_letter_dim WORD 0707h
e_letter BYTE "               .---. / /__\\| \__., '.__.'       "

d_letter_dim WORD 0A07h
d_letter BYTE "       __       |  ]  .--.| | / /'`\' | | \__/  |  '.__.;__]          "

s_letter_dim WORD 0707h
s_letter BYTE "               .--.  ( (`\]  `'.'. [\__) )       "

h_letter_dim WORD 0907h
h_letter BYTE " __      [  |      | |--.   | .-. |  | | | | [___]|__]         "

ue_letter_dim WORD 0A07h
ue_letter BYTE " ________ |_   __  |  | |_ \_|  |  _| _  _| |__/ ||________|          "

lg_letter_dim WORD 0807h
lg_letter BYTE "                  .--./) / /'`\; \ \._// .',__` ( ( __))"

n_letter_dim WORD 0907h
n_letter BYTE "                   _ .--.  [ `.-. |  | | | | [___||__]         "

tiogaedes_dim WORD 0606h
tiogaedes BYTE " / X\  \ V/, /|J\3O ||   //\\ //  ||"

.code
;desenha as letras na tela, uma a uma, enquanto TIOGAEDES sofre alteracoes periodicamente.
INVOKE draw_matrix, OFFSET t_letter, t_letter_dim, 0202h, LIGHTRED
mov eax, 200
call Delay
INVOKE draw_matrix, OFFSET i_letter, i_letter_dim, 020Dh, LIGHTRED
call Delay
INVOKE draw_matrix, OFFSET o_letter, o_letter_dim, 0213h, LIGHTRED
INVOKE draw_matrix, OFFSET tiogaedes, tiogaedes_dim, 1221h, GRAY
call Delay
INVOKE draw_matrix, OFFSET g_letter, g_letter_dim, 021Bh, LIGHTRED
call Delay
INVOKE draw_matrix, OFFSET a_letter, a_letter_dim, 0226h, LIGHTRED
call Delay
INVOKE draw_matrix, OFFSET e_letter, e_letter_dim, 022Dh, LIGHTRED
call Delay
INVOKE draw_matrix, OFFSET d_letter, d_letter_dim, 0234h, LIGHTRED
call Delay
INVOKE draw_matrix, OFFSET e_letter, e_letter_dim, 023Eh, LIGHTRED
call Delay
INVOKE draw_matrix, OFFSET s_letter, s_letter_dim, 0245h, LIGHTRED
INVOKE draw_matrix, OFFSET tiogaedes, tiogaedes_dim, 1221h, LIGHTGRAY

mov eax, 500
call Delay

INVOKE draw_matrix, OFFSET t_letter, t_letter_dim, 0C02h, LIGHTGRAY
mov eax, 150
call Delay
INVOKE draw_matrix, OFFSET h_letter, h_letter_dim, 0B0Dh, LIGHTGRAY
call Delay
INVOKE draw_matrix, OFFSET e_letter, e_letter_dim, 0A16h, LIGHTGRAY
INVOKE draw_matrix, OFFSET tiogaedes, tiogaedes_dim, 1221h, WHITE
call Delay
INVOKE draw_matrix, OFFSET ue_letter, ue_letter_dim, 0920h, LIGHTGRAY
call Delay
INVOKE draw_matrix, OFFSET lg_letter, lg_letter_dim, 092Ah, LIGHTGRAY
call Delay
INVOKE draw_matrix, OFFSET e_letter, e_letter_dim, 0A32h, LIGHTGRAY
call Delay
INVOKE draw_matrix, OFFSET n_letter, n_letter_dim, 0B39h, LIGHTGRAY
call Delay
INVOKE draw_matrix, OFFSET d_letter, d_letter_dim, 0C42h, LIGHTGRAY
mov eax, 500
call Delay

;a cada 75ms, tiogaedes mudara de cor, e isto se repetira 60 vezes
mov eax, 75
mov ecx, 60

introStateLoop:
	push eax
	call Random32
	shr al, 4
	INVOKE draw_matrix, OFFSET tiogaedes, tiogaedes_dim, 1221h, al
	pop eax
	call Delay

	loop introStateLoop

mov eax, 0
mov estadoAtual, al
call Clrscr
ret
intro_state ENDP
;----------------------------------------------------------------------------


END main