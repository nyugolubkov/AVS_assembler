format PE console
entry main
use32

; ========== CODE SECTION ==========
section '.text' code readable executable

main:
    push message
    call [printf]
    add esp, 4
    call [getch]
    push 0
    call [exit]

; ========== DATA SECTION ==========
section '.data' data readable writeable
    message db "Hello, World!", 0

; ========== IMPORT SECTION ==========
section '.idata' data import readable

; --- array of IMAGE_IMPORT_DESCRIPTOR structures ---
dd 0, 0, 0, RVA msvcrt_name, RVA msvcrt_table
dd 0, 0, 0, 0, 0
; ---

; --- array of IMAGE_THUNK_DATA structures ---
msvcrt_table:
    printf dd RVA _printf
    getch  dd RVA _getch
    exit   dd RVA _exit
    dd 0
; ---

msvcrt_name db 'MSVCRT.DLL', 0

; IMAGE_IMPORT_BY_NAME structure
_printf:
    dw 0
    db 'printf', 0

; IMAGE_IMPORT_BY_NAME structure
_exit:
    dw 0
    db 'exit', 0

_getch:
    dw 0
    db '_getch', 0