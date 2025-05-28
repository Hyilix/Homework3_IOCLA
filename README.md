Cosminel the Passionate - Homework 3
====================================

> Ursescu Sebastian - 315CA (Tema 3 PCLP2)

# Tasks

### Task 1 - Sorts

This task is about "sorting" several nodes from an array, and forming a sorted list, without swapping any elements.

Here is the node structure (c language)

```c
struct node {
    int val;
    struct node* next;
};
```

Initially, all the nodes have the next pointer set to null. The function **sort** returns the pointer to the node with the lowest val.

The intended way is to sort from lowest to highest using some form of selection sort. Here's what I did instead:

1. Find the next node with the maximum value (initially, the maximum value, then the next highest value after that..)
2. Assign to all nodes with a value lower than the current maximum the pointer to the current maximum node
3. Repeat until done

Now the last node will be the one with the lowest value, so the function will return the pointer to that node.

Also, the node with the highest value will still point to NULL, since it's not affected by the operations mentioned above.

Since it's not required by the task to utilise a specific sorting algorithm, I think this is a nice and elegant solution, and I'm quite proud of this.

The rest is just a matter of finding the next maximum value and comparing.

Here is an illustration for better understanding of the solution:

```
The value will hold the address of the node in this example, for better understanding
The code will set the addresses correctly, not based on int values.

| value | next |                     | value | next |                     | value | next |                     | value | next |
----------------                     ----------------                     ----------------                     ----------------
|   2   | NULL |                     |   2   |  11  |                     |   2   |  10  |                     |   2   |  3   |
|   1   | NULL |                     |   1   |  11  |                     |   1   |  10  |                     |   1   |  2   |
|   3   | NULL |                     |   3   |  11  |                     |   3   |  10  |                     |   3   |  4   |
|   4   | NULL |   next maximum: 11  |   4   |  11  |   next maximum: 10  |   4   |  10  |                     |   4   |  5   |
|   10  | NULL |   set next to all   |   10  |  11  |   set next to all   |   10  |  11  |        ...          |   10  |  11  |
|   6   | NULL | with a value lower  |   6   |  11  | with a value lower  |   6   |  10  |                     |   6   |  8   |
|   8   | NULL |                     |   8   |  11  |                     |   8   |  10  |                     |   8   |  9   |
|   11  | NULL |                     |   11  | NULL |                     |   11  | NULL |                     |   11  | NULL |
|   5   | NULL |                     |   5   |  11  |                     |   5   |  10  |                     |   5   |  6   |
|   9   | NULL |                     |   9   |  11  |                     |   9   |  10  |                     |   9   |  10  |
----------------                     ----------------                     ----------------                     ----------------

Eventually, all values will be assigned correctly, and the last maximum will be the minimum.
The address of this node will be the return value
```

Now there is no need to search for the shortest node again at the end or store the address untill the end of the sort.

### Task 2 - Operations

This task is about sorting (for real this time) an array of strings. It is split in two functions (**get_words** and **sort**), and requires the use of **qsort** from libc.

#### get_words

Given a string as input, this function splits the string into several substrings based on delimiters.

Although the delimiters are fixed " .,\n", in .text section there is the array that holds all possible delimiters, and can be modified freely (the size of this array is calculated dinamically).

What this function does is taking the first valid byte (letter) that is not a delimiter, saving the position of it as start of word, and finding the end of word that is a delimiter.

The new string is dinamically malloc'ed (using the **malloc** function from libc), and all the bytes from the start position to end position will be copied inside the string.
The string is saved into the array of strings, ready to be used by the **sort** function.

A custom function was used (**func_is_delimiter**) that returns if a byte (letter) is inside the delimiter string (check if a letter is a delimiter or not).
This eases up and makes for a more modularized solution for the **get_words** method.

#### sort

Given the array of strings computed by the **get_words** method, this function sorts the container using the **qsort** function. Qsort requires the container to sort, the length of the container, the size of each element and the function to use for comparison.
The function used is the custom made **func_compare_words**;

#### func_compare_words

The strings must be sorted first by lowest size (**strlen** from libc), then by lowest lexicographically (**strcmp** from libc).

The function first compares the lengths of both strings. If they are equal, **strcmp** is called to determine which is "lower".

### Task 3 - KFfib

Recursive Fibonacci with extra steps!

### Task 4 - Composite Palindrome

#### Subtask 1 - Palindrome Check

#### Subtask 2 - Composite Palindrome
