---
layout: post
title:  "Building a LiveReload with bash"
date:   2018-07-12 17:00:00 +0100
image: /assets/building-livereload-with-bash.png
author: czarnota
image_pos: center center
tags:
  - bash
---

LiveReload automatically refreshes a web page when 
your website files change.
You don't have to manually switch to your browser and click
**refresh** or press **F5** button. 
LiveReload does it for you and saves you a lot
of time.
There are already many existing tools and browser-plugins,
but it can also be **easily** implemented with bash.

Existing solutions
------------------

LiveReload is not a new idea. Web developers have been using it for years.
There are many solutions that already exists

- [http://livereload.com/](http://livereload.com/)
- [https://www.npmjs.com/package/livereload](https://www.npmjs.com/package/livereload)
- [https://addons.mozilla.org/pl/firefox/addon/livereload/](https://addons.mozilla.org/pl/firefox/addon/livereload/)
- many many more

And they all do their job pretty well.  
They setup a LiveReload server and most of them require a some sort of
browser plugin to communicate with the server and refresh the entire page
(or just refresh the css/js files), whenever assets change.

Turns out, you can implement a LiveReload solution with bash pretty easily
and **with just few line of code**!

Monitoring file changes
-----------------------

First, we need a way of monitoring file changes. This won't be hard.
All we need is to check the modifiaction time of a file. We can do so with
`date` program and `-r` option.

```console
$ date -r index.html %+s
```

We need to save the old modification date and continuously check if the
new modification is different than the old one.
If it is, we should perform a certain task (for example refresh a web page)

Let's create a bash script called `monitor` which will monitor the list of files
and perform the specified action if they changed.

And the script
```bash
#!/bin/bash

#For each file passed as an argument return
#a line containing the last modification date
modification_dates () {
    for file in "$@"; do
        date -r "$file" +%s 2> /dev/null
    done
}

#The main function of the script
main () {
    local -a files=()
    local arg
    local current_modification
    local last_modification

    #Read all argument until "do" is reached
    while arg="$1" && shift && [[ $arg != do ]]; do
        files+=("$arg")
    done

    #Get list of modification dates
    last_modification="$(modification_dates "${files[@]}")"

    while sleep 1; do
        current_modification="$(modification_dates "${files[@]}")"
        if [[ $last_modification != $current_modification ]]; then
            #Execute the command passed after "do"
            "$@"
            last_modification="$current_modification"
        fi
    done
}

main "$@"
```

The script has the following syntax

```console
$ ./monitor FILES do ACTION
```
Example
```console
$ ./monitor index.html style.css index.js do echo files changed
```

We did it! We can execute a specified command whenever the files change.
We are almost done. The last thing we need is a way to refesh the browser window
from the command line.

Refreshing the browser window
-----------------------------

In order to refresh a browser window, we need to press the **F5** key.
To press **F5** from the bash script we must interact with
[X Window System](https://en.wikipedia.org/wiki/X_Window_System), which is
responsible for drawing, moving windows and handling of the mouse and keyboard
input.

We can easily do that using `xdotool` program.
```console
$ sudo apt install xdotool
```

We can use `xdotool` to send the **F5** key to specified window

```console
$ xdotool key --window WINDOW_ID F5
```

Now we just need to obtain the `WINDOW_ID`.
Let's list the window ids for "Mozilla Firefox"

```console
$ xdotool search --name "Mozilla Firefox"
39845904
39846171
```

Let's create the `refresh-firefox` script that will send the **F5** key to one of the Mozilla Firefox windows

```bash
#!/bin/bash

firefox_wid () {
    xdotool search --name "Mozilla Firefox" | head -n 1
}

main () {
    xdotool key --window "$(firefox_wid)" F5
}

main "$@"
```

Wrap up!
--------

Now let's use these 2 scripts together.

```console
$ ./monitor index.html style.css index.js do ./refresh-firefox
```

It works! Whenever you change one of the specified files, the browser window will
be refreshed.

If you place `./monitor` and `./refresh-firefox` in your path the syntax becomes
even more elegant
```console
$ monitor index.html style.css index.js do refresh-firefox
```
This is almost like the natural language.

Google Chrome
-------------

To refresh the Google Chrome window you need slightly different `xdotool`
commands

```bash
refresh_chrome () {
    local active_window="$(xdotool getactivewindow)"
    xdotool search --onlyvisible --class chrome windowfocus key F5
    xdotool windowfocus "$active_window"
}
```

First, you need to obtain the ID of current window, to restore the focus
after you change the active window to Google Chrome.
This is because Google Chrome only accepts events if the window is active.

Summary
-------
You can build LiveReload with a few lines of code in bash and without the need 
of installing any third-party browser plugins
