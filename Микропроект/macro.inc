macro VInputMacro vecAddr, len {
        xor ecx, ecx
        mov ebx, vecAddr

  getVecLoop:
        mov [tmp], ebx
        mov edx, [len]
        imul edx, [len]
        cmp ecx, edx
        jge endInputVector

        mov [i], ecx
        mov eax, [i]
        cdq
        idiv [len]
        invoke printf, strVecElInput, eax, edx

        invoke scanf, strScanInt, ebx

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
  endInputVector:
}
;
macro CalcVecTrMacro vecAddr, len {
        xor ecx, ecx
        mov ebx, vecAddr
        mov eax, [len]
        inc eax
        mov [step], eax
        xor eax, eax

  trVecLoop:
        mov [tmp], ebx
        mov edx, [len]
        imul edx, [len]

        cmp ecx, edx
        jge endTrVector

        add eax, [ebx]

        add ecx, [step]
        mov ebx, [tmp]
        mov edx, [step]
        imul edx, 4
        add ebx, edx
        jmp trVecLoop
  endTrVector:
}