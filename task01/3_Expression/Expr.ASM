format PE console 4.0 at 400000h
include 'win32w.inc'
entry $
invoke GetStdHandle,STD_OUTPUT_HANDLE
mov    ebx,eax
mov    eax,[A]
sub    eax,[D]
cdq
idiv   [B]
mov    ecx,[C]
imul   ecx,[E]
add    eax,ecx
invoke wsprintfW,text,text,eax
add    esp,12
invoke WriteConsoleW,ebx,text,eax,0,0
jmp $
A    dd 5
B    dd 6
C    dd 3
D    dd 4
E    dd 1
text du '(A-D)/B+C*E=%i',0
data import
  library user,'USER32.DLL',\
          kernel,'KERNEL32.DLL'
  import user,\
         wsprintfW,'wsprintfW'
  import kernel,\
         GetStdHandle,'GetStdHandle',\
         WriteConsoleW,'WriteConsoleW'
end data