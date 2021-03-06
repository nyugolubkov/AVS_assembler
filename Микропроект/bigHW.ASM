; ���-195 �������� ������ �������
; ������� 3
;
; ����������� ���������, ������� ������ ���������� ������� A[N], ���������
; �� ��������� ������� A ������ B �� ��������, ��������� � �������,
; � ������� ���. ������ ��� ������� ����� ���������� ��� ����������,
; ��� � ����������� �� ������ ������������.
;
; ������� ������� ������ �� ������� ��������� �������:
; 1) ���� � ����� �������� �������� ��� ������������.
; 2) ���������� ������� �� �������� �������� ��� ���������.
; 3) ������������ ����� ��� ���������, ��� � ��������������� ��������.
;
; ��������� ��������� ����� ������������ ������ �������� (�������� ��������
; ��� ����������). �������� ������ � ����������� ����� ���������.
;
; ������ B �� ���� �������� ��������� A ({A[0] + A[1], A[1] + A[2], ...}).
;
;--------------------------------------------------------------------------
format PE console
entry start

include 'win32a.inc'
include 'macro.inc'

section '.data' data readable writable

        strVecSize        db 'Enter the size of array A in range from 1 to 5: ', 0
        strVecInput       db 'Enter the elements of array:', 10, 0
        strVecElInput     db '[%d, %d] = ', 0
        strSomethingWrong db 'Something went wrong!', 10, 0
        strScanInt        db '%d', 0
        strVecElemOut     db 'trA = %d', 10, 0

        vec_size      dd 0
        trVal         dd 0
        step          dd ?
        i             dd ?
        tmp           dd ?
        vec           rd 25

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
        invoke printf, strVecSize
        invoke scanf, strScanInt, vec_size

        ;check size of vector
        cmp [vec_size], 5
        jg extra_finish
        cmp [vec_size], 0
        jle extra_finish

        invoke printf, strVecInput

        VInputMacro vec, vec_size

        CalcVecTrMacro vec, vec_size

        mov [trVal], eax
        invoke printf, strVecElemOut, [trVal]

        jmp finish

;extra finish
extra_finish:
        invoke printf, strSomethingWrong

;finish
finish:
        invoke getch
        invoke ExitProcess, 0

;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'