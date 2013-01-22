.data

realVal REAL8 +1.5

.code
PUBLIC CombineA
CombineA proc

   ADD    ECX,DWORD PTR [RSP+28h]
   ADD    ECX, R9D                 ; add other three register parameters
   ADD    ECX, R8D                 ;
   ADD    ECX, EDX                 ;
   MOVD   XMM0, ECX                ; move doubleword ECX into XMM0
   CVTDQ2PD  XMM0, XMM0            ; convert doubleword to floating point
   MOVSD  XMM1, realVal            ; load 1.5
   ADDSD  XMM1, MMWORD PTR [RSP+30H]  ; add parameter
   DIVSD  XMM0, XMM1               ; do division, answer in xmm0
   RET                             ; return
CombineA ENDP
End


		

