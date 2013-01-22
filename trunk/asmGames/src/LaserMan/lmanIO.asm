.data
;Organização
;cada registro será: 3 bytes iniciais 1 byte separador x bytes de pontos 1 byte terminal
rankBuffer BYTE 150 dup(0)
rankfile BYTE "rankreg",0
infofile BYTE "gamereg",0

;Master helper
fhandle dword ?

.code
;--------------------------------------------------------
;SHOW RANK
;Lucas carvalhaes
;Mostra o rank salvo no arquivo
showRank PROC uses edx ecx eax
;--------------------------------------------------------
	;Create or open the input file
	mov edx, OFFSET rankfile

	;Call the open
	call OpenInputFile

	;Prepare params
	mov edx, OFFSET rankBuffer
	mov ecx,150

	;Read
	call ReadFromFile

	;Clear the screen
	call Clrscr

	;Prepare again
	mov edx, OFFSET rankBuffer

	;Show the buffer nice in the screen
	mov ecx,1 ;zera contador
	showRank_showEntries:
		mov al, [edx]
		cmp al, ';' ;end of file
		je showRank_sair
		cmp ecx, 11
		je showRank_sair

		mov eax,white+(black*16)
	    call SetTextColor

		;Print the position
		mov eax,ecx
		call WriteDec
		mWrite "/ lugar - *"
		inc ecx ;avança contador

			;Desenha as iniciais
			mov eax,lightblue+(black*16)
			call SetTextColor
			push ecx
			mov ecx,3
			iniciais:
			mov al, [edx]
			call writeChar
			inc edx
			loop iniciais
			pop ecx

			;Desenha a pontuação
			mov eax,white+(black*16)
			call SetTextColor
			mWrite "* - Pontos: "
			mov eax,yellow+(black*16)
			call SetTextColor
			pontos:
			mov al,[edx]
			cmp al,';'
			je showRank_sair
			cmp al,'@'
			je pulaLinha
			call WriteChar
			inc edx
			mov eax,60
			call delay
			jmp pontos

			pulaLinha:
			call crlf
			inc edx
		jmp showRank_showEntries
	showRank_sair:
	ret
showRank ENDP

;--------------------------------------------------------
;LOAD GAME REGISTRY
;Lucas Carvalhaes
LoadGameReg PROC uses eax edx ecx
;--------------------------------------------------------
	;Pass the file pos
	mov edx, OFFSET infofile
	;Try to open the file
	call OpenInputFile
	;check if file exists
	cmp eax,INVALID_HANDLE_VALUE
	jne LoadGameReg_file_exists
	;invalid file
	;This means the file doesn't exists so we create one
	call CreateGameReg
	jmp LoadGameReg_exit

	;valid file
	LoadGameReg_file_exists:
	;store the file handle
	mov fhandle, eax

	;Stor params for read
	mov edx, offset fileBuffer ;Store at fileBuffer
	mov ecx,4 ; 3 bytes are inicials 1 is level

	;Try to read
	mWrite "Reading file to buffer..."
	call ReadFromFile
	jnc LoadGameReg_safeRead0
	mWrite "Error reading file: buffer!"
	mov eax, 10000
	call delay
	exit

	;Read was safe
	LoadGameReg_safeRead0:
	mWrite "Done."

	;Close the file
	mov eax,fhandle
	call closeFile

	LoadGameReg_exit:
	ret
LoadGameReg ENDP

;--------------------------------------------------------
;CREATE GAME REGISTRY
;Lucas Carvalhaes
;This will destroy EAX with the handle
CreateGameReg PROC
;--------------------------------------------------------

	mov edx, offset infofile
	call CreateOutputFile
	cmp eax, INVALID_HANDLE_VALUE
	jne CreateGameReg_fileok
	mWrite "Error creating reg file!"
	mov eax, 10000
	call delay
	exit

	CreateGameReg_fileok:
	mov fhandle, eax

	;write defaultinfo
	mov edx, OFFSET defaultFileInfo
	mov ecx, 4
	call writeToFile

	;close the file
	mov eax, fhandle
	call closeFile

	ret
CreateGameReg ENDP

;--------------------------------------------------------
;SAVE REGISTRY
;Lucas carvalhaes
;Salva o registro do jogo - as iniciasi do usuario e o
;level que ele está
saveRegistry PROC uses edx ecx eax
;--------------------------------------------------------

	;open for write
	mov edx, offset infofile
	call CreateOutputFile
	mov fhandle,eax

	;prepare params
	mov ecx,4
	mov edx, OFFSET currPlayer

	;try to write because the file is supposed to be open
	call WriteToFile

	;Check if was a success
	cmp eax,0
	jne saveRegistry_leave

	;File failed to write! must quit!
	call crlf
	mWrite "Problem writing to file!"
	mov eax, 5000
	call delay
	exit

	saveRegistry_leave:

	;Close the file
	mov eax,fhandle
	call closeFile

	ret
saveRegistry ENDP

;--------------------------------------------------------
;LOAD MAP TO THE MEMORY
;Guilherme Perego
;Loads the map to the memory
LoadMap PROC uses eax ecx edx,
	OFFSETmapfile:DWORD, ;"mapa_0",0
	OFFSETmapbuffer:DWORD 
;--------------------------------------------------------
	mov edx, OFFSETmapfile
	
	call OpenInputFile
	
	cmp eax,INVALID_HANDLE_VALUE
	jne Map_file_exists

	mWrite "Erro: Mapa nao existe/nao encontrado"	
	mov eax, 2000
	call delay
	exit
	
	Map_file_exists:
	mov edx, OFFSETmapbuffer
	mov ecx, 1882
	
	call ReadFromFile
	ret
LoadMap ENDP