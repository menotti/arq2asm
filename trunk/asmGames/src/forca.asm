.data

enforcado	BYTE ' O', 13, 10,
				 '/|\', 13, 10,
				 '/ \', 0

.code

forca PROC uses edx eax
	mov edx, OFFSET enforcado
	call WriteString
	call ReadChar
	ret
forca ENDP