; БПИ-195 Голубков Никита Юрьевич
; Вариант 3
;
; Разработать программу, которая вводит одномерный массивв A[N], формирует
; из элементов массива A массив B по правилам, указанным в таблице,
; и выводит его. Память под массивы может выделяться как статически,
; так и динамически по выбору разработчика.
;
; Разбить решение задачи на функции следующим образом:
; 1) Ввод и вывод массивов оформить как подпрограммы.
; 2) Выполнение задания по варианту оформить как процедуру.
; 3) Организовать вывод как исходного, так и сформированного массивов.
;
; Указанные процедуры могут использовать данные напрямую (имитация процедур
; без параметров). Имитация работы с параметрами также допустима.
;
; Массив B из сумм соседних элементов A ({A[0] + A[1], A[1] + A[2], ...}).
;
;--------------------------------------------------------------------------
format PE console
entry start

include 'win32a.inc'

section '.data' data readable writable

        strVecSize    db 'Enter the size of array A in range from 2 to 100: ', 0
        strVecA       db 'Array A: ', 10, 0
        strVecB       db 'Array B: ', 10, 0
        strIncorSize  db 'Wrong size of array = %d', 10, 0
        strVecElemI   db 'Enter [%d] array element: ', 0
        strScanInt    db '%d', 0
        strSumValue   db 'Sum = %d', 10, 0
        strVecElemOut db '[%d] = %d', 10, 0

        vecA_size     dd 0
        vecB_size     dd 0
        sum           dd 0
        i             dd ?
        tmp           dd ?
        tmpStack      dd ?
        vecA          rd 100
        vecB          rd 100

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) vector input
        call VectorInput
; 2) form vecB
        mov eax, [vecA_size]
        add eax, -1
        mov [vecB_size], eax

        xor ecx, ecx
        mov eax, vecA
        mov ebx, vecB
vecLoop:
        cmp ecx, [vecB_size]
        jge vecContinue

        mov edx, [eax]
        mov [ebx], edx
        add eax, 4
        mov edx, [eax]
        add [ebx], edx
        add ebx, 4
        inc ecx

        jmp vecLoop

vecContinue:
; 3) test vector out
        call VectorOut
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vecA_size
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vecA_size]
        cmp eax, 1
        jle failSize
        cmp eax, 100
        jg  failSize
; else continue...
getVector:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecA           ; ebx = &vecA
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vecA_size]
        jge endInputVector       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
; fail size
failSize:
        push [vecA_size]
        push strIncorSize
        call [printf]
        call [getch]
        push 0
        call [ExitProcess]
endInputVector:
        ret
;--------------------------------------------------------------------------
VectorOut:

putVecA:
        push strVecA
        call [printf]
        add esp, 4

        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov eax, vecA            ; ebx = &vec


putVecALoop:
        mov [tmp], eax
        cmp ecx, [vecA_size]
        je putVecB      ; to VecB
        mov [i], ecx

        ; output element
        push dword [eax]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov eax, [tmp]
        add eax, 4
        jmp putVecALoop

putVecB:
        push strVecB
        call [printf]
        add esp, 4

        xor ecx, ecx            ; ecx = 0
        mov ebx, vecB

putVecBLoop:
        mov [tmp], ebx
        cmp ecx, [vecB_size]
        je endOutputVector      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecBLoop


endOutputVector:
        mov esp, [tmpStack]
        ret
;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'