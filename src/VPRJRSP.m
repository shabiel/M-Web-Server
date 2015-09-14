VPRJRSP ;SLC/KCM -- Handle HTTP Response;2014-05-09  6:45 PM
 ;;1.0;JSON DATA STORE;;Sep 01, 2012
 ;
 ; -- prepare and send RESPONSE
 ;
RESPOND ; find entry point to handle request and call it
 ; expects HTTPREQ, HTTPRSP is used to return the response
 ;
 ; TODO: check cache of HEAD requests first and return that if there?
 K ^TMP($J)
 N ROUTINE,LOCATION,HTTPARGS,HTTPBODY
 I HTTPREQ("path")="/",HTTPREQ("method")="GET" D EN^%WHOME(.HTTPRSP) QUIT  ; Home page requested.
 D MATCH(.ROUTINE,.HTTPARGS) I $G(HTTPERR) QUIT  ; Resolve the URL and authenticate if necessary
 D QSPLIT(.HTTPARGS) I $G(HTTPERR) QUIT          ; Split the query string
 S HTTPREQ("paging")=$G(HTTPARGS("start"),0)_":"_$G(HTTPARGS("limit"),999999)
 S HTTPREQ("store")=$S($$LOW^VPRJRUT($E(HTTPREQ("path"),2,4))="vpr":"vpr",1:"data")
 I "PUT,POST"[HTTPREQ("method") D
 . N BODY
 . M BODY=HTTPREQ("body") K HTTPREQ("body")
 . X "S LOCATION=$$"_ROUTINE_"(.HTTPARGS,.BODY,.HTTPRSP)" ; VEN/SMH - Modified -- added HTTPRSP per http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.2.2
 . I $L(LOCATION) S HTTPREQ("location")=$S($D(HTTPREQ("header","host")):"https://"_HTTPREQ("header","host")_LOCATION,1:LOCATION)
 E  D @(ROUTINE_"(.HTTPRSP,.HTTPARGS)")
 Q
QSPLIT(QUERY) ; parses and decodes query fragment into array
 ; expects HTTPREQ to contain "query" node
 ; .QUERY will contain query parameters as subscripts: QUERY("name")=value
 N I,X,NAME,VALUE
 F I=1:1:$L(HTTPREQ("query"),"&") D
 . S X=$$URLDEC^VPRJRUT($P(HTTPREQ("query"),"&",I))
 . S NAME=$P(X,"="),VALUE=$P(X,"=",2,999)
 . I $L(NAME) S QUERY($$LOW^VPRJRUT(NAME))=VALUE
 Q
MATCH(ROUTINE,ARGS) ; evaluate paths in sequence until match found (else 404)
 ; Also does authentication and authorization
 ; TODO: this needs some work so that it will accomodate patterns shorter than the path
 ; expects HTTPREQ to contain "path" and "method" nodes
 ; ROUTINE contains the TAG^ROUTINE to execute for this path, otherwise empty
 ; .ARGS will contain an array of resolved path arguments
 ;
 N AUTHNODE ; Authentication and Authorization node
 ;
 S ROUTINE=""  ; Default. Routine not found. Error 404.
 ;
 ; If we have the %W file for mapping...
 IF $D(^%W(17.6001)) DO MATCHF(.ROUTINE,.ARGS,.AUTHNODE) 
 ;
 ; Using built-in table if routine is still empty.
 I ROUTINE="" DO MATCHR(.ROUTINE,.ARGS)
 ;
 ; Okay. Do we have a routine to execute?
 I ROUTINE="" D SETERROR^VPRJRUT(404,"Not Found") QUIT
 ;
 I +$G(AUTHNODE) D  ; Web Service has authorization node
 . ;
 . ; If there is no File 200, forget the whole thing. Pretend it didn't happen.
 . I '$D(^VA(200)) QUIT
 . ;
 . ; First, user must authenticate
 . S HTTPRSP("auth")="Basic realm="""_HTTPREQ("header","host")_"""" ; Send Authentication Header
 . N AUTHEN S AUTHEN=$$AUTHEN($G(HTTPREQ("header","authorization"))) ; Try to authenticate
 . I 'AUTHEN D SETERROR^VPRJRUT(401) QUIT  ; Unauthoirzed
 . ;
 . ; DEBUG.ASSERT that DUZ is greater than 0
 . I $G(DUZ)'>0 S $EC=",U-NO-DUZ,"
 . ;
 . ; Then user must have security key
 . N KEY S KEY=$P(AUTHNODE,"^",2)    ; Get Key pointer
 . I KEY S KEY=$P($G(^DIC(19.1,KEY,0)),"^") ; Get Key name from Security Key file
 . I $L(KEY),'$D(^XUSEC(KEY,DUZ)) D SETERROR^VPRJRUT(405,"Missing security key "_KEY) QUIT  ; Method not allowed
 . K KEY
 . ;
 . ; And not have reverse security key
 . N RKEY S RKEY=$P(AUTHNODE,"^",3)  ; Get Key pointer
 . I RKEY S RKEY=$P($G(^DIC(19.1,RKEY,0)),"^") ; Get Reverse Key name from Security Key file
 . I $L(RKEY),$D(^XUSEC(RKEY,DUZ)) D SETERROR^VPRJRUT(405,"Holding exclusive key "_RKEY) QUIT  ; Method not allowed
 . K RKEY
 . ;
 . ; And have access to the menu option indicated
 . N OPTION S OPTION=$P(AUTHNODE,"^",4)  ; Get Option pointer
 . I OPTION N OPTIONNM S OPTIONNM=$P($G(^DIC(19,OPTION,0)),"^") ; Get Option name from Option file
 . I OPTION,$L($T(ACCESS^XQCHK)),'$$ACCESS^XQCHK(DUZ,OPTION) D SETERROR^VPRJRUT(405,"No access to option "_OPTIONNM)  ; Method not allowed
 . K OPTION,OPTIONNM
 QUIT
 ;
 ;
MATCHF(ROUTINE,ARGS,AUTHNODE) ; Match against a file...
 ; ^%W(17.6001,"B","GET","xml"
 N PATH S PATH=HTTPREQ("path")
 S:$E(PATH)="/" PATH=$E(PATH,2,$L(PATH))
 ;
 N DONE S DONE=0
 N PATH1 S PATH1=$$URLDEC^VPRJRUT($P(PATH,"/",1),1) ; get first / piece of path; and decode.
 N PATTERN S PATTERN=PATH1  ; looper variable; start at first piece of path.
 I $D(^%W(17.6001,"B",HTTPREQ("method"),PATTERN)) D  ; if path isn't just a simple full path that already exists
 . S ROUTINE=$O(^%W(17.6001,"B",HTTPREQ("method"),PATTERN,""))
 E  D
 . ; Loop through patterns. Start with first piece of path. quit if $order took us off the deep end.
 . F  S PATTERN=$O(^%W(17.6001,"B",HTTPREQ("method"),PATTERN)) Q:PATTERN=""  Q:PATH1'=$E(PATTERN,1,$L(PATH1))  D  Q:DONE
 . . ;
 . . ; TODO: only matches 1st piece then *. Second piece can be different.
 . . N I F I=2:1:$L(PATTERN,"/") D
 . . . N PATTSEG S PATTSEG=$$URLDEC^VPRJRUT($P(PATTERN,"/",I),1) ; pattern Segment url-decoded
 . . . I PATTSEG="*" S ARGS("*")=$P(PATH,"/",I,999) QUIT
 . . ;
 . . I $D(ARGS("*")) S DONE=1 QUIT  ; We are done if we found the *
 . . ;
 . . I $L(PATTERN,"/")'=$L(PATH,"/") QUIT  ; not the same number of pieces; quit.
 . . K ARGS
 . . N FAIL S FAIL=0
 . . N I F I=2:1:$L(PATH,"/") D  Q:FAIL  ; we have matched the first piece; now, do every piece after that.
 . . . N PATHSEG S PATHSEG=$$URLDEC^VPRJRUT($P(PATH,"/",I),1)  ; Path Segment url-decoded
 . . . N PATTSEG S PATTSEG=$$URLDEC^VPRJRUT($P(PATTERN,"/",I),1) ; pattern Segment url-decoded
 . . . I $E(PATTSEG)'="{" S FAIL=($$LOW^VPRJRUT(PATHSEG)'=$$LOW^VPRJRUT(PATTSEG)) Q  ; if not mumps pattern, just string equality
 . . . S PATTSEG=$E(PATTSEG,2,$L(PATTSEG)-1) ; else, extract pattern by getting rid of curly braces
 . . . N ARGUMENT,TEXT S ARGUMENT=$P(PATTSEG,"?"),TEST=$P(PATTSEG,"?",2) ; get pattern match
 . . . I $L(TEST) S FAIL=(PATHSEG'?@TEST) Q:FAIL  ; run pattern match
 . . . S ARGS(ARGUMENT)=PATHSEG  ; if pattern matches, put into arguments hopper.
 . . ;
 . . Q:FAIL  ; last loop failed to find a match
 . . ;
 . . ; At this point, none of the stuff failed. We can tell the initial loop that we are done.
 . . S DONE=1
 Q:PATH1'=$E(PATTERN,1,$L(PATH1))
 S ROUTINE=$O(^%W(17.6001,"B",HTTPREQ("method"),PATTERN,""))
 N IEN S IEN=$O(^%W(17.6001,"B",HTTPREQ("method"),PATTERN,ROUTINE,""))
 S AUTHNODE=$G(^%W(17.6001,IEN,"AUTH"))
 QUIT
 ;
 ;
 ;
MATCHR(ROUTINE,ARGS) ; Match against this routine
 N PATH S PATH=HTTPREQ("path")
 S:$E(PATH)="/" PATH=$E(PATH,2,$L(PATH))
 N SEQ,METHOD
 N DONE S DONE=0
 F SEQ=1:1 S PATTERN=$P($T(URLMAP+SEQ),";;",2,99) Q:PATTERN="zzzzz"  D  Q:DONE
 . K ARGS
 . S ROUTINE=$P(PATTERN," ",3),METHOD=$P(PATTERN," "),PATTERN=$P(PATTERN," ",2),FAIL=0
 . I $L(PATTERN,"/")'=$L(PATH,"/") S ROUTINE="" Q  ; must have same number segments
 . F I=1:1:$L(PATH,"/") D  Q:FAIL
 . . S PATHSEG=$$URLDEC^VPRJRUT($P(PATH,"/",I),1)
 . . S PATTSEG=$$URLDEC^VPRJRUT($P(PATTERN,"/",I),1)
 . . I $E(PATTSEG)'="{" S FAIL=($$LOW^VPRJRUT(PATHSEG)'=$$LOW^VPRJRUT(PATTSEG)) Q
 . . S PATTSEG=$E(PATTSEG,2,$L(PATTSEG)-1) ; get rid of curly braces
 . . S ARGUMENT=$P(PATTSEG,"?"),TEST=$P(PATTSEG,"?",2)
 . . I $L(TEST) S FAIL=(PATHSEG'?@TEST) Q:FAIL
 . . S ARGS(ARGUMENT)=PATHSEG
 . I 'FAIL I METHOD'=HTTPREQ("method") S FAIL=1
 . S:FAIL ROUTINE="" S:'FAIL DONE=1
 QUIT
 ;
 ;
 ;
SENDATA ; write out the data as an HTTP response
 ; expects HTTPERR to contain the HTTP error code, if any
 ; RSPTYPE=1  local variable
 ; RSPTYPE=2  data in ^TMP($J)
 ; RSPTYPE=3  pageable data in ^TMP($J,"data") or ^VPRTMP(hash,"data")
 ;
 N %WBUFF S %WBUFF="" ; Write Buffer
 ;
 ; DKM - Send raw data.
 I $G(HTTPRSP("raw")) D  Q
 . N ARY,X,L
 . S ARY=$NA(@HTTPRSP),X=ARY,L=$QL(ARY)
 . F  S X=$Q(@X) Q:'$L(X)  Q:$NA(@X,L)'=ARY  D W(@X)
 . D FLUSH
 . K @ARY
 N SIZE,RSPTYPE,PREAMBLE,START,LIMIT
 S RSPTYPE=$S($E($G(HTTPRSP))'="^":1,$D(HTTPRSP("pageable")):3,1:2)
 I RSPTYPE=1 S SIZE=$$VARSIZE^VPRJRUT(.HTTPRSP)
 I RSPTYPE=2 S SIZE=$$REFSIZE^VPRJRUT(.HTTPRSP)
 I RSPTYPE=3 D
 . S START=$P(HTTPREQ("paging"),":"),LIMIT=$P(HTTPREQ("paging"),":",2)
 . D PAGE^VPRJRUT(.HTTPRSP,START,LIMIT,.SIZE,.PREAMBLE)
 ;
 ; TODO: Handle HEAD requests differently
 ;       (put HTTPRSP in ^XTMP and return appropriate header)
 ; TODO: Handle 201 responses differently (change simple OK to created)
 ;
 D W($$RSPLINE()_$C(13,10)) ; Status Line (200, 404, etc)
 D W("Date: "_$$GMT^VPRJRUT_$C(13,10)) ; RFC 1123 date
 I $D(HTTPREQ("location")) D W("Location: "_HTTPREQ("location")_$C(13,10))  ; ?? Request location; TODO: Check this. Should be Response.
 I $D(HTTPRSP("auth")) D W("WWW-Authenticate: "_HTTPRSP("auth")_$C(13,10)) K HTTPRSP("auth") ; Authentication
 I $D(HTTPRSP("mime")) D  ; Stack $TEST for the ELSE below
 . D W("Content-Type: "_HTTPRSP("mime")_$C(13,10)) K HTTPRSP("mime") ; Mime-type
 E  D W("Content-Type: application/json; charset=utf-8"_$C(13,10))
 ;
 ; I +$SY=47,$G(HTTPREQ("header","accept-encoding"))["gzip" D GZIP QUIT  ; If on GT.M, and we can zip, let's do that!
 ;
 D W("Content-Length: "_SIZE_$C(13,10)_$C(13,10))
 I 'SIZE D FLUSH Q  ; flush buffer and quit if empty
 ;
 N I,J
 I RSPTYPE=1 D            ; write out local variable
 . I $D(HTTPRSP)#2 D W(HTTPRSP)
 . I $D(HTTPRSP)>1 S I=0 F  S I=$O(HTTPRSP(I)) Q:'I  D W(HTTPRSP(I))
 I RSPTYPE=2 D            ; write out global using indirection
 . I $D(@HTTPRSP)#2 D W(@HTTPRSP)
 . ; I $D(@HTTPRSP)>1 S I=0 F  S I=$O(@HTTPRSP@(I)) Q:'I  D W(@HTTPRSP@(I))
 . I $D(@HTTPRSP)>1 D
 . . N ORIG,OL S ORIG=HTTPRSP,OL=$QL(HTTPRSP) ; Orig, Orig Length
 . . ZSHOW "*":^KBANTEMP
 . . F  S HTTPRSP=$Q(@HTTPRSP) Q:(($G(HTTPRSP)="")!($NA(@HTTPRSP,OL)'=$NA(@ORIG,OL)))  D W(@HTTPRSP)
 . . S HTTPRSP=ORIG
 I RSPTYPE=3 D            ; write out pageable records
 . W PREAMBLE
 . F I=START:1:(START+LIMIT-1) Q:'$D(@HTTPRSP@($J,I))  D
 . . I I>START D W(",") ; separate items with a comma
 . . S J="" F  S J=$O(@HTTPRSP@($J,I,J)) Q:'J  D W(@HTTPRSP@($J,I,J))
 . D W("]}}")
 . K @HTTPRSP@($J)
 D FLUSH ; flush buffer
 ; W $C(13,10),!  ; flush buffer ; ****VEN/SMH NOT INCLUDED IN THE SIZE!!!
 I RSPTYPE=3,($E(HTTPRSP,1,4)="^TMP") D UPDCACHE
 Q
W(DATA) ; EP to write data
 ; ZEXCEPT: %WBUFF - Buffer in Symbol Table
 S %WBUFF=%WBUFF_DATA
 I $L(%WBUFF)>32000 D FLUSH
 QUIT
 ;
FLUSH ; EP to flush written data
 ; ZEXCEPT: %WBUFF - Buffer in Symbol Table
 W %WBUFF,!
 S %WBUFF=""
 QUIT
 ;
GZIP ; EP to write gzipped content -- unstable right now...
 ;
 ; Nothing to write?
 I 'SIZE D  QUIT  ; nothing to write!
 . W "Content-Length: 0"_$C(13,10,13,10)
 . W ! ; flush buffer
 ;
 ; zip away - Open gzip and write to it, then read back the zipped file.
 N OLDIO S OLDIO=$IO
 ; NB: Must have wrap,fixed,chset="M" for GT.M to read the data back as binary.
 O "D":(shell="/bin/sh":command="gzip -f":parse:wrap:fixed:chset="M")::"pipe" 
 U "D"
 ;
 ; Write out data
 N ZIPPED,C S C=1
 N I,J
 I RSPTYPE=1 D            ; write out local variable
 . I $D(HTTPRSP)#2 W HTTPRSP ; R ZIPPED(C):0 I  S C=C+1
 . I $D(HTTPRSP)>1 S I=0 F  S I=$O(HTTPRSP(I)) Q:'I  W HTTPRSP(I) R ZIPPED(C)#32767:0 S C=C+1
 I RSPTYPE=2 D            ; write out global using indirection
 . I $D(@HTTPRSP)#2 W @HTTPRSP ; R ZIPPED(C):0 I  S C=C+1
 . I $D(@HTTPRSP)>1 S I=0 F  S I=$O(@HTTPRSP@(I)) Q:'I  W @HTTPRSP@(I) ; R ZIPPED(C):0 I  S C=C+1
 I RSPTYPE=3 D            ; write out pageable records
 . W PREAMBLE
 . F I=START:1:(START+LIMIT-1) Q:'$D(@HTTPRSP@($J,I))  D
 . . I I>START W "," ; R ZIPPED(C):0 I  S C=C+1 ; separate items with a comma
 . . S J="" F  S J=$O(@HTTPRSP@($J,I,J)) Q:'J  W @HTTPRSP@($J,I,J) ; R ZIPPED(C):0 I  S C=C+1
 . W "]}}" ; R ZIPPED(C):0 I  S C=C+1
 . K @HTTPRSP@($J)
 ;
 ZSHOW "V":^KBANRPC1
 ; Tell gzip we are done.
 W /EOF
 ;
 ; Read back
 F  R ZIPPED(C)#32767 Q:$ZEOF  S C=C+1
 ;
 ; Close
 U OLDIO C "D"
 ; 
 ; Calculate new size (reset SIZE first)
 S SIZE=0 
 N I F I=0:0 S I=$O(ZIPPED(I)) Q:'I  S SIZE=SIZE+$L(ZIPPED(I))
 ;
 ; Write out the content headings for gzipped file.
 W "Content-Encoding: gzip"_$C(13,10)
 W "Content-Length: "_SIZE_$C(13,10)_$C(13,10)
 N I F I=0:0 S I=$O(ZIPPED(I)) Q:'I  W ZIPPED(I)
 W !
 ;
 ZSHOW "V":^KBANRPC2
 ; House keeping.
 I RSPTYPE=3,($E(HTTPRSP,1,4)="^TMP") D UPDCACHE
 QUIT
 ;
UPDCACHE ; update the cache for this query
 I HTTPREQ("store")="data" G UPD4DATA
UPD4VPR ;
 N PID,INDEX,HASH,HASHTS,MTHD
 S PID=$G(^TMP($J,"pid")),INDEX=$G(^TMP($J,"index"))
 S HASH=$G(^TMP($J,"hash")),HASHTS=$G(^TMP($J,"timestamp"))
 Q:'$L(PID)  Q:'$L(INDEX)  Q:'$L(HASH)
 ;
 S MTHD=$G(^VPRMETA("index",INDEX,"common","method"))
 L +^VPRTMP(HASH):1  E  Q
 I $G(^VPRPTI(PID,MTHD,INDEX))=HASHTS D
 . K ^VPRTMP(HASH)
 . M ^VPRTMP(HASH)=^TMP($J)
 . S ^VPRTMP(HASH,"created")=$H
 . S ^VPRTMP("PID",PID,HASH)=""
 L -^VPRTMP(HASH)
 Q
UPD4DATA ;
 N INDEX,HASH,HASHTS,MTHD
 S INDEX=$G(^TMP($J,"index"))
 S HASH=$G(^TMP($J,"hash")),HASHTS=$G(^TMP($J,"timestamp"))
 Q:'$L(INDEX)  Q:'$L(HASH)
 ;
 S MTHD=$G(^VPRJMETA("index",INDEX,"common","method"))
 L +^VPRTMP(HASH):1  E  Q
 I $G(^VPRJDX(MTHD,INDEX))=HASHTS D
 . K ^VPRTMP(HASH)
 . M ^VPRTMP(HASH)=^TMP($J)
 . S ^VPRTMP(HASH,"created")=$H
 L -^VPRTMP(HASH)
 Q
RSPERROR ; set response to be an error response
 D ENCODE^VPRJSON("^TMP(""HTTPERR"",$J,1)","^TMP(""HTTPERR"",$J,""JSON"")")
 S HTTPRSP="^TMP(""HTTPERR"",$J,""JSON"")"
 K HTTPRSP("pageable")
 Q
RSPLINE() ; writes out a response line based on HTTPERR
 ; VEN/SMH: TODO: There ought to be a simpler way to do this!!!
 I '$G(HTTPERR),'$D(HTTPREQ("location")) Q "HTTP/1.1 200 OK"
 I '$G(HTTPERR),$D(HTTPREQ("location")) Q "HTTP/1.1 201 Created"
 I $G(HTTPERR)=400 Q "HTTP/1.1 400 Bad Request"
 I $G(HTTPERR)=401 Q "HTTP/1.1 401 Unauthorized"
 I $G(HTTPERR)=404 Q "HTTP/1.1 404 Not Found"
 I $G(HTTPERR)=405 Q "HTTP/1.1 405 Method Not Allowed"
 Q "HTTP/1.1 500 Internal Server Error"
 ;
PING(RESULT,ARGS) ; writes out a ping response
 S RESULT="{""status"":"""_$J_" running""}"
 Q
XML(RESULT,ARGS) ; text XML
 S HTTPRSP("mime")="text/xml"
 S RESULT=$NA(^TMP($J))
 S ^TMP($J,1)="<?xml version=""1.0"" encoding=""UTF-8""?>"
 S ^TMP($J,2)="<note>"
 S ^TMP($J,3)="<to>Tovaniannnn</to>"
 S ^TMP($J,4)="<from>Jani</from>"
 S ^TMP($J,5)="<heading>Remindersss</heading>"
 S ^TMP($J,6)="<body>Don't forget me this weekend!</body>"
 S ^TMP($J,7)="</note>"
 QUIT
VPRMATCH(ROUTINE,ARGS) ; specific algorithm for matching URL's
 Q
URLMAP ; map URLs to entry points (HTTP methods handled within entry point)
 ;;POST vpr/{pid?1.N} PUTOBJ^VPRJPR
 ;;PUT vpr/{pid?1.N} PUTOBJ^VPRJPR
 ;;GET vpr/{pid?1.N}/index/{indexName} INDEX^VPRJPR
 ;;GET vpr/{pid?1.N}/index/{indexName}/{template} INDEX^VPRJPR
 ;;GET vpr/{pid?1.N}/count/{countName} COUNT^VPRJPR
 ;;GET vpr/{pid?1.N}/last/{indexName} LAST^VPRJPR
 ;;GET vpr/{pid?1.N}/last/{indexName}/{template} LAST^VPRJPR
 ;;GET vpr/{pid?1.N}/{uid?1"urn:".E} GETOBJ^VPRJPR
 ;;GET vpr/{pid?1.N}/{uid?1"urn:".E}/{template} GETOBJ^VPRJPR
 ;;GET vpr/{pid?1.N}/find/{collection} FIND^VPRJPR
 ;;GET vpr/{pid?1.N}/find/{collection}/{template} FIND^VPRJPR
 ;;GET vpr/{pid?1.N} GETPT^VPRJPR
 ;;GET vpr/uid/{uid?1"urn:".E} GETUID^VPRJPR
 ;;GET vpr/uid/{uid?1"urn:".E}/{template} GETUID^VPRJPR
 ;;POST vpr PUTPT^VPRJPR
 ;;PUT vpr PUTPT^VPRJPR
 ;;GET vpr/all/count/{countName} ALLCOUNT^VPRJPR
 ;;GET vpr/all/index/{indexName} ALLINDEX^VPRJPR
 ;;GET vpr/all/index/{indexName}/{template} ALLINDEX^VPRJPR
 ;;GET vpr/all/find/{collection} ALLFIND^VPRJPR
 ;;GET vpr/all/find/{collection}/{template} ALLFIND^VPRJPR
 ;;GET vpr/pid/{icndfn} PID^VPRJPR
 ;;DELETE vpr/{pid?1.N}/{uid?1"urn:".E} DELUID^VPRJPR
 ;;DELETE vpr/uid/{uid?1"urn:".E} DELUID^VPRJPR
 ;;DELETE vpr/{pid?1.N} DELPT^VPRJPR
 ;;DELETE vpr DELALL^VPRJPR
 ;;DELETE vpr/{pid?1.N}/collection/{collectionName} DELCOLL^VPRJPR
 ;;DELETE vpr/all/collection/{collectionName} ALLDELC^VPRJPR
 ;;POST data PUTOBJ^VPRJDR
 ;;PUT data PUTOBJ^VPRJDR
 ;;PUT data/{collectionName} NEWOBJ^VPRJDR
 ;;POST data/{collectionName} NEWOBJ^VPRJDR
 ;;GET data/{uid?1"urn:".E} GETOBJ^VPRJDR
 ;;GET data/index/{indexName} INDEX^VPRJDR
 ;;GET data/last/{indexName} LAST^VPRJDR
 ;;GET data/count/{countName} COUNT^VPRJDR
 ;;GET data/find/{collection} FIND^VPRJDR
 ;;GET data/find/{collection}/{template} FIND^VPRJDR
 ;;DELETE data/{uid?1"urn:".E} DELUID^VPRJDR
 ;;DELETE data/collection/{collectionName} DELCTN^VPRJDR
 ;;DELETE data DELALL^VPRJDR
 ;;GET ping PING^VPRJRSP
 ;;zzzzz
 Q
 ;
AUTHEN(HTTPAUTH) ; Authenticate User against VISTA from HTTP Authorization Header
 ;
 ; We only support Basic authentication right now
 N P1,P2 S P1=$P(HTTPAUTH," "),P2=$P(HTTPAUTH," ",2)
 I $$UP^VPRJRUT(P1)'="BASIC" Q 0 ; We don't support that authentication
 ;
 ; Decode Base64 encoded un:pwd
 N ACVC S ACVC=$$DECODE64^VPRJRUT(P2)
 S ACVC=$TR(ACVC,":",";") ; switch the : so that it's now ac;vc
 ; TODO: Check if there is more than one colon in the ACVC
 ;
 ; Sign-on
 N IO S IO=$P
 D SETUP^XUSRB() ; Only partition set-up; No single sign-on or CAPRI
 N RTN D VALIDAV^XUSRB(.RTN,$$ENCRYP^XUSRB1(ACVC)) ; sign-on call
 I RTN(0)>0,'RTN(2) Q 1 ; Sign on successful!
 I RTN(0)=0,RTN(2) Q 0  ; Verify Code must be changed NOW!
 I $L(RTN(3)) Q 0  ; Error Message
 ;
 ; TODO: Division Selection
 QUIT 0
