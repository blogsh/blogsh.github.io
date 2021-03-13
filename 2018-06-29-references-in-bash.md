---
layout: post
title:  "References in Bash"
date:   2018-06-29 00:00:00 +0100
image: /assets/references-in-bash.jpg
comments: true
image_pos: center center
tags:
  - bash
---

Bash 4.3 provides the support for "namerefs".
This is particularly useful to create functions which modify a variable.
Yes, you can pass variables by reference in bash! 
But this feature comes with some hidden gotchas.

Passing variables by reference
------------------------------

In other programming languages (eg. `c`, `c++`, `php`), there are ways
to pass a variable by a reference

For example:

In C there are pointers

```c
void increment(int *a) {
    (*a)++;
}

int main(void) {
    int x = 0;
    increment(&x); /* x gets modified */
    return 0;
}
```

C++ has a dedicated reference type
```c++
void increment(int& a) {
    a++;
}

int main(void) {
    int x = 0;
    increment(x); //x gets modified
    return 0;
}
```

One day even the php language started to support it
```php
function increment(&$a) {
    $a++;
}

$x = 1
increment($x); //$x gets modified
```

Dynamic scope
-------------
Before we get to passing variables by reference in bash, we should be aware of something
that is called the **dynamic scope**.

In programming languages variables can have a static (lexical) or dynamic scope.
Unlike in most languages (c++, c, php, python, ruby, ...) where variables have a static scope,
variables in bash have the **dynamic scope**

What does it mean? Let's look at the example:

```bash
#pseudocode
x = 1

f () {
    print x
}

g () {
    var x = 17 #local variable declaration
    f()
}

f()
g()
```

If an identifier has a static scope, the object that it is referring to is
determined at compile/parsing/interpretation or linking time and is based on its 
"location" in the program text/bytecode/binary.

```bash
f() #prints 1
g() #prints 1
```

This means that in the above example when we call `g()` function, the 
`f()` function will print the value of global variable `x`. Actually 
it doesn't matter where the `f()` is called. The `x` symbol will be resolved
before program is run.

This is not the case for dynamic scope however. 

```bash
f() #prints 1
g() #prints 17
```

>With dynamic scope, a global identifier refers to the identifier associated with the most recent environment.

Which means that the `x` identifier is resolved at run-time.
In the above example `f()` would print `1`, because in the **most recent environment**
the `x` variable equals `1`. However the `g()` would print `17`, because `f()`
is called in `g()`, and in this scope `f()` would refer to `x` local variable defined by `g()`

How to pass variables by reference in bash
------------------------------------------

Let's come back to passing variables by reference.
Bash has some mechanisms that let you support this behaviour.

Let's start with dynamic scope
```bash
increment () {
    ((x++))
}

foo () {
    local x=3
    increment
}

bar () {
    local x=5
    increment
}
```

Here, thanks to dynamic scope we can call `increment` function to modify a variable
for us. This has obviously one issue - we can only increment variable called `x`

We need a way to specify which variable from parent scope the `increment` function
should change. So we must do something like this:

```bash
increment () {
    (("$1"++))
}

foo () {
    local x=3
    increment x
}
```
Great! This will work. We have passed a variable by reference! This is awesome.
But, let's try another example. A function which will capitalize all letters.
This can be easily done with `tr`

```console
$ tr '[[:lower:]]' '[[:upper:]]'
```

And the function

```bash
capitalize () {
    #here the ${!1} is syntax for $$1 - indirect variable reference
    $1="$(echo "${!1}" | tr '[[:lower:]]' '[[:upper:]]')"
}


foo () {
    local hello="hello world"
    capitalize hello #pass by reference
    echo "$hello"
}

foo
```

But this won't work. It will print

```bash
hello=HELLO WORLD: command not found
```

This is because out capitalize function will try to do this
```bash
capitalize () {
    hello="HELLO WORLD"
}
```

And because we used parameter expansion on the left side, bash
will consider this as a command and will try to invoke it.

We can somehow overcome this issue.
You have probably already seen the `read` built in.
```bash
read -p "Please provide a name" name
```

It is going to read string from standard input into a variable called `name`.
So? How can we use `read` to pass parameters by reference?
Let's implement the `capitalize` function again

```bash
capitalize () {
    IFS= read "$1" <<< "$(echo "${!1}" | tr '[[:lower:]]' '[[:upper:]]')"
}
```

Damn! This looks crazy. Let's break it up a little bit.

- `$1` is the first argument - here the name of variable passed by reference
- `${!1}` is the value of variable passed by reference
- `$(echo "${!1}" | tr '[[:lower:]]' '[[:upper:]]')` - passes the value of the variable on `tr` stdin, which will change all lowercase character to uppercase
and print the result on stdout
- `<<<` is the HERESTRING syntax, which will pass the string on right side the stdin of `read` builtin.
- `IFS=` is the internal field separator, it is set to `""` to prevent `read` from stripping whitespace

Note that we can't just pipe the `tr` output to `read` like this:
```
echo ${!1} | tr '[[:lower:]]' '[[:upper:]]' | read "$1"
```

because each command in pipeline is executed in a subshell, thus `read` would
be unable to modify our environment, because it would be called in a child process.

Anyway our capitalize function works
```bash
foo () {
    local hello="hello world"
    capitalize hello #pass by reference
    echo "$hello"
}

foo #prints HELLO WORLD
```

Turns out we don't even need the `read` function.
Bash 4.3 introduced support for "namerefs" which is exactly what we need
to make our solution less hacky.

From bash manual:

>Whenever the nameref variable is referenced, assigned to, unset, or has its attributes modified (other
>than using or changing the nameref attribute itself), the operation is actually performed on
>the variable specified by the nameref variable’s value. A nameref is commonly used within
>shell functions to refer to a variable whose name is passed as an argument to the function.

In practice this means that:

```bash
x=1
declare -n ref_x=x
#from now on all operations on ref_x will be performed on x
ref_x=hello
echo $x #prints hello
echo $ref_x #prints hello
```

This means can use namerefs in our `capitalize` function instead of `read`!

```bash
capitalize () {
    local -n _ref="$1"
    _ref="$(echo "$_ref" | tr '[[:lower:]]' '[[:upper:]]')"
}

foo () {
    local hello="hello world"
    capitalize hello #pass by reference
    echo "$hello"
}

foo #prints HELLO WORLD
```

In my opinion, it is less magical than the `read` example.

One thing which namerefs have that `read` does not is natural support for arrays

```bash
append () {
    local -n _ref="$1"; shift || return
    _ref+=("$1")
}

main () {
    local -a numbers=(1 2 3)
    append numbers 4
    append numbers 5
    echo "${numbers[@]}"
}

main "$@"
```

Caveats
-------

The first problem can occur when the callee uses the same variable
name for nameref as the variable passed by reference

```bash
foo () {
    local foo=5
    increment foo
}

increment () {
    local -n foo="$1" #this expands to foo=foo and will cause circular reference
    ((foo++))
}
```

When this situation occurs, bash will report an error.

Another problem can occur if the function uses local variable with the 
same name as the variable passed by reference

```bash
change () {
    local -n ref="$1"
    local x
    ref=1 #this will just change the local x from this function
}

foo () {
    local x
    change x #x will be unchanged
}
```

This is due to the fact that namerefs, as the name suggests, operate on variable
names and those can easily overlap.
The only solution to this problem is to limit the amount of local variables in
functions that use namerefs and prefix the namerefs with so many `_`
that can fit on the screen.

```bash
increment () {
    local -n _______________________________________________ref="$1"
    ((_______________________________________________ref++))
}
```

Just kidding. One `_` will do.

Summary
-------

Thanks to dynamic scope of variables and namerefs, we can pass variables by reference.
in bash. This feature however comes with some caveats, so be careful.
