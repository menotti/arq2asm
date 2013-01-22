.data

val1 WORD ?

.code
PUBLIC testeAsm
testeAsm proc

mov eax,0
mov bx,val1
add eax,ebx
add val1,cx


ret
testeAsm endp
end
