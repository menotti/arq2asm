TITLE Labirinto da Morte (labirinto.asm)

.data
msgInicio BYTE "Labirinto da Morte", 0dh, 0ah, 0
msgMenu BYTE "______Menu______", 0dh, 0ah,
             "1-Iniciar", 0dh, 0ah,
			 "0-Sair", 0dh, 0ah, 0

msgDificuldade BYTE "0-Voltar ao menu inicial", 0dh, 0ah, 0ah,
                    "Escolha a dificuldade:", 0dh, 0ah,
                    "1-Normal  (Visao com raio 2 em volta de voce)", 0dh, 0ah,
			        "2-Dificil (Visao com raio 1 em volta de voce)", 0dh, 0ah, 0

msgOpcao BYTE "Sua opcao: ", 0

msgFase01 BYTE "0-Voltar ao menu inicial", 0dh, 0ah, 0ah,
             "Escolha a fase:", 0dh, 0ah,
             "1-Labirinto do Troll ", 0dh, 0ah, 0
msgFase02 BYTE "2-Labirinto do Troll 2 ", 0dh, 0ah, 0
msgFase03 BYTE "3-Labirinto do Troll 3 ", 0dh, 0ah, 0
msgFase04 BYTE "4-Labirinto do Troll 4 ", 0dh, 0ah, 0
msgFase05 BYTE "5-Labirinto do Minotauro ", 0dh, 0ah, 0       
msgFase06 BYTE "6-Labirinto do Minotauro 2", 0dh, 0ah, 0  
msgFase07 BYTE "7-Labirinto do Minotauro 3", 0dh, 0ah, 0  
msgFase08 BYTE "8-Labirinto do Dragao", 0dh, 0ah, 0  
msgFase09 BYTE "9-Labirinto do Dragao 2", 0dh, 0ah, 0   
msgFase10 BYTE "10-Labirinto do Dragao 3", 0dh, 0ah, 0

msg1 BYTE "- O tempo parou quando te conheci...", 0
msg2 BYTE "- E o meu coracao parou quando voce foi embora...", 0
msg3 BYTE "- Ela sumiu... me abandonou...", 0
msg4 BYTE "- Serah mesmo que ela me abandonou?", 0
msg5 BYTE "- O que eh isso no chao?", 0
msg6 BYTE "- Pegadas?",	 0
msg7 BYTE "- Para onde elas estao me levando?", 0
msg8 BYTE "- Uma caverna...", 0

nomeArq01 BYTE "src/Labirinto/Fases/labirinto01.txt", 0
nomeArq02 BYTE "src/Labirinto/Fases/labirinto02.txt", 0
nomeArq03 BYTE "src/Labirinto/Fases/labirinto03.txt", 0
nomeArq04 BYTE "src/Labirinto/Fases/labirinto04.txt", 0
nomeArq05 BYTE "src/Labirinto/Fases/labirinto05.txt", 0
nomeArq06 BYTE "src/Labirinto/Fases/labirinto06.txt", 0
nomeArq07 BYTE "src/Labirinto/Fases/labirinto07.txt", 0
nomeArq08 BYTE "src/Labirinto/Fases/labirinto08.txt", 0
nomeArq09 BYTE "src/Labirinto/Fases/labirinto09.txt", 0
nomeArq10 BYTE "src/Labirinto/Fases/labirinto10.txt", 0
nomeArq11 BYTE "src/Labirinto/MISC/medalha.txt", 0

nomeArqLore1 BYTE "src/Labirinto/Historia/lore1.txt", 0
nomeArqLore2 BYTE "src/Labirinto/Historia/lore2.txt", 0
nomeArqLore3 BYTE "src/Labirinto/Historia/lore3t.txt", 0

nomeArqMino1 BYTE "src/Labirinto/MISC/morteMino.txt", 0

msgErro BYTE "Não foi possivel carregar o arquivo desejado.", 0dh, 0ah, 0
msgErro2 BYTE "Por favor, selecione um labirinto valido.", 0dh, 0ah, 0

tamanhoX DWORD 64
tamanhoY DWORD 24
tamanhoM DWORD 1650 
matriz BYTE 1650 DUP (0) ; 1650 = 25 linhas * 66 colunas

posicao DWORD ?
posicaoS DWORD ?
posicaoVelha DWORD ?

direcao BYTE ?
mapa BYTE 0
mapaPossivel BYTE 1
liberado BYTE 0
visao BYTE 1
lore BYTE 1

msgPassos BYTE "PASSOS:", 0
msgPassos2 BYTE "MELHOR:", 0
msgPassos3 BYTE "RECORD:", 0

msgPont BYTE "PARABENS! VOCE COMPLETOU O LABIRINTO E ESTA VIVO!", 0
msgPont2 BYTE "VOCE CONSEGUIU EM", 0
msgPont3 BYTE " PASSOS. SEU MELHOR CAMINHO FOI FEITO EM", 0
msgPont4 BYTE "VOCE NAO OBTEVE MEDALHA! :( ", 0dh, 0ah, 0
msgPont5 BYTE "VOCE OBTEVE UMA MEDALHA DE OURO :D ", 0dh, 0ah, 0
msgPont6 BYTE "VOCE OBTEVE UMA MEDALHA DE PRATA :) ", 0dh, 0ah, 0
msgPont7 BYTE "VOCE OBTEVE UMA MEDALHA DE BRONZE :| ", 0dh, 0ah, 0

passos WORD 0
seusMelhoresPassos WORD 10 DUP (1000)
melhoresPassos WORD 129, 141, 102, 103, 104, 100, 100, 100, 100, 100

.code

jogaLabirinto PROC
; funcao MAIN onde a parte logica do jogo acontece

    mov eax, 0
    mov ah, blue
	shr ax, 4
	add al, white
    call SetTextColor

	call Clrscr

	

menuInicial:
	call escreveMenu
	call escreveOpcao
	
	call ReadInt
	jc menuInicial

	cmp eax, 1
	je dif

	jmp voltar

dif:
	call escreveDificuldade
	call escreveOpcao

	call ReadInt
	jc dif

	cmp eax, 1
	je v1

	cmp eax, 2
	je v2

	cmp eax, 0
	je menuInicial

  v1:
	mov visao, 2
	jmp historia
	
  v2: 
	mov visao, 1
	jmp historia

historia:
	
	;antes da fase eh mostrado uma historia
	cmp lore, 1  ; mostra a historia inicial uma vez
	je fase
	call LoreInicial
	mov lore, 1

fase:

	call escreveFase
	call escreveOpcao

	call ReadInt
	jc fase

	cmp eax, 0
	je menuInicial

	mov mapa, al
	mov dl, mapaPossivel
	cmp mapa, dl
	jbe jogo
	call Crlf
	mov edx, offset msgErro2
	call WriteString
	call WaitMsg

	cmp eax, 666
	jne fase
	mov mapaPossivel, 10
	jmp fase

jogo:
	call leLabirinto
	mov ecx, 1
	call atualizaLabirinto
	mov passos, 0	

continua:
	mov eax, posicaoVelha
	cmp eax, posicao
	je naoConta
    inc passos
	mov eax, posicao
	mov posicaoVelha, eax
  naoConta:
	mov dx, 0
	call Gotoxy
    call escreveLabirinto
 
 volta:   
    call ReadChar
    
    cmp ah, 48h
    je mCima
    
	cmp ah, 50h
    je mBaixo
    
    cmp ah, 4Dh
    je mDireita
    
    cmp ah, 4Bh
    je mEsquerda
    
    cmp al, 108
    je mLibera
    
    jmp volta
    
  mCima: 
    mov dl, 0
    mov direcao, dl
    jmp m
    
  mBaixo:
    mov dl, 2
    mov direcao, dl
    jmp m
    
  mDireita:
     mov dl, 1
     mov direcao, dl
     jmp m
     
  mEsquerda:
	mov dl, 3
	mov direcao, dl 
	jmp m
    
  mLibera:
	call liberaMapa
	mov liberado, 1
	jmp continua

  m: 
    mov ecx, 0
    call atualizaLabirinto
    
    call movimento
    
    mov eax, posicao
    cmp eax, posicaoS
    je fim
    
    jmp continua

fim:
	call Clrscr
	call mostraPontuacao
	;call liberaMapa
	call ReadKey
    
sair::
    call Clrscr
	jmp fase

voltar:
	mov eax, 0
    mov ah, black
	shr ax, 4
	add al, white
    call SetTextColor
	ret
jogaLabirinto ENDP

escreveMenu PROC
; Exibe as opcoes iniciais do jogo
	
	call Clrscr	  
	mov edx,OFFSET msgInicio
	call WriteString
	mov edx, OFFSET msgMenu
	call WriteString
	ret
escreveMenu ENDP

escreveOpcao PROC
; Exibe para que o usuario escolha uma opcao 

	mov edx, OFFSET msgOpcao
	call WriteString
	ret
escreveOpcao ENDP

escreveDificuldade PROC
; Exibe as opcoes de dificuldade

	call Clrscr
	mov edx, OFFSET msgDificuldade
	call WriteString
	ret
escreveDificuldade ENDP

escreveFase PROC
;Exibe as opcoes de fase

	call Clrscr
	  
	mov edx, OFFSET msgFase01
	call WriteString

	cmp mapaPossivel, 2
	jb acabouFases
	mov edx, OFFSET msgFase02
    call WriteString
    
    cmp mapaPossivel, 3
    jb acabouFases
    mov edx, OFFSET msgFase03
    call WriteString
    
    cmp mapaPossivel, 4
    jb acabouFases
    mov edx, OFFSET msgFase04
    call WriteString
    
    cmp mapaPossivel, 5
    jb acabouFases
    mov edx, OFFSET msgFase05
    call WriteString
    
    cmp mapaPossivel, 6
    jb acabouFases
    mov edx, OFFSET msgFase06
    call WriteString
    
    cmp mapaPossivel, 7
    jb acabouFases
    mov edx, OFFSET msgFase07
    call WriteString
    
    cmp mapaPossivel, 8
    jb acabouFases
    mov edx, OFFSET msgFase08
    call WriteString
    
    cmp mapaPossivel, 9
    jb acabouFases
    mov edx, OFFSET msgFase09
    call WriteString
    
    cmp mapaPossivel, 10
    jb acabouFases
    mov edx, OFFSET msgFase10
    call WriteString

acabouFases:
	ret
escreveFase ENDP

leLabirinto PROC
; Carrega o labirinto que sera jogado do arquivo para a memoria

    mov edx, offset nomeArq01
    cmp mapa, 1
    je abreArq
    mov edx, offset nomeArq02
    cmp mapa, 2
    je abreArq
    mov edx, offset nomeArq03
    cmp mapa, 3
    je abreArq
    mov edx, offset nomeArq04
    cmp mapa, 4
    je abreArq
    mov edx, offset nomeArq05
    cmp mapa, 5
    je abreArq
    mov edx, offset nomeArq06
    cmp mapa, 6
    je abreArq
    mov edx, offset nomeArq07
    cmp mapa, 7
    je abreArq
    mov edx, offset nomeArq08
    cmp mapa, 8
    je abreArq
    mov edx, offset nomeArq09
    cmp mapa, 9
    je abreArq
    mov edx, offset nomeArq10
    
abreArq:
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    jne semErro
    mov edx, offset msgErro
    call WriteString
	call Crlf
	call WaitMsg
	jmp sair

semErro:
    push eax ; deixa na pilha o file handle
    
    mov ecx, tamanhoM
    mov edx, offset matriz
    call ReadFromFile ; vai ler todo o arquivo do labirinto e salvar na matriz
    
    call buscaPosicao
    call buscaSaida
    
    pop eax
    call CloseFile
	ret
leLabirinto ENDP

desliberaMapa PROC

    mov ecx, tamanhoM
    mov edx, offset matriz
    
deslibera:
    mov al, [edx]
    cmp al, 35
    jne nMuda5
    
    mov al, 2ah
    mov [edx], al
    
    nMuda5: 
    
    inc edx
	loop deslibera

	mov liberado, 0
	ret
desliberaMapa ENDP

liberaMapa PROC

	mov edx, 0h
	call Gotoxy

	mov ecx, tamanhoM
	mov edx, offset matriz

libera:
    mov al, [edx]
    cmp al, 2ah
    jne nMuda3
    
    mov al, 35
    mov [edx], al
    
    nMuda3: 
    
    inc edx
	loop libera

	call escreveLabirinto

	ret
liberaMapa ENDP

buscaPosicao PROC 
; Busca a posicao atual do usuario na memoria

	mov ecx, tamanhoM
	mov esi, offset matriz

busca:
	mov al, [esi]
	cmp al, 79
	je sai
	inc esi
loop busca

sai:
	mov posicao, esi
	mov posicaoVelha, esi

	ret
buscaPosicao ENDP

buscaSaida PROC
; Busca a posição da saída do labirinto na memória
	mov ecx, tamanhoM
	mov esi, offset matriz
	
busca:
	mov al, [esi]
	cmp al, 70
	je sai
	inc esi
	loop busca
	
sai:
	mov posicaoS, esi
	ret 
buscaSaida ENDP

escreveLabirinto PROC
; Exibe o labirinto visível para o usuario, o numero de passos, o melhor tempo e o recorde

	mov ecx, tamanhoM
	mov esi, offset matriz

passa:
	call escreveChar
	inc esi
	loop passa

	push edx
	mov eax, 0

	mov ah, blue
	shr ax, 4
	add al, yellow
    call SetTextColor

	movzx esi, mapa
	dec esi
	mov eax, 0

	mov edx, 41h
	call Gotoxy
	mov edx, OFFSET msgPassos
	call WriteString
	mov ax, passos
	call WriteDec
	
	mov edx, 0141h
	call Gotoxy
	mov edx, OFFSET msgPassos2
	call WriteString
	mov ax, seusMelhoresPassos[esi * TYPE WORD]
	call WriteDec

    mov edx, 0241h
	call Gotoxy
	mov edx, OFFSET msgPassos3
	call WriteString
	mov ax, melhoresPassos[esi * TYPE WORD]
	call WriteDec
    
	mov eax, 0
    mov ah, blue
	shr ax, 4
	add al, white
    call SetTextColor

	pop edx

	ret
escreveLabirinto ENDP

escreveChar PROC
; Escreve o caractere especifico. Para paredes ou saída, o caractere é mudado

	mov al,[esi]

	cmp al, 79
	je p

	cmp al, 77
	je p

	cmp al, 0dh
	je p

	cmp al, 0ah
	je p

	cmp al, 35
	je parede

	cmp passos, 1 ;mostra o inicio e fim por 3 passos
	ja nParede

	cmp al, 73
	je p

	cmp al, 70
	je p

	jmp nParede

p:
	call WriteChar
	jmp escreveu

parede:
	mov al, 35
	call WriteChar
	jmp escreveu

nParede:
	mov al, 32
	call WriteChar
	jmp escreveu

escreveu:
	ret
escreveChar ENDP

movimento PROC
; Executa o movimento (possivel) do usuario no labirinto
    
    cmp direcao, 0
    je dcima
    
    cmp direcao, 1
    je ddireita
    
    cmp direcao, 2
    je dbaixo
    
    cmp direcao, 3
    je desquerda
    
dcima:
    mov edx, tamanhoX
	add edx, 2

	mov edi, posicao
	sub edi, edx

	cmp edi, offset matriz
	jb invalido

    call verificaMovimento
    jmp invalido

ddireita:
    mov edi, posicao
	inc edi

	mov al, [edi]

	cmp al, 0dh
	je invalido

	call verificaMovimento
	jmp invalido

dbaixo:
    mov edx, tamanhoX
	add edx, 2

	mov edi, posicao
	add edi, edx

	mov esi, offset matriz
	add esi, tamanhoM

	cmp edi, esi
	ja invalido

    call verificaMovimento
	jmp invalido

desquerda:
    mov edi, posicao
    sub edi, 1
    
    mov al, [edi]
    
    cmp al, 0ah
    je invalido
    
    call verificaMovimento
    jmp invalido
    
invalido:
	ret
movimento ENDP

verificaMovimento PROC uses EAX
; Verifica se o movimento e possivel (nao encara uma parede)
    mov al, [edi]
    
    cmp al, 32
    je move
    
	cmp al, 70
    je move

	cmp al, 73
    je sair

	cmp al, 78
    je morreMino
    
    jmp nMove

morreMino:

	call Clrscr
retornaErro:
	mov esi, OFFSET matriz
	mov edx, OFFSET nomeArqMino1
	call OpenInputFile
	cmp eax, INVALID_HANDLE_VALUE
	jne semErro
	call Crlf
	mov edx, offset msgErro
	call WriteString
	call WaitMsg
	jmp retornaErro
semErro:
	push eax
	mov edx, OFFSET matriz
	mov ecx, tamanhoM
	call ReadFromFile
	mov ecx, eax
L3:
	mov al, [esi]
	call WriteChar
	inc esi
	loop L3
	
	mov ebx, 5000
	call esperaXms
	call Clrscr
	pop eax
	call CloseFile
	jmp sair
    
move: 
    mov eax, posicao
    mov bl, 32
    mov [eax], bl
    mov posicao, edi
    mov al, 79
    mov [edi], al
    
    mov al, liberado
    cmp al, 1
    jne nMove
    
    call desliberaMapa
    
nMove: 
	mov ecx, 1
	call atualizaLabirinto
    ret
verificaMovimento ENDP

atualizaLabirinto PROC
    
	mov al, [visao]
	
	cmp al, 1
	je visao1

	cmp al, 2
	je visao2

	jmp erro

visao2:
	mov eax, tamanhoX
	add eax, 2	
	mov esi, eax

	mov edi, posicao
	add edi, 2
	call verificaBorda
    cmp eax, 1
	jne nValido23
	call substituiParede

nValido23:
	sub edi, 4
	call verificaBorda
    cmp eax, 1
	jne nValido24
	call substituiParede

nValido24:
	mov edi, posicao
	add edi, esi
	add edi, esi
	call verificaBorda
	cmp eax, 1
	jne nValido9
    call substituiParede

nValido9:
	inc edi
	call verificaBorda
    cmp eax, 1
	jne nValido10
	call substituiParede
	
nValido10:
	inc edi
	call verificaBorda
    cmp eax, 1
	jne nValido11
	call substituiParede

nValido11:
	sub edi, 3
	call verificaBorda
    cmp eax, 1
	jne nValido12
	call substituiParede

nValido12:
	sub edi, 1
	call verificaBorda
    cmp eax, 1
	jne nValido13
	call substituiParede

nValido13:
	mov edi, posicao
	sub edi, esi
	sub edi, esi
	call verificaBorda
	cmp eax, 1
	jne nValido14
    call substituiParede
	
nValido14:
	inc edi
	call verificaBorda
    cmp eax, 1
	jne nValido15
	call substituiParede
	
nValido15:
	inc edi
	call verificaBorda
    cmp eax, 1
	jne nValido16
	call substituiParede
	
nValido16:
	sub edi, 3
	call verificaBorda
    cmp eax, 1
	jne nValido17
	call substituiParede
	
nValido17:
	sub edi, 1
	call verificaBorda
    cmp eax, 1
	jne nValido18
	call substituiParede
	
nValido18:
	mov edi, posicao
	sub edi, esi

	add edi, 2
	call verificaBorda
    cmp eax, 1
	jne nValido19
	call substituiParede
	
nValido19:
	sub edi, 4
	call verificaBorda
    cmp eax, 1
	jne nValido20
	call substituiParede
	
nValido20:
	mov edi, posicao
	add edi, esi

	add edi, 2
	call verificaBorda
    cmp eax, 1
	jne nValido21
	call substituiParede
	
nValido21:
	sub edi, 4
	call verificaBorda
    cmp eax, 1
	jne visao1
	call substituiParede
	
visao1: 
	mov eax, tamanhoX
	add eax, 2
	mov esi, eax

	mov edi, posicao
	add edi, esi
	call verificaBorda
	cmp eax, 1
	jne nValido1
    call substituiParede
	
nValido1:
	inc edi
	call verificaBorda
    cmp eax, 1
	jne nValido2
	call substituiParede
	
nValido2:
	sub edi, 2
	call verificaBorda
    cmp eax, 1
	jne nValido3
	call substituiParede
	
nValido3:
	mov edi, posicao
	sub edi, esi
	call verificaBorda
    cmp eax, 1
	jne nValido4
	call substituiParede
	
nValido4:
	inc edi
	call verificaBorda
    cmp eax, 1
	jne nValido5
	call substituiParede
	
nValido5:
	sub edi, 2
	call verificaBorda
    cmp eax, 1
	jne nValido6
	call substituiParede
	
nValido6:
	mov edi, posicao

	inc edi
	call verificaBorda
    cmp eax, 1
	jne nValido7
	call substituiParede
	
nValido7:
	sub edi, 2
	call verificaBorda
    cmp eax, 1
	jne nValido8
	call substituiParede
	
nValido8:
	jmp erro

erro:
	ret 
atualizaLabirinto ENDP

substituiParede PROC
    
    mov al, [edi]
    cmp al, 42
    jne nMuda
    
    mov al, 35
    mov [edi], al
    
nMuda:
	call substituiMino
	ret
substituiParede ENDP

substituiMino PROC
    
    mov al, [edi]
    cmp al, 80
    jne nMuda
    
    mov al, 77
    mov [edi], al
    
nMuda:
	ret
substituiMino ENDP

verificaBorda PROC uses esi
    mov ebx, offset matriz
	mov esi, tamanhoM
	add esi, ebx

	cmp edi, ebx
	jb fora
	
	cmp edi, esi
	ja fora 

	mov al, [edi]
	cmp al, 0dh
	je fora

	mov al, [edi]
	cmp al, 0ah
	je fora
    
	mov eax, 1
	jmp s2

fora:

	mov eax, 0 

s2:
	ret
verificaBorda ENDP

mostraPontuacao PROC
    mov eax, 0
	mov ebx, 50 ; tempo para esperar
    mov esi, offset msgPont
	mov ecx, SIZEOF msgPont
mostra:
	mov al, [esi]
	call WriteChar
	inc esi
	call esperaXms
	loop mostra

	mov ebx, 2000
	call esperaXms
	mov ebx, 50 

	call Crlf
    mov esi, offset msgPont2
	mov ecx, SIZEOF msgPont2
mostra2:
	mov al, [esi]
	call WriteChar
	inc esi
	call esperaXms
	loop mostra2

	mov ax, passos
	call WriteDec


    mov esi, offset msgPont3
	mov ecx, SIZEOF msgPont3
mostra3:
	mov al, [esi]
	call WriteChar
	inc esi
	call esperaXms
	loop mostra3

	movzx esi, mapa
	dec esi
	mov ax, seusMelhoresPassos[esi * TYPE WORD]
	call WriteDec

	cmp passos, ax
	jae naoMuda
	mov ax, passos
	mov seusMelhoresPassos[esi * TYPE WORD], ax

naoMuda:
	mov ebx, 2000
	call esperaXms
	call Crlf

	mov edx, offset nomeArq11

    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    jne semErro
    mov edx, offset msgErro
    call WriteString   

semErro:
    push eax ; deixa na pilha o file handle
    
    mov ecx, 400
    mov edx, offset matriz
    call ReadFromFile ; 

	mov ax, passos
	mov bx, 100
	mul bx
	movzx esi, mapa
	dec esi
	mov bx, melhoresPassos[esi * TYPE WORD] ; esi = , mapa-1
	mov dx, 0
	div bx
	sub ax, 100

	mov dx, ax
	mov ax, 0
	mov ah, blue
	shr ax, 4
	
	cmp dx, 5
	jb cor1
	cmp dx, 30
	jb cor2
	cmp dx, 60
	jb cor3
	jmp semcor

cor1:
	mov edx, offset msgPont5
	add al, yellow
	inc mapaPossivel ; aumenta o numero de labirintos possiveis
	jmp mudacor
cor2:
	mov edx, offset msgPont6
	add al, gray
	inc mapaPossivel ; aumenta o numero de labirintos possiveis
	jmp mudacor
cor3:
	mov edx, offset msgPont7
	add al, magenta
	jmp mudacor
semcor:
	mov edx, offset msgPont4
	jmp semMedalha
mudacor:
	call SetTextColor

	mov ecx, 400
	mov esi, offset matriz
mostra4:
	mov al, [esi]
	call WriteChar
	inc esi
	loop mostra4
    
    pop eax
	push edx
    call CloseFile
	pop edx

	mov ah, blue
	shr ax, 4
	add al, white
    call SetTextColor

semMedalha:
	call Crlf
	call WriteString
	call Crlf
	mov ebx, 3000
	call esperaXms

    ret
mostraPontuacao ENDP

esperaXms PROC USES EAX EDX
; Recebe em EBX o numero de milisegundos para esperar
    call GetMseconds
	mov edx, eax

espera:
	call GetMseconds
	sub eax, edx
	cmp eax, ebx
	ja fim
	jmp espera

fim:
	ret
esperaXms ENDP

LoreInicial PROC USES edx eax esi
	call Clrscr
	mov eax, 0

	;primeira frase
	mov ebx, 50
	mov esi, OFFSET msg1
	mov ecx, LENGTHOF msg1
L11:
	mov eax, [esi]
	call WriteChar
	inc esi
	call esperaXms
	loop L11

	;mov ebx, 2000
	;call esperaXms
	;call Clrscr

	;primeiro cenario
retornaErro1:
	mov edx, OFFSET nomeArqLore1
	call OpenInputFile
	cmp eax, INVALID_HANDLE_VALUE
	jne semErro1
	call Crlf
	mov edx, offset msgErro
	call WriteString
	call WaitMsg
	jmp retornaErro1
semErro1:
	push eax
	mov edx, OFFSET matriz
	mov ecx, tamanhoM
	call ReadFromFile

	mov ecx, eax ; numero de bytes lidos
    mov esi, OFFSET matriz
L1:
	mov al, [esi]
	cmp al, ';'
	je final
	call WriteChar
	inc esi
  final:
	loop L1
	
	pop eax
	call CloseFile
	mov ebx, 4000
	call esperaXms
	call Clrscr
	

	;segunda frase
	mov ebx, 50
	mov esi, OFFSET msg2
	mov ecx, LENGTHOF msg2
L12:
	mov eax, [esi]
	call WriteChar
	inc esi
	call esperaXms
	loop L12

	;mov ebx, 2000
	;call esperaXms
	;call Clrscr

	;segundo cenario
retornaErro2:
	mov edx, OFFSET nomeArqLore2
	call OpenInputFile
	cmp eax, INVALID_HANDLE_VALUE
	jne semErro2
	call Crlf
	mov edx, offset msgErro
	call WriteString
	call WaitMsg
	jmp retornaErro2
semErro2:
	push eax
	mov edx, OFFSET matriz
	mov ecx, tamanhoM
	call ReadFromFile
	
	mov ecx, eax ; numero de bytes lidos
	mov esi, OFFSET matriz
L2:
	mov al, [esi]
	cmp al, ';'
	je final2
	call WriteChar
	inc esi
  final2:
	loop L2
	
	pop eax
	call CloseFile
	mov ebx, 4000
	call esperaXms
	call Clrscr

	;terceira frase
	mov ebx, 50
	mov esi, OFFSET msg3
	mov ecx, LENGTHOF msg3
L13:
	mov eax, [esi]
	call WriteChar
	inc esi
	call esperaXms
	loop L13

	mov ebx, 2000
	call esperaXms
	call Crlf
	call Crlf

	;quarta frase
	mov ebx, 50
	mov esi, OFFSET msg4
	mov ecx, LENGTHOF msg4
L14:
	call esperaXms
	mov eax, [esi]
	call WriteChar
	mov eax, 50
	inc esi
	loop L14

	mov ebx, 2000
	call esperaXms
	call Crlf
	call Crlf

	;quinta frase
	mov ebx, 50
	mov esi, OFFSET msg5
	mov ecx, LENGTHOF msg5
L15:
	mov eax, [esi]
	call WriteChar
	inc esi
	call esperaXms
	loop L15

	mov ebx, 2000
	call esperaXms
	call Crlf
	call Crlf


	;sexta frase
	mov ebx, 50
	mov esi, OFFSET msg6
	mov ecx, LENGTHOF msg6
L16:
	mov eax, [esi]
	call WriteChar
	inc esi
	call esperaXms 
	loop L16

	mov ebx, 2000
	call esperaXms
	call Crlf
	call Crlf


	;sétima frase
	mov ebx, 50
	mov esi, OFFSET msg7
	mov ecx, LENGTHOF msg7
L17:
	mov eax, [esi]
	call WriteChar
	inc esi
	call esperaXms
	loop L17

	mov ebx, 2000
	call esperaXms
	call Crlf
	call Crlf

	;oitava frase
	mov ebx, 50
	mov esi, OFFSET msg8
	mov ecx, LENGTHOF msg8
L18:
	mov eax, [esi]
	call WriteChar
	inc esi
	call esperaXms
	loop L18

	mov ebx, 2000
	call esperaXms
	call Clrscr

	;terceiro cenário
retornaErro3:
	mov esi, OFFSET matriz
	mov edx, OFFSET nomeArqLore3
	call OpenInputFile
	cmp eax, INVALID_HANDLE_VALUE
	jne semErro3
	call Crlf
	mov edx, offset msgErro
	call WriteString
	call WaitMsg
	jmp retornaErro3
semErro3:
	push eax
	mov edx, OFFSET matriz
	mov ecx, tamanhoM
	call ReadFromFile
	mov ecx, eax
L3:
	mov al, [esi]
	call WriteChar
	inc esi
	loop L3
	
	mov ebx, 5000
	call esperaXms
	call Clrscr
	pop eax
	call CloseFile

ret
LoreInicial ENDP