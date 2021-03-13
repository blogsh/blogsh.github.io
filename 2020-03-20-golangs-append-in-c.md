---
layout: post
title:  "Porting Golang's append function to C"
date:   2020-03-21 11:26:00 +0100
comments: true
tags:
  - c
---

One of the things that caught my eye when I was experimenting with the
`Go` language was the `append()` function. 

```go
func append(s []T, vs ...T) []T
```

Example usage:

```go
func main() {
	var s []int

	s = append(s, 0)
	s = append(s, 1)
	s = append(s, 2, 3, 4)
}
```

The `append()` function adds an element into a slice, and if the
backing array of the slice is not large enough, it will be reallocated with
a bigger size. This works exactly like `std::vector::push_back()` in `C++`.

What I generally like about the `Go`'s approach to the dynamic array is that
it is minimalistic. You have one function and that's it.

The minimalism is one of the top reasons that made `C` language so popular and
successful, especially in the world of embedded systems.
Unfortunately this minimalism, which makes `C` easy to port to almost any platform
comes with a cost of having **zero** data structures built into the language
or the standard library.

One of the most useful data structures is definitely the dynamic array and there
are many libraries out there providing its implementation, but in my personal
projects I prefer to quickly port `Go`'s `append()` function to `C`.

Append in C
-----------

The `C`'s version of `append()` is not as neat as in `Go` because we have to
explicitly pass the capacity and the length, but the implementation
consists of just a few lines of code.

```c
#define INITIAL_CAPACITY 2
#define GROWTH_FACTOR 2
void* append(void *array,
             unsigned int *cap,
             unsigned int *len,
             const void *item,
             unsigned int size)
{
    unsigned int capacity = *cap;

    if (*len == capacity) {
        capacity = capacity ? capacity * GROWTH_FACTOR : INITIAL_CAPACITY;

        array = realloc(array, capacity * size);
        if (!array) {
            /* Here you should handle Out of memory condition,
               in some cases exit(1) is really all you need, but
               it all depends on your use case. In more critical
               applications you may return NULL here to let the
               caller recover. */
            exit(1);
        }
        *cap = capacity;
    }

    memcpy((unsigned char *)*array + *len * size, item, size);
    *len += 1;

    return array;
}
```

Usage

```c
struct item {
    int x;
};

int main(int argc, char **argv)
{
    struct item item;
    unsigned long i = 0;

    /* We need 3 variables - pointer to the beginning of the array,
       length and capacity (this is not as cool as in Go, where this is hidden
       behind the scenes) */
    struct item *items = NULL; /* realloc(NULL, size) acts as malloc(size)*/
    unsigned int items_len = 0;
    unsigned int items_cap = 0;

    item.x = 1;
    items = append(items, &items_len, &items_cap, &item, sizeof item);
    item.x = 2;
    items = append(items, &items_len, &items_cap, &item, sizeof item);
    item.x = 3;
    items = append(items, &items_len, &items_cap, &item, sizeof item);
    item.x = 4;
    items = append(items, &items_len, &items_cap, &item, sizeof item);

    for (i = 0; i < items_len; ++i)
        printf("%d", items[i].x);

    free(items);

    return 0;
}
```
