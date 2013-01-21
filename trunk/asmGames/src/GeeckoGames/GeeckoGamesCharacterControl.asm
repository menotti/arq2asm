
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
MoveDiamond PROTO,
				bgMap : PTR BYTE,
				fgMap : PTR BYTE,
				lineSize : DWORD,
				X : DWORD,
				Y: DWORD,
				dir : BYTE

.data


.code

GetCharPos PROC USES ECX EAX ESI EDX, 
					fgMap : PTR BYTE,
					mapSize : DWORD,
					lineSize : DWORD,
					char : PTR DWORD
	MOV ESI, fgMap
	MOV ECX, mapSize ;//looks for the character '0' in the map and stores its position
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


MoveChar PROC USES ECX ESI,	
				bgMap : PTR BYTE,
				fgMap : PTR BYTE,
				lineSize : DWORD,
				char : PTR DWORD,
				dir : BYTE

				LOCAL X: DWORD, Y : DWORD
	;//checks if the input is saying UP, RIGHT, LEFT or DOWN
	MOV ESI, char
	CMP dir, 00b ;//UP
	JE MovingUp
	CMP dir, 01b ;//RIGHT
	JE MovingRight
	CMP dir, 10b ;//DOWN
	JE MovingDown
	CMP dir, 11b ;//LEFT
	JE MovingLeft


	;//Calculating the new position
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

	;//HERE WE TEST FOR DIAMONDS ON THE WAY

	POP EAX
	PUSH EAX

	MOV ESI, fgMap
	ADD ESI, EAX

	MOV AL, BYTE PTR [ESI]

	CMP AL, '+'
	JNE NODIAMOND

YESDIAMOND:
	;//IF THERE IS A DIAMOND WE CHECK IF IT CAN MOVE, EAX = 0 IF IT CAN'T

	;//INVOKE MOVE DIAMOND HERE, IT RETURNS A VALUE IN EAX SAYING IF THE DIAMOND WAS MOVED
	INVOKE MoveDiamond, bgMap, fgMap, lineSize, X, Y, dir

	CMP EAX, 0
	JE FIN1
NODIAMOND:
	;//IF CHARACTER CAN MOVE

	;//PAINT THE OLD POSITION BLANK
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
	MOV EAX, 1
FIN1:
	POP EAX ;//if character doesn't move we need to pop EAX out of the stack before returning
	MOV EAX, 0
FIN2:
	RET
MoveChar ENDP

MoveDiamond PROC,
				bgMap : PTR BYTE,
				fgMap : PTR BYTE,
				lineSize : DWORD,
				X : DWORD,
				Y: DWORD,
				dir : BYTE

	CMP dir, 00b ;UP
	JE MovingUp
	CMP dir, 01b ;RIGHT
	JE MovingRight
	CMP dir, 10b ;DOWN
	JE MovingDown
	CMP dir, 11b ;LEFT
	JE MovingLeft
;//SAME LOGIC AS THE CHARACTER'S MOVEMENT
MovingUp:
	DEC Y
	JMP NEXT

MovingRight:
	INC X
	JMP NEXT

MovingDown:
	INC Y
	JMP NEXT

MovingLeft:
	DEC X
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

	;//HERE WE TEST FOR DIAMONDS ON THE WAY
	;//PS: Diamonds can't "push" other diamonds

	POP EAX
	PUSH EAX

	MOV ESI, fgMap
	ADD ESI, EAX

	MOV AL, BYTE PTR [ESI]

	CMP AL, '+'
	JE FIN1

	;//IF CHARACTER CAN MOVE

	;//PAINT THE OLD POSITION WITH CHAR

	POP EAX
	ADD EAX, fgMap
	
	MOV BYTE PTR [EAX], '+'
	MOV EAX, 1h
	JMP FIN2

FIN1:
	MOV EAX, 0h
FIN2:
	
	RET
MoveDiamond ENDP