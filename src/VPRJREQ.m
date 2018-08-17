VPRJREQ ;slc/kcm - m-web: http server ;2018-04-27T12:52Z
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
 ; renamespace to %w & %whs & %whsreq
 ; change namespace for error global
 ; time out connection after N minutes of wait
 ; check format of TCPX & raise error if incorrect
 ; handle chunked input
 ; restore HTTPLOG if necessary
 ; VISTA SIGN-ON
 ; VISTA SIGN-OFF
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
 . new Q set Q=""""
 . new ARG set ARG=Q_"/dev/null"_Q ; no in & out files please
 . new J set J="START(PORT,,TLSCONFIG):(in="_ARG_":out="_ARG_":err="_ARG_"):5"
 . job @J
 . quit
 ;
 else  do  ; cache
 . ; cache can't accept empty 2nd argument, must be empty string
 . new J set J="START(PORT,"""""",TLSCONFIG)"
 . job @J
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
 ; START-LOOP (commented out, for gt.m before v6.1)
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
 use TCPIO ; same for gt.m & cache
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
 . new J set J="CHILD($get(TLSCONFIG)):(:4:TCPIO:TCPIO):10"
 . job @J
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
 . quit:$extract(^VPRHTTP(0,"listener"),1,4)="stop"
 . ; 
 . ; at connection, job off new child socket to be served away
 . ;
 . ; if $piece($key,"|")="CONNECT" quit  ; before gt.m v6.1
 . ;
 . if $piece($key,"|")="CONNECT" do  ; gt.m >= v6.1
 . . set CHILDSOCK=$piece($key,"|",2)
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
 . ; new Q set Q=""""
 . ; new ARG set ARG=Q_"/dev/null"_Q
 . ; new J set J="START(TCPPORT):(IN="_ARG_":OUT="_ARG_":ERR="_ARG_"):5"
 . ; job @J
 . ; set GTMDONE=1 ; will goto child at the do exit up above
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
 ;@error-trap
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
 ;@error-trap
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
 use $principal:(nowrap:nodelimiter:ioerror="ETSOCK")
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
 ;
 ; HTTPREQ = HTTP request, with subscripts as follow:
 ; HTTPREQ("method") = GET, POST, PUT, HEAD, or DELETE
 ; HTTPREQ("path") = path of request (part from server to ?)
 ; HTTPREQ("query") = query params (part after ?)
 ; HTTPREQ("header",name) = header values (1 node for each)
 ; HTTPREQ("body",n) = request body (as an array)
 ; HTTPREQ("location") = location value for PUT, POST
 ; HTTPREQ("store") = type of store (vpr or data)
 ;
 ; HTTPRSP = HTTP response (or name of global with response)
 ;
 ; HTTPLOG = logging level for this process
 ; HTTPLOG("DT") = day in $horolog format
 ; HTTPLOG("ID") = log id
 ;
 ; HTTPERR = non-zero if error state
 ;
 ;
 ;
CHILD(TLSCONFIG) ; http 1.0 single-request handler
 ;
 ;@jobbed-by
 ; START-LOOP
 ;@branches-from
 ; GTMLNX
 ;@called-by: none
 ;@falls-thru-to
 ; CHILDDEBUG
 ;@calls: none
 ;
 ; handle HTTP requests on this connection
 ;
CHILDDEBUG ; [internal] debugging entry point for CHILD
 ;
 ;@falls-thru-from
 ; CHILD
 ;@branches-from
 ; DEBUG
 ;@called-by: none
 ;@error-trap
 ; ETSOCK^VPRJREQ
 ;@falls-thru-to
 ; TLS
 ;@calls
 ; INCRLOG
 ;
 new $etrap set $etrap="goto ETSOCK^VPRJREQ"
 new %WTCP set %WTCP=$get(TCPIO,$principal) ; tcp device
 ; mumps virtual machine:
 new %WOS set %WOS=$select(+$system=47:"GT.M",+$system=50:"MV1",1:"CACHE")
 set HTTPLOG=$get(^VPRHTTP(0,"logging"),0) ; logging level
 set HTTPLOG("DT")=+$horolog ; day in $horolog format
 do INCRLOG ; set unique request id for log
 ;
 ;
TLS ; turn on transport layer security?
 ;
 ;@falls-thru-from
 ; CHILDDEBUG
 ;@branches-from: none
 ;@called-by: none
 ;@error-trap
 ; ETSOCK^VPRJREQ [set in CHILDDEBUG]
 ;@falls-thru-to
 ; NEXT
 ;@calls: none
 ;
 if TLSCONFIG]"" do
 . if %WOS="GT.M" do
 . . write /TLS("server",1,TLSCONFIG)
 . . quit
 . if %WOS="CACHE"
 . . use %WTCP:(::"-M":/TLS=TLSCONFIG)
 . . quit
 . quit
 ;
 ; put a break point here to debug tls
 ;
 new D set D=$device
 new K set K=$key
 new T set T=$test
 ;
 ; debugging code - uncomment while debugging:
 ; use 0
 ; write !
 ; write "$device: "_D,!
 ; write "$key: "_K,!
 ; write "$test: "_T,!
 ; use %WTCP
 ;
 ;
NEXT ; begin next request
 ;
 ;@falls-thru-from
 ; TLS
 ;@branches-from
 ; WAIT
 ;@called-by: none
 ;@error-trap
 ; ETSOCK^VPRJREQ [set in CHILDDEBUG]
 ;@falls-thru-to
 ; WAIT
 ;@calls: none
 ;
 kill HTTPREQ,HTTPRSP,HTTPERR
 kill ^TMP($job)
 kill ^TMP("HTTPERR",$job)
 ;
 ; TODO: change namespace for error global
 ;
 ;
WAIT ; wait for request on this connection
 ;
 ;@falls-thru-from
 ; NEXT
 ;@branches-from: none
 ;@called-by: none
 ;@error-trap
 ; ETSOCK^VPRJREQ [set in CHILDDEBUG]
 ; ETCODE [traps call to RESPOND^VPRJRSP]
 ;@branches-to
 ; ETDC
 ; NEXT
 ;@calls
 ; LOGRAW
 ; LOGHDR
 ; $$RDCRLF
 ; ADDHEAD
 ; LOGCN
 ; $$LOW^VPRJRUT
 ; RDCHNKS
 ; RDLEN
 ; LOGBODY
 ; RESPOND^VPRJRSP
 ; RSPERROR^VPRJRSP
 ; LOGRSP
 ; SENDATA^VPRJRSP
 ; $$LOW^VPRJRUT
 ;
 if $extract($get(^VPRHTTP(0,"listener")),1,4)="stop" do  quit
 . close %WTCP
 . quit
 ;
 ; implementation-specific use lines by ven/smh
 ;
 use:%WOS="CACHE" %WTCP:(::"CT") ; cache: terminators are cr/lf
 use:%WOS="GT.M" %WTCP:(delim=$char(13,10)) ; gt.m: delimiters are cr/lf
 read TCPX:10 ; get next input
 else  goto ETDC ; client disconnect
 if TCPX="" goto ETDC ; client disconnect
 ;
 ; -- got request & have 1st line
 ;
 do:HTTPLOG LOGRAW(TCPX),LOGHDR(TCPX)
 set HTTPREQ("method")=$piece(TCPX," ")
 set HTTPREQ("path")=$piece($piece(TCPX," ",2),"?")
 set HTTPREQ("query")=$piece($piece(TCPX," ",2),"?",2,999)
 ;
 ; TODO: time out connection after N minutes of wait
 ; TODO: check format of TCPX & raise error if incorrect
 ;
 I $E($P(TCPX," ",3),1,4)'="HTTP" G NEXT
 ;
 ; -- read rest of lines in header
 ;
 for  do  quit:TCPX=""
 . set TCPX=$$RDCRLF()
 . quit:TCPX=""
 . do ADDHEAD(TCPX)
 . quit
 ;
 ; -- handle continuation request - ven/smh
 ;
 if $get(HTTPREQ("header","expect"))="100-continue" do
 . do LOGCN
 . write "HTTP/1.1 100 Continue",$char(13,10,13,10),!
 . quit
 ;
 ; -- decide how to read body, if any
 ; implementation-specific use lines by ven/smh
 ;
 use:%WOS="CACHE" %WTCP:(::"S") ; cache: stream mode
 use:%WOS="GT.M" %WTCP:(nodelim) ; gt.m: no delimiters
 if $$LOW^VPRJRUT($get(HTTPREQ("header","transfer-encoding")))="chunked" do
 . do RDCHNKS
 . ; TODO: handle chunked input
 . if HTTPLOG>2 ; log array of chunks
 . quit
 if $get(HTTPREQ("header","content-length"))>0 do
 . do RDLEN(HTTPREQ("header","content-length"),99)
 . do:HTTPLOG>2 LOGBODY
 . quit
 ;
 ; -- build response (map path to routine & call, otherwise 404)
 ;
 set $etrap="goto ETCODE^VPRJREQ" ; trap for response
 set HTTPERR=0
 do RESPOND^VPRJRSP
 set $etrap="goto ETSOCK^VPRJREQ"
 ;
 ; TODO: restore HTTPLOG if necessary
 ;
 ; -- send response (error if HTTPERR>0)
 ; implementation-specific use lines by ven/smh
 ;
 use:%WOS="CACHE" %WTCP:(::"S") ; cache: stream mode
 use:%WOS="GT.M" %WTCP:(nodelim) ; gt.m: no delimiters
 do:$get(HTTPERR) RSPERROR^VPRJRSP ; switch to error response
 do:HTTPLOG>2 LOGRSP
 do SENDATA^VPRJRSP
 ;
 ; -- exit on connection close
 ;
 if $$LOW^VPRJRUT($get(HTTPREQ("header","connection")))="close" do
 . kill ^TMP($job)
 . kill ^TMP("HTTPERR",$job)
 . close %WTCP
 . halt
 ;
 ; -- otherwise get ready for the next request
 ;
 ; gt.m: unlink all routines; only for debug mode
 if %WOS="GT.M",$get(HTTPLOG) zgoto 0:NEXT^VPRJREQ
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
 ;@error-trap-for
 ; CHILD-CHILDDEBUG-TLS-NEXT-WAIT
 ;  at call to RESPOND^VPRJRSP
 ;  which invokes web services in response to request
 ;@error-trap
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
 set $etrap="quit:$estack&$quit 0 quit:$estack  set $ecode="""" goto NEXT"
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
 ;@error-trap-for
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
 do
 . new ISGTM set ISGTM=$piece($system,",")=47
 . set:ISGTM ERROR=$zstatus
 . set:'ISGTM ERROR=$zerror_"  ($ecode:"_$ecode_")"
 . set ^VPRHTTP("log",%D,$J,%I,"error")=ERROR
 . quit
 ;
 new %TOP set %TOP=$stack(-1)
 new %N set %N=0
 new %LVL
 for %LVL=0:1:%TOP do
 . set %N=%N+1
 . new STACK set STACK=$stack(%LVL,"PLACE")_":"_$stack(%LVL,"MCODE")
 . set ^VPRHTTP("log",%D,$J,%I,"error","stack",%N)=STACK
 . quit
 ;
 ; works on gt.m & cache to capture symbol table
 new %X set %X=$name(^VPRHTTP("log",%D,$J,%I,"error","symbols"))
 new %Y set %Y="%"
 for  do  quit:%Y=""
 . merge:$data(@%Y) @%X@(%Y)=%Y
 . set %Y=$order(@%Y) ; nonstandard: $order thru name table
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
