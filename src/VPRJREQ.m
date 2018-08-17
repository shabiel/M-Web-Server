VPRJREQ ;SLC/KCM -- Listen for HTTP requests;2018-08-17  9:40 AM
 ;;1.0;JSON DATA STORE;;Sep 01, 2012;Build 6
 ;
 ; Listener Process ---------------------------------------
 ; Mods by VEN/SMH for GT.M support.
 ;
GO ; start up REST listener with defaults
 N PORT S PORT=$G(^VPRHTTP(0,"port"),9080)
 D JOB(PORT)
 QUIT
 ;
JOB(PORT,TLSCONFIG,NOGBL) ; Convenience entry point
 I +$SY=47 J START^VPRJREQ(PORT,,$G(TLSCONFIG),$G(NOGBL)):(IN="/dev/null":OUT="vprjreq.mjo":ERR="vprjreq.mje"):5  ; no in and out files please.
 E  J START^VPRJREQ(PORT,"",$G(TLSCONFIG),$G(NOGBL)) ; Cache can't accept an empty string in the second argument
 QUIT
 ;
START(TCPPORT,DEBUG,TLSCONFIG,NOGBL) ; set up listening for connections
 ; I hope TCPPORT needs no explanations.
 ;
 ; DEBUG is so that we run our server in the foreground.
 ; You can place breakpoints at CHILD+1 or anywhere else.
 ; CTRL-C will always work
 ;
 S:'$G(NOGBL) ^VPRHTTP(0,"listener")="starting"
 ;
 N %WOS S %WOS=$S(+$SY=47:"GT.M",+$SY=50:"MV1",1:"CACHE") ; Get Mumps Virtual Machine
 ;
 ; $ZINTERRUPT for GT.M/YottaDB
 I %WOS="GT.M" D
 . I $T(JOBEXAM^ZSY)]"" S $ZINT="I $$JOBEXAM^ZSY($ZPOS),$$JOBEXAM^VPRJREQ($ZPOS)"
 . E  S $ZINT="I $$JOBEXAM^VPRJREQ($ZPOS)"
 ;
 S TCPPORT=$G(TCPPORT,9080)
 ;
 ; Device ID
 I %WOS="CACHE" S TCPIO="|TCP|"_TCPPORT
 I %WOS="GT.M" S TCPIO="SCK$"_TCPPORT
 ;
 ; Open Code
 I %WOS="CACHE" O TCPIO:(:TCPPORT:"ACT"):15 E  U 0 W !,"error cannot open port "_TCPPORT Q
 I %WOS="GT.M" O TCPIO:(LISTEN=TCPPORT_":TCP":delim=$C(13,10):attach="server"):15:"socket" E  U 0 W !,"error cannot open port "_TCPPORT Q
 ;
 ; K. Now we are really really listening.
 S:'$G(NOGBL) ^VPRHTTP(0,"listener")="running"
 ;
 ; This is the same for GT.M and Cache
 U TCPIO
 ;
 I %WOS="GT.M" W /LISTEN(5) ; Listen 5 deep - sets $KEY to "LISTENING|socket_handle|portnumber"
 N PARSOCK S PARSOCK=$P($KEY,"|",2)  ; Parent socket
 N CHILDSOCK  ; That will be set below; Child socket
 ;
 I $G(DEBUG) D DEBUG($G(TLSCONFIG))
 ;
LOOP ; wait for connection, spawn process to handle it. GOTO favorite.
 I '$G(NOGBL)&$E(^VPRHTTP(0,"listener"),1,4)="stop" C TCPIO S ^VPRHTTP(0,"listener")="stopped" Q
 ;
 ; ---- CACHE CODE ----
 I %WOS="CACHE" D  G LOOP
 . R *X:10
 . E  QUIT  ; Loop back again when listening and nobody on the line
 . J CHILD($G(TLSCONFIG)):(:4:TCPIO:TCPIO):10 ; Send off the device to another job for input and output.
 . i $ZA\8196#2=1 W *-2  ; job failed to clear bit
 ; ---- END CACHE CODE ----
 ;
 ; ----- GT.M CODE ----
 ; In GT.M $KEY is "CONNECT|socket_handle|portnumber" then "READ|socket_handle|portnumber"
 ; N GTMDONE S GTMDONE=0  ; To tell us if we should loop waiting or process HTTP requests ; don't need this anymore
 ;I %WOS="GT.M" D  G LOOP:'GTMDONE,CHILD:GTMDONE
 I %WOS="GT.M" D  G LOOP
 . ;
 . ; Wait until we have a connection (inifinte wait). 
 . ; Stop if the listener asked us to stop.
 . FOR  W /WAIT(10) Q:$KEY]""  Q:('$G(NOGBL)&$E(^VPRHTTP(0,"listener"),1,4)="stop")
 . ;
 . ; We have to stop! When we quit, we go to loop, and we exit at LOOP+1
 . I '$G(NOGBL)&$E(^VPRHTTP(0,"listener"),1,4)="stop" QUIT
 . ; 
 . ; At connection, job off the new child socket to be served away.
 . ; I $P($KEY,"|")="CONNECT" QUIT ; before 6.1
 . I $P($KEY,"|")="CONNECT" D  ; >=6.1
 . . S CHILDSOCK=$P($KEY,"|",2)
 . . U TCPIO:(detach=CHILDSOCK)
 . . N Q S Q=""""
 . . N ARG S ARG=Q_"SOCKET:"_CHILDSOCK_Q
 . . N J S J="CHILD($G(TLSCONFIG),$G(NOGBL)):(input="_ARG_":output="_ARG_")"
 . . J @J
 . ;
 . ; GT.M before 6.1:
 . ; Use the incoming socket; close the server, and restart it and goto CHILD
 . ; USE TCPIO:(SOCKET=$P($KEY,"|",2))
 . ; CLOSE TCPIO:(SOCKET="server")
 . ; JOB START^VPRJREQ(TCPPORT):(IN="/dev/null":OUT="/dev/null":ERR="/dev/null"):5
 . ; SET GTMDONE=1  ; Will goto CHILD at the DO exist up above
 . ; ---- END GT.M CODE ----
 ; 
 QUIT
 ;
DEBUG(TLSCONFIG) ; Debug continuation. We don't job off the request, rather run it now.
 ; Stop using Ctrl-C (duh!)
 N $ET S $ET="BREAK"
 K:'$G(NOGBL) ^VPRHTTP("log") ; Kill log so that we can see our errors when they happen.
 I %WOS="GT.M" U $I:(CENABLE:ioerror="T")
 I %WOS="CACHE" F  R *X:10 I  G CHILDDEBUG
 I %WOS="GT.M" F  W /WAIT(10) I $KEY]"" G CHILDDEBUG
 QUIT
 ;
JOBEXAM(%ZPOS) ; Interrupt framework for GT.M.
 ZSHOW "*":^VPRHTTP("processlog",+$H,$P($H,",",2),$J)
 QUIT 1
 ;
GTMLNX  ;From Linux xinetd script; $P is the main stream
 S ^VPRHTTP(0,"listener")="starting"
 I $T(JOBEXAM^ZSY)]"" S $ZINT="I $$JOBEXAM^ZSY($ZPOS),$$JOBEXAM^VPRJREQ($ZPOS)"
 E  S $ZINT="I $$JOBEXAM^VPRJREQ($ZPOS)"
 X "U $P:(nowrap:nodelimiter:ioerror=""ETSOCK"")"
 S %="",@("%=$ZTRNLNM(""REMOTE_HOST"")") S:$L(%) IO("IP")=%
 G CHILD
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
CHILD(TLSCONFIG,NOGBL) ; handle HTTP requests on this connection
CHILDDEBUG ; [Internal] Debugging entry point
 N %WTCP S %WTCP=$GET(TCPIO,$PRINCIPAL) ; TCP Device
 N %WOS S %WOS=$S(+$SY=47:"GT.M",+$SY=50:"MV1",1:"CACHE") ; Get Mumps Virtual Machine
 S HTTPLOG=$G(^VPRHTTP(0,"logging"),0) ; HTTPLOG remains set throughout
 S HTTPLOG("DT")=+$H
 D INCRLOG ; set unique request id for log
 N $ET S $ET="G ETSOCK^VPRJREQ"
 ;
TLS ; Turn on TLS?
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
NEXT ; begin next request
 K HTTPREQ,HTTPRSP,HTTPERR
 K:'$G(NOGBL) ^TMP($J),^TMP("HTTPERR",$J) ; TODO: change the namespace for the error global
 ;
WAIT ; wait for request on this connection
 I '$G(NOGBL)&$E($G(^VPRHTTP(0,"listener")),1,4)="stop" C %WTCP Q
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
 I $G(HTTPREQ("header","expect"))="100-continue" D:HTTPLOG LOGCN W "HTTP/1.1 100 Continue",$C(13,10,13,10),!
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
 . K:'$G(NOGBL) ^TMP($J),^TMP("HTTPERR",$J)
 . C %WTCP
 ;
 ; -- otherwise get ready for the next request
 I %WOS="GT.M"&$G(HTTPLOG) ZGOTO 0:NEXT^VPRJREQ ; unlink all routines; only for debug mode
 G NEXT
 ;
RDCRLF() ; read a header line
 ; fixes a problem where the read would terminate before CRLF
 ; (on a packet boundary or when 1024 characters had been read)
 N X,LINE,RETRY
 S LINE=""
 F RETRY=1:1 R X:1 D:HTTPLOG LOGRAW(X) S LINE=LINE_X Q:$A($ZB)=13  Q:RETRY>10
 Q LINE
 ;
RDCHNKS ; read body in chunks
 Q  ; still need to implement
 ;
RDLEN(REMAIN,TIMEOUT) ; read L bytes with timeout T
 N X,LINE,LENGTH
 S LINE=0
RDLOOP ;
 ; read until L bytes collected
 ; quit with what we have if read times out
 S LENGTH=REMAIN I LENGTH>4000 S LENGTH=4000
 R X#LENGTH:TIMEOUT
 I '$T D:HTTPLOG>1 LOGRAW("timeout:"_X) S LINE=LINE+1,HTTPREQ("body",LINE)=X Q
 I HTTPLOG>1 D LOGRAW(X)
 S REMAIN=REMAIN-$L(X),LINE=LINE+1,HTTPREQ("body",LINE)=X
 G:REMAIN RDLOOP
 Q
 ;
ADDHEAD(LINE) ; add header name and header value
 ; expects HTTPREQ to be defined
 D:HTTPLOG LOGHDR(LINE)
 N NAME,VALUE
 S NAME=$$LOW^VPRJRUT($$LTRIM^VPRJRUT($P(LINE,":")))
 S VALUE=$$LTRIM^VPRJRUT($P(LINE,":",2,99))
 I LINE'[":" S NAME="",VALUE=LINE
 I '$L(NAME) S NAME=$G(HTTPREQ("header")) ; grab the last name used
 I '$L(NAME) Q  ; no header name so just ignore this line
 I $D(HTTPREQ("header",NAME)) D
 . S HTTPREQ("header",NAME)=HTTPREQ("header",NAME)_","_VALUE
 E  D
 . S HTTPREQ("header",NAME)=VALUE,HTTPREQ("header")=NAME
 Q
 ;
ETSOCK ; error trap when handling socket (i.e., client closes connection)
 D LOGERR
 C %WTCP
 HALT  ; exit because connection has been closed
 ;
ETCODE ; error trap when calling out to routines
 S $ETRAP="G ETBAIL^VPRJREQ"
 I $TLEVEL TROLLBACK ; abandon any transactions
 L                   ; release any locks
 ; Set the error information and write it as the HTTP response.
 D LOGERR
 D SETERROR^VPRJRUT(501,"Log ID:"_HTTPLOG("ID")) ; sets HTTPERR
 D RSPERROR^VPRJRSP  ; switch to error response
 D SENDATA^VPRJRSP
 ; Leave $ECODE as non-null so that the error handling continues.
 ; This next line will 'unwind' the stack and got back to listening
 ; for the next HTTP request (goto NEXT).
 S $ETRAP="Q:$ESTACK&$QUIT 0 Q:$ESTACK  S $ECODE="""" G NEXT"
 Q
ETDC ; error trap for client disconnect ; not a true M trap
 D:HTTPLOG LOGDC
 K:'$G(NOGBL) ^TMP($J),^TMP("HTTPERR",$J)
 C $P  
 HALT ; Stop process 
 ;
ETBAIL ; error trap of error traps
 U %WTCP
 W "HTTP/1.1 500 Internal Server Error",$C(13,10),$C(13,10),!
 K:'$G(NOGBL) ^TMP($J),^TMP("HTTPERR",$J)
 C %WTCP
 HALT  ; exit because we can't recover
 ;
INCRLOG ; get unique log id for each request
 N DT,ID
 S DT=HTTPLOG("DT")
 I '$G(NOGBL) D
 . L +^VPRHTTP("log",DT):2 E  S HTTPLOG("ID")=99999 Q  ; get unique logging session
 . S ID=$G(^VPRHTTP("log",DT),0)+1
 . S ^VPRHTTP("log",DT)=ID
 . L -^VPRHTTP("log",DT)
 E  S ID=99999
 S HTTPLOG("ID")=ID
 Q:'HTTPLOG
 S:'$G(NOGBL) ^VPRHTTP("log",DT,$J,ID)=$$HTE^VPRJRUT($H)_"  $J:"_$J_"  $P:"_%WTCP_"  $STACK:"_$STACK
 Q
LOGRAW(X) ; log raw lines read in
 N DT,ID,LN
 S DT=HTTPLOG("DT"),ID=HTTPLOG("ID")
 I $G(NOGBL) QUIT
 S LN=$G(^VPRHTTP("log",DT,$J,ID,"raw"),0)+1
 S ^VPRHTTP("log",DT,$J,ID,"raw")=LN
 S ^VPRHTTP("log",DT,$J,ID,"raw",LN)=X
 S ^VPRHTTP("log",DT,$J,ID,"raw",LN,"ZB")=$A($ZB)
 Q
LOGHDR(X) ; log header lines read in
 N DT,ID,LN
 S DT=HTTPLOG("DT"),ID=HTTPLOG("ID")
 I $G(NOGBL) QUIT
 S LN=$G(^VPRHTTP("log",DT,$J,ID,"req","header"),0)+1
 S ^VPRHTTP("log",DT,$J,ID,"req","header")=LN
 S ^VPRHTTP("log",DT,$J,ID,"req","header",LN)=X
 Q
LOGBODY ; log the request body
 Q:'$D(HTTPREQ("body"))
 N DT,ID
 S DT=HTTPLOG("DT"),ID=HTTPLOG("ID")
 I $G(NOGBL) QUIT
 M ^VPRHTTP("log",DT,$J,ID,"req","body")=HTTPREQ("body")
 Q
LOGRSP ; log the response before sending
 Q:'$L($G(HTTPRSP))  ; Q:'$D(@HTTPRSP) VEN/SMH - Response may be scalar
 N DT,ID
 S DT=HTTPLOG("DT"),ID=HTTPLOG("ID")
 I $G(NOGBL) QUIT
 I $E(HTTPRSP)="^" M ^VPRHTTP("log",DT,$J,ID,"response")=@HTTPRSP
 E  M ^VPRHTTP("log",DT,$J,ID,"response")=HTTPRSP
 Q
LOGCN ; log continue
 N DT,ID
 S DT=HTTPLOG("DT"),ID=HTTPLOG("ID")
 I $G(NOGBL) QUIT
 S ^VPRHTTP("log",DT,$J,ID,"continue")="HTTP/1.1 100 Continue"
 QUIT
LOGDC ; log client disconnection; VEN/SMH
 N DT,ID
 S DT=HTTPLOG("DT"),ID=HTTPLOG("ID")
 I $G(NOGBL) QUIT
 S ^VPRHTTP("log",DT,$J,ID,"disconnect")=$$HTE^VPRJRUT($H)
 QUIT
 ;
LOGERR ; log error information
 N %D,%I
 S %D=HTTPLOG("DT"),%I=HTTPLOG("ID")
 N ISGTM S ISGTM=$P($SYSTEM,",")=47
 S:'$G(NOGBL) ^VPRHTTP("log",%D,$J,%I,"error")=$S(ISGTM:$ZSTATUS,1:$ZERROR_"  ($ECODE:"_$ECODE_")")
 N %LVL,%TOP,%N
 S %TOP=$STACK(-1),%N=0
 F %LVL=0:1:%TOP S %N=%N+1,^VPRHTTP("log",%D,$J,%I,"error","stack",%N)=$STACK(%LVL,"PLACE")_":"_$STACK(%LVL,"MCODE")
 N %X,%Y
 S %X="^VPRHTTP(""log"",%D,$J,%I,""error"",""symbols"","
 ; Works on GT.M and Cache to capture ST.
 S %Y="%" F  M:$D(@%Y) @(%X_"%Y)="_%Y) S %Y=$O(@%Y) Q:%Y=""
 Q
 ;
SIGNON ; TODO: VISTA SIGN-ON
 ;
SIGNOFF ; TODO: VISTA SIGN-OFF
 ;
 ; Deprecated -- use VPRJ
 ;
STOP ; tell the listener to stop running
 S ^VPRHTTP(0,"listener")="stopped"
 Q
