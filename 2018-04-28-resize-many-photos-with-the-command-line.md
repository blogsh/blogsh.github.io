---
layout: post
title:  "Resize many images with the command line"
date:   2018-04-28 17:00:07 +0100
image: /assets/resize-many-photos-with-the-command-line.jpg
comments: true
image_pos: center center
tags:
  - bash
---

Often you need to resize many images to, for example, place them on your website.
To do it, you don't have to open every image in Free Trial version of Photoshop
or Gimp. You also don't need to install bloated apps like Batch Image Resizer Pro&trade;,
Enterprise Resizer Ultra&trade; or YetAnotherResizer&reg;, that you will
want get rid off just after you're done with the job.

You can use [ImageMagick&reg;](https://www.imagemagick.org/), which
is a proven and powerful tool for manipulating images from the command line.

Prerequisities
--------------

First, you need to install [ImageMagick&reg;](https://www.imagemagick.org/).
This is just one line. Here is how to do it on various linux distros:

Ubuntu/Debian
```console
$ sudo apt install imagemagick
```
Fedora/CentOS
```console
$ sudo yum install imagemagick
```
Arch Linux
```console
$ sudo pacman -S imagemagick
```

For other linux distributions, please refer to the internet.

Do it
-----

1. Navigate to the directory, where your images are located
```console
$ cd images
```

2. Execute this awesome one-liner to resize all images:
```console
$ ls | xargs -n1 -I{} -d'\n' convert {} -resize 500x500 resized-{}
```

Done! You didn't even have to take your hands off the keyboard.

How it works
------------

Let's take a closer look at this complex looking one-liner.
The first part is simple - it lists directories. So, for example, after
you entered `images` directory and executed `ls` in it, you may see the following
list of directories.
```console
$ ls
a.jpg b.jpg c.jpg d.jpg
```

Next, the standard output of `ls` is redirected using `|` operator to `xargs`.
But, what does `xargs` do?

To put it simply, `xargs` reads words from standard input and passes them as
arguments to a given command. For example:
```console
$ echo a b c | xargs rm
```

Would have the same effect as:
```console
$ rm a b c
```

You can limit the number of arguments passed to a single
command invocation by passing
`-n` switch to `xargs`, so that executing:

```console
$ echo a b c | xargs -n 1 rm
```

Would become an equivalent of the following series of commands:
```console
$ rm a
$ rm b
$ rm c
```

There is also the another important bit of `xargs` command.
It is when you not neccessarily want to place the arguments
at the end of the command. You can control where `xargs` 
puts arguments using `-I` option. The argument to `-I` option
is the string that will be replaced with the arguments read 
from stdin.

Example:
```console
$ echo a b c | xargs -n1 -I{} echo foo {} bar
foo a bar
foo b bar
foo c bar
```

Next comes the `convert` command, which is provided by ImageMagic.
It is used to perform various operations on images, like resizing,
converting formats or applying filters. Here is how you can
resize the image with it:

```
$ convert input.jpg -resize 128x128 output.jpg
```

The `input.jpg` will be resized to 128px width and
128px height and save to `output.jpg`.

Now, you've seen all the important bits. Let's put 
them together again.
```console
$ ls | xargs -n1 -I{} convert {} -resize 500x500 resized-{}
```

The list of files printed to stdout is redirected
to `xargs`, which will execute `convert` command for each
filename. Before every invocation of the `convert` command
, `xargs` will replace `{}` with a filename.

Summary
-------

ImageMagick is a very versatile tool for manipulating images from command line.
If you want to know more about it, check out the [official website](https://www.imagemagick.org/).

Also `xargs` is a very useful utility when it comes to shell scripting.
It is good to know more about it, you can learn more from the [manual](http://man7.org/linux/man-pages/man1/xargs.1.html)
