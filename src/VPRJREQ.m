VPRJREQ ;slc/kcm - m-web: listener ;2018-04-30T22:35Z
 ;;1.8;MASH;;
 ;
 ; VPRJREQ implements the Mumps Advanced Shell's M Web Server (m-web),
 ; which supplies HTTP version 1.0 single-request listening & response
 ; services for mumps systems.
 ; It was originally developed by Kevin C. Meldrum at VA Salt Lake,
 ; then upgraded by Sam Habiel at the Vista Expertise Network & OSEHRA
 ; to support GT.M and additional capabilties. It is now undergoing
 ; refactoring for formal inclusion in Mumps Advanced Shell v1.8 by
 ; Frederick D. S. Marshall.
 ; This refactored version is currently untested & in progress. Stick
 ; with the stable version in Sam's Github repository.
 ;
 ;
 ;
 ;@section 0 primary development
 ;
 ;
 ;
 ;@to-do
 ; refactor
 ; renamespace to %w
 ; upgrade to http 1.1
 ;  add ETag support
 ; upgrade to http 2.0
 ;@contents
 ; ^VPRJREQ-GO: dmi: start m-web listener on port 9080
 ; JOB: start m-web listener on specified port
 ; START-LOOP: m-web listener main entry point
 ; STOP: dmi: tell listener to stop running
 ;
 ; DEBUG: dmi: debug http 1.0 single-request handler
 ; JOBEXAM: interrupt framework for gt.m
 ; GTMLNX: xinetd wrapper for http 1.0 single-request handler
 ; CHILD-CHILDDEBUG-TLS-NEXT-WAIT: http 1.0 single-request handler
 ; ADDHEAD: add header name & value
 ;
 ; $$RDCRLF = read a header line
 ; RDCHNKS: read body in chunks
 ; RDLEN-RDLOOP: fixed-length read
 ;
 ; ETSOCK: error trap for http 1.0 single-request handler
 ; ETCODE: error trap for response
 ; ETDC: handle client disconnect
 ; ETBAIL: emergency error trap
 ;
 ; INCRLOG: get unique log id for each request
 ; LOGRAW: log raw lines read in
 ; LOGHDR: log header lines read in
 ; LOGBODY: log request body
 ; LOGRSP: log response before sending
 ; LOGCN: log continue
 ; LOGDC: log client disconnection
 ; LOGERR: log error information
 ;
 ; SIGNON: TODO: VISTA SIGN-ON
 ; SIGNOFF: TODO: VISTA SIGN-OFF
 ;
 ;
 ;
 ;@section 1 http listener
 ;
 ;
 ;
 ; ^VPRJREQ ; dmi: start m-web listener on port 9080
 ;
 ;@called-by
 ; direct-mode interface only, no calls in
 ;@falls-thru-to
 ; GO
 ;@input: none
 ;@output: none
 ;
 ;
 ;
GO ; start up REST listener with defaults
 ;
 ;@falls-thru-from
 ; ^VPRJREQ
 ;@called-by: none
 ;@calls
 ; JOB
 ;@input
 ; ^VPRHTTP(0,"port")
 ;@output: none
 ;
 new PORT set PORT=$get(^VPRHTTP(0,"port"),9080)
 do JOB(PORT)
 ;
 quit  ; end of ^VPRJREQ-GO
 ;
 ;
 ;
JOB(PORT,TLSCONFIG) ; start m-web on specified port
 ;
 ;@called-by
 ; ^VPRJREQ-GO
 ; direct-mode interface
 ;@jobs
 ; START^VPRJREQ
 ;@calls: none
 ;@input
 ; PORT =
 ; TLSCONFIG =
 ;@output: none
 ;
 ; convenience entry point
 ;
 set TLXCONFIG=$get(TLSCONFIG)
 ;
 if +$system=47 do  ; gt.m
 . job START^VPRJREQ(PORT,,TLSCONFIG):(IN="/dev/null":OUT="/dev/null":ERR="/dev/null"):5  ; no in & out files please
 . quit
 ;
 else  do  ; cache
 . job START^VPRJREQ(PORT,"",TLSCONFIG) ; cache can't accept an empty string in 2nd argument
 . quit
 ;
 quit  ; end of JOB
 ;
 ;
 ;
START(TCPPORT,DEBUG,TLSCONFIG) ; m-web listener main entry point
 ;
 ;@jobbed-by
 ; JOB
 ;@called-by: none
 ;@falls-thru-to
 ; LOOP
 ;@calls
 ; DEBUG
 ;@interrupt-calls
 ; $$JOBEXAM^ZSY
 ; $$JOBEXAM^VPRJREQ
 ;@text-ref
 ; JOBEXAM^ZSY
 ;@input
 ;@output
 ;
 ; set up listening for connections
 ;
 ; I hope TCPPORT needs no explanations
 ;
 ; DEBUG is so that we run our server in the foreground.
 ; You can place breakpoints at CHILD+1 or anywhere else.
 ; CTRL-C will always work
 ;
 set ^VPRHTTP(0,"listener")="starting"
 ;
 ; get mumps virtual machine
 new %WOS set %WOS=$select(+$system=47:"GT.M",+$system=50:"MV1",1:"CACHE")
 ;
 ; $zinterrupt for gt.m/yottadb
 if %WOS="GT.M" do
 . if $text(JOBEXAM^ZSY)]"" do
 . . set $zinterrupt="if $$JOBEXAM^ZSY($zpos),$$JOBEXAM^VPRJREQ($zpos)"
 . . quit
 . else  do
 . . set $zinterrupt="if $$JOBEXAM^VPRJREQ($zpos)"
 . . quit
 . quit
 ;
 set TCPPORT=$get(TCPPORT,9080)
 ;
 ; device id
 if %WOS="CACHE" do
 . set TCPIO="|TCP|"_TCPPORT
 . quit
 if %WOS="GT.M" do
 . set TCPIO="SCK$"_TCPPORT
 . quit
 ;
 ; open code
 new %WEXIT set %WEXIT=0
 if %WOS="CACHE" do  quit:%WEXIT
 . open TCPIO:(:TCPPORT:"ACT"):15 if  quit
 . set %WEXIT=1
 . use 0
 . write !,"error cannot open port "_TCPPORT
 . quit
 if %WOS="GT.M" do  quit:%WEXIT
 . open TCPIO:(LISTEN=TCPPORT_":TCP":delim=$char(13,10):attach="server"):15:"socket" if  quit
 . set %WEXIT=1
 . use 0
 . write !,"error cannot open port "_TCPPORT
 . quit
 ;
 ; K. Now we are really really listening.
 set ^VPRHTTP(0,"listener")="running"
 ;
 ; this is the same for gt.m & cache
 use TCPIO
 ;
 ; listen 5 deep - sets $key to "LISTENING|socket_handle|portnumber"
 if %WOS="GT.M" do
 . write /LISTEN(5)
 . quit
 new PARSOCK set PARSOCK=$piece($key,"|",2) ; parent socket
 new CHILDSOCK ; child socket, set below
 ;
 if $get(DEBUG) do
 . do DEBUG($get(TLSCONFIG))
 . quit
 ;
 ;
LOOP ; wait for connection, spawn process to handle it. GOTO favorite.
 ;
 ;@falls-thru-from
 ; START
 ;@branches-from
 ; LOOP
 ;@called-by: none
 ;@jobs
 ; CHILD
 ; START^VPRJREQ [commented out, pre-v6.1]
 ;@branches-to
 ; LOOP
 ; CHILD
 ;@calls: none
 ;
 if $extract(^VPRHTTP(0,"listener"),1,4)="stop" do  quit
 . close TCPIO
 . set ^VPRHTTP(0,"listener")="stopped"
 . quit
 ;
 ;
 ; ---- CACHE CODE ----
 ;
 if %WOS="CACHE" do  goto LOOP
 . read *X:10
 . else  quit  ; loop back again when listening & nobody on the line
 . ; send device to another job for input & output:
 . job CHILD($get(TLSCONFIG)):(:4:TCPIO:TCPIO):10
 . if $za\8196#2=1 do  ; if job failed to clear bit
 . . write *-2
 . . quit
 . quit
 ;
 ; ---- END CACHE CODE ----
 ;
 ;
 ; ----- GT.M CODE ----
 ;
 ; in gt.m $key is
 ;  "CONNECT|socket_handle|portnumber"
 ; then
 ;  "READ|socket_handle|portnumber"
 ;
 ; to tell us if we should loop waiting or process HTTP requests
 ; we don't need this anymore
 ; new GTMDONE set GTMDONE=0
 ; if %WOS="GT.M" do  goto LOOP:'GTMDONE,CHILD:GTMDONE
 ;
 if %WOS="GT.M" do  goto LOOP
 . ;
 . ; wait until we have a connection (infinite wait)
 . ; stop if listener asked us to stop
 . ;
 . for  do  quit:$key]""  quit:$extract(^VPRHTTP(0,"listener"),1,4)="stop"
 . . write /WAIT(10)
 . . quit
 . ;
 . ; we have to stop! when we quit, we go to loop & exit at loop+1
 . ;
 . if $extract(^VPRHTTP(0,"listener"),1,4)="stop" quit
 . ; 
 . ; at connection, job off new child socket to be served away
 . ;
 . ; if $piece($key,"|")="CONNECT" quit  ; before gt.m v6.1
 . ;
 . if $piece($key,"|")="CONNECT" do  ; gt.m >= v6.1
 . . seet CHILDSOCK=$piece($key,"|",2)
 . . use TCPIO:(detach=CHILDSOCK)
 . . new Q set Q=""""
 . . new ARG set ARG=Q_"SOCKET:"_CHILDSOCK_Q
 . . new J set J="CHILD($get(TLSCONFIG)):(input="_ARG_":output="_ARG_")"
 . . job @J
 . . quit
 . ;
 . ; gt.m before 6.1:
 . ; use incoming socket; close server, restart it, goto child
 . ; use TCPIO:(SOCKET=$piece($key,"|",2))
 . ; close TCPIO:(SOCKET="server")
 . ; job START^VPRJREQ(TCPPORT):(IN="/dev/null":OUT="/dev/null":ERR="/dev/null"):5
 . ; set GTMDONE=1 ; will goto child at the do exist up above
 . ;
 . ; ---- END GT.M CODE ----
 . quit
 ; 
 quit  ; end of START-LOOP
 ;
 ;
 ;
STOP ; dmi: tell listener to stop running
 ;
 ;@called-by
 ; direct-mode interface
 ;@calls: none
 ;
 ; this direct-mode interface lets system managers manually stop
 ; the m web server listener
 ;
 set ^VPRHTTP(0,"listener")="stopped"
 ;
 quit  ; end of STOP
 ;
 ;
 ;
 ;@section 2 http 1.0 single-request handler
 ;
 ;
 ;
DEBUG(TLSCONFIG) ; dmi: debug http 1.0 single-request handler
 ;
 ;@called-by
 ; START
 ;@trap
 ; debug mode
 ;@branches-to
 ; CHILDDEBUG
 ;@calls: none
 ;
 ; debug continuation
 ; we don't job off request, rather run it now
 ;
 ; stop using ctrl-c (duh!)
 ;
 new $etrap set $etrap="break"
 kill ^VPRHTTP("log") ; kill log to see our errors when they happen
 if %WOS="GT.M" do
 . use $io:(CENABLE:ioerror="T")
 . quit
 if %WOS="CACHE" for  read *X:10 if  goto CHILDDEBUG
 if %WOS="GT.M" for  write /WAIT(10) if $key]"" goto CHILDDEBUG
 ;
 quit  ; end of DEBUG
 ;
 ;
 ;
JOBEXAM(%ZPOS) ; interrupt framework for gt.m
 ;
 ;@called-by
 ; interrupt processing
 ;@interrupt-setup-by
 ; START-LOOP
 ; GTMLNX
 ;@calls: none
 ;
 zshow "*":^VPRHTTP("processlog",+$horolog,$piece($horolog,",",2),$job)
 ;
 quit 1 ; end of $$JOBEXAM
 ;
 ;
 ;
GTMLNX ; xinetd wrapper for http 1.0 single-request handler
 ;
 ;@called-by
 ; linux xinetd script
 ;@trap
 ; ETSOCK
 ;@branches-to
 ; CHILD
 ;@interrupt-calls
 ; $$JOBEXAM^ZSY
 ; $$JOBEXAM^VPRJREQ
 ;@text-ref
 ; JOBEXAM^ZSY
 ;@calls
 ;@input
 ; $principal = main stream
 ;
 set ^VPRHTTP(0,"listener")="starting"
 if $text(JOBEXAM^ZSY)]"" do
 . set $zinterrupt="if $$JOBEXAM^ZSY($zpos),$$JOBEXAM^VPRJREQ($zpos)"
 . quit
 else  do
 . set $zinterrupt="if $$JOBEXAM^VPRJREQ($zpos)"
 . quit
 xecute "use $principal:(nowrap:nodelimiter:ioerror=""ETSOCK"")"
 set %=""
 set @("%=$ztrnlnm(""REMOTE_HOST"")")
 set:$length(%) IO("IP")=%
 ;
 goto CHILD ; end of GTMLNX
 ;
 ;
 ;
 ; Child Handling Process ---------------------------------
 ;
 ; The following variables exist during the course of the request
 ; HTTPREQ contains the HTTP request, with subscripts as follow --
 ; HTTPREQ("method") contains GET, POST, PUT, HEAD, or DELETE
 ; HTTPREQ("path") contains the path of the request (part from server to ?)
 ; HTTPREQ("query") contains any query params (part after ?)
 ; HTTPREQ("header",name) contains a node for each header value
 ; HTTPREQ("body",n) contains as an array the body of the request
 ; HTTPREQ("location") stashes the location value for PUT, POST
 ; HTTPREQ("store") stashes the type of store (vpr or data)
 ;
 ; HTTPRSP contains the HTTP response (or name of global with the response)
 ; HTTPLOG indicates the logging level for this process
 ; HTTPERR non-zero if there is an error state
 ;
 ;
 ;
CHILD(TLSCONFIG) ; http 1.0 single-request handler
 ;
 ;@called-by
 ;@calls
 ;
 ; handle HTTP requests on this connection
 ;
CHILDDEBUG ; [internal] debugging entry point for CHILD
 ;
 ;@called-by
 ;@calls
 ;
 N %WTCP S %WTCP=$GET(TCPIO,$PRINCIPAL) ; TCP Device
 N %WOS S %WOS=$S(+$SY=47:"GT.M",+$SY=50:"MV1",1:"CACHE") ; Get Mumps Virtual Machine
 S HTTPLOG=$G(^VPRHTTP(0,"logging"),0) ; HTTPLOG remains set throughout
 S HTTPLOG("DT")=+$H
 D INCRLOG ; set unique request id for log
 N $ET S $ET="G ETSOCK^VPRJREQ"
 ;
 ;
TLS ; Turn on TLS?
 ;
 ;@called-by
 ;@calls
 ;
 I TLSCONFIG]"" D
 . I %WOS="GT.M" W /TLS("server",1,TLSCONFIG)
 . I %WOS="CACHE" U %WTCP:(::"-M":/TLS=TLSCONFIG)
 N D,K,T
 ; put a break point here to debug TLS
 S D=$DEVICE,K=$KEY,T=$TEST
 ; U 0
 ; W !
 ; W "$DEVICE: "_D,!
 ; W "$KEY: "_K,!
 ; W "$TEST: "_T,!
 ; U %WTCP
 ;
 ;
NEXT ; begin next request
 ;
 ;@called-by
 ;@calls
 ;
 K HTTPREQ,HTTPRSP,HTTPERR
 K ^TMP($J),^TMP("HTTPERR",$J) ; TODO: change the namespace for the error global
 ;
 ;
WAIT ; wait for request on this connection
 ;
 ;@called-by
 ;@calls
 ;
 I $E($G(^VPRHTTP(0,"listener")),1,4)="stop" C %WTCP Q
 X:%WOS="CACHE" "U %WTCP:(::""CT"")" ;VEN/SMH - Cache Only line; Terminators are $C(10,13)
 X:%WOS="GT.M" "U %WTCP:(delim=$C(13,10))" ; VEN/SMH - GT.M Delimiters
 R TCPX:10 I '$T G ETDC
 I '$L(TCPX) G ETDC
 ;
 ; -- got a request and have the first line
 I HTTPLOG D LOGRAW(TCPX),LOGHDR(TCPX)
 S HTTPREQ("method")=$P(TCPX," ")
 S HTTPREQ("path")=$P($P(TCPX," ",2),"?")
 S HTTPREQ("query")=$P($P(TCPX," ",2),"?",2,999)
 ; TODO: time out connection after N minutes of wait
 ; TODO: check format of TCPX and raise error if not correct
 I $E($P(TCPX," ",3),1,4)'="HTTP" G NEXT
 ;
 ; -- read the rest of the lines in the header
 F  S TCPX=$$RDCRLF() Q:'$L(TCPX)  D ADDHEAD(TCPX)
 ;
 ; -- Handle Contiuation Request - VEN/SMH
 I $G(HTTPREQ("header","expect"))="100-continue" D LOGCN W "HTTP/1.1 100 Continue",$C(13,10,13,10),!
 ;
 ; -- decide how to read body, if any
 X:%WOS="CACHE" "U %WTCP:(::""S"")" ; Stream mode
 X:%WOS="GT.M" "U %WTCP:(nodelim)" ; VEN/SMH - GT.M Delimiters
 I $$LOW^VPRJRUT($G(HTTPREQ("header","transfer-encoding")))="chunked" D
 . D RDCHNKS ; TODO: handle chunked input
 . I HTTPLOG>2 ; log array of chunks
 I $G(HTTPREQ("header","content-length"))>0 D
 . D RDLEN(HTTPREQ("header","content-length"),99)
 . I HTTPLOG>2 D LOGBODY
 ;
 ; -- build response (map path to routine & call, otherwise 404)   
 S $ETRAP="G ETCODE^VPRJREQ"
 S HTTPERR=0
 D RESPOND^VPRJRSP
 S $ETRAP="G ETSOCK^VPRJREQ"
 ; TODO: restore HTTPLOG if necessary
 ;
 ; -- write out the response (error if HTTPERR>0)
 X:%WOS="CACHE" "U %WTCP:(::""S"")" ; Stream mode
 X:%WOS="GT.M" "U %WTCP:(nodelim)" ; VEN/SMH - GT.M Delimiters
 I $G(HTTPERR) D RSPERROR^VPRJRSP ; switch to error response
 I HTTPLOG>2 D LOGRSP
 D SENDATA^VPRJRSP
 ;
 ; -- exit on Connection: Close
 I $$LOW^VPRJRUT($G(HTTPREQ("header","connection")))="close" D  HALT
 . K ^TMP($J),^TMP("HTTPERR",$J)
 . C %WTCP
 ;
 ; -- otherwise get ready for the next request
 I %WOS="GT.M"&$G(HTTPLOG) ZGOTO 0:NEXT^VPRJREQ ; unlink all routines; only for debug mode
 ;
 goto NEXT ; end of CHILD-CHILDDEBUG-TLS-NEXT-WAIT
 ;
 ;
 ;
ADDHEAD(LINE) ; add header name & value
 ;
 ;@called-by
 ; CHILD-CHILDDEBUG-TLS-NEXT-WAIT
 ;@calls
 ; LOGHDR
 ; $$LTRIM^VPRJRUT
 ; $$LOW^VPRJRUT
 ;
 ; expects HTTPREQ to be defined
 ;
 do:HTTPLOG LOGHDR(LINE)
 new NAME set NAME=$$LOW^VPRJRUT($$LTRIM^VPRJRUT($piece(LINE,":")))
 new VALUE set VALUE=$$LTRIM^VPRJRUT($piece(LINE,":",2,99))
 if LINE'[":" do
 . set NAME=""
 . set VALUE=LINE
 . quit
 if '$length(NAME) do
 . set NAME=$get(HTTPREQ("header")) ; grab the last name used
 . quit
 quit:'$length(NAME)  ; no header name so just ignore this line
 if $data(HTTPREQ("header",NAME)) do
 . set HTTPREQ("header",NAME)=HTTPREQ("header",NAME)_","_VALUE
 . quit
 else  do
 . set HTTPREQ("header",NAME)=VALUE
 . set HTTPREQ("header")=NAME
 . quit
 ;
 quit  ; end of ADDHEAD
 ;
 ;
 ;
 ;@section 3 http reader subroutines
 ;
 ;
 ;
RDCRLF() ; read a header line
 ;
 ;@called-by
 ; CHILD-CHILDDEBUG-TLS-NEXT-WAIT
 ;@calls
 ; LOGRAW
 ;
 ; fixes a problem where the read would terminate before CRLF
 ; (on a packet boundary or when 1024 characters had been read)
 ;
 new LINE set LINE=""
 new X,RETRY
 for RETRY=1:1 do  quit:$ascii($zb)=13  quit:RETRY>10
 . read X:1
 . do:HTTPLOG LOGRAW(X)
 . set LINE=LINE_X
 . quit
 ;
 quit LINE ; end of $$RDCRLF
 ;
 ;
 ;
RDCHNKS ; read body in chunks
 ;
 ;@called-by
 ; CHILD-CHILDDEBUG-TLS-NEXT-WAIT
 ;@calls: none
 ;
 ; still need to implement
 ;
 quit  ; end of RDCHNKS
 ;
 ;
 ;
RDLEN(REMAIN,TIMEOUT) ; fixed-length read
 ;
 ;@falls-thru-to
 ; RDLOOP
 ;@called-by
 ; CHILD-CHILDDEBUG-TLS-NEXT-WAIT
 ;@calls: none
 ;
 ; read L bytes with timeout T
 ;
 new LINE set LINE=0
 new X,LENGTH
 ;
RDLOOP ;
 ;
 ;@falls-thru-from
 ; RDLEN
 ;@branches-to
 ; RDLOOP
 ;@called-by: none
 ;@calls
 ; LOGRAW
 ;
 ; read until L bytes collected
 ; quit with what we have if read times out
 ;
 set LENGTH=REMAIN
 if LENGTH>4000 do
 . set LENGTH=4000
 . quit
 read X#LENGTH:TIMEOUT else  do  quit
 . do:HTTPLOG>1 LOGRAW("timeout:"_X)
 . set LINE=LINE+1
 . set HTTPREQ("body",LINE)=X
 . quit
 ;
 if HTTPLOG>1 do
 . do LOGRAW(X)
 . quit
 set REMAIN=REMAIN-$length(X)
 set LINE=LINE+1
 set HTTPREQ("body",LINE)=X
 goto:REMAIN RDLOOP
 ;
 quit  ; end of RDLEN-RDLOOP
 ;
 ;
 ;
 ;@section 4 http error handling
 ;
 ;
 ;
ETSOCK ; error trap for http 1.0 single-request handler
 ;
 ;@called-by
 ; GTMLNX
 ; CHILD-CHILDDEBUG-TLS-NEXT-WAIT
 ;@calls: LOGERR
 ;
 ; socket-handler trap, i.e., client closes connection
 ;
 do LOGERR
 close %WTCP
 ;
 ; exit because connection has been closed
 ;
 halt  ; end of ETSOCK & end of process
 ;
 ;
 ;
ETCODE ; error trap for response
 ;
 ;@traps
 ; CHILD-CHILDDEBUG-TLS-NEXT-WAIT
 ;  at call to RESPOND^VPRJRSP
 ;  which invokes web services in response to request
 ;@trapped-by
 ; ETBAIL
 ;@branches-from
 ; $etrap
 ;@called-by: none
 ;@calls
 ; LOGERR
 ; SETERROR^VPRJRUT
 ; RSPERROR^VPRJRSP
 ; SENDATA^VPRJRSP
 ;@output
 ; changes error trap
 ;
 ; trap when calling out to routines
 ;
 set $etrap="goto ETBAIL^VPRJREQ" ; set emergency backup trap
 ;
 if $tlevel trollback  ; abandon any transactions
 lock  ; & release any locks
 ;
 ; set error info & write as http response
 do LOGERR
 do SETERROR^VPRJRUT(501,"Log ID:"_HTTPLOG("ID")) ; sets HTTPERR
 do RSPERROR^VPRJRSP ; switch to error response
 do SENDATA^VPRJRSP
 ;
 ; leave $ecode as non-null so error handling continues
 ; next line unwinds stack & goes back to listening
 ; for the next HTTP request (goto NEXT)
 ;
 st $etrap="quit:$estack&$quit 0 quit:$estack  set $ecode="""" goto NEXT"
 ;
 quit  ; end of ETCODE
 ;
 ;
 ;
ETDC ; handle client disconnect
 ;
 ;@called-by
 ; CHILD-CHILDDEBUG-TLS-NEXT-WAIT
 ;@calls
 ; LOGDC
 ;
 ; error trap for client disconnect ; not a true M trap
 ;
 do:HTTPLOG LOGDC
 kill ^TMP($job)
 kill ^TMP("HTTPERR",$job)
 close $principal
 ;
 ; Stop process
 ;
 halt  ; end of ETDC & end of process
 ;
 ;
 ;
ETBAIL ; emergency error trap
 ;
 ;@traps
 ; ETCODE
 ;@branches-from
 ; $etrap
 ;@called-by: none
 ;@calls: none
 ;
 ; error trap of error traps
 ;
 use %WTCP
 write "HTTP/1.1 500 Internal Server Error",$char(13,10),$char(13,10),!
 kill ^TMP($job)
 kill ^TMP("HTTPERR",$job)
 close %WTCP
 ;
 ; exit because we can't recover
 ;
 halt  ; end of ETBAIL & end of process
 ;
 ;
 ;
 ;@section 5 http logging
 ;
 ;
 ;
INCRLOG ; get unique log id for each request
 ;
 ;@called-by
 ; CHILD-CHILDDEBUG-TLS-NEXT-WAIT
 ;@calls
 ; $$HTE^VPRJRUT
 ;
 new DT set DT=HTTPLOG("DT")
 lock +^VPRHTTP("log",DT):2 else  do  quit  ; get unique logging session
 . set HTTPLOG("ID")=99999
 . quit
 new ID set ID=$get(^VPRHTTP("log",DT),0)+1
 set ^VPRHTTP("log",DT)=ID
 lock -^VPRHTTP("log",DT)
 ;
 set HTTPLOG("ID")=ID
 quit:'HTTPLOG
 ;
 set ^VPRHTTP("log",DT,$job,ID)=$$HTE^VPRJRUT($horolog)_"  $j:"_$job_"  $p:"_%WTCP_"  $stack:"_$stack
 ;
 quit  ; end of INCRLOG
 ;
 ;
 ;
LOGRAW(X) ; log raw lines read in
 ;
 ;@called-by
 ; CHILD-CHILDDEBUG-TLS-NEXT-WAIT
 ; RDCRLF
 ; RDLEN-RDLOOP
 ;@calls: none
 ;
 new DT set DT=HTTPLOG("DT")
 new ID set ID=HTTPLOG("ID")
 new LN set LN=$get(^VPRHTTP("log",DT,$job,ID,"raw"),0)+1
 set ^VPRHTTP("log",DT,$job,ID,"raw")=LN
 set ^VPRHTTP("log",DT,$job,ID,"raw",LN)=X
 set ^VPRHTTP("log",DT,$job,ID,"raw",LN,"ZB")=$ascii($zb)
 ;
 quit  ; end of LOGRAW
 ;
 ;
 ;
LOGHDR(X) ; log header lines read in
 ;
 ;@called-by
 ; CHILD-CHILDDEBUG-TLS-NEXT-WAIT
 ; ADDHEAD
 ;@calls: none
 ;
 new DT set DT=HTTPLOG("DT")
 new ID set ID=HTTPLOG("ID")
 new LN set LN=$get(^VPRHTTP("log",DT,$job,ID,"req","header"),0)+1
 set ^VPRHTTP("log",DT,$job,ID,"req","header")=LN
 set ^VPRHTTP("log",DT,$job,ID,"req","header",LN)=X
 ;
 quit  ; end of LOGHDR
 ;
 ;
 ;
LOGBODY ; log request body
 ;
 ;@called-by
 ; CHILD-CHILDDEBUG-TLS-NEXT-WAIT
 ;@calls: none
 ;
 quit:'$data(HTTPREQ("body"))
 ;
 new DT set DT=HTTPLOG("DT")
 new ID set ID=HTTPLOG("ID")
 merge ^VPRHTTP("log",DT,$job,ID,"req","body")=HTTPREQ("body")
 ;
 quit  ; end of LOGBODY
 ;
 ;
 ;
LOGRSP ; log response before sending
 ;
 ;@called-by
 ; CHILD-CHILDDEBUG-TLS-NEXT-WAIT
 ;@calls: none
 ;
 quit:'$length($get(HTTPRSP))
 ; quit:'$data(@HTTPRSP)  ; ven/smh - response may be scalar
 ;
 new DT set DT=HTTPLOG("DT")
 new ID set ID=HTTPLOG("ID")
 if $extract(HTTPRSP)="^" do
 . merge ^VPRHTTP("log",DT,$job,ID,"response")=@HTTPRSP
 . quit
 else  do
 . merge ^VPRHTTP("log",DT,$job,ID,"response")=HTTPRSP
 . quit
 ;
 quit  ; end of LOGRSP
 ;
 ;
 ;
LOGCN ; log continue
 ;
 ;@called-by
 ; CHILD-CHILDDEBUG-TLS-NEXT-WAIT
 ;@calls: none
 ;
 new DT set DT=HTTPLOG("DT")
 new ID set ID=HTTPLOG("ID")
 set ^VPRHTTP("log",DT,$job,ID,"continue")="HTTP/1.1 100 Continue"
 ;
 quit  ; end of LOGCN
 ;
 ;
 ;
LOGDC ; log client disconnection
 ;
 ;@called-by
 ; ETDC
 ;@calls
 ; $$HTE^VPRJRUT
 ;
 ; ven/smh
 ;
 new DT set DT=HTTPLOG("DT")
 new ID set ID=HTTPLOG("ID")
 set ^VPRHTTP("log",DT,$job,ID,"disconnect")=$$HTE^VPRJRUT($horolog)
 ;
 quit  ; end of LOGDC
 ;
 ;
 ;
LOGERR ; log error information
 ;
 ;@called-by
 ; ETSOCK
 ; ETCODE
 ;@calls: none
 ;
 new %D set %D=HTTPLOG("DT")
 new %I set %I=HTTPLOG("ID")
 new ISGTM set ISGTM=$piece($system,",")=47
 set ^VPRHTTP("log",%D,$J,%I,"error")=$select(ISGTM:$zstatus,1:$zerror_"  ($ecode:"_$ecode_")")
 ;
 new %TOP set %TOP=$stack(-1)
 new %N set %N=0
 new %LVL
 for %LVL=0:1:%TOP do
 . set %N=%N+1
 . set ^VPRHTTP("log",%D,$J,%I,"error","stack",%N)=$stack(%LVL,"PLACE")_":"_$stack(%LVL,"MCODE")
 . quit
 ;
 new %X set %X="^VPRHTTP(""log"",%D,$J,%I,""error"",""symbols"","
 ; works on gt.m & cache to capture symbol table
 new %Y set %Y="%"
 for  do  quit:%Y=""
 . merge:$data(@%Y) @(%X_"%Y)="_%Y)
 . set %Y=$order(@%Y)
 . quit
 ;
 quit  ; end of LOGERR
 ;
 ;
 ;
 ;@section 6 incomplete subroutines
 ;
 ;
 ;
SIGNON ; TODO: VISTA SIGN-ON
 ;
 ;
 ;
SIGNOFF ; TODO: VISTA SIGN-OFF
 ;
 ;
 ;
 ; Deprecated -- use VPRJ
 ;
 ;
 ;
EOR ; end of routine VPRJREQ
