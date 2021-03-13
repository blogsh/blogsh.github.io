---
layout: post
title:  "Listing all TODO comments"
date:   2020-01-11 19:00:00 +0100
author: czarnota
tags:
  - bash
---

TODO comments are a simple, yet a very effective way of maintaining
a list of tasks in a project.

Below you can see an example of a TODO comment:
```c
/* TODO: Read this setting from the driver instead of hardcoding it */
```

Although they can't replace a full-featured issue tracker like
[Jira](https://www.atlassian.com/software/jira) or even a simple issue list like
the one offered by [Github](https://github.com), they have one feature that these tools do not.

TODO comments are stored next to the code - so when the code is changed, then the
associated TODO comment will most likely also be updated (or completely removed)
by the developer, who edited the related code. Tickets in the issue tracker have to be
manually synchronised with the current state of the project
([backlog refinement](https://www.agilealliance.org/glossary/backlog-grooming/)).

Placing project requirements in TODO comments is, of course, not a wise decision,
but I think they are the perfect place for tasks that are strictly related to the code.
Maintenance, removal of "temporary" workarounds, refactorings, are good examples
of tasks that are often too small to deserve a dedicated ticket in the issue tracker.

Some tools - especially IDEs - offer a simple way of listing all TODO comments.
If you don't use an IDE or like to craft your own tools, you can write
a Bash script that will do the same.

Let's write it
--------------

Getting all lines containing the word `"TODO"` is super easy.

```console
$ grep -r "TODO" .
```

The above command will recursively search all files for `"TODO"` string.

```console
./src/main.c:    // TODO: Add support for --help argument
./src/main.c:        // TODO: Remove this workaround
./src/foo.c:        // TODO: This should be configurable by the user
```

This is great. Actually it could be just enough.

But we can make this just a little better.

We can change the pattern that we are searching for to detect all possible
variants of `TODO`, `ToDo`, `todo`, `FixMe`, `FIXME`, etc.
Also by using `-o` with `grep` we will see only these parts of lines that match
the `"(TODO|FIXME).*"` regular expression enabled by `-E`.

```console
$ grep -rioE "(TODO|FIXME).*" .
./src/main.c:TODO: Add support for --help argument
./src/main.c:TODO: Remove this workaround
./src/foo.c:TODO: This should be configurable by the user
./src/foo.c:FIXME: We just return -1 on error - we should recover properly by reverting these changes
```

The good old `grep` is a very powerful tool indeed.
But there are newer tools out there, in the wilderness, and they are
not only more powerful and intelligent, but also significantly faster.

If you haven't heard of `ag` or `rg` - I encourage you to try them out.
Partly because they are faster than grep and partly because their names are
easier to type.

You can find more information on them here:
- [https://github.com/BurntSushi/ripgrep](https://github.com/BurntSushi/ripgrep)
- [https://github.com/ggreer/the_silver_searcher](https://github.com/ggreer/the_silver_searcher)

The usage is similar to `grep`

```console
$ grep -rioE "(TODO|FIXME).*" .
$ ag -io "(TODO|FIXME).*"
$ rg -io "(TODO|FIXME).*"
```

So now we have 3 tools that we can use. Which one to use?

Whatever is available!

Let's create a script that will check if a tool is available and choose the best one.

```bash
#!/usr/bin/env bash

PATTERN="(TODO|FIXME).*"

rg_todo () {
    rg -io "$PATTERN" "$@"
}

rg_has () {
    hash rg
}

ag_todo () {
    ag -io "$PATTERN" "$@"
}

ag_has () {
    hash rg
}

grep_todo () {
    grep -r -ioE "$PATTERN" "$@" .
}

grep_has () {
    hash grep
}

TOOLS=(
    rg # ripgrep is the fastest
    ag # The Silver Searcher is a little slower than rg
    grep # Use grep is available almost everywhere
)

main () {
    for tool in "${TOOLS[@]}"; do
        # If the tool is available
        if ${tool}_has; then
            # List TODOs
            ${tool}_todo "$@"
            return
        fi
    done
}

main "$@"
```

Now we can list the TODO's in our code using `rg`, `ag` or `grep` - whatever is installed.
You can even easily extend the script to add a support for a new search tool.

Let's call the script `todo` and put it in some directory in your `$PATH`.

Then you can just type:
```console
$ todo
src/main.c
8:TODO: Add support for --help argument
14:TODO: Remove this workaround
src/foo.c
22:TODO: This should be configurable by the user
25:FIXME: We just return -1 on error - we should recover properly by reverting these changes
```

And then immediately - you know what to do!
Now it's time to worry about how...
