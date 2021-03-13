---
layout: post
title:  "The oddities of the variable assignment syntax"
date:   2018-04-05 17:20:07 +0100
image: /assets/the-oddities-of-variable-assignment-syntax.jpg
comments: true
image_pos: center left
tags:
  - bash
---

The variable assignment in bash may seem straightforward at the first glance,
but there exist a few counter-intuitive pitfalls.
If you have ever felt like "why can't I have whitespace in here?!" or "bash is insane!", 
then this article is for you. Once you know the rules behind the syntax of
variable assignment in bash, you will see that it actually makes a lot of sense.

How to assign variables in bash?
--------------------------------

The variable assignment looks just like in any other programming language.

```console
$ MY_VARIABLE=myvalue
```

Here the string value `"myvalue"` is assigned to the variable named `MY_VARIABLE`.
If you want to get the value of a variable, you can use
the `$` operator. This is called a **parameter expansion**. 
```console
$ echo ${MY_VARIABLE}
myvalue
$ echo $MY_VARIABLE #simplified syntax
myvalue
```

Beware of whitespace surrounding =
----------------------------------
So, this is how you assign variables:
```console
$ A=B
```
Here the string value `"B"` will be assigned to variable named `A`.
If you are new to bash (e.g. coming from C, Python or other programming
language), then you may want to include some whitespace to make this assignment
more readable.
```console
$ A = B
```
It was one of the first mistakes that I used to make. 
What is going to happen here? Let's&nbsp;see.
```console
$ A = B
A: unknown command
```

This is not a syntax error.
It doesn't work, because it is not interpreted as variable assignment syntax.
It is interpreted as a simple command, which is defined in bash the following way:
>It’s a sequence of words separated by blanks. 
>The first word generally specifies a command to be executed, with the rest of the words being that command’s arguments.

Bash will attempt to execute a command
`A` with `=` given as first argument and `B` as the second.

Let's consider another example
```console
$ A= B
B: unknown command
```
This is another trap that you can fall into just by making a typo. The error
is again not a syntax error, but this time `B` is intepreted as a command. Why?

Turns out that bash will interpret `A=` as a variable assignment preceding the command name.
Such assignments only affect the environment of the executed command. For example if you wanted
to open a `man` for `ls` program, but you wanted to use a `more` pager you could execute
the following command:
```console
$ MANPAGER=more man ls
```
This has almost the same effect as:
```console
$ export MANPAGES=more
$ man ls
```
With the exception that the former example would only affect the environment of 
a `man` process and the latter would affect the environment of current bash session.

So in this example:
```console
$ A= B
B: unknown command
```

Bash would attempt to execute `B` command with variable `A` in its environment, which
would be set to an empty value.

Strings should be quoted
------------------------

In previous examples of assignments you could see that string values don't
have to be quoted. There are cases where quotes are neccessary. For example:
``` console
$ caption=hello my friend
```

From previous examples you can learn that here bash would attempt to execute
`my` program with word `friend` given as a first argument and with `caption`
variable set to `"hello"` value in its environment.
You can enclose the string with quotes or escape whitespace characters with `\` character:
```console
$ caption="hello my friend"
$ caption=hello\ my\ friend
```

Variables don't have to be quoted
---------------------------------
Another interesting example concerns the feature called **word splitting**.
In bash the world splitting occurs during parameter expansion when variable isn't quoted:
```console
$ hello="mkdir foo"
$ $hello #will call 'mkdir' with 'foo' as a first argument
$ "$hello" #will try call 'mkdir foo' program
mkdir foo: unknown command
```

So when performing the following assignment:
```console
$ foo="a b"
$ bar=$foo
```
You may think that it would result in:
```console
$ bar=a b
```
Which is calling `b` command with `bar=a` in its environment. This is not 
the case, however. Turns out that bash doesn't perform word splitting when it
comes to variable assignment. So this results in:
```console
$ bar="a b"
```

Did you expect it? I didn't.

Summary
-------
There are few surprises when it comes to variable assignment, but once you
know what is the reasoning behind they are not that surprising.

