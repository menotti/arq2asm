TITLE Space_Invaders


;INCLUDE Irvine32.inc
.data
	fHighscore BYTE "highscore.txt", 0
	fDificuldades BYTE "src\SpaceInvaders\dificuldades.txt", 0

	bufferHighscore BYTE 4096 DUP(0)
	bufferConversaoHighscore BYTE 10 DUP(?)
	erroDificuldades BYTE "ARQUIVO DE DIFICULDADES NAO ENCONTRADO",0

	enemyTop BYTE 219,"    ", 219, 0
	enemyMid BYTE 6 DUP(219), 0
	enemyBottom BYTE 219,219, 0

	enemyTopEmpty BYTE "      ", 0
	enemyMidEmpty BYTE "      ",0
	enemyBottomEmpty BYTE "  ",0

	heroTop BYTE 219, 0				;Essas sao as strings que formam o desenho do nosso personagem
	heroBottom BYTE 219,219,219, 0		
	heroTopEmpty BYTE " ", 0		;Essas sao as strings que usamos para apagar nosso personagem, apenas espaços em branco
	heroBottomEmpty BYTE "   ",0
	heroUpdateBool BYTE 0			;Variavel utilizada para verificar se existe uma modificacao a ser feita no nosso personagem.
									;	este valor eh muito importante, e seu uso se da na parte de processamento do codigo.
	scoreLabel BYTE "SCORE: ",0
	livesLabel BYTE "VIDAS: ",0
	countLives BYTE 0				;Contagem de "vidas" do personagem
	countScore BYTE 0				;Contagem dos pontos do personagem
	placarBool BYTE 0				;Verifica se o placar precisa ser atualizado

	tiroX BYTE 0, 0					;Vetor de coordenadas X dos tiros correspondentes, i.e. tiroX[0] -> coord X do primeiro tiro
	tiroY BYTE 0, 0					;Vetor de coordenadas Y dos tiros correspondentes, i.e. tiroY[0] -> coord Y do primeiro tiro
									;PS: Coordenadas vao, em ordem crescente: X da esq. para a direita da tela.
									;   Y de cima para baixo da tela.
	tiroHitBool BYTE 0, 0			;Vetor de variaveis utilizadas para verificar se existe o "tiro" ou nao e se existe algum tiro que atingiu o inimigo.
	tiroBool BYTE 0, 0				;	Usados para rastrear e atualizar os tiros
				
	tiroTime DWORD 0, 0			;Vetor de "Tempos" dos tiros, utilizados para regular a velocidade de atualização dos tiros.

;	teclaTime DWORD 0
	setaEsquerdaBool DWORD 0		;Variaveis utilizadas para rastreamento das teclas do teclado. 
	setaDireitaBool DWORD 0			;	A implementação desta maneira buscava melhor desempenho e resposta do teclado.


	enemyX BYTE 10, 24, 45, 60, 64		;Vetores de coordenadas X e Y dos inimigos
	enemyY BYTE 5 DUP(1)
	enemyBool BYTE 5 DUP(0)			;Vetor de variaveis de controle de existencia
	enemyTime DWORD 5 DUP(0)		;Vetor de variaveis de controle de tempo de atualização (similar aos tiros)
	enemyHitBool BYTE 5 DUP(0)		;Vetor de variáveis de controle de colisão do inimigo
	enemyHitLabel BYTE -1		;Indica qual o inimigo (indice) atingido pelo ultimo tiro, com -1 sendo NENHUM

	personagemX BYTE 39				;Coordenadas do personagem principal
	personagemY BYTE 24
	
	geradorTime DWORD 0				;Variavel de controle do tempo do "gerador aleatório" de inimigos

	tempoGeracaoEnemy DWORD 0, 0, 0, 0, 0, 0, 0, 0
	dificuldade BYTE 0

	linhaFundo BYTE 80 DUP("-"), 0
	emptyLine BYTE 80 DUP(" "), 0
	fraseGameOver BYTE "GAME OVER",0
	frasePontuacaoFinal BYTE "PONTUACAO FINAL: ",0

	gameOver BYTE 0					;Variavel de fim de jogo.

.code
Space_Invaders PROC

	
		call ClrScr
		call GetMseconds		;Inicializa a variavel do tempo do gerador e as vidas
		mov geradorTime, eax
		mov countLives, 2
		
;--------------------------------------------- Escreve personagem na tela pela primeira vez
		
		mov dh, personagemY
		mov dl, personagemX
		sub dh, 1
		add dl, 1
		call GotoXY
		mov edx, OFFSET heroTop
		call WriteString

		mov dh, personagemY
		mov dl, personagemX
		call GotoXY
		mov edx, OFFSET heroBottom
		call WriteString
		
		mov heroUpdateBool, 0
;----------------------------------------------

;---------------------------------------------- Inicia placar, vida, e linha do fundo
		mov dh, 25
		mov dl, 0
		call GotoXY
		mov edx, OFFSET linhaFundo
		call WriteString

		mov dh, 26
		mov dl,0
		push edx
		call GotoXY
		mov edx, OFFSET scoreLabel
		call WriteString

		pop edx
		add dl, (LENGTHOF scoreLabel - 1)
		call GotoXY
		movzx eax, countScore
		call WriteDec

		mov dh, 27
		mov dl, 0
		push edx
		call GotoXY
		mov edx, OFFSET livesLabel
		call WriteString
		
		pop edx
		add dl, (LENGTHOF livesLabel - 1)
		call GotoXY
		movzx eax, countLives
		call WriteDec
		
;-----------------------------------------------	

;-------------------------------CARREGA DIFICULDADES DO ARQUIVO
	mov eax, OFFSET bufferConversaoHighscore
	mov eax, OFFSET tempoGeracaoEnemy

	mov edx, OFFSET fDificuldades
	call OpenInputFile
	cmp eax, INVALID_HANDLE_VALUE
	je NAO_CARREGOU_DIFICULDADES

	push eax						;Guarda na pilha o valor de manipular arquivo.

	;se carregou:
	mov edx, OFFSET bufferHighscore
	mov ecx, 4096					;Tamanho do arquivo
	call ReadFromFile


	mov esi, OFFSET bufferHighscore	;esi aponta para primeira dificuldade
	mov edi, OFFSET bufferConversaoHighscore
	mov ebx, 0						;ebx será o índice para acessar o vetor das dificuldades

LOOP_CARREGA_STRING:
	mov al, [esi]
	cmp al, '/'
	je FIM_NUMERO_STRING
		mov [edi], al
		add edi, 1
		add esi, 1
	jmp LOOP_CARREGA_STRING

	FIM_NUMERO_STRING:
	add esi, 1
	mov al, 'K'
	mov [edi], al					;Caractere para que o PROC ParseDecimal32 pare a conversao
	
	mov edx, OFFSET bufferConversaoHighscore
	mov ecx, SIZEOF bufferConversaoHighscore
	call ParseDecimal32

	mov tempoGeracaoEnemy[ebx*4], eax
	mov edi, OFFSET bufferConversaoHighscore		;edi recebe novamente a string de conversao
	add ebx,1
	cmp ebx, 7						;Verifica se o índice ultrapassou a ultima posicao no vetor dos temposde geracao
	ja FIM_CARREGAR_DIFICULDADES
	jmp LOOP_CARREGA_STRING
FIM_CARREGAR_DIFICULDADES:

	pop eax							;recupera em eax o valor de manipular aquivos
	call CloseFile					;fecha arquivo de dificuldades

	
;-------------------------------FIM CARREGAR DIFICULDADES


;Aqui começa o GameLoop, que é nossa verificacao constante de todos os elementos, e atualizacao dos mesmos.
		
GameLoop:		
	cmp gameOver, 1

	je GAME_OVER

	
	call verificaScore
	movzx esi, dificuldade
	call GetMseconds			;Este trecho de codigo funciona verificando a ultima vez
	mov ebx, eax				;	que o tempo do gerador foi atualizado, assim
	sub eax, geradorTime	;	sabemos se o tempo está de nosso gosto. 
	cmp eax, tempoGeracaoEnemy[esi * 4]	;Se tempo < 4 segundos (4000 milisegundos)
	jb NAO_GERA_INIMIGO
		call gerarInimigos		;Inicializa os dados de um inimigo
		mov geradorTime, ebx	;Atualiza o tempo do gerador.
	NAO_GERA_INIMIGO:

; ------------------------------------------- LEITURA CONSTANTE DOS BOTÕES
	mov eax, 10
	call Delay					;TENTATIVA DE MELHORAR LEITURA DE TECLAS, o delay ajuda a pegar as teclas corretamente!
	call ReadKey				;Le sem esperar, direto do buffer do teclado.
	jz NO_KEY_READ				;Nenhuma tecla apertada, pular para processamento
	push eax				
	call ReadKeyflush			;Limpa o buffer, ajuda na performance
	pop eax			
		cmp ah, 75				;Verifica quais teclas foram apertadas, pelo codigo em ax(retornado por ReadKey!)
		je SetaEsquerda
		cmp ah, 77
		je SetaDireita
		cmp ah, 57
		je BarraEspaco

	SetaEsquerda:				;Verificacao da seta esquerda
		cmp personagemX, 0		;Verifica se nao esta na "parede" esquerda
		jbe PROCESSAMENTO		;	se estiver na borda, nao aceita o input
		mov setaEsquerdaBool, 1		;faz as atualizacoes dos dados do personagem
		mov heroUpdateBool, 1		;indica que o personagem foi modificado, processamento fará a escrita
		jmp PROCESSAMENTO
	SetaDireita:
		cmp personagemX, 77			
		jae PROCESSAMENTO
		mov setaDireitaBool, 1
		mov heroUpdateBool, 1
		jmp PROCESSAMENTO
	BarraEspaco:					
		mov ecx, LENGTHOF tiroBool			;numero de tiros possiveis	
		mov esi, 0			;indice para controlar qual tiro estamos verificando
		LOOP1:				;Loop que busca um tiro livre (que nao esta em uso na tela)
			cmp tiroBool[esi], 1
			je EXISTE_TIRO
				mov tiroBool[esi],1
				call GetMseconds
				mov tiroTime[esi * 4], eax
				mov al, personagemX
				mov tiroX[esi], al
				mov al, personagemY
				mov tiroY[esi], al
				add tiroX[esi], 1
				sub tiroY[esi], 2
				jmp PROCESSAMENTO ;Tiro criado, finaliza geração de tiro.

			EXISTE_TIRO:
			add esi, 1
		loop LOOP1
		jmp PROCESSAMENTO			
		
;---------------------------------------------- FIM DA LEITURA DE BOTOES
NO_KEY_READ:					;Se nada foi lido, atualiza as variaveis de teclado.
	mov setaEsquerdaBool, 0 
	mov setaDireitaBool, 0
PROCESSAMENTO:					;Secao de processamento dos dados
	cmp heroUpdateBool, 0		;Verifica se existe algo a mudar no personagem
	je NO_UPDATE_HERO
		call EscrevePersonagem	;Escreve o personagem com suas alteracoes
NO_UPDATE_HERO:

;==================CHECAGEM DE COLISÕES
call checaColisoes

;==================FIM CHECAGEM DE COLISÕES 

;==================ATUALIZA E ESCREVE INIMIGOS
mov ecx, 5		;Numero maximo de inimigos
mov esi, 0		;indice dos inimigos
LOOP_INIMIGOS:
	cmp enemyBool[esi], 0		;Verifica se o inimigo "existe" ou esta desligado
		je NO_ENEMY_UPDATE
			call escreveInimigo1	;Se inimigo estiver ativo, escreve e atualiza o inimigo
	NO_ENEMY_UPDATE:
	add esi, 1
loop LOOP_INIMIGOS



;==================FIM DA ATUALIZACAO E ESCRITA DE INIMIGOS

;==================ATUALIZA E ESCREVE TIROS
mov ecx, LENGTHOF tiroBool		;Numero max de tiros
mov esi, 0						;indice dos tiros
LOOP_TIROS:
	cmp tiroBool[esi], 0		;Verifica se tiro esta ativo
		je NO_TIRO_UPDATE
			call escreveTiro1	;Caso ativo, atualiza e desenha na tela
		NO_TIRO_UPDATE:
		add esi, 1
loop LOOP_TIROS
;==================FIM ATUALIZAÇÃO E ESCRITA DE TIROS

;==================ATUALIZA E ESCREVE: PLACAR E VIDA
cmp placarBool, 0
je NO_UPDATE_PLACAR
	mov dh, 26
	mov dl,0
	push edx
	call GotoXY
	mov edx, OFFSET emptyLine
	call WriteString

	pop edx

	push edx
	call GotoXY
	mov edx, OFFSET scoreLabel
	call WriteString


	pop edx
	add dl, (LENGTHOF scoreLabel - 1)
	call GotoXY
	movzx eax, countScore
	call WriteDec

	mov dh, 27
	mov dl, 0
	push edx
	call GotoXY
	mov edx, OFFSET emptyLine
	call WriteString

	pop edx
	push edx
	call GotoXY
	mov edx, OFFSET livesLabel
	call WriteString
		
	pop edx
	add dl, (LENGTHOF livesLabel - 1)
	call GotoXY
	movzx eax, countLives
	call WriteDec

	mov placarBool, 0
NO_UPDATE_PLACAR:
;==================FIM ATUALIZAÇÃO DE PLACARE VIDA

cmp countLives, 0
jne NAO_MORREU
	mov gameOver, 1
NAO_MORREU:	
	jmp GameLoop	;Volta ao inicio das verificacoes, fechando assim nosso loop de jogo.

NAO_CARREGOU_DIFICULDADES:
	call ClrScr
	mov edx, OFFSET erroDificuldades
	call WriteString
	call Crlf
	call WaitMsg
jmp FINAL_PROGRAMA
	

GAME_OVER:
	call ClrScr
	mov edx, OFFSET fraseGameOver
	call WriteString
	call Crlf
	mov edx, OFFSET frasePontuacaoFinal
	call WriteString
	movzx eax, countScore
	call WriteDec
	call Crlf
	call WaitMsg
	
FINAL_PROGRAMA:
	mov gameOver, 0						;gameOver recebe zero novamente, caso jogo reinicie.
	ret
Space_Invaders ENDP






















;---------------------------------------------------------------------------------------------
escreveTiro1 PROC USES EBX EDX ECX EAX 
;Funcao que atualiza um tiro, modificando suas posicoes X e Y
;	e escreve o tiro na tela
;Recebe: ESI <- indice do tiro a ser escrito
;Retorna: Nada
;---------------------------------------------------------------------------------------------
	call GetMseconds
	mov ebx, eax
	sub eax, tiroTime[esi * 4]			;Parecido com o esquema do gerador de inimigos
	cmp eax, 100						;	os valores aqui regulam a taxa de atualizacao do tiro
	jb FIM_TIRO
	
	cmp tiroHitBool[esi], 1				;Verifica se o tiro atingiu um inimigo
	je ATINGIU_HIT
	
	cmp tiroY[esi], 0					;Verifica se o tiro atingiu o "teto" da tela
	je ATINGIU_HIT				
	
	;====================Atualiza posicao do tiro, quando este nao atinge nada
	sub tiroY[esi], 1
	mov tiroTime[esi * 4], ebx

	mov dh, tiroY[esi]
	mov dl, tiroX[esi]
	call GotoXY
	add dh, 1
	mov al, 30
	call WriteChar
	call GotoXY
	mov al, " "
	call WriteChar

	jmp FIM_TIRO

ATINGIU_HIT:				;Desativa o tiro, e apaga da tela o tiro
	mov tiroBool[esi], 0
	mov tiroHitBool[esi], 0
	mov dh, tiroY[esi]
	mov dl, tiroX[esi]
	call GotoXY
	mov al, " "
	call WriteChar
	mov tiroTime[esi * 4], 0

jmp FIM_TIRO

FIM_TIRO:

	ret
escreveTiro1 ENDP

;---------------------------------------------------------------------------------------------
EscrevePersonagem PROC USES EDX EBX EAX
;Procedimento que atualiza e escreve o personagem em tela, a partir de seus dados
;
;Recebe: Nada
;Retorna: Nada
;---------------------------------------------------------------------------------------------


		cmp setaDireitaBool, 0
		je MOVE_PARA_ESQUERDA
			add personagemX, 1		;move pra esquerda
			jmp ERASE_HERO_LEFT
		MOVE_PARA_ESQUERDA:	
		cmp setaEsquerdaBool, 0
		je NAO_MODIFICA_PERSONAGEM
			sub personagemX, 1
			jmp ERASE_HERO_RIGHT

	
	;Aqui, o personagem será apagado para o novo ser desenhado.
	ERASE_HERO_LEFT:
		mov dh, personagemY
		mov dl, personagemX
		sub dl, 1
		push edx
		sub dh, 1
		add dl, 1
		call GotoXY
		mov edx, OFFSET heroTopEmpty
		call WriteString
		pop edx
		call GotoXY
		mov edx, OFFSET heroBottomEmpty
		call WriteString
	jmp ESCRITA_PERSONAGEM

	ERASE_HERO_RIGHT:
		mov dh, personagemY
		mov dl, personagemX
		add dl, 1
		push edx
		sub dh, 1
		add dl, 1
		call GotoXY
		mov edx, OFFSET heroTopEmpty
		call WriteString
		pop edx
		call GotoXY
		mov edx, OFFSET heroBottomEmpty
		call WriteString		

NAO_MODIFICA_PERSONAGEM:
ESCRITA_PERSONAGEM:
;=======================================ESCRITA DO PERSONAGEM
		mov dh, personagemY
		mov dl, personagemX
		sub dh, 1
		add dl, 1
		call GotoXY
		mov edx, OFFSET heroTop
		call WriteString

		mov dh, personagemY
		mov dl, personagemX
		call GotoXY
		mov edx, OFFSET heroBottom
		call WriteString
		
		
		mov heroUpdateBool, 0			;Avisa que as atualizacoes que foram feitas foram computadas, e reseta o verificador
FIM_PERSONAGEM:
ret
EscrevePersonagem ENDP

;---------------------------------------------------------------------------------------------
escreveInimigo1 PROC USES EBX EDX EAX
;Procedimento para escrita e atualizacao dos inimigos em tela
;	por meio do ESI como indice, o inimigo é selecionado nos vetores e modificado/escrito em tela
;Recebe: ESI <- Indice do inimigo [0...n-1]
;Retorna: Nada
;---------------------------------------------------------------------------------------------
	
	cmp enemyHitBool[esi], 1
	je ATINGIU_HIT

	call GetMseconds
 	mov ebx, eax
	sub eax, enemyTime[esi * 4]			;Regula a atualizacao, nesse caso 0.5 segundos
	cmp eax, 500
	jb FIM_ENEMY
	
	
	cmp enemyY[esi], 24					;Verifica se atingiu a base da tela
	je ATINGIU_CHAO
	
	;=======================Atualiza posicao e escreve
	add enemyY[esi], 1
	mov enemyTime[esi * 4], ebx
	
	mov dh, enemyY[esi]
	mov dl, enemyX[esi]
	mov ebx, edx				;Guarda posicao em EBX, pois EDX é usado em WriteString

	;Primeiro, apaga o desenho anterior
	mov edx, ebx
	sub dh,1
	call GotoXY
	mov edx, OFFSET enemyBottomEmpty
	call WriteString

	mov edx, ebx
	sub dh,2
	sub dl,2
	call GotoXY
	mov edx, OFFSET enemyMidEmpty
	call WriteString

	mov edx, ebx
	sub dh,3
	sub dl,2
	call GotoXY
	mov edx, OFFSET enemyTopEmpty
	call WriteString


	;Agora escreve o novo desenho
	mov edx, ebx
	call GotoXY
	mov edx, OFFSET enemyBottom
	call WriteString

	mov edx, ebx				;Recupera posicao
	sub dh,1
	sub dl,2					;Vai para meio do inimigo
	call GotoXY
	mov edx, OFFSET enemyMid
	call WriteString

	mov edx, ebx
	sub dh,2
	sub dl,2
	call GotoXY
	mov edx, OFFSET enemyTop
	call WriteString
	
	jmp FIM_ENEMY

ATINGIU_HIT:
	mov dh, enemyY[esi]
	mov dl, enemyX[esi]
	mov ebx, edx
	call GotoXY

	mov edx, ebx
	call GotoXY
	mov edx, OFFSET enemyBottomEmpty
	call WriteString

	mov edx, ebx
	sub dh,1
	sub dl,2
	call GotoXY
	mov edx, OFFSET enemyMidEmpty
	call WriteString

	mov edx, ebx
	sub dh,2
	sub dl,2
	call GotoXY
	mov edx, OFFSET enemyTopEmpty
	call WriteString
	mov dh, enemyY[esi]
	mov dl, enemyX[esi]
	mov ebx, edx
	call GotoXY
	
	mov enemyBool[esi], 0
	add countScore, 1						;Quando um inimigo é deletado, a pontuação é contada
	mov placarBool, 1
	jmp FIM_ENEMY
ATINGIU_CHAO:				;Realiza a "delecao" do inimigo
	sub countLives, 1
	mov placarBool, 1
	mov enemyBool[esi], 0
	mov dh, enemyY[esi]
	mov dl, enemyX[esi]
	mov ebx, edx
	call GotoXY
	
	mov edx, ebx
	call GotoXY
	mov edx, OFFSET enemyBottomEmpty
	call WriteString

	mov edx, ebx
	sub dh,1
	sub dl,2
	call GotoXY
	mov edx, OFFSET enemyMidEmpty
	call WriteString

	mov edx, ebx
	sub dh,2
	sub dl,2
	call GotoXY
	mov edx, OFFSET enemyTopEmpty
	call WriteString

	mov enemyTime[esi * 4], 0

FIM_ENEMY:

	ret
escreveInimigo1 ENDP
;---------------------------------------------------------------------------------------------
gerarInimigos PROC USES ECX EDX EAX ESI
;Inicializa um inimigo no topo da tela, com uma coordenada X pseudo-randomica
;
;Recebe: Nada
;Retorna: Nada
;---------------------------------------------------------------------------------------------
		mov ecx, 5
		mov esi, 0
		
		LOOP_SEARCH_ENEMY:
		push ecx
		cmp enemyBool[esi], 1
		je JA_EXISTE
			mov enemyBool[esi], 1
			mov enemyHitBool[esi], 0
			mov enemyY[esi], 2
			
			mov eax, 80
			call RandomRange
			
			mov enemyX[esi], al
			cmp al, 2
			jbe SAIU_DOIS			; A posicao X = 2 e X = 77 dá problema no grafico!!
				cmp al, 77
				jae SAIU_SETENTA_SETE
					jmp INIMIGO_GERADO
			SAIU_DOIS:
				mov enemyX[esi], 3
				jmp INIMIGO_GERADO
			SAIU_SETENTA_SETE:
				mov enemyX[esi], 76
				jmp INIMIGO_GERADO
		JA_EXISTE:
		add esi, 1
		pop ecx
		loop LOOP_SEARCH_ENEMY
		jmp FINAL

		INIMIGO_GERADO:
		pop ecx
		FINAL:
	ret
gerarInimigos ENDP

;-----------------------------------------------------------
checaColisoes PROC USES ECX EBX ESI
;
;
;-----------------------------------------------------------
mov ecx, LENGTHOF tiroBool	;Numero de tiros max
mov ebx, 0	;Indice dos tiros
CHECAGEM_COLISOES:
	push ecx	;Loop aninhado
	mov esi, 0	;indice dos inimigos
	mov ecx, 5	;numero de inimigos max
	L1:	cmp enemyBool[esi], 0
		je NO_COLISION		;Inimigo está inativo, não pode colidir.
		cmp tiroBool[ebx], 0
		je NO_COLISION
		mov al, enemyX[esi]
		cmp tiroX[ebx], al	;verifica se atingiu a cabeça na esquerda
		jne NO_COLISION_CABECA_ESQUERDA	
			jmp ACERTOU_X
		NO_COLISION_CABECA_ESQUERDA:
		add al, 1			;verifica se atingiu a cabeça na direita
		cmp tiroX[ebx], al	
		jne NO_COLISION_CABECA_DIREITA
			jmp ACERTOU_X
		NO_COLISION_CABECA_DIREITA:
			jmp NO_COLISION
			ACERTOU_X:
			mov al, enemyY[esi]
			cmp tiroY[ebx], al
			jne NO_COLISION
				mov enemyHitBool[esi], 1		;Colisao encontrada, indica colisao no inimigo
				mov tiroHitBool[ebx], 1			;	e avisa que o tiro atingiu inimigo
		NO_COLISION:
		add esi, 1							;Vai para prox inimigo
	loop L1
	add ebx, 1
	pop ecx
loop CHECAGEM_COLISOES

ret
checaColisoes ENDP

verificaScore PROC
	cmp countScore, 15
	jne NOT_15
		mov dificuldade, 2
	NOT_15:
	cmp countScore, 30
	jne NOT_30
		mov dificuldade, 4
	NOT_30:
	cmp countScore, 45
	jne NOT_45
		mov dificuldade, 6
	NOT_45:
	cmp countScore, 60
	jne NOT_60
		mov dificuldade, 7
	NOT_60:


	ret
verificaScore ENDP

deletaInimigo PROC
;Procedimento chamado dentro do escreveTiro, para ir até o inimigo atingido e apagar seu grafico
;Recebe:
;Retorna: Nada
deletaINIMIGO ENDP