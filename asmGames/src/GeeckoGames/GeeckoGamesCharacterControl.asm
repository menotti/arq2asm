
GetCharPos PROTO, fgMap : PTR BYTE,
				  mapSize : DWORD,
				  lineSize : DWORD,
				  char : PTR DWORD

MoveChar PROTO,	
				bgMap : PTR BYTE,
				fgMap : PTR BYTE,
				lineSize : DWORD,
				char : PTR DWORD,
				dir : BYTE
MoveDiamond PROTO

.data


.code

GetCharPos PROC USES ECX EAX ESI EDX, 
					fgMap : PTR BYTE,
					mapSize : DWORD,
					lineSize : DWORD,
					char : PTR DWORD
	MOV ESI, fgMap
	MOV ECX, mapSize
	L:
		MOV AL, BYTE PTR[ESI]
		CMP AL, '0'
		JE NEXT
		INC ESI
	LOOP L
NEXT:
	SUB ESI, fgMap
	MOV EAX, ESI
	MOV EDX, 0
	DIV lineSize

	MOV ESI, char
	MOV [ESI], EDX
	MOV [ESI + 4], EAX
	RET
GetCharPos ENDP


MoveChar PROC USES ECX EAX ESI,	bgMap : PTR BYTE,
				fgMap : PTR BYTE,
				lineSize : DWORD,
				char : PTR DWORD,
				dir : BYTE

				LOCAL X: DWORD, Y : DWORD

	MOV ESI, char
	CMP dir, 00b ;UP
	JE MovingUp
	CMP dir, 01b ;RIGHT
	JE MovingRight
	CMP dir, 10b ;DOWN
	JE MovingDown
	CMP dir, 11b ;LEFT
	JE MovingLeft

MovingUp:
	MOV EAX, [ESI]
	MOV X, EAX
	MOV EAX, [ESI + 4]
	MOV Y, EAX
	DEC Y
	JMP NEXT

MovingRight:
	MOV EAX, [ESI]
	MOV X, EAX
	INC X
	MOV EAX, [ESI + 4]
	MOV Y, EAX
	JMP NEXT

MovingDown:
	MOV EAX, [ESI]
	MOV X, EAX
	MOV EAX, [ESI + 4]
	MOV Y, EAX
	INC Y
	JMP NEXT

MovingLeft:
	MOV EAX, [ESI]
	MOV X, EAX
	DEC X
	MOV EAX, [ESI + 4]
	MOV Y, EAX
	JMP NEXT
NEXT:


	MOV EAX, Y
	MUL lineSize
	ADD EAX, X

	MOV ESI, bgMap
	ADD ESI, EAX

	PUSH EAX

	MOV AL, BYTE PTR [ESI]

	CMP AL, '*'
	JE FIN1

	;HERE WE TEST FOR DIAMONDS ON THE WAY

	POP EAX
	PUSH EAX

	MOV ESI, fgMap
	ADD ESI, EAX

	MOV AL, BYTE PTR [ESI]

	CMP AL, '+'
	JNE NODIAMOND

YESDIAMOND:
	;IF THERE IS A DIAMOND WE CHECK IF IT CAN MOVE, EAX = 0 IF IT CAN'T

	;INVOKE MOVE DIAMOND HERE (REMEMBER TO RECEIVE THE POSITION OF THE DIAMOND, IT IS IN X, Y

	CMP EAX, 0
	JE FIN1
NODIAMOND:
	;IF CHARACTER CAN MOVE

	;PAINT THE OLD POSITION BLANK
	MOV ESI, char
	MOV EAX, DWORD PTR[ESI + 4]
	MUL lineSize
	ADD EAX, DWORD PTR[ESI]

	MOV ESI, fgMap
	ADD ESI, EAX

	MOV BYTE PTR [ESI], ' '

	POP EAX

	MOV ESI, fgMap
	ADD ESI, EAX

	MOV BYTE PTR [ESI], '0'

	MOV ESI, char

	MOV EAX, X
	MOV [ESI], EAX
	MOV EAX, Y
	MOV [ESI + 4], EAX
	JMP FIN2
FIN1:
	POP EAX ;if character doesn't move we need to pop EAX out of the stack before returning
FIN2:
	RET
MoveChar ENDP

MoveDiamond PROC
	RET
MoveDiamond ENDP