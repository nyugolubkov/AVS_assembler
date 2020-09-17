format pe console 4.0
entry start
 
include 'win32w.inc'
include 'encoding/win1251.inc'
include 'api/kernel32.inc'
include 'api/user32.inc'
 
section '.idata' import data readable
library kernel32,'KERNEL32.DLL',\
user32,'USER32.DLL'
 
struc TCHAR [data]
{
common
    . TCHAR data
    .length = ($ - .) / sizeof.TCHAR 
}
 
section '.data' data readable writeable
    hOut dd ?
    hIn dd ?
    Buffer TCHAR 100h dup ?
    dNumWri dd ?
  
szformat_q TCHAR 'x=%u',0
szformat_e TCHAR 'y=%u',0
szformat_res TCHAR 'x+y=%u',0
szformat_res2 TCHAR 'x-y=%u',0
szformat_res3 TCHAR 'x*y=%u',0
szformat_res4 TCHAR 'x/y=%u',0
str_title TCHAR 'lab 6', 0
str_end TCHAR 'exit...', 0
 
section '.code' code readable executable
 
;------------------------------------------------------------------
ish_zn:
mov ebx, 4
mov ecx, 3
ret
;------------------------------------------------------------------
 
proc printf,arg1,arg2
 
 
cinvoke wsprintf, Buffer, [arg1], [arg2]
mov dword [Buffer+eax*2],0a000dh
add eax,2
invoke WriteConsole, [hOut], Buffer, eax, 0, 0
 
ret
 
endp
; -------------------------------------------------------------------------
 
start:
 invoke SetConsoleTitle, str_title
 
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov [hOut], eax
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov [hIn], eax
 
call ish_zn
stdcall printf,szformat_q,ebx
 
call ish_zn
stdcall printf,szformat_e,ecx
  
call ish_zn
mov edx, ebx
add edx, ecx
 
stdcall printf,szformat_res,edx
 
call ish_zn
mov edx, ebx
sub edx, ecx
 
stdcall printf,szformat_res2,edx
 
call ish_zn
mov edx, ebx
imul edx, ecx
 
stdcall printf,szformat_res3,edx
  
call ish_zn
xor edx,edx ; ???????? edx - ??? ?????, ?.?. edx ???? ????????? ? ???????.
mov eax,ebx
idiv ecx ; ????? ?????????? eax ?? ecx, ????????? ? eax, ??????? ? edx.
 
stdcall printf,szformat_res4,eax
 
invoke ReadConsole, [hIn], Buffer, 1, dNumWri, 0
invoke ExitProcess,0