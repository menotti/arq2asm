TITLE Labirinto da Morte (labirinto.asm)

.data
msgInicio BYTE "Labirinto da Morte",0dh,0ah,0
msgMenu BYTE "______Menu______",0dh,0ah,
             "1-Iniciar",0dh,0ah,
			 "2-Sair",0dh,0ah,
			 "Sua opcao:", 0

msgDificuldade BYTE "Escolha a dificuldade:", 0dh, 0ah,
                    "1-Normal (Visao de raio 2 em volta de voce)",0dh,0ah,
			        "2-Dificil(Visao de raio 1 em volta de voce)",0dh,0ah,
					"0-Voltar ao menu inicial",0dh,0ah,
			        "Sua opcao:", 0

msgFase BYTE "Escolha a fase:", 0dh, 0ah,
             "1-Labirinto e o Minotauro ",0dh,0ah,
			 "2- Labirinto do Troll",0dh,0ah,
			 "0-Voltar ao menu inicial",0dh,0ah,
			 "Sua opcao:", 0
                     

nomeArq BYTE "m1.txt", 0
nomeTArq BYTE "tamM1.txt",0
nomeArq2 BYTE "m2.txt", 0
nomeTArq2 BYTE "tamM2.txt",0

aux BYTE 10 DUP(0)

tamanho DWORD ?
tamanhoM DWORD ?
matriz BYTE 2400 DUP (0)

posicao DWORD ?
posicaoS DWORD ?

direcao BYTE ?
mapa BYTE ?
liberado BYTE 0
visao BYTE 1

.code

escreveMenu PROC
      call Clrscr
	  
	  mov edx,OFFSET msgInicio
	  call WriteString
	  mov edx, OFFSET msgMenu
	  call WriteString
  ret
escreveMenu ENDP

escreveDificuldade PROC
      call Clrscr
	 
	  mov edx, OFFSET msgDificuldade
	  call WriteString
  ret
escreveDificuldade ENDP

escreveFase PROC
      call Clrscr
	  
	  mov edx, OFFSET msgFase
	  call WriteString
  ret
escreveFase ENDP

leLabirinto PROC
      cmp mapa, 2
	  je m2

	  mov edx, offset nomeTArq
	  jmp nPassa

	  m2: 
	  mov edx, offset nomeTArq2

	  nPassa:

	  call OpenInputFile

	  mov edx, offset tamanho
	  mov ecx, 3
	  call ReadFromFile
      
	  mov edx, offset tamanho
	  movsx ecx, al 
	  call ParseDecimal32

	  mov tamanho, eax

	  mov bl, al
	  movsx bx, bl
	  mul bl

	  shl bl, 1
	  movsx bx, bl
	  add ax, bx

	  movsx ecx, ax
	  mov tamanhoM, ecx

	  cmp mapa, 2
	  je m3

	  mov edx, offset nomeArq
	  jmp nPassa2

	  m3: 
	  mov edx, offset nomeArq2

	  nPassa2:

	  call OpenInputFile

	  mov ecx, tamanhoM
	  mov edx, offset matriz
	  call ReadFromFile

	  call buscaPosicao
	  call buscaSaida
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
  ret
buscaPosicao ENDP

buscaSaida PROC
    mov ecx, tamanhoM
    mov esi, offset matriz
    
	busca:
	  mov al, [esi]
	  cmp al, 124
	  je sai
	  inc esi
	loop busca

	sai:
	  mov posicaoS, esi
  ret
   
buscaSaida ENDP

escreveLabirinto PROC
    mov ecx, tamanhoM
	mov esi, offset matriz

	passa:
	  call escreveChar
	  inc esi
	loop passa

  ret
escreveLabirinto ENDP

escreveChar PROC
    mov al,[esi]

	cmp al, 79
	je p

	cmp al, 35
	je pa

	cmp al, 0dh
	je p

	cmp al, 0ah
	je p


	jmp parede

	p:
	  call WriteChar
	  jmp escreveu

	pa:
	  mov al, 35
	  call WriteChar
	  jmp escreveu

	parede:

	mov al, 32
	call WriteChar
	
	escreveu:

  ret
escreveChar ENDP

movimento PROC
  cmp direcao, 0
  je cima

  cmp direcao, 1
  je direita

  cmp direcao, 2
  je baixo

  cmp direcao, 3
  je esquerda

  cima:
    mov edx, tamanho
	add edx, 2

	mov edi, posicao
	sub edi, edx

	cmp edi, offset matriz
	jb invalido

    call verificaMovimento
    jmp invalido

  direita:
    mov edi, posicao
	inc edi

	mov al, [edi]

	cmp al, 0dh
	je invalido

	call verificaMovimento
	jmp invalido

   baixo:
    mov edx, tamanho
	add edx, 2

	mov edi, posicao
	add edi, edx

	mov esi, offset matriz
	add esi, tamanhoM

	cmp edi, esi
	ja invalido

    call verificaMovimento
	jmp invalido

	esquerda:
      mov edi, posicao
	  sub edi, 1

  	  mov al, [edi]

	  cmp al, 0ah
	  je invalido

	  call verificaMovimento

	invalido:
 
  ret
movimento ENDP

verificaMovimento PROC uses EAX
    mov al, [edi]
    
	cmp al, 32
	je move

	cmp al, 124
	je move

	jmp nMove
	
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
	  mov eax, tamanho
	  add eax, 2
	  mov esi, eax

	  mov edi, posicao
	  inc edi
	  inc edi
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

	  inc edi
	  inc edi
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

	  inc edi
	  inc edi
	  call verificaBorda
      cmp eax, 1
	  jne nValido21
	  call substituiParede
	  nValido21:

	  sub edi, 4
	  call verificaBorda
      cmp eax, 1
	  jne nValido22
	  call substituiParede
	  nValido22:

	visao1: 
	  mov eax, tamanho
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
   cmp ecx, 1
   je mostra

    mov al, [edi]
    cmp al, 35
	jne nMuda

	mov al, 42
	mov [edi], al

	nMuda:

	jmp fim3

  mostra:

      mov al, [edi]
	  cmp al, 42
	  jne nMuda2

	  mov al, 35
	  mov [edi], al

	  nMuda2:
  
  fim3:

  ret
substituiParede ENDP

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

jogaLabirinto PROC
	menuInicial:
	  call escreveMenu
	  
	  call ReadInt
	  jc menuInicial

	  cmp eax, 1
	  je dif

	  jmp sair

    dif:
	  call escreveDificuldade

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
		jmp fase
	  
	  v2: 
	    mov visao, 1
		jmp fase

	  fase:

	  call escreveFase

	  call ReadInt
	  jc fase

	  cmp eax, 0
	  je menuInicial

	  mov mapa, al

	jogo:
	  call leLabirinto
	  mov ecx, 1
	  call atualizaLabirinto

	  continua:
	    call Clrscr
        call escreveLabirinto
;		mov eax, posicao
;	    cmp eax, posicaoS

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

		jmp inv

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

	   inv:


       jmp continua
	fim:

	  call liberaMapa
	  call ReadKey
    
	sair:
	ret
jogaLabirinto ENDP