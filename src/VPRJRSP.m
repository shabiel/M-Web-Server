VPRJRSP ;SLC/KCM -- Handle HTTP Response;2019-01-18  3:57 PM
 ;;1.0;JSON DATA STORE;;Sep 01, 2012
 ;
 ; -- prepare and send RESPONSE
 ;
RESPOND ; find entry point to handle request and call it
 ; expects HTTPREQ, HTTPRSP is used to return the response
 ;
 ; TODO: check cache of HEAD requests first and return that if there?
 K:'$G(NOGBL) ^TMP($J)
 N ROUTINE,LOCATION,HTTPARGS,HTTPBODY,PARAMS,RTNARGTYPES
 I HTTPREQ("path")="/",HTTPREQ("method")="GET" D EN^%WHOME(.HTTPRSP) QUIT  ; Home page requested.
 ;
 ; Resolve the URL and authenticate if necessary
 D MATCH(.ROUTINE,.HTTPARGS,.PARAMS) I $G(HTTPERR) QUIT
 ;
 ; Split the query string
 D QSPLIT(HTTPREQ("query"),.HTTPARGS) I $G(HTTPERR) QUIT
 ;
 ; %WNULL Support for VistA - Use this device to prevent VistA from writing to you.
 N %WNULL S %WNULL=""
 I +$SY=47 S %WNULL="/dev/null"
 I $L($SY,":")=2 D
 . I $ZVERSION(1)=2 s %WNULL="//./nul"
 . I $ZVERSION(1)=3 s %WNULL="/dev/null"
 I %WNULL="" S $EC=",U-OS-NOT-SUPPORTED,"
 O %WNULL U %WNULL
 ;
 N BODY
 N FORMPARAMS
 M BODY=HTTPREQ("body") K HTTPREQ("body")
 ;
 I '$D(PARAMS) D
 . I "PUT,POST"[HTTPREQ("method") D
 .. X "S LOCATION=$$"_ROUTINE_"(.HTTPARGS,.BODY,.HTTPRSP)"
 .. I $L(LOCATION) S HTTPREQ("location")=$S($D(HTTPREQ("header","host")):"https://"_HTTPREQ("header","host")_LOCATION,1:LOCATION)
 . E  D
 .. D @(ROUTINE_"(.HTTPRSP,.HTTPARGS)")
 E  D
 . N DYN
 . S DYN=ROUTINE_"("
 . S ITR=""
 . F  S AT=$O(RTNARGTYPES(ITR)) Q:AT=""  D
 . . S ITR=AT
 . . I $F(RTNARGTYPES(AT),"q:")=3 D
 . . . I $D(HTTPARGS($E(RTNARGTYPES(AT),3,$L(RTNARGTYPES(AT)))))=0 D  S HTTPERR=400 Q
 . . . X "S ARG"_AT_"="""_HTTPARGS($E(RTNARGTYPES(AT),3,$L(RTNARGTYPES(AT))))_""""
 . . . S DYN=DYN_"ARG"_AT_","
 . . I $F(RTNARGTYPES(AT),"h:")=3 D
 . . . I $D(HTTPREQ("header",$E(RTNARGTYPES(AT),3,$L(RTNARGTYPES(AT)))))=0 D  S HTTPERR=400 Q
 . . . X "S ARG"_AT_"="""_HTTPREQ("header",$E(RTNARGTYPES(AT),3,$L(RTNARGTYPES(AT))))_""""
 . . . S DYN=DYN_"ARG"_AT_","
 . . I $F(RTNARGTYPES(AT),"f:")=3 D
 . . . I $D(BODY)!10 D  S HTTPERR=400 Q
 . . . I HTTPREQ("header","content-type")["application/x-www-form-urlencoded" D
 . . . . N BSTR S BSTR=$$BODYASSTR(.BODY)
 . . . . D QSPLIT(BSTR,FORMPARAMS)
 . . . . S DYN=DYN_".FORMPARAMS,"
 . . . E  S HTTPERR=400 Q
 . . I $F(RTNARGTYPES(AT),"req:")=5 D
 . . . S DYN=DYN_".HTTPREQ,"
 . . I $F(RTNARGTYPES(AT),"res:")=5 D
 . . . S DYN=DYN_".HTTPRSP,"
 . . I $F(RTNARGTYPES(AT),"body:")=5 D
 . . . S DYN=DYN_".BODY,"
 . I $E(DYN,$L(DYN))="," D
 . . S DYN=$E(DYN,1,$L(DYN)-1)
 . S DYN=DYN_")"
 . X "S LOCATION=$$"_DYN
 ;
 ; Back to our original device
 C %WNULL U %WTCP
 Q
 ;
QSPLIT(QPARAMS,QUERY) ; parses and decodes query fragment into array
 ; expects QPARAMS to contain "query" node
 ; .QUERY will contain query parameters as subscripts: QUERY("name")=value
 N I,X,NAME,VALUE
 F I=1:1:$L(QPARAMS,"&") D
 . S X=$$URLDEC^VPRJRUT($P(QPARAMS,"&",I))
 . S NAME=$P(X,"="),VALUE=$P(X,"=",2,999)
 . I $L(NAME) S QUERY($$LOW^VPRJRUT(NAME))=VALUE
 Q
BODYASSTR(BODY)
 S BSTR=""
 S ITR=""
 F  S AT=$O(BODY(ITR)) Q:AT=""  D
 . S ITR=AT
 . S BSTR=BSTR_BODY(AT)
 Q BSTR
 ;
MATCH(ROUTINE,ARGS,PARAMS) ; evaluate paths in sequence until match found (else 404)
 ; Also does authentication and authorization
 ; TODO: this needs some work so that it will accomodate patterns shorter than the path
 ; expects HTTPREQ to contain "path" and "method" nodes
 ; ROUTINE contains the TAG^ROUTINE to execute for this path, otherwise empty
 ; .ARGS will contain an array of resolved path arguments
 ; .PARAMS will contain whether the routine should be called with the default argument structure of , it will either contain zero or the number of
 ;      default (no params specified)
 ;      		- PUT/POST (.HTTPARGS,.BODY,.HTTPRSP)
 ;      		- GET (.HTTPRSP,.HTTPARGS)
 ;       OR
 ;      		^%web(17.6001,3,"PARAMS",0)="q:p1"
 ;      		^%web(17.6001,3,"PARAMS",1)="f:p1"
 ;      		^%web(17.6001,3,"PARAMS",2)="h:p1"
 ;      		^%web(17.6001,3,"PARAMS",3)="req:"
 ;      		^%web(17.6001,3,"PARAMS",4)="res:"
 ;      		^%web(17.6001,3,"PARAMS",5)="body:"
 ;              extracting the arguments from the available list by type and then calling the routine with actual formal parameters instead
 ;              for eg,
 ;                      R1(qp1, fp1, hp1, cHTTPREQ, cHTTPRSP, body)
 ; .RTNARGTYPES will contain the type of argument, whether it is a query param, a header param, a form param, a body param or a context param (like request/response) 
 ;
 N AUTHNODE ; Authentication and Authorization node
 ;
 S ROUTINE=""  ; Default. Routine not found. Error 404.
 ;
 ; If we have the %W file for mapping...
 IF $D(^%web(17.6001)) DO MATCHF(.ROUTINE,.ARGS,.PARAMS,.AUTHNODE)
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
MATCHF(ROUTINE,ARGS,PARAMS,AUTHNODE) ; Match against a file...
 ; ^%web(17.6001,"B","GET","xml"
 N PATH S PATH=HTTPREQ("path")
 S:$E(PATH)="/" PATH=$E(PATH,2,$L(PATH))
 ;
 N DONE S DONE=0
 N PATH1 S PATH1=$$URLDEC^VPRJRUT($P(PATH,"/",1),1) ; get first / piece of path; and decode.
 N PATTERN S PATTERN=PATH1  ; looper variable; start at first piece of path.
 I $D(^%web(17.6001,"B",HTTPREQ("method"),PATTERN)) D  ; if path isn't just a simple full path that already exists
 . S ROUTINE=$O(^%web(17.6001,"B",HTTPREQ("method"),PATTERN,""))
 E  D
 . ; Loop through patterns. Start with first piece of path. quit if $order took us off the deep end.
 . F  S PATTERN=$O(^%web(17.6001,"B",HTTPREQ("method"),PATTERN)) Q:PATTERN=""  Q:PATH1'=$E(PATTERN,1,$L(PATH1))  D  Q:DONE
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
 S ROUTINE=$O(^%web(17.6001,"B",HTTPREQ("method"),PATTERN,""))
 N IEN S IEN=$O(^%web(17.6001,"B",HTTPREQ("method"),PATTERN,ROUTINE,""))
 I $O(^%web(17.6001,IEN,"PARAMS",0)) M PARAMS=^%web(17.6001,IEN,"PARAMS")
 S AUTHNODE=$G(^%web(17.6001,IEN,"AUTH"))
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
 I $D(HTTPREQ("location")) D W("Location: "_HTTPREQ("location")_$C(13,10))  ; Response Location
 I $D(HTTPRSP("auth")) D W("WWW-Authenticate: "_HTTPRSP("auth")_$C(13,10)) K HTTPRSP("auth") ; Authentication
 I $D(HTTPRSP("cache")) D W("Cache-Control: max-age="_HTTPRSP("cache")_$C(13,10)) K HTTPRSP("cache") ; Browser caching
 I $D(HTTPRSP("mime")) D  ; Stack $TEST for the ELSE below
 . D W("Content-Type: "_HTTPRSP("mime")_$C(13,10)) K HTTPRSP("mime") ; Mime-type
 E  D W("Content-Type: application/json; charset=utf-8"_$C(13,10))
 ;
 I +$SY=47,$G(HTTPREQ("header","accept-encoding"))["gzip" GOTO GZIP  ; If on GT.M, and we can zip, let's do that!
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
 . . N HTTPEXIT S HTTPEXIT=0
 . . F  D  Q:HTTPEXIT
 . . . S HTTPRSP=$Q(@HTTPRSP)
 . . . D:$G(HTTPRSP)'="" W(@HTTPRSP)
 . . . I $G(HTTPRSP)="" S HTTPEXIT=1
 . . . E  I $G(@HTTPRSP),$G(@ORIG),$NA(@HTTPRSP,OL)'=$NA(@ORIG,OL) S HTTPEXIT=1
 . . ; End ~ vertical rewrite
 . . S HTTPRSP=ORIG
 D FLUSH ; flush buffer
 Q
 ;
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
 ; Nothing to write?
 I 'SIZE D  QUIT  ; nothing to write!
 . W "Content-Length: 0"_$C(13,10,13,10)
 . W ! ; flush buffer
 ;
 ; zip away - Open gzip and write to it, then read back the zipped file.
 N OLDIO S OLDIO=$IO
 n file
 i $ZV["Linux" s file="/dev/shm/mws-"_$J_"-"_$R(999999)_".dat"
 e  s file="/tmp/mws-"_$J_"-"_$R(999999)_".dat"
 o file:(newversion:stream:nowrap)
 u file
 ;
 ; Write out data
 N I,J
 I RSPTYPE=1 D            ; write out local variable
 . I $D(HTTPRSP)#2 W HTTPRSP
 . I $D(HTTPRSP)>1 S I=0 F  S I=$O(HTTPRSP(I)) Q:'I  W HTTPRSP(I)
 I RSPTYPE=2 D            ; write out global using indirection
 . I $D(@HTTPRSP)#2 W @HTTPRSP
 . I $D(@HTTPRSP)>1 S I=0 F  S I=$O(@HTTPRSP@(I)) Q:'I  W @HTTPRSP@(I)
 ;
 ; Close
 c file
 ;
 O "D":(shell="/bin/sh":command="gzip "_file:parse):0:"pipe"
 U "D" C "D"
 ;
 n ZIPPED
 o file_".gz":(readonly:fixed:nowrap:recordsize=255:chset="M"):0
 u file_".gz"
 n i f i=1:1 read ZIPPED(i):0  q:$zeof
 U OLDIO c file_".gz":delete
 ;
 ; Calculate new size (reset SIZE first)
 S SIZE=0
 N I F I=0:0 S I=$O(ZIPPED(I)) Q:'I  S SIZE=SIZE+$L(ZIPPED(I))
 ;
 ; Write out the content headings for gzipped file.
 D W("Content-Encoding: gzip"_$C(13,10))
 D W("Content-Length: "_SIZE_$C(13,10)_$C(13,10))
 N I F I=0:0 S I=$O(ZIPPED(I)) Q:'I  D W(ZIPPED(I))
 D FLUSH
 ;
 QUIT
 ;
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
 ;
URLMAP ; map URLs to entry points (HTTP methods handled within entry point)
 ;;GET ping PING^VPRJRSP
 ;;zzzzz
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
