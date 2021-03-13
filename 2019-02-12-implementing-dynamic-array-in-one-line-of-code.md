---
layout: post
title:  "Implementing a dynamic array in a single line of code"
date:   2019-02-12 12:07:19 +0100
image: /assets/implementing-dynamic-array-in-one-line-of-code.jpg
comments: true
image_pos: center center
tags:
  - c
---
The C standard library does not provide an implementation of any data structure
so if you need a dynamic array or a linked list you must provide your own
implementation. The simplest implementation of a single linked list just
requires to add a pointer to the next element in the target structure, that is
why it is often chosen by developers instead of a dynamic array. A simple
implementation of a dynamic array is also possible and can be done in one line
of code.

Dynamic array
-------------
The dynamic array is an array that grows or shrinks if elements are added or
removed. Typically implementation must store 3 attributes:
- pointer to the allocated data
- size of the array
- capacity of the array

![size-vs-capacity](/assets/implementing-dynamic-array-in-one-line-of-code/size-vs-capacity.svg)

If size gets closer to capacity, then the array is reallocated with a bigger
capacity (usually 2 or 1.5 times larger) and all elements are copied into the
new array.

![size-vs-capacity2](/assets/implementing-dynamic-array-in-one-line-of-code/size-vs-capacity2.svg)

![size-vs-capacity3](/assets/implementing-dynamic-array-in-one-line-of-code/size-vs-capacity3.svg)

One line implementation
-----------------------
Our simple implementation will just consist of a `grow()` function which we will
call after adding each element into the array in order to resize it if needed.

To allocate a new array and copy all previous elements we will use `realloc()`.

We can simplify the implementation by making an assumption that `capacity` is
next power of two, greater than `size`. This way we won't need to store the
capacity. For example:
```
if size is 3 then capacity is 4
if size is 8 then capacity is 16
if size is 3000 then capacity is 4096
```
We only need to check if size is a power of two, then we shall allocate
the new array of a double size. To check if the size is a power of two we can
use the following trick:
```c
(size - 1) & size
```
Thanks to this, grow operation can be implemented in just one line of code.
```c
void *grow(void *ptr, unsigned int size, unsigned int elemsize)
{
    return (size - 1) & size ? ptr : realloc(ptr, 2 * size * elemsize);
}
```

Usage
-----
Example usage (error checking omitted):
```c
/* start with size of zero and capacity of one */
int *numbers = malloc(sizeof(*numbers));
unsigned int size = 0;
int i = 0;

/* add one element to the end */
numbers[size++] = 1;
numbers = grow(numbers, size, sizeof(*numbers));

/* add 100 elements to the end*/
for (i = 0; i < 100; ++i) {
    numbers[size++] = i;
    numbers = grow(numbers, size, sizeof(*numbers));
}

/* iterate over all elements */
for (i = 0; i < size; ++i)
    printf("%d\n", numbers[i]);

/* remove last 80 elements */
size -= 80;

/* add an element again */
numbers[size++] = 99;
numbers = grow(numbers, size, sizeof(*numbers));

free(numbers);
```

Limitations
-----------
Although this approach is quite simple it has some issues, one of which is that
repeated adding and removing elements when `size = 2^k + 1` causes an allocation
that is simply unneccassary. If size is `65` (capacity is `128`) and we remove
one element by simply decrementing the size by one (size is `64`) and add an
element again followed by a call to `grow()`, then we will make an allocation
for `128` elements again. The `realloc()` **may** be optimized [not to do a 
reallocation of the same size](https://www.gnu.org/software/libc/manual/html_node/Changing-Block-Size.html),
nevertheless in serious applications you should use a more robust implementation
of a dynamic array.
