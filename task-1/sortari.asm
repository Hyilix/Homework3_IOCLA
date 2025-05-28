section .text
global sort

;   struct node {
;    int val;
;    struct node* next;
;   };

;; struct node* sort(int n, struct node* node);
;   The function will link the nodes in the array
;   in ascending order and will return the address
;   of the new found head of the list
; @params:
;   n -> the number of nodes in the array
;   node -> a pointer to the beginning in the array
;   @returns:
;   the address of the head of the sorted list
sort:
    ; create a new stack frame
    enter 0, 0
    ; address of the minimum element
    xor eax, eax

    ; [ebp + 8] -> n
    mov ecx, [ebp + 8]
    ; [ebp + 12] -> *node
    mov esi, [ebp + 12]

    ; I will store in ebx the next maximum number
    ; I will basically look form the biggest to the smallest
    ; Just bear with me
    mov ebx, -1

    ; search the maximum value
    push ecx
    dec ecx

    ; temp value
    xor edx, edx
loop_first:
    ; compare index with 0
    cmp ecx, 0
    jl done_first

    ; get the int value of the node at index ecx
    mov edx, [esi + 8 * ecx]

    cmp ebx, edx
    jge skip_assign_higher
    ; get new maximum value and address
    mov ebx, edx
    ; load effective address of the node at index ecx
    lea eax, [esi + 8 * ecx]

skip_assign_higher:
    dec ecx
    jmp loop_first

done_first:
    pop ecx

    ; now ebx will store the maximum value

    ; goal:
    ; 1) assign the current maximum address to the other nodes
    ;    lower than the current maximum value
    ; 2) get the new maximum value and address
    ; 3) repeat until done

    ; second iterator
    mov edx, ecx
loop_nodes:
    ; compare index with 0
    cmp ecx, 0
    je done_nodes

    push edx
    dec edx
assign_next_nodes:
    ; compare index with 0
    cmp edx, 0
    jl done_assign_next_nodes

    ; get the int value of the node at index edx
    mov edi, [esi + 8 * edx]

    cmp edi, ebx
    jge skip_assign_node

    ; assign next pointer of structure at index edx
    ; +4 bytes to skip the int value and reach the next pointer
    mov [esi + 8 * edx + 4], eax

skip_assign_node:
    dec edx
    jmp assign_next_nodes

done_assign_next_nodes:
    pop edx

    push ecx
    push edx
    ; store in ecx the next maximum, temporarily
    mov ecx, 0

get_next_max:
    ; compare index with 0
    cmp edx, 0
    jl done_next_max

    ; get the int value of the node at index edx
    mov edi, [esi + 8 * edx]

    cmp edi, ebx
    jge skip_assign_greater

    cmp ecx, edi
    jge skip_assign_greater

    mov ecx, edi
    ; load effective address of structure at index edx
    lea eax, [esi + 8 * edx]

skip_assign_greater:
    dec edx
    jmp get_next_max

done_next_max:
    pop edx
    mov ebx, ecx
    pop ecx

    dec ecx
    jmp loop_nodes

done_nodes:

    leave
    ret

