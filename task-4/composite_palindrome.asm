section .text
global check_palindrome
global composite_palindrome

extern strlen
extern strcmp
extern strcat
extern malloc

check_palindrome:
    ; create a new stack frame
    enter 0, 0
    ; ebx and edx must be saved, because there will be a segfault
    push ebx
    push edx

    xor eax, eax
    ; assume the string is palindrome
    mov eax, 1

    ; [ebp + 8] -> the string
    mov esi, [ebp + 8]
    ; [ebp + 12] -> the length of the string
    mov edi, [ebp + 12]

    ; divide edi by 2
    shr edi, 1

    ; counter
    xor ecx, ecx

palindrome_string_loop:
    cmp ecx, edi
    je done_string_loop

    movzx ebx, byte [esi + ecx]

    push edi
    ; [ebp + 12] -> the length of the string
    mov edi, [ebp + 12]
    sub edi, ecx
    dec edi

    movzx edx, byte [esi + edi]

    pop edi

    cmp ebx, edx
    jne not_palindrome

    inc ecx
    jmp palindrome_string_loop

not_palindrome:
    xor eax, eax

done_string_loop:
    pop edx
    pop ebx

    leave
    ret

composite_palindrome:
    ; create a new stack frame
    enter 0, 0
    xor eax, eax

    ; [ebp + 8] -> pointer to the strings array
    ; [ebp + 12] -> size (always 15, but it should work with values up to 32)

    ; [ebo + 8] -> pointer to the strings array
    mov esi, [ebp + 8]

    ; the main counter
    xor edx, edx
    ; the bit mask
    xor ebx, ebx

    ; the final string address (eax is temp)
    xor edi, edi

composite_main_loop:
    ; [ebp + 12] -> the size of the array (always 15 in tests)
    cmp edx, [ebp + 12]
    jge done_composite_main

    ; create the current bitmask
    ; the 1's in the bitmask represent what string to get for concatenation
    ; start from 0
    mov ebx, 0
    not ebx

    push eax
    ; [ebp + 12] -> the size of the array
    mov eax, [ebp + 12]
    ; get the amount to shift right
    mov ecx, 32

    sub ecx, eax
    shl ebx, cl

    ; don't forget to make the bitmask representative of counter
    push ecx
    mov ecx, edx
    shl ebx, cl
    shr ebx, cl
    pop ecx

    shr ebx, cl
    pop eax

    ; compute 1 << len
    push ebx
    ; [ebp + 12] -> the size of the array
    mov ecx, [ebp + 12]
    ; take 1 to shift left by the size of the array
    mov ebx, 1
    shl ebx, cl

    mov ecx, edx
    shr ebx, cl
    ; shift right once more (off by one problem)
    shr ebx, 1

    mov ecx, ebx
    pop ebx

bitmask_loop:
    cmp ebx, ecx
    jl done_bitmask_loop

    ; get maximum size of concatenated string (also null termination)
    push ebx
    ; [ebp + 12] -> the size of the array
    mov ebx, [ebp + 12]
    ; since all the strings have a length of maximum 10,
    ; multiply the size by 10 to get the biggest maximum string possible
    imul ebx, 10
    inc ebx

    ; malloc new string in eax
    ; I don't think it's correct to just malloc a new string every time,
    ; but I tried freeing it and it broke the task, so here it is.
    push edx
    push ecx
    push ebx

    ; heap allocation of string
    push ebx
    call malloc
    ; clean the stack of 1 (x 4 bytes) argument
    add esp, 4

    pop ebx
    pop ecx
    pop edx

    push ecx
    xor ecx, ecx

    ; set all bytes to 0
clean_string:
    cmp ecx, ebx
    jge done_clean_string

    ; set each byte to 0, to avoid garbage
    mov byte [eax + ecx], 0

    inc ecx
    jmp clean_string

done_clean_string:
    pop ecx
    ; concat all strings based on the current bitmask
    pop ebx

    push ebx
    push edx

    xor edx, edx

concat_from_bitmask:
    ; [ebp + 12] -> the size of the array
    cmp edx, [ebp + 12]
    jge done_concat_bitmask

    push ebx
    push ecx

    ; [ebp + 12] -> the size of the array
    mov ecx, [ebp + 12]
    dec ecx

    sub ecx, edx
    shr ebx, cl

    ; get the last byte of ebx
    and ebx, 1
    ; check if last byte of ebx is 1
    cmp ebx, 1
    pop ecx
    pop ebx
    jne skip_string

    push edx
    push ecx
    push ebx

    ; push the string of index edx
    push dword [esi + 4 * edx]
    push eax
    call strcat
    ; clean the stack of 2 (x 4 bytes) arguments
    add esp, 8

    pop ebx
    pop ecx
    pop edx

skip_string:
    inc edx
    jmp concat_from_bitmask

done_concat_bitmask:
    pop edx
    pop ebx

    push edx

    push ebx
    push ecx
    push edx

    push eax
    push eax
    call strlen
    ; clean the stack of 1 (x 4 bytes) arguments
    add esp, 4
    mov ecx, eax
    pop eax

    push esi
    push edi
    push eax
    push ecx
    push eax
    call check_palindrome
    ; clean the stack of 2 (x 4 bytes) arguments
    add esp, 8
    mov ebx, eax
    pop eax
    pop edi
    pop esi

    pop edx
    pop ecx

    ; check if the string is palindrome
    cmp ebx, 1
    pop ebx
    jne done_assign_string

    ; if edi is nothing, assign it to eax
    cmp edi, 0
    jne skip_first_assign

    mov edi, eax
    jmp done_assign_string

skip_first_assign:
    ; compare string sizes
    push ebx
    push ecx

    ; get size of eax
    push edx
    push eax
    push eax
    call strlen
    mov ebx, eax
    ; clean the stack of 1 (x 4 bytes) argument
    add esp, 4
    pop eax
    pop edx

    ; get size of edi
    push edx
    push edi
    push ebx
    push eax
    push edi
    call strlen
    mov ecx, eax
    ; clean the stack of 1 (x 4 bytes) argument
    add esp, 4
    pop eax
    pop ebx
    pop edi
    pop edx

    cmp ebx, ecx
    jl done_assign
    jg assign_greater

    push edx

    push eax
    push edi
    push eax
    call strcmp
    mov edx, eax
    ; clean the stack of 2 (x 4 bytes) arguments
    add esp, 8
    pop eax

    ; if strcmp >= 0, there is nothing to do
    cmp edx, 0
    pop edx
    jge done_assign

assign_greater:
    mov edi, eax

done_assign:
    pop ecx
    pop ebx

done_assign_string:
    dec ebx
    jmp bitmask_loop

done_bitmask_loop:
    pop edx
    inc edx
    jmp composite_main_loop

done_composite_main:
    mov eax, edi

    leave
    ret
