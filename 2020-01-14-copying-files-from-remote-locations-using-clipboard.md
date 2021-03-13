---
layout: post
title:  "Copying files from a remote location using the clipboard"
date:   2020-01-14 23:30:00 +0100
author: czarnota
tags:
  - bash
---

Every so often you may find yourself connected to a remote Linux machine 
located in a place far far away and with absolutely no straightforward method 
of transfering files. You might desperately need to copy a file from that 
location, but there  might be no ftp server, no ssh server (so no `scp` 
available), no samba share nor any other file transfer service.
Clearly, not the most convenient set of circumstances.

Often you are limited to only copying the text from a remote console into the 
clipboard. This is true for the telnet or serial connections, also for the 
situations where you connect somewhere using the remote desktop to use `ssh`
remotely. In addition you can work with a Virtual Machine,
with no shared directories set up, only the clipboard.

How to transfer the files, then? If you have the internet connectivity you can use 
services like [https://transfer.sh](https://transfer.sh), but is transfering 
your data to a remote server on the internet secure? Provided that you may hold 
confidential or sensitive data - there is no discussion. It is possible to quickly 
configure a local network service just for this purpose, but it may take time
that you don't have. After all, you just need to copy a file!

Crazy method
------------

Assuming that your file is named `your_file`.

First compress `your_file` with `tar` and then redirect `tar` output to the
`base64` command

```console
$ tar -xzvf - your_file | base64
```

This will print a BIG string

```
H4sIAI86Hl4AA9RafXRTVba/SRsoSLkVqRQsEjBIQdomhULrUGgh1VtMEaF8KMXQjwQiaVLTGyg
xGoS7TVmreqooDPPxTgf+nzjDE+XlWlZGkAL6sgA6jzUNVoQn4ko0wHB0krz9t73JjmNXGf+mT9
WM25v9/dZ5+999lnn3Oi9Q5Xoejx2rh/48cIn/nFxdTCJ6WdP7dovpEzzSmaYzTOm2cqAjmTqWi
idMb/51GxT/eFrHOo9dzHrdb/Cm5f/b+/+nngUrLLVqNJoHTuIUcoj0TZFyu8HvvTfYp50q4UfC
y13HjQCsY+RS237N8DYjMQ7HpcNfiVbGqW0uN7zVMK3uJ/wpbxjecpw+0Q9t7dsss32b9cPajnS
N44Y3k+r9FvrlNm1Tv2wtk8xrC/Fv3Tlr0bxJ7U1c8NbZXhu+ZdiIz43rpZxartAO7yN97sD+iV
/xc+WUq7QhlPLS5ZygDxNj4PhU5H/by5hc7GfKfD5W3Nby2Zlz9vbkGLu6CIbMpSZG9dtorkcb6

...

f9KLrvS0tHjW6SWMeypFNQABo8uzpr5GjxXyq/1+RtZKxoOG+saH/pNdkhCyhPh7dwpX+v5icn8
gdS4+dsUyd83lJLyW5Oev5VUXklLhLlfUp7WHYag04zyht43YC2PN+xAshzTNziyTPXHFDyHxnc
CVhM5Q39PE9I/KahYWcMaNgVIyTzj8ylZqLf0NMG7EiiPy0JLhd0G2A8G3bAgKuEkek3wncFnad
ecMuGXBZkh1Nbr/Cy5fyZ8POGdCwi1R+/AjlfyjEv8lJwfALDGj+losgDO//dUnlz16bBNMS8zu
YEdS+YFxiTCZX7YkGE6uf1wiLDF/lEEYbnefTCpv+EEGHJOUP7n9zwiJ49f4zpoBb8pOzC8llf9
UvkrfWf0SvW/kFT+uWVJMDMxfzI//03Qv+diDJP4d0dHzp/M/52C/t0Xo7zhF174C8vv4/THhqn
vxjfeU0qLyU9vyPofWeUj38XlreHD3ijf83veilsTKrf8CvlRv35xSSFkUz/qWT6DTvbrIP2L6H
I47LKG9856idl38uqf7k8ueE4TrNXH5qUnyy/CTQbgov8fKWJOQj1ZUKqZAKqZAKqZAKqZAKqZA
qZAKqZAKqZAKqZAKqZAKqZAKqZAKqZAKqZAKqZAKqZAKqZAKqfDfOfxfSGm/qwCgAAA=
```

Which then you can **copy from the terminal into the clipboard** and paste it
into the file (let's call it `base64.txt`) at the destination location.

After saving the file with base64 string in it, it is the time to decode it.

Just do the reverse:

```
$ cat base64.txt | base --decode | tar -xzvf -
```

And there you have it.
