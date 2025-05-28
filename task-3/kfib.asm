section .text
global kfib

kfib:
    ; create a new stack frame
    enter 0, 0
    xor eax, eax

    ; [ebp + 8] -> n
    mov esi, [ebp + 8]
    ; [ebp + 12] -> k
    mov edi, [ebp + 12]

    ; store the sum in ebx
    xor ebx, ebx
    ; counter, starting from 1
    mov ecx, 1

    cmp esi, edi
    jl n_lower_k
    je n_equal_k

kfib_sum_loop:
    cmp ecx, edi
    jg n_greater_k

    push ebx
    push ecx
    push edi
    push esi
    ; next function call is n - i
    sub esi, ecx

    ; recursively add the sum
    push edi
    push esi
    call kfib
    ; clean the stack of 2 (x 4 bytes) arguments
    add esp, 8

    pop esi
    pop edi
    pop ecx
    pop ebx

    add ebx, eax

    inc ecx
    jmp kfib_sum_loop

n_lower_k:
    ; return 0
    xor eax, eax
    jmp done_kfib

n_equal_k:
    ; return 1
    mov eax, 1
    jmp done_kfib

n_greater_k:
    ; return the sum
    mov eax, ebx

done_kfib:

    leave
    ret

