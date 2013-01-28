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
msg4 BYTE "- Sera mesmo que ela me abandonou?", 0
msg5 BYTE "- O que e isso no chao?", 0
msg6 BYTE "- Pegadas?",	 0
msg7 BYTE "- Para onde elas estao me levando?", 0
msg8 BYTE "- Uma caverna...", 0

msg9 BYTE "VOCE MORREU!", 0
msg10 BYTE "Continua...",0

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
nomeArqLore4 BYTE "src/Labirinto/Historia/Fase10.txt", 0
nomeArqLore5 BYTE "src/Labirinto/Historia/Dragon1.txt", 0
nomeArqLore6 BYTE "src/Labirinto/Historia/dialogofinal.txt", 0
nomeArqLore7 BYTE "src/Labirinto/Historia/enigmas.txt",0
nomeArqLore8 BYTE "src/Labirinto/Historia/morte.txt",0
nomeArqLore9 BYTE "src/Labirinto/Historia/dialogofinal2.txt",0
nomeArqLore10 BYTE "src/Labirinto/Historia/Dragon2.txt",0
nomeArqLore11 BYTE "src/Labirinto/Historia/creditos.txt", 0

nomeArqMino1 BYTE "src/Labirinto/MISC/morteMino.txt", 0

msgErro BYTE "Nao foi possivel carregar o arquivo desejado.", 0dh, 0ah, 0
msgErro2 BYTE "Por favor, selecione um labirinto valido.", 0dh, 0ah, 0

tamanhoX DWORD 64
tamanhoY DWORD 24
tamanhoM DWORD 1584
matriz BYTE 1584 DUP (0) ; 1584 = 24 linhas * 66 colunas

posicao DWORD ?
posicaoS DWORD ?
posicaoVelha DWORD ?

direcao BYTE ?
mapa BYTE 0
mapaPossivel BYTE 1
liberado BYTE 0
visao BYTE 1
lore BYTE 0

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
melhoresPassos WORD 132, 142, 114, 128, 82, 103, 131, 132, 134, 99

.code

jogaLabirinto PROC
; funcao MAIN onde a parte logica do jogo acontece

    mov al, 1
	call mudaCores

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
	mov al, 2
	call mudaCores

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

	mov al, 3
	call mudaCores

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
    
	mov al, 1
	call mudaCores

	pop edx

	ret
escreveLabirinto ENDP

escreveChar PROC USES ebx
; Escreve o caractere especifico. Para paredes ou saída, o caractere é mudado

	mov al,[esi]

	cmp al, 79
	je p

	cmp al, 88
	je p

	cmp al, 77
	je mino

	cmp al, 0dh
	je p

	cmp al, 0ah
	je p

	cmp al, 35
	je parede

	cmp al, 73
	je p

	cmp passos, 1 ;mostra o inicio e fim por 3 passos
	ja nParede

	cmp al, 70
	je p

	jmp nParede

p:
	call WriteChar
	jmp escreveu

mino:
	mov al, 4
	call mudaCores
	mov al, 77
	call WriteChar
	mov al, 1
	call mudaCores
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

	cmp al, 'X'
	je morreArmadilha

	cmp al, 90
	jne nMove
	call DialogoFinal
	jmp sair

morreArmadilha:
	call Morte
	jmp sair

morreMino:

	call TelaPreta
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
	
	mov ebx, 3000
	call esperaXms

	call Clrscr
	mov al, 1
	call MudaCores
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
	call substituiArmadilha
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

substituiArmadilha PROC

mov al, [edi]
    cmp al, 65
    jne nMuda
    
    mov al, 88
    mov [edi], al
nMuda:
	ret
substituiArmadilha ENDP

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
	mov ebx, 30 ; tempo para esperar
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

	mov al, 1
	call mudaCores

semMedalha:
	call Crlf
	call WriteString
	call Crlf
	mov ebx, 3000
	call esperaXms
	
	pop eax
	push edx
    call CloseFile
	pop edx

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

mudaCores PROC

	and ax, 0Fh

	cmp al, 1
	jne cor2
    mov al, blue
	shl al, 4
	add al, white
    call SetTextColor
	jmp fim

cor2:
	cmp al, 2
	jne cor3
    mov al, black
	shl al, 4
	add al, white
    call SetTextColor
	jmp fim

cor3:
	cmp al, 3
	jne cor4
    mov al, blue
	shl al, 4
	add al, yellow
    call SetTextColor
	jmp fim

cor4:
	cmp al, 4
	jne cor5
    mov al, red
	shl al, 4
	add al, yellow
    call SetTextColor
	jmp fim

cor5: 
	cmp al, 5
	jne fim
	mov al, black
	shl al, 4
	add al, lightgreen
	call SetTextColor
	
fim:
	ret
mudaCores ENDP

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
	mov edx, OFFSET nomeArqLore1
	call OpenInputFile
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
	mov edx, OFFSET nomeArqLore2
	call OpenInputFile
	cmp eax, INVALID_HANDLE_VALUE
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

	;Minotauro imagem
retornaErro3:
	mov esi, OFFSET matriz
	mov edx, OFFSET nomeArqLore3
	call OpenInputFile
	push eax
	mov edx, OFFSET matriz
	mov ecx, tamanhoM
	call ReadFromFile
	mov ecx, eax

	call TelaPreta
	L3:
	mov al, [esi]
	mov dl, al
	cmp al, ';'
jne redc
	mov al, red
	call SetTextColor
jmp x
redc:
	cmp al, ','
jne yellowc
	mov al, yellow
	call SetTextColor
jmp y
yellowc:
	cmp al, '´'
jne whitec
	mov al, white
	call SetTextColor
whitec:
y:
x:
	mov al, dl
	call WriteChar
	inc esi
	loop L3

	mov ebx, 4000
	call esperaXms
	call Clrscr
	mov al, 1
	call mudaCores
	pop eax
	call CloseFile

ret
LoreInicial ENDP

DialogoFinal PROC

;revelação Dragão
    call Clrscr
	mov edx, OFFSET nomeArqLore4
	call OpenInputFile
	push eax
	mov edx, OFFSET matriz
	mov ecx, tamanhoM
	call ReadFromFile
	mov ecx, eax
	mov esi, OFFSET matriz
L3:
	mov al, [esi]
	call WriteChar
	inc esi
	loop L3

	pop eax
	call CloseFIle

	mov ebx, 2000
	call esperaXms
	call Clrscr

	mov edx, OFFSET nomeArqLore5
	call OpenInputFile
	push eax
	mov edx, OFFSET matriz
	mov ecx, tamanhoM
	call ReadFromFile
	mov ecx, eax
	mov esi, OFFSET matriz
	call TelaPreta
L33:
	;colorindo separadamente o dragao e a moça
L4:
	mov al, [esi]
	mov dl, al
	cmp al, '.'
jne greenc
	mov al, lightgreen
	call SetTextColor
jmp x
greenc:
	cmp al, ','
jne whitec
	mov al, white
	call SetTextColor
jmp y
whitec:
	cmp al, '('
jne yellowc
	mov al, yellow
	call SetTextColor
yellowc:
y:
x:
	mov al, dl
	call WriteChar
	inc esi
	loop L4
	call esperaXms
	pop eax
	call CloseFIle

	mov ebx, 3000
	call esperaXms
	call Crlf

	mov al, white
	call SetTextColor
;Dialogo Final 1
	mov edx, OFFSET nomeArqLore6
	call OpenInputFile
	push eax
	mov edx, OFFSET matriz
	mov ecx, tamanhoM
	call ReadFromFile
	mov ecx, eax

	mov ebx, 70
	mov esi, OFFSET matriz
L31:
	mov al, [esi]
	cmp al, ';'
	je pulalinha
	cmp al, '@'
	je pulaleitura
	call WriteChar
	inc esi
	call esperaXms
	Loop L31
  pulalinha:
	call Crlf
	inc esi
	inc esi
	jmp L31
  pulaleitura:
	call WaitMsg
	call Clrscr
	pop eax
	call CloseFile

;Enigmas
	mov al, 4
	call mudaCores
	call Clrscr
	mov ebx, 45

;primeiro enigma
	
	mov edx, OFFSET nomeArqLore7
	call OpenInputFile
	push eax
	mov edx, OFFSET matriz
	mov ecx, tamanhoM
	call ReadFromFile
	mov ecx, eax
	pop eax
	call CloseFIle

	mov esi, OFFSET matriz
L32:
	mov al, [esi]
	cmp al, ';'
	je pulalinha1
	cmp al, '@'
	je pulaleitura1
	cmp al, '#'
	je pulaleitura2
	cmp al, '$'
	je pulaleitura3
	call WriteChar
	inc esi
	call esperaXms
	Loop L32
pulalinha1:
	call Crlf
	inc esi
	jmp L32
pulaleitura1:
	call ReadInt
	cmp eax, 1
	je respcerta1
	call Morte
	jmp finalmorte
pulaleitura2:
	call ReadInt
	cmp eax, 3
	je respcerta1
	call Morte
	jmp finalmorte
pulaleitura3:
	call ReadInt
	cmp eax, 1
	je saiEnigmas
	call Morte
	jmp finalmorte
respcerta1:
	call Clrscr
	add esi, 3
	jmp L32

saiEnigmas:

;Dialogo Final 2
	call Clrscr
	mov ebx, 30
	
	mov edx, OFFSET nomeArqLore9
	call OpenInputFile
	push eax
	mov edx, OFFSET matriz
	mov ecx, tamanhoM
	call ReadFromFile
	mov ecx, eax

	mov esi, OFFSET matriz
L35:
	mov al, [esi]
	cmp al, ';'
	je pulalinha4
	cmp al, '@'
	je pulaleitura4
	call WriteChar
	inc esi
	call esperaXms
	loop L35
  pulalinha4:
	call Crlf
	inc esi
	inc esi
	jmp L35
  pulaleitura4:

	pop eax
	call CloseFIle
	mov ebx, 2000
	call esperaXms

;revelação Final
	mov edx, OFFSET nomeArqLore10
	call OpenInputFile
	push eax
	mov edx, OFFSET matriz
	mov ecx, tamanhoM
	call ReadFromFile
	mov ecx, eax
	mov esi, OFFSET matriz
	mov al, 5
	call mudacores
	call Clrscr

L36:
	mov al, [esi]
	call WriteChar
	inc esi	
	loop L36

	call Crlf
	mov al, 2
	call mudacores
	mov ebx, 50
	mov esi, OFFSET msg10
	mov ecx, LENGTHOF msg10
L2:
	mov eax, [esi]
	call WriteChar
	inc esi
	call esperaXms
	loop L2

finalmorte:
	call Crlf
	call Crlf
	pop eax
	call CloseFIle
	mov ebx, 4000
	call esperaXms

;creditos
	mov edx, OFFSET nomeArqLore11
	call OpenInputFile
	push eax
	mov edx, OFFSET matriz
	mov ecx, tamanhoM
	call ReadFromFile
	mov ecx, eax
	mov esi, OFFSET matriz

L1:
	mov al, [esi]
	call WriteChar
	inc esi
	loop L1

	pop eax
	call CloseFIle
	call Crlf
	call WaitMsg

	mov al, 1
	call mudacores
	ret
DialogoFinal ENDP

Morte PROC
	call Clrscr
	mov edx, OFFSET nomeArqLore8
	call OpenInputFile
	push eax
	mov edx, OFFSET matriz
	mov ecx, tamanhoM
	call ReadFromFile
	mov ecx, eax
	mov esi, OFFSET matriz
	call TelaPreta

L5:
	mov al, [esi]
	mov dl, al
	cmp al, 'o'
jne redeyes
	mov al, lightred
	call SetTextColor
	jmp r
redeyes:
	cmp al, 'O'
	jne grayscythe
	mov al, lightgray
	call SetTextColor
	jmp r
grayscythe:
	cmp al, 'D'
    jne grayscythe2
	mov al, lightgray
	call SetTextColor
	jmp r
grayscythe2:
	cmp al, '#'
	jne magentarobe
	mov al, lightmagenta
	call SetTextColor
	jmp r
magentarobe:
	mov al, white
	call SetTextColor

r:
	mov al, dl
	call WriteChar
	inc esi
	loop L5

	call escreveVoceMorreu

	pop eax
	call CloseFile

ret
Morte ENDP

TelaPreta PROC
	mov al, 2
	call mudaCores
	call Clrscr
ret
TelaPreta ENDP

escreveVoceMorreu PROC

	mov ebx, 50
	mov esi, OFFSET msg9
	mov ecx, LENGTHOF msg9
L1:
	mov eax, [esi]
	call WriteChar
	inc esi
	call esperaXms
	loop L1

	mov ebx, 4000
	call esperaXms

	;retornando para as cores originais do jogo (fundo azul e caracteres brancos)
	mov al, 1
	call mudaCores
	
	call Clrscr
ret
escreveVoceMorreu ENDP