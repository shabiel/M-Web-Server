# Controlling M Web Server Start-Up from M (most common) 
## Starting the M Web Server
To start the server, in direct mode type:

```
do ^%webreq
```

This will start the server on port 9080. The default port can be changed by setting the global `^%webhttp(0,"port")` to another port number.

To get more control over the the start, you can just the `job^%webreq` entry point. `job` is harder to use, as it takes multiple arguments. The arguments are:

 - PORT (Port Number: required)
 - TLSCONFIG (TLS Config Name)
 - NOGBL (run without using Globals. Used by YottaDB for GDE GUI.)
 - USERPASS (set-up HTTP Basic Authentication using a username:password)
 - NOGZIP (Disable gzip compression for GT.M/YottaDB. Used to prevent errors inside of docker containers where the space to do gzipping is limited)

A typical use of `job^%webreq` is `do job^%webreq(8080)`.

TLSCONFIG's use is documented in detail in [this document](doc/tls-setup.md).

Another entry point for advanced users/programmers is the `start^%webreq` entry point. I won't document it in detail here. It supports a DEBUG flag to cause you to break to debug your code, and also a TRACE flag to allow you to trace your code execution for coverage (GT.M/YottaDB only). DEBUG's use is described in detail in [this document](doc/debugging.md).

## Stopping the M-Web-Server
To stop the server, run `do stop^%webreq`. The loop that checks if a stop have been requested is 10 seconds long, so you need to wait at most that time to check that it stopped.

# Controlling M Web Server Start-Up from Xinetd
This is not a commonly used feature; and we (as the developers) don't regression test for it. You can also run the M Web Server from Xinetd. A sample xinetd config can be found [here](src/example.xinetd.cleartext) and the script to run the job is [here](src/example.xientd.client). The key is that your Xinetd server will eventually call the Xinetd entry point `GTMLNX^%webreq`.

# Testing that the server is actually running
The easiest way to check that the sever is running is doing a curl against `/ping`. For example,

```
$ curl -s localhost:9080/ping | jq
{
"status": "19621 running"
}
```

Also, navigating your browser to / will show you the home page.

Another way is to check using ZSY (if installed). `do ^ZSY` will show the following:

```
GT.M System Status users on 12-OCT-19 16:09:30
PID   PName   Device       Routine            Name                CPU Time
19576 mumps   BG-S9080     LOOP+19^%webreq                        0:00.05
```

Last but not least, you can use netstat or lsof to check which process is listening on a specific port. For example,

```
$ lsof -iTCP -sTCP:LISTEN -P
COMMAND    PID USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
rapportd   470  sam    3u  IPv4 0xd1f43f7b28c2f965      0t0  TCP *:55282 (LISTEN)
rapportd   470  sam    4u  IPv6 0xd1f43f7b290e2cbd      0t0  TCP *:55282 (LISTEN)
yottadb  19576  sam    6u  IPv6 0xd1f43f7b290e327d      0t0  TCP *:9080 (LISTEN)
```
