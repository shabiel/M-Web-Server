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
