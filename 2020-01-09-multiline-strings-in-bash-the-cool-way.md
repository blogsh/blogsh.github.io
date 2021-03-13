---
layout: post
title:  "Multiline strings in Bash - the cool way"
date:   2020-01-09 12:07:19 +0100
author: czarnota
tags:
  - bash
---

Bash supports multiline strings using heredoc syntax. They are extremely useful
if you want to embed other programming language code in a Bash script.

For example:
```bash
cat << EOF
import os
print(os.getcwd())
EOF
```

Will output
```
import os
print(os.getcwd())
```

This is working and cool, but has one little limitation.

```bash
# test.sh
python_code () {
    cat << EOF
    import os
    print(os.getcwd())
    EOF
}
python_code
```

Doesn't work.

```console
$ bash test.sh
test.sh: line 9: warning: here-document at line 4 delimited by end-of-file (wanted `EOF')
test.sh: line 10: syntax error: unexpected end of file
```

You can't indent code. You need to do this instead:

```bash
# test.sh
python_code () {
cat << EOF
import os
print(os.getcwd())
EOF
}
python_code
```

This works, but looks ugly. It is a known problem - indentation is not supported by heredoc. 

The simplest solution is just not to use indentation and be done with the problem, after all, we developers have so many problems to fix, and the deadlines are just around the corner.
Nevertheless for some of us the readability is worth fighting for. So let's fight!

But hola, amigo - not so fast.
Heredoc supports indentation and you are lying! See?


```bash
# test.sh
python_code () {
	cat <<- EOF
	import os
	print(os.getcwd())
	EOF
}
python_code
```

Well, yes. There is `<<-` operator which enables the indentation, but it has one limitation - You must use tabs to indent. Doesn't work with spaces. So lame.

So unless you indent your bash scripts with tabs - you are out of luck. (you can always commit the sin of mixed indentation, but you didn't hear that from me)

Now those who believe that tabs > spaces can stop reading, go back to work and start solving real domain problems.

We poor "space" souls must stay and fix this indentation issue.

Fixing the situation a bit
--------------------------

Personally i like to visually simulate the indentation.

```bash
# test.sh
python_code () {
    cat << "    EOF"
    import os
    print("Hello world")
    EOF
}
python_code
```

Looks good enough. But here we are introducing one problem. Look:

```console
$ bash test.sh
    import os
    print("Hello world")
```

Now we output unecessary indentation and here for example this python code won't work.

```bash
python3 <(python_code)
```

```
  File "/dev/fd/63", line 1
    import os
    ^
IndentationError: unexpected indent
```

Oh no! What to do? Let us increase the level of insanity and "deindent" this code with `sed`.

```bash
python_code () {
    sed -r 's/^.{4}//' << "    EOF"
    import os
    print("Hello world")
    EOF
}
```

Voila! We even add an extra level if we want to:

```bash
python_code () {
    sed -r 's/^.{8}//' << "    EOF"
        import os
        print("Hello world")
    EOF
}
```

Also let's make this `sed` a little bit less scary.

```bash
deindent () {
    sed -r 's/^.{8}//'
}

python_code () {
    deindent << "    EOF"
        import os
        print("Hello world")
    EOF
}
```

That was hacky. Is there a better way? Let me know.
