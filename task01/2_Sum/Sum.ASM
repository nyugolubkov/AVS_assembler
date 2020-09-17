format PE console 4.0
include 'win32a.inc'
 
mov EAX, 100  ;EAX
mov [b], 600  ;[b]
add EAX, [b]
cinvoke printf, a, EAX
invoke sleep, 3000
 
invoke exit, 0
a db 'EAX is %u', 0
b dd ?
 
data import
library msvcrt, 'MSVCRT.DLL',\
        kernel32, 'KERNEL32.DLL'
 
import kernel32,\
       sleep, 'Sleep'
 
import msvcrt,\
    printf,'printf',\
    exit,'exit'
 
end data