# Debugging Code Written using the M-Web-Server
Most of the time, if you write something of significant complexity, you may
need to set a breakpoint and trace through it. The M-Web-Server supports a mode
for allowing you to do that, where all the processing will take place in a
foreground process. You need to set your breakpoints first, and then you start
the web server using `DO START^VPRJREQ(<port>,1)`. The second parameter of 1 
means that the web server won't job off new processes but will use the current
process to service the request.

Here's an example: Suppose we want to debug the code that displays routines for
us at r/{routine}. From the home page, we know that it calls R^%W0. So what we
can do is put a break point there, and then launch the web server in debug mode.

```
ZB R^%W0
D START^VPRJREQ(9080,1)
```

Now, we need to make a web service call to get a routine. In another terminal
on the same machine, we can run curl.

```
curl localhost:9080/r/XUS
```

At this point, we will hit the break point and we will be able to step into it:

```
%YDB-I-BREAKZBA, Break instruction encountered during ZBREAK action
                At M source location R^%W0
%YDB-W-NOTPRINCIO, Output currently directed to device SCK$9080

VEHU6>zst into
 S RESULT("mime")="text/plain; charset=utf-8"
%YDB-I-BREAKZST, Break instruction encountered during ZSTEP action
                At M source location R+1^%W0

VEHU6>zst into
 S RESULT=$NA(^TMP($J))
%YDB-I-BREAKZST, Break instruction encountered during ZSTEP action
                At M source location R+2^%W0

VEHU6>zst into
 K @RESULT
%YDB-I-BREAKZST, Break instruction encountered during ZSTEP action
                At M source location R+3^%W0

VEHU6>
```

That's it. You are now stepping into the code. Of note, you can use the same
mechanism to debug the M Web Server itself.

For help learning how to debug on specific M platforms:

 * GTM: http://tinco.pair.com/bhaskar/gtm/doc/books/pg/UNIX_manual/ch04s02.html
 * YottaDB: https://docs.yottadb.com/ProgrammersGuide/opdebug.html#debugging-a-routine-in-direct-mode
 * Cache: https://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=GCOS_debug


