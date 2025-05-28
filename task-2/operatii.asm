section .text
    ; the string used for finding delimiter. It is \n and null terminated
    delimiters db " .,", 10, 0

global sort
global get_words

extern malloc
extern qsort
extern strcmp
extern strlen

;; sort(char **words, int number_of_words, int size)
;  functia va trebui sa apeleze qsort pentru soratrea cuvintelor 
;  dupa lungime si apoi lexicografix
sort:
    ; create a new stack frame
    enter 0, 0
    xor eax, eax

    push func_compare_words
    ; push argument "size"
    push dword [ebp + 16]
    ; push argument "number_of_words"
    push dword [ebp + 12]
    ; push argument "**words"
    push dword [ebp + 8]
    call qsort
    ; clean the stack of 4 (x 4 bytes) arguments
    add esp, 16

    leave
    ret

func_compare_words:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; get function parameters
    ; [ebp + 8] -> string 1
    mov eax, [ebp + 8]
    ; [ebp + 12] -> string 2
    mov ebx, [ebp + 12]

    ; dereference the pointers (get the actual strings)
    mov eax, [eax]
    mov ebx, [ebx]

    ; strlen of eax string
    push eax
    call strlen
    mov ecx, eax
    ; clean the stack of 1 (x 4 bytes) argument
    add esp, 4

    ; strlen of ebx string
    push ecx
    push ebx
    call strlen
    mov edx, eax
    ; clean the stack of 1 (x 4 bytes) argument
    add esp, 4
    pop ecx

    ; compare string length (strlen)
    cmp ecx, edx
    jl ret_first
    jg ret_second

    ; compare lexicographically (strcmp)
    ; [ebp + 8] -> string 1
    mov eax, [ebp + 8]
    ; [ebp + 12] -> string 2
    mov ebx, [ebp + 12]
    mov eax, [eax]
    mov ebx, [ebx]

    push ebx
    push eax
    call strcmp
    ; clean the stack of 2 (x 4 bytes) arguments
    add esp, 8
    jmp done_compare

ret_first:
    ; return -1
    mov eax, -1
    jmp done_compare

ret_second:
    ; return 1
    mov eax, 1

done_compare:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop ebp
    ret

;; get_words(char *s, char **words, int number_of_words)
;  separa stringul s in cuvinte si salveaza cuvintele in words
;  number_of_words reprezinta numarul de cuvinte
get_words:
    ; create a new stack frame
    enter 0, 0
    xor eax, eax

    ; [ebp + 8] -> "*s"
    mov esi, [ebp + 8]
    ; [ebp + 12] -> "**words"
    mov edi, [ebp + 12]
    ; word indexer
    xor edx, edx

string_loop:
    ; [ebp + 16] -> "number_of_words"
    cmp edx, [ebp + 16]
    jge done_string_loop

;; delimiter search start
skip_delimiters:
    mov al, byte [esi]
    ; check for end of string
    test al, al
    jz done_string_loop

    ; check for delimiters
    call func_is_delimiter
    test eax, eax
    jz word_start_found

    inc esi
    jmp skip_delimiters

word_start_found:
    ; word start position
    mov ecx, esi

find_end_word:
    mov al, byte [esi]
    ; check for end of string
    test al, al
    jz end_word_found

    ; check for delimiters
    call func_is_delimiter
    test eax, eax
    jnz end_word_found

    inc esi
    jmp find_end_word

end_word_found:
    ; word end position
    mov ebx, esi
    ; word length
    sub ebx, ecx

    ; since words[i] is not malloc'ed in the c file, that must be done here
    push edx
    push ecx
    inc ebx
    push ebx
    call malloc
    ; clean stack of 1 (x 4 bytes) argument
    add esp, 4
    pop ecx
    pop edx

    ; save the newly malloc'ed address into the string at index edx
    mov [edi + 4 * edx], eax

    push esi
    push edi

    mov esi, ecx
    mov edi, eax
    mov ecx, ebx

    ; ecx must be decreased, so the delimiter is not accidentally copied over
    ; and screws everything up (definitelly did not happen to me)
    dec ecx

    ; now I don't have to write another loop to copy byte by byte
    rep movsb
    ; set source to NULL
    mov byte [edi], 0

    pop edi
    pop esi

    inc edx
    jmp string_loop

done_string_loop:
    xor eax, eax
    leave
    ret

;; func_is_delimiter, determines if a char is a delimiter
; this is a helper function
func_is_delimiter:
    push edx
    push ebx

    mov edx, delimiters

check_delim_loop:
    mov bl, byte [edx]

    ; check for end of delimiter string
    test bl, bl
    jz no_delimiter

    cmp bl, al
    je yes_delimiter

    inc edx
    jmp check_delim_loop

yes_delimiter:
    ; return 1
    mov eax, 1
    jmp delim_loop_done

no_delimiter:
    ; return 0
    xor eax, eax

delim_loop_done:
    pop ebx
    pop edx
    ret
