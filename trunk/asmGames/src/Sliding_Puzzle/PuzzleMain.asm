TITLE MASM TioGaedes					

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
resposta_entrada PROTO
ExibirDicas PROTO
MovePiece PROTO
VerifyCollision PROTO
VerifyEGENDNESS PROTO
IntParaString PROTO,
 buffer_B:PTR BYTE


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

pedidoDica	byte 116d	; tecla para comprar uma dica

estadoAtual	byte 0	; estado em que o jogo se encontra	
selecionado	byte 0	; diz qual das opçoes está selecionado

proxEG		byte 100d	; tecla para ir para a proxima EG
antEG		byte	97d	; tecla para ir para a EG anterior

pontuacao		dword 0	;pontuação que o jogador recebeu por jogar TioGaedes

pontosFase	dword 100000000	;pontuação que você começa em uma fase


;vetores auxiliares para a ordenação da pontuação
iniciais		byte  63 DUP(?)
chaves		dword 21 DUP(0)


faseAtual		byte 0	;fase em q TioGaedes se encontra e que o jogador está jogando

EGescolhida	byte 0	;posição da eg escolhida
EGantEscolhida byte 0 ;posicao da eg previamente escolhida
VoidEgendPos BYTE 0

pontuacoes	byte		"pontos.txt",0
dicas		byte		"aquinaotemdicas/0.txt",0
mapa			byte		"mapas/0.txt",0
confCompraDica BYTE 0
dicasCompradas	byte 0	;numero de dicas que o jogador pediu
valorDica DWORD 0
buffer		byte		280 DUP(?),0
MapCovered BYTE 64 DUP(0)
MapInfo BYTE 70 DUP(0)
movCount DWORD 0

EpicWinAux BYTE 0

CursorInfoA DWORD 1 
CursorInfoB DWORD 0
.code

main PROC

Call Clrscr
Call Randomize

INVOKE GetStdHandle, STD_OUTPUT_HANDLE
INVOKE SetConsoleCursorInfo, EAX, ADDR CursorInfoA

call intro_state

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

push ebx
mov eax, 30
call Delay
call ReadKey
pop ebx


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
;AUTOR: THIAGO FARIA, LUCAS Y, NICOLAS OE
;-------------------------------------------------------
.data
interface_layout_upperleft BYTE 0C9h, 38 DUP(0CDh), 0BBh,
								0BAh, 6 DUP(20h), 0C9h, 24 DUP(0CDh), 0BBh, 6 DUP(20h), 0BAh,
								16 DUP( 0BAh, 6 DUP(20h), 0BAh, 24 DUP(20h), 0BAh, 6 DUP(20h), 0BAh ),
								0BAh, 6 DUP(20h), 0C8h, 24 DUP(0CDh), 0BCh, 6 DUP(20h), 0BAh

interface_layout_lowerleft BYTE 0BAh, 0C9h, 36 DUP(0CDh), 0BBh, 0BAh,
								3 DUP( 0BAh, 0BAh, 36 DUP(20h), 0BAh, 0BAh ),
								0BAh, 0C8h, 36 DUP(0CDh), 0BCh, 0BAh,
								0C8h, 38 DUP(0CDh), 0BCh

interface_layout_right BYTE 0C9h, 38 DUP(0CDh), 0BBh, 23 DUP( 0BAh, 38 DUP(20h), 0BAh ), 0C8h, 38 DUP(0CDh), 0BCh

.code
pushfd
;inicializacao

call LoadMap	;carrega o mapa;carrega o mapa
;cria o mapa de posicoes ocupadas
call GenerateMapCovered

INVOKE draw_matrix, OFFSET interface_layout_upperleft, 2813h, 0000h, YELLOW + RED*16
INVOKE draw_matrix, OFFSET interface_layout_lowerleft, 2806h, 1300h, YELLOW + RED*16
INVOKE draw_matrix, OFFSET interface_layout_right, 2819h, 0028h, YELLOW + RED*16

mov dx, 0
call Gotoxy

call CarregarDicas

;adiciona para a pontuação do jogador os pontos máximos da fase
mov eax,pontosFase
add pontuacao,eax

GameLoop:	;game loop

call ExibirDicas
call ExibirPontuacao
call ExibirMovimentos

mov eax, OFFSET MapInfo
;desenha o mapa na tela
call draw_map

;espera por um input do usuario
Call ReadChar

;decide a resposta referente à tecla pressionada
call resposta_entrada


cmp estadoAtual,0
jne GameLoop

popfd
ret
jogo_state ENDP
;-------------------------------------------------------



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
		pontos:
		mov al,[edx]
		cmp al,'/'
		je proximaLinha
		cmp al,';'
		je listaTerminada		
		Call WriteChar
		inc edx
		jmp pontos
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
		jnc dmx_NAOAJUSTA
		inc ah
		dmx_NAOAJUSTA:
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


;-----------------------------------------
draw_map PROC USES eax ebx ecx edx
;
;Receives: eax= map's offset
;Returns: just a map, EGENDARILY drawn
;
;AUTOR: LUCAS Y
;-----------------------------------------
.data
EG_WALL BYTE 9 DUP(0B1h)
EG_PIECE_1 BYTE 0C9h, 0CAh, 0BBh, 0C8h, 0CBh, 0BCh
EG_PIECE_2 BYTE 0CAh, 0BBh, 0CCh, 0CBh, 0CBh, 0CAh, 0CBh, 0CAh, 0CAh, 0B9h, 0C8h, 0CBh
EG_PIECE_3 BYTE 0C9h, 0CEh, 0BBh, 0BCh, 0BAh, 0C8h, 0BBh, 0BAh, 0C9h, 0C8h, 0CEh, 0BCh
EG_MASTERPIECE BYTE 218, 196, 208, 196, 196, 191, 179, 201, 190, 205, 162, 179, 179, 228, 204, 187, 032, 179, 192, 196, 186, 219, 196, 217
EG_ZERO BYTE 6 DUP(20h)

.code
;desenha os objetos do mapa 
mov ecx, 0
push eax
draw_map_L1:
	cmp ch, 8
	je draw_map_SAIRL1

	draw_map_L2:
		cmp cl, 8
		je draw_map_SAIRL2

		mov bl, [eax]	;bl recebe o conteudo de eax

		cmp bl, 0
		je draw_map_END

		;poe as coordenadas em dx e as multiplica pela dimensao dos tiles para encontrar a posicao na tela
		mov dx, cx
		shl dx, 1	;dx * 2
		add dl, cl	;dl + cl
		add dx, 0208h

		cmp bl, 1
		jne dm_NOTWALL
			INVOKE draw_matrix, OFFSET EG_WALL, 0302h, dx, BROWN + 16*RED
			jmp draw_map_END
		dm_NOTWALL:
		cmp bl, 6
		jne dm_NP1
			INVOKE draw_matrix, OFFSET EG_PIECE_1, 0302h, dx, GRAY + 16*BLUE
			jmp draw_map_END
		dm_NP1:
		cmp bl, 7
		jne dm_NP2
			INVOKE draw_matrix, OFFSET EG_PIECE_2, 0602h, dx, GRAY + 16*WHITE
			jmp draw_map_END
		dm_NP2:
		cmp bl, 8
		jne dm_NP3
			INVOKE draw_matrix, OFFSET EG_PIECE_3, 0304h, dx, GRAY + 16*GREEN
			jmp draw_map_END
		dm_NP3:

		cmp bl, 5
		jne draw_map_END
			INVOKE draw_matrix, OFFSET EG_MASTERPIECE, 0604h, dx, YELLOW + 16*RED

		draw_map_END:

		inc eax
		inc cl
		jmp draw_map_L2
	draw_map_SAIRL2:
	mov cl, 0

	inc ch
	jmp draw_map_L1
draw_map_SAIRL1:
pop eax

;desenha a peca selecionada
movzx edx, EGescolhida
mov al, [eax + edx]
call GetEgendCoords

mov cl, dl
shl dx, 1
add dl, cl
add dx, 0208h

cmp al, 6
jne dm_SP1
	INVOKE draw_matrix, OFFSET EG_PIECE_1, 0302h, dx, LIGHTRED + 16*BLUE
	jmp draw_map_SP_END


dm_SP1:
cmp al, 7
jne dm_SP2
	INVOKE draw_matrix, OFFSET EG_PIECE_2, 0602h, dx, LIGHTRED + 16*WHITE
	jmp draw_map_SP_END


dm_SP2:
cmp al, 8
jne dm_SP3
	INVOKE draw_matrix, OFFSET EG_PIECE_3, 0304h, dx, LIGHTRED + 16*GREEN
	jmp draw_map_SP_END

cmp al, 5
jne draw_map_SP_END
dm_SP3:
	INVOKE draw_matrix, OFFSET EG_MASTERPIECE, 0604h, dx, LIGHTRED + 16*RED

draw_map_SP_END:
ret
draw_map ENDP
;-----------------------------------------


;-----------------------------------------
resposta_entrada PROC
;
; Receives: 
; ah=codigo especial da entrada	
; al=codigo da entrada na tabela ascii
; Returns: um jogo Egendary 
;
;AUTOR: THIAGO FARIA
;-----------------------------------------


;ve se apertou esc
cmp ah,saida
je voltarMenu



;se apertou para cima
cmp ah,cima
jne paraBaixo
mov al, EGescolhida	; posição qualquer pra testar, depois entender como funciona isso com o nicolas
mov ebx, 0	; codigo de colisão para colisão para cima
Call VerifyCollision
;testa se a colisão realmente ocorreu e trata a colisão
cmp edx,0
je ToTheEgend	; se não teve colisão ele movimenta
jmp finalizar


;se apertou para baixo
paraBaixo:
cmp ah,baixo
jne paraEsquerda
mov al, EGescolhida	; posição qualquer pra testar, depois entender como funciona isso com o nicolas
mov ebx, 1	; codigo de colisão para colisão para baixo
Call VerifyCollision
;testa se a colisão realmente ocorreu e trata a colisão
cmp edx,0
je ToTheEgend	; se não teve colisão ele movimenta
jmp finalizar

;se apertou para esquerda
paraEsquerda:
cmp ah,esquerda
jne paraDireita
mov al, EGescolhida		; posição qualquer pra testar, depois entender como funciona isso com o nicolas
mov ebx, 2	; codigo de colisão para colisão para a esquerda
Call VerifyCollision
;testa se a colisão realmente ocorreu e trata a colisão
cmp edx,0
je ToTheEgend	; se não teve colisão ele movimenta
jmp finalizar

;se apertou para direita
paraDireita:
cmp ah,direita
jne trocaEG
mov al, EGescolhida	; posição qualquer pra testar, depois entender como funciona isso com o nicolas
mov ebx, 3	; codigo de colisão para colisão para a direita
Call VerifyCollision
;testa se a colisão realmente ocorreu e trata a colisão
cmp edx,0
je ToTheEgend	; se não teve colisão ele movimenta
jmp finalizar


;se apertou < ou > para trocar de EG
trocaEG:
;se apertou >
cmp al,proxEG
jne voltaEG
push eax
mov esi, OFFSET MapInfo
movzx eax, EGescolhida
call NextEGSelect
pop eax
jmp finalizar

;se apertou <
voltaEG:
cmp al,antEG
jne compraDica
push eax
mov esi, OFFSET MapInfo
movzx eax, EGescolhida
call PrevEGSelect
pop eax
jmp finalizar

;se apertou T para comprar uma dica
compraDica:
cmp dicasCompradas, 3
je finalizar

cmp confCompraDica, 1
je EGUnleash

push eax
push edx
push ebx
mov ax, YELLOW+RED*16
call SetTextColor
mov dx, 0429h
call Gotoxy
mWrite "Deseja receber uma dica de TioGaedes?"
inc dh
call Gotoxy
mWrite "Para ve-la, tecle T. EG Cost: "
movzx eax, dicasCompradas
inc eax
mov ebx, 100000
mul ebx
mov valorDica, eax
call WriteDec
pop ebx
pop edx
pop eax
mov confCompraDica, 1
jmp finalizar

EGUnleash:
cmp al,pedidoDica
jne finalizar
mov confCompraDica, 0
inc dicasCompradas
mov ebx, valorDica
sub pontuacao, ebx
jmp finalizar

voltarMenu:
mov estadoAtual,0
jmp finalizar

ToTheEgend:
Call MovePiece
cmp EpicWinAux, 1
je EGEND
call GenerateMapCovered
inc movCount
cmp pontuacao,0
je finalizar
sub pontuacao,5000
jmp finalizar

EGEND:
call EGEND_state;chama tela de vitoria
jmp voltarMenu

finalizar:

ret
resposta_entrada ENDP
;-----------------------------------------

;------------------------------------------------------
VerifyCollision PROC USES ecx
;
; Verifies the EGENDNESS of the collision
; Receives: AL receives the position. EBX receives the moviment
; UP, DOWN, LEFT, RIGHT
; 0 ,  1  ,  2  ,   3
; Returns: If NO COLLISION EDX = 0, if COLLISION EDX = 1
;
;AUTOR: NICOLAS OE
;------------------------------------------------------

movzx eax, al

cmp MapInfo[eax], 5
je PecaMae

cmp MapInfo[eax], 6
je PecaMenor

cmp MapInfo[eax], 7
je PecaDeitada

cmp MapInfo[eax], 8
je PecaEmPe


PecaMenor:

cmp ebx, 0
je PecaMenorUp

cmp ebx, 1
je PecaMenorDown

cmp ebx, 2
je PecaMenorLeft

cmp ebx, 3
je PecaMenorRight

PecaMenorUp:
movzx ecx, al
sub ecx, 8
cmp MapCovered[ecx], 1
je Collision
cmp MapCovered[ecx], 2
je Collision
jmp NoCollision

PecaMenorDown:
movzx ecx, al
add ecx, 8
cmp MapCovered[ecx], 1 
je Collision
cmp MapCovered[ecx], 2
je Collision
jmp NoCollision

PecaMenorLeft:
movzx ecx, al
sub ecx, 1
cmp MapCovered[ecx], 1
je Collision
cmp MapCovered[ecx], 2
je Collision
jmp NoCollision

PecaMenorRight:
movzx ecx, al
add ecx, 1
cmp MapCovered[ecx], 1
je Collision
cmp MapCovered[ecx], 2
je Collision
jmp NoCollision


PecaDeitada:

cmp ebx, 0
je PecaDeitadaUp

cmp ebx, 1
je PecaDeitadaDown

cmp ebx, 2
je PecaDeitadaLeft

cmp ebx, 3
je PecaDeitadaRight

PecaDeitadaUp:
movzx ecx, al
sub ecx, 8
cmp MapCovered[ecx], 1
je Collision
cmp MapCovered[ecx], 2
je Collision
add ecx, 1
cmp MapCovered[ecx], 1
je Collision
cmp MapCovered[ecx], 2
je Collision
jmp NoCollision

PecaDeitadaDown:
movzx ecx, al
add ecx, 8
cmp MapCovered[ecx], 1 
je Collision
cmp MapCovered[ecx], 2
je Collision
add ecx, 1
cmp MapCovered[ecx], 1 
je Collision
cmp MapCovered[ecx], 2
je Collision
jmp NoCollision

PecaDeitadaLeft:
movzx ecx, al
sub ecx, 1
cmp MapCovered[ecx], 1
je Collision
cmp MapCovered[ecx], 2
je Collision
jmp NoCollision

PecaDeitadaRight:
movzx ecx, al
add ecx, 2
cmp MapCovered[ecx], 1
je Collision
cmp MapCovered[ecx], 2
je Collision
jmp NoCollision

PecaEmPe:

cmp ebx, 0
je PecaEmPeUp

cmp ebx, 1
je PecaEmPeDown

cmp ebx, 2
je PecaEmPeLeft

cmp ebx, 3
je PecaEmPeRight

PecaEmPeUp:
movzx ecx, al
sub ecx, 8
cmp MapCovered[ecx], 1
je Collision
cmp MapCovered[ecx], 2
je Collision
jmp NoCollision

PecaEmPeDown:
movzx ecx, al
add ecx, 16
cmp MapCovered[ecx], 1 
je Collision
cmp MapCovered[ecx], 2
je Collision
jmp NoCollision

PecaEmPeLeft:
movzx ecx, al
sub ecx, 1
cmp MapCovered[ecx], 1
je Collision
cmp MapCovered[ecx], 2
je Collision
add ecx, 8
cmp MapCovered[ecx], 1 
je Collision
cmp MapCovered[ecx], 2
je Collision
jmp NoCollision

PecaEmPeRight:
movzx ecx, al
add ecx, 1
cmp MapCovered[ecx], 1
je Collision
cmp MapCovered[ecx], 2
je Collision
add ecx, 8
cmp MapCovered[ecx], 1 
je Collision
cmp MapCovered[ecx], 2
je Collision
jmp NoCollision

PecaMae:

cmp ebx, 0
je PecaMaeUp

cmp ebx, 1
je PecaMaeDown

cmp ebx, 2
je PecaMaeLeft

cmp ebx, 3
je PecaMaeRight

PecaMaeUp:
movzx ecx, al
sub ecx, 8
cmp MapCovered[ecx], 1
je Collision
add ecx, 1
cmp MapCovered[ecx], 1
je Collision
jmp NoCollision

PecaMaeDown:
movzx ecx, al
add ecx, 16
cmp MapCovered[ecx], 1 
je Collision
add ecx, 1
cmp MapCovered[ecx], 1 
je Collision
jmp NoCollision

PecaMaeLeft:
movzx ecx, al
sub ecx, 1
cmp MapCovered[ecx], 1
je Collision
add ecx, 8
cmp MapCovered[ecx], 1 
je Collision
jmp NoCollision

PecaMaeRight:
movzx ecx, al
add ecx, 2
cmp MapCovered[ecx], 1
je Collision
add ecx, 8
cmp MapCovered[ecx], 1 
je Collision
jmp NoCollision

Collision:
mov edx, 1
jmp EndVerify

NoCollision:
mov edx, 0

EndVerify:

ret
VerifyCollision ENDP


;---------------------------------------------------------
NextEGSelect PROC USES ebx
;seleciona a proxima EG contida na matriz logica
;recebe: EAX: EGescolhida, ESI = endereco da matriz
;retorna: EGescolhida atualizada, e EPICNESS
;
;AUTOR: LUCAS Y
;---------------------------------------------------------
NEGSL1:
	cmp al, 63
	jb NPULAAJUSTE
		mov al, 0
	NPULAAJUSTE:

	inc al
	mov bl, [esi + eax]

	cmp bl, 5
	jae SELECT_NEXT_EG

	jmp NEGSL1

SELECT_NEXT_EG:
mov EGescolhida, al

ret
NextEGSelect ENDP

;---------------------------------------------------------
PrevEGSelect PROC USES ebx
;seleciona a EG anterior contida na matriz logica
;recebe: EAX: EGescolhida, ESI = endereco da matriz
;retorna: EGescolhida atualizada, e mais EPICNESS
;
;AUTOR: LUCAS Y
;---------------------------------------------------------
PEGSL1:
	cmp al, 0
	ja PPULAAJUSTE
		mov al, 63
	PPULAAJUSTE:

	dec al
	mov bl, [esi + eax]

	cmp bl, 5
	jae SELECT_PREV_EG

	jmp PEGSL1

SELECT_PREV_EG:
mov EGescolhida, al

ret
PrevEGSelect ENDP

;---------------------------------------------------------
GetEgendCoords PROC
;transforma uma posicao de ate 64 bits numa coordenada
;recebe: EDX: valor recebido
;retorna: EDX: Posicao alterada, com X em DH e Y em DL
;
;AUTOR: LUCAS Y
;---------------------------------------------------------
shl edx, 5
shr dl, 5
ret
GetEgendCoords ENDP
;-------------------------------------------------------


;------------------------------------------------------
ExibirDicas PROC uses EDX ECX
;
; Mostra as dicas que o jogador comprou, afinal, nem
; todos são Egend o bastante para pssar o jogo sem ajuda 
; Autor: Thiago Faria
;------------------------------------------------------
;contador de dicas escritas
mov ecx,0

;contador de linhas puladas, começa na linha dois 
mov bh,7


mov ax,YELLOW + RED*16
call SetTextColor
mGotoxy 41,1
mWrite "Pressione T para pedir ajuda a"
mGotoxy 41,2
mWrite "TioGaedes, The Egend."
mGotoxy 41,bh

;passa para edx o Offset do buffer e para ECX o numero de dicas que o jogador pediu
mov edx, OFFSET buffer

imprimeDicas:
;checa se o arquivo de dicas jah acabou
mov al,"@"
cmp [edx],al
je fimDicas

;checa se todas as dicas compradas foram exibidas
cmp cl,dicasCompradas
je fimDicas

;se for o fim de uma dica, aumenta o ecx e depois ve se ele nao passou
mov al,";"
cmp [edx],al
je dicafim

;pular linha por motivos estéticos
mov al,"/"
cmp	[edx],al
jne continuaLinha
inc bh
mGotoxy 41,bh
inc edx
continuaLinha:
;escreve o caracter da dica
mov al,[edx]
call WriteChar
inc edx
jmp imprimeDicas

dicafim:
inc cl
inc edx
jmp imprimeDicas

fimDicas:
ret
ExibirDicas ENDP
;------------------------------------------------------


;-------------------------------------------------------
CarregarDicas PROC USES eax ebx ecx edx
; Esse procedimento abre o arquivo refente a fase atual
; e carrega na memoria suas dicas
;AUTOR: LUCAS Y e THIAGO FARIA
;-------------------------------------------------------
pushfd

;altera o caminho para que este aponte para o arquivo da fase
mov edx, OFFSET dicas
add edx, 16
mov al,faseAtual
add al,48
mov [edx],al


;abre o arquivo em que as pontuações estão salvas
mov edx, OFFSET dicas
Call OpenInputFile
push eax
;grava tudo que está no arquivo em um local da memória
mov edx, OFFSET buffer
mov ecx,100
Call ReadFromFile

pop eax
call CloseFile
popfd
ret
CarregarDicas ENDP
;-------------------------------------------------------

;-------------------------------------------------------
GenerateMapCovered PROC USES eax esi
;Gera a matriz de posicoes ocupadas no mapa
;recebe: nada
;retorna: nada
;AUTOR: LUCAS Y
;-------------------------------------------------------
mov esi, 0

GMC_INIT:
cmp esi, 64
je GMC_INIT_END
mov MapCovered[esi], 0
inc esi
jmp GMC_INIT

GMC_INIT_END:
mov esi, 0
GMC_L1:
	cmp esi, 64
	je GMC_SAIRLOOP
	mov al, MapInfo[esi]
	cmp al, 0
	je GMC_NFAZNADA

	cmp al, 1
	jne GMC_J1
	mov MapCovered[esi], 1
	jmp GMC_NFAZNADA

	GMC_J1:
	cmp al, 5
	jne GMC_J2
	mov MapCovered[esi], 1
	mov MapCovered[esi + 1], 1
	mov MapCovered[esi + 8], 1
	mov MapCovered[esi + 9], 1
	jmp GMC_NFAZNADA

	GMC_J2:
	cmp al, 6
	jne GMC_J3
	mov MapCovered[esi], 1
	jmp GMC_NFAZNADA

	GMC_J3:
	cmp al, 7
	jne GMC_J4
	mov MapCovered[esi], 1
	mov MapCovered[esi + 1], 1
	jmp GMC_NFAZNADA

	GMC_J4:
	mov MapCovered[esi], 1
	mov MapCovered[esi + 8], 1
	jmp GMC_NFAZNADA

	GMC_NFAZNADA:
	inc esi
	jmp GMC_L1

GMC_SAIRLOOP:
	movzx esi, VoidEgendPos
	mov MapCovered[esi], 2
	mov MapCovered[esi + 1], 2
	mov MapCovered[esi + 8], 2
	mov MapCovered[esi + 9], 2
ret
GenerateMapCovered ENDP

;------------------------------------------------------
MovePiece PROC USES ebx ecx edx
;
; Updates the game (Map info and Map Covered)
; Receives:AL receives the position of the selected piece
;	   EBX receives the movement of the piece
;
; 	   UP, DOWN, LEFT, RIGHT
; 	   0 ,  1  ,  2  ,   3
;
; Returns: Only courage to the player
; AUTOR: NICOLAS OE, LUCAS Y
;------------------------------------------------------
.data
movement_undoing_1 BYTE 6 DUP(20h)
movement_undoing_2 BYTE 12 DUP(20h)
movement_undoing_3 BYTE 24 DUP(20h)

.code
movzx edx, al
movzx ecx, MapInfo[edx]
mov MapInfo[edx], 0
mov EGantEscolhida, al

MP_NJ2:
cmp ebx, 0
jne Down
	sub edx, 8
	sub EGescolhida, 8
jmp ExitMove

Down:
cmp ebx, 1
jne Left
	add edx, 8
	add EGescolhida, 8
jmp ExitMove

Left:
cmp ebx, 2
jne Right
	sub edx, 1
	sub EGescolhida, 1
jmp ExitMove

Right:
	add edx, 1
	add EGescolhida, 1
jmp ExitMove

ExitMove:
mov ebx, 0604h
mov MapInfo[edx], cl

;parte responsavel pela limpeza
push edx
movzx dx, al
call GetEgendCoords
mov bl, dl
shl dx, 1
add dl, bl
add dx, 0208h
mov ax, dx
pop edx

cmp cl, 5
jne MPU1

INVOKE draw_matrix, OFFSET movement_undoing_3, 0604h, ax, RED+RED*16
jmp MPUEGCheck

MPU1:
cmp cl, 6
jne MPU2

INVOKE draw_matrix, OFFSET movement_undoing_1, 0302h, ax, RED+RED*16
jmp MPUEND

MPU2:
cmp cl, 7
jne MPU3

INVOKE draw_matrix, OFFSET movement_undoing_2, 0602h, ax, RED+RED*16
jmp MPUEND

MPU3:
INVOKE draw_matrix, OFFSET movement_undoing_2, 0304h, ax, RED+RED*16
jmp MPUEND

MPUEGCheck:
cmp dl, VoidEgendPos
jne MPUEND
	mov EpicWinAux, 1

MPUEND:

ret
MovePiece ENDP

;------------------------------------------------------
VerifyEGENDNESS PROC USES ecx
;
; Verify if the player GOT THE EGENDEEEEEEEEEEEEEEEEESS
; Receives:AL receives the position of the mother
; Returns: EDX rerturns the EGENDNESS of the player
; 	   If is Egend, return 1, else return 0
; AUTOR: NICOLAS OE
;------------------------------------------------------

mov edx, 1
movzx ecx, al
cmp MapCovered[ecx], 2
je EGENDNESS
mov edx, 0
EGENDNESS:
ret
VerifyEGENDNESS ENDP
;------------------------------------------------------


;------------------------------------------------------
ExibirPontuacao PROC USES EAX
;
; Exibe a pontuação que TioGaedes deu a você  
; AUTOR: THIAGO FARIA 
;------------------------------------------------------

mGotoxy 2,20
mWrite"\||||||||||||||||||||||||||||||||||/"
mGotoxy 2,21
mWrite"-------------"
mov eax, pontuacao
call WriteDec
mWrite"-------------"
mGotoxy 2,22
mWrite"/||||||||||||||||||||||||||||||||||\"


ret
ExibirPontuacao ENDP
;------------------------------------------------------

;------------------------------------------------------
LoadMap PROC
;
; Loads the map with EGEND
; Receives: EDX points to the filename.
; Returns: MapInfo receives the map's EGENDS!
;------------------------------------------------------

;altera o caminho para que este aponte para o arquivo da fase
mov edx, OFFSET mapa
add edx, 6
mov al,faseAtual
add al,48
mov [edx],al
sub edx,6

call OpenInputFile
push eax
mov edx, OFFSET MapInfo
mov ecx, 70
call ReadFromFile

pop eax
call CloseFile

mov ah, 0
mov edx, 0
mov ecx, 64

LoadMapLoop1:

mov al, MapInfo[edx]
sub al,48
mov MapInfo[edx], al

cmp MapInfo[edx], 1
je Parede

cmp MapInfo[edx], 6
je PecaMenor

cmp MapInfo[edx], 7
je PecaDeitada

cmp MapInfo[edx], 8
je PecaEmPe

cmp MapInfo[edx], 5
je PecaMae

jmp LoadMapVerifyExit

Parede:
mov MapInfo[edx], 1
jmp LoadMapVerifyExit

PecaMenor:
mov MapInfo[edx], 6
jmp LoadMapVerifyExit

LoadMapLoop:
jmp LoadMapLoop1

PecaDeitada:
mov MapInfo[edx], 7
jmp LoadMapVerifyExit

PecaEmPe:
mov MapInfo[edx], 8
jmp LoadMapVerifyExit

PecaMae:
mov MapInfo[edx], 5
mov EGescolhida, ah
mov EGantEscolhida, ah

LoadMapVerifyExit:

add edx, 1
inc ah
loop LoadMapLoop

add edx, OFFSET MapInfo
call ConverteInt
mov VoidEgendPos, bl

ret

LoadMap ENDP

;------------------------------------------------------
ExibirMovimentos PROC
; imprime na tela a quantidade de movimentos feitos
;
;AUTOR: LUCAS Y
;------------------------------------------------------
pushad
mov ax, YELLOW+RED*16
call SetTextColor
mov dx, 1729h
call Gotoxy
mWrite "Movimentos: "
mov eax, movCount
call WriteDec
popad
ret
ExibirMovimentos ENDP
;------------------------------------------------------



;------------------------------------------------------
SalvarPontuacao PROC USES  eax ebx ecx edx esi
;
; Salva a pontuação que TioGaedes deu a você  
; AUTOR: THIAGO FARIA 
;------------------------------------------------------

;abre o arquivo em que as pontuações estão salvas
mov edx, OFFSET pontuacoes
Call OpenInputFile

;grava tudo que está no arquivo em um local da memória
mov edx, OFFSET buffer
mov ecx,280
Call ReadFromFile

;passa para edx o Offset do buffer, para ecx o offset das iniciais e para esi o offset das pontuacoes
mov edx, OFFSET buffer
mov ecx, OFFSET iniciais
mov esi, OFFSET chaves


;colocada de todos os valores em seus vetores auxiliares
mov al,";"

copiando:
cmp [edx],al
je ordenar

;carrega as inciais
mov bl,[edx]
mov [ecx],bl
inc ecx
inc edx
mov bl,[edx]
mov [ecx],bl
inc ecx
inc edx
mov bl,[edx]
mov [ecx],bl
add ecx,2
add edx,2

;carrega a pontuação como uma lista de inteiros
Call ConverteInt
mov [esi],ebx
add esi,4
inc edx
jmp copiando

ordenar:
; agora é inserido a pontuação atual do jogador no final do vetor, e depois ordena
mov ebx, pontuacao
mov [esi],ebx
;os valores aqui são só temporarios
mov bl,"T"
mov [ecx],bl
inc ecx
mov bl,"I"
mov [ecx],bl
inc ecx
mov bl,"o"
mov [ecx],bl

ordenando:
mov eax,pontuacao
cmp eax,[esi-4]
jna gravar
Call TrocaPosicoes
jmp ordenando

gravar:


ret
SalvarPontuacao ENDP
;------------------------------------------------------


;------------------------------------------------------
ConverteInt PROC USES eax ecx esi
;
; Le uma string até um "/" e a transforma em um inteiro  
; Recebe: EDX=OFFSET da string
; Retorna: EBX = inteiro convertido, EDX aponta para o final do inteiro
; AUTOR: THIAGO FARIA e LUCAS Y
;------------------------------------------------------

mov eax,1		;multiplicador
mov ecx,0
mov ebx, 0
push eax
;anda no vetor até chegar em um "/"
mov al,"/"
andando:
cmp [edx],al
je andado
inc edx
inc ecx
jmp andando

andado:
pop eax
push edx
;aqui começa a conversão propriamente dita
convertendo:
dec edx
mov esi,[edx]
shl esi, 24
shr esi, 24
sub esi, 48
;agora começam as multiplicações
push edx	
push eax
mul esi
add ebx,eax
pop eax
mov edx,10
mul edx
pop edx

loop convertendo

;Call GravaNovaPontuacao
pop edx
ret
ConverteInt ENDP
;------------------------------------------------------



;------------------------------------------------------
TrocaPosicoes PROC USES eax ebx
;
; Inverte as posições de duas iniciais e chaves (pontuações)
; Recebe: ecx= OFFSET iniciais, esi= OFFSET chaves
; AUTOR: THIAGO FARIA 
;------------------------------------------------------

;troca as iniciais
mov eax,[ecx]
mov ebx,[ecx-3]
mov [ecx-3],eax
mov [ecx],ebx
dec ecx
mov eax,[ecx]
mov ebx,[ecx-3]
mov [ecx-3],eax
mov [ecx],ebx
dec ecx
mov eax,[ecx]
mov ebx,[ecx-3]
mov [ecx-3],eax
mov [ecx],ebx
dec ecx

;troca os inteiros
mov eax,[esi]
mov ebx,[esi-4]
mov [esi-4],eax
mov [esi],ebx
dec esi

ret
TrocaPosicoes ENDP
;------------------------------------------------------







;-----------------------------------------------------
IntParaString PROC USES edi,
 buffer_B:PTR BYTE
 LOCAL neg_flag:BYTE
; Escreve inteiro em uma string
; em ASCII decimal.
; Receives: EAX = o inteiro e buffer_B um ponteiro a uma string que tem 12 posicoes
; Returns:  EDX = o endereço p/ a string, ECX = o tamanho da string
;-----------------------------------------------------
WI_Bufsize = 12
true  =   1
false =   0


mov   neg_flag,false    ; assume neg_flag is false
or    eax,eax             ; is AX positive?
jns   WIS1              ; yes: jump to B1
neg   eax                ; no: make it positive
mov   neg_flag,true     ; set neg_flag to true

WIS1:
mov   ecx,0              ; digit count = 0
mov   edi,buffer_B
add   edi,(WI_Bufsize-1)
mov   ebx,10             ; will divide by 10

WIS2:
mov   edx,0              ; set dividend to 0
div   ebx                ; divide AX by 10
or    dl,30h            ; convert remainder to ASCII
dec   edi                ; reverse through the buffer
mov   [edi],dl           ; store ASCII digit
inc   ecx                ; increment digit count
or    eax,eax             ; quotient > 0?
jnz   WIS2              ; yes: divide again

; Insert the sign.
cmp   neg_flag,false    	; was the number positive?
jz    WIS3              	; yes
dec   edi	; back up in the buffer
inc   ecx               ; increment counter
mov   BYTE PTR [edi],'-' ; no: insert negative sign

WIS3:	; retorna numero
mov  edx,edi

ret
IntParaString ENDP
;-----------------------------------------------------
;-------------------------------------------------------
; ID DO ESTADO: 5
EGEND_state PROC  
;	Estado em que parabeniza o player por chegar
;	um pouco mais perto de ser EGEND
;
;AUTOR: NICOLAS OE
;-------------------------------------------------------
.data
EGENDARY_congrats1 BYTE  "                              _                                    ",
					"/\_/\___  _   _    __ _  ___ | |_   ___  ___  _ __ ___   ___       ",
					"\_ _/ _ \| | | |  / _` |/ _ \| __| / __|/ _ \| '_ ` _ \ / _ \      ",
					" / \ (_) | |_| | | (_| | (_) | |_  \__ \ (_) | | | | | |  __/_ _ _ ",
					" \_/\___/ \__,_|  \__, |\___/ \__| |___/\___/|_| |_| |_|\___(_|_|_)",
					"                  |___/                                            "
EGENDARY_congrats2 BYTE	 "   __  ___   __    __  ___  ",
					 "  /__\/ _ \ /__\/\ \ \/   \ ",
					 " /_\ / /_\//_\ /  \/ / /\ / ",
					 "//__/ /_\\//__/ /\  / /_//  ",
					 "\__/\____/\__/\_\ \/___,'   "
                                                             
.code
call Clrscr

INVOKE draw_matrix, OFFSET EGENDARY_congrats1, 4306h, 0208h, LIGHTRED+BLACK*16
INVOKE draw_matrix, OFFSET EGENDARY_congrats2, 1C05h, 0A1Ah, LIGHTRED+BLACK*16

mov ax, bx
call SetTextColor

mGotoxy 5,17
mWrite "Preesione T para ir para a proxima fase ou Enter para salvar sua pontuação"
Call ReadChar

cmp al,pedidoDica
jne testaInicial
inc faseAtual
mov dicasCompradas,0
mov estadoAtual,1
mov movCount, 0
mov EpicWinAux, 0
jmp voltaJogo

testaInicial:
cmp al,escolha
jne voltaJogo



voltaJogo:


ret
EGEND_state ENDP

END main