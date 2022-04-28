%webrsp ;SLC/KCM -- Handle HTTP Response;Jun 20, 2022@14:47
 ;
 ; -- prepare and send RESPONSE
 ;
RESPOND ; find entry point to handle request and call it
 ; expects HTTPREQ, HTTPRSP is used to return the response
 ;
 K:'$G(NOGBL) ^TMP($J)
 N ROUTINE,LOCATION,HTTPARGS,HTTPBODY,PARAMS,AUTHNODE
 I HTTPREQ("path")="/",HTTPREQ("method")="GET" D en^%webhome(.HTTPRSP) QUIT  ; Home page requested.
 I HTTPREQ("method")="OPTIONS" S HTTPRSP="OPTIONS,POST" QUIT ; Always repond to OPTIONS to give CORS header info
 ;
 ; Resolve the URL and authenticate if necessary
 D MATCH(.ROUTINE,.HTTPARGS,.PARAMS,.AUTHNODE)
 ;
 I $G(HTTPERR)    QUIT  ; Error in matching
 I $O(HTTPRSP(0)) QUIT  ; File on file system found matching path
 ;
 ; Split the query string
 D QSPLIT(HTTPREQ("query"),.HTTPARGS) I $G(HTTPERR) QUIT
 ;
 ; %WNULL Support for VistA - Use this device to prevent VistA from writing to you.
 N %WNULL S %WNULL=""
 I $P($SY,",")=47 S %WNULL="/dev/null"
 I $L($SY,":")=2 D
 . I $ZVERSION(1)=2 s %WNULL="//./nul"
 . I $ZVERSION(1)=3 s %WNULL="/dev/null"
 I %WNULL="" S $EC=",U-OS-NOT-SUPPORTED,"
 O %WNULL U %WNULL
 ;
 N BODY M BODY=HTTPREQ("body") K HTTPREQ("body")
 ;
 ; r will contain the routine to execute
 n r,order
 ;
 ; No parameters, do it the original way
 if '$D(PARAMS) D
 . if "PUT,POST"[HTTPREQ("method") set r=ROUTINE_"(.HTTPARGS,.BODY,.HTTPRSP)"
 . else  set r=ROUTINE_"(.HTTPRSP,.HTTPARGS)"
 ;
 ;
 ; Parameters, do it the new way
 else  s r=ROUTINE_"(.HTTPRSP," f order=0:0 s order=$O(PARAMS(order)) quit:'order  new @("a"_order) do  quit:$get(HTTPERR)
 . ; PARAMS(0)="^17.60012S^1^1"
 . ; PARAMS(1,0)="U^rpc"
 . ;
 . ; Set arguments into variables
 . n type s type=$p(PARAMS(order,0),"^",1)
 . n name s name=$p(PARAMS(order,0),"^",2)
 . n var  s var="a"_order
 . if type="U"!(type="Q") do  ; URL component or HTTP GET Query parameter
 .. set @var=$get(HTTPARGS(name))
 .. set r=r_var_","
 . if type="H" do  ; HTTP Header
 .. set @("a"_order)=$get(HTTPREQ("header",name))
 .. set r=r_var_","
 . if type="F" do  ; application/x-www-form-urlencoded form
 .. if BODY($order(BODY(0)))="" set HTTPERR=400 quit
 .. if $get(HTTPREQ("header","content-type"))'="application/x-www-form-urlencoded" set HTTPERR=400 quit
 .. new concatBody set concatBody=$$BODYASSTR(.BODY)
 .. new formParams do QSPLIT(concatBody,.formParams)
 .. set @var=$g(formParams(name))
 .. set r=r_var_","
 . if type="B" do  ; whole body
 .. set r=r_".BODY"_","
 . ;
 . ; replace trailing comma with close paran
 if $extract(r,$l(r))="," set $extract(r,$l(r))=")"
 ;
 if "PUT,POST"[HTTPREQ("method") xecute "S LOCATION=$$"_r if 1
 else  do @r
 ;
 if $get(LOCATION)'="" do
 . S HTTPREQ("location")=$S($D(HTTPREQ("header","host")):HTTPREQ("header","host")_LOCATION,1:LOCATION)
 . if $get(TLSCONFIG)'="" set HTTPREQ("location")="https://"_HTTPREQ("location")
 . else                   set HTTPREQ("location")="http://"_HTTPREQ("location")
 ;
 ; Back to our original device
 C %WNULL U %WTCP
 ;
 Q
 ;
QSPLIT(QPARAMS,QUERY) ; parses and decodes query fragment into array
 ; expects QPARAMS to contain "query" node
 ; .QUERY will contain query parameters as subscripts: QUERY("name")=value
 N I,X,NAME,VALUE
 F I=1:1:$L(QPARAMS,"&") D
 . S X=$$URLDEC^%webutils($P(QPARAMS,"&",I))
 . S NAME=$P(X,"="),VALUE=$P(X,"=",2,999)
 . I $L(NAME) S QUERY($$LOW^%webutils(NAME))=VALUE
 Q
BODYASSTR(BODY)
 N BSTR S BSTR=""
 N AT F AT=0:0 S AT=$O(BODY(AT)) Q:'AT  S BSTR=BSTR_BODY(AT)
 Q BSTR
 ;
MATCH(ROUTINE,ARGS,PARAMS,AUTHNODE) ; evaluate paths in sequence until match found (else 404)
 ; Also does authentication and authorization
 ; TODO: this needs some work so that it will accomodate patterns shorter than the path
 ; expects HTTPREQ to contain "path" and "method" nodes
 ; ROUTINE contains the TAG^ROUTINE to execute for this path, otherwise empty
 ; .ARGS will contain an array of resolved path arguments
 ; .PARAMS will contain whether the routine should be called with the default
 ;  argument structure of , it will either contain zero or the number of
 ;      default (no params specified)
 ;                      - PUT/POST (.HTTPARGS,.BODY,.HTTPRSP)
 ;                      - GET (.HTTPRSP,.HTTPARGS)
 ;
 S ROUTINE=""  ; Default. Routine not found. Error 404.
 ;
 ; If we have the %W file for mapping...
 IF ('$G(NOGBL)),$D(^%web(17.6001)) DO MATCHF(.ROUTINE,.ARGS,.PARAMS,.AUTHNODE)
 ;
 ; Using built-in table if routine is still empty.
 I ROUTINE="" DO MATCHR(.ROUTINE,.ARGS)
 ;
 I $L($T(^SYNRGSHM))>0 D  ; RGNet DHP Shim
 . Q:'$D(^RGNET)
 . DO MATCHRG^SYNRGSHM(.ROUTINE,.ARGS,.AUTHNODE)
 ;
 ; If both of these fail, try matching against a file on the file system
 I ROUTINE="" DO MATCHFS(.ROUTINE)
 ;
 ; Okay. Do we have a routine to execute?
 I ROUTINE="" D SETERROR^%webutils(404,"Not Found") QUIT
 ;
 I $L($G(USERPASS)) S AUTHNODE=1
 I +$G(AUTHNODE) D  ; Web Service has authorization node
 . ;
 . I $L($G(USERPASS)) D  QUIT
 . . ; First, user must authenticate
 . . S HTTPRSP("auth")="Basic realm="""_HTTPREQ("header","host")_"""" ; Send Authentication Header
 . . N AUTHEN S AUTHEN=(USERPASS=$$DECODE64^%webutils($P($G(HTTPREQ("header","authorization"))," ",2))) ; Try to authenticate
 . . I 'AUTHEN D SETERROR^%webutils(401) QUIT  ; Unauthoirzed
 . ;
 . ; If there is no File 200, forget the whole thing. Pretend it didn't happen.
 . I '$D(^VA(200)) QUIT
 . ;
 . ; First, user must authenticate
 . S HTTPRSP("auth")="Basic realm="""_HTTPREQ("header","host")_"""" ; Send Authentication Header
 . N AUTHEN S AUTHEN=$$AUTHEN($G(HTTPREQ("header","authorization"))) ; Try to authenticate
 . I 'AUTHEN D SETERROR^%webutils(401) QUIT  ; Unauthoirzed
 . ;
 . ; DEBUG.ASSERT that DUZ is greater than 0
 . I $G(DUZ)'>0 S $EC=",U-NO-DUZ,"
 . ;
 . ; Then user must have security key
 . N KEY S KEY=$P(AUTHNODE,"^",2)    ; Get Key pointer
 . I KEY S KEY=$P($G(^DIC(19.1,KEY,0)),"^") ; Get Key name from Security Key file
 . I $L(KEY),'$D(^XUSEC(KEY,DUZ)) D SETERROR^%webutils(405,"Missing security key "_KEY) QUIT  ; Method not allowed
 . K KEY
 . ;
 . ; And not have reverse security key
 . N RKEY S RKEY=$P(AUTHNODE,"^",3)  ; Get Key pointer
 . I RKEY S RKEY=$P($G(^DIC(19.1,RKEY,0)),"^") ; Get Reverse Key name from Security Key file
 . I $L(RKEY),$D(^XUSEC(RKEY,DUZ)) D SETERROR^%webutils(405,"Holding exclusive key "_RKEY) QUIT  ; Method not allowed
 . K RKEY
 . ;
 . ; And have access to the menu option indicated
 . N OPTION S OPTION=$P(AUTHNODE,"^",4)  ; Get Option pointer
 . I OPTION N OPTIONNM S OPTIONNM=$P($G(^DIC(19,OPTION,0)),"^") ; Get Option name from Option file
 . I OPTION,$L($T(ACCESS^XQCHK)),'$$ACCESS^XQCHK(DUZ,OPTION) D SETERROR^%webutils(405,"No access to option "_OPTIONNM)  ; Method not allowed
 . K OPTION,OPTIONNM
 QUIT
 ;
 ;
MATCHF(ROUTINE,ARGS,PARAMS,AUTHNODE) ; Match against a file...
 ; ^%web(17.6001,"B","GET","xml"
 N PATH S PATH=HTTPREQ("path")
 S:$E(PATH)="/" PATH=$E(PATH,2,$L(PATH))
 ;
 N METHOD S METHOD=HTTPREQ("method")
 I METHOD="HEAD" S METHOD="GET" ; just for here
 ;
 N DONE S DONE=0
 N PATH1 S PATH1=$$URLDEC^%webutils($P(PATH,"/",1),1) ; get first / piece of path; and decode.
 N PATTERN S PATTERN=PATH1  ; looper variable; start at first piece of path.
 I $D(^%web(17.6001,"B",METHOD,PATTERN)) D  ; if path isn't just a simple full path that already exists
 . S ROUTINE=$O(^%web(17.6001,"B",METHOD,PATTERN,""))
 E  D
 . ; Loop through patterns. Start with first piece of path. quit if $order took us off the deep end.
 . F  S PATTERN=$O(^%web(17.6001,"B",METHOD,PATTERN)) Q:PATTERN=""  Q:PATH1'=$E(PATTERN,1,$L(PATH1))  D  Q:DONE
 . . ;
 . . I $E(PATTERN)="/" S PATTERN=$E(PATTERN,2,$L(PATTERN))
 . . ;
 . . ; TODO: only matches 1st piece then *. Second piece can be different.
 . . N I F I=2:1:$L(PATTERN,"/") D
 . . . N PATTSEG S PATTSEG=$$URLDEC^%webutils($P(PATTERN,"/",I),1) ; pattern Segment url-decoded
 . . . I PATTSEG="*" S ARGS("*")=$P(PATH,"/",I,999) QUIT
 . . ;
 . . I $D(ARGS("*")) S DONE=1 QUIT  ; We are done if we found the *
 . . ;
 . . I $L(PATTERN,"/")'=$L(PATH,"/") QUIT  ; not the same number of pieces; quit.
 . . K ARGS
 . . N FAIL S FAIL=0
 . . N I F I=2:1:$L(PATH,"/") D  Q:FAIL  ; we have matched the first piece; now, do every piece after that.
 . . . N PATHSEG S PATHSEG=$$URLDEC^%webutils($P(PATH,"/",I),1)  ; Path Segment url-decoded
 . . . N PATTSEG S PATTSEG=$$URLDEC^%webutils($P(PATTERN,"/",I),1) ; pattern Segment url-decoded
 . . . I $E(PATTSEG)'="{" S FAIL=($$LOW^%webutils(PATHSEG)'=$$LOW^%webutils(PATTSEG)) Q  ; if not mumps pattern, just string equality
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
 S ROUTINE=$O(^%web(17.6001,"B",METHOD,PATTERN,""))
 N IEN S IEN=$O(^%web(17.6001,"B",METHOD,PATTERN,ROUTINE,""))
 I $O(^%web(17.6001,IEN,"PARAMS",0)) M PARAMS=^%web(17.6001,IEN,"PARAMS")
 S AUTHNODE=$G(^%web(17.6001,IEN,"AUTH"))
 QUIT
 ;
 ;
 ;
MATCHR(ROUTINE,ARGS) ; Match against this routine
 N METHOD S METHOD=HTTPREQ("method")
 I METHOD="HEAD" S METHOD="GET" ; just for here
 N PATH S PATH=HTTPREQ("path")
 S:$E(PATH)="/" PATH=$E(PATH,2,$L(PATH))
 N SEQ,PATMETHOD
 N DONE S DONE=0
 F SEQ=1:1 S PATTERN=$P($T(URLMAP+SEQ^%weburl),";;",2,99) Q:PATTERN="zzzzz"  D  Q:DONE
 . K ARGS
 . S ROUTINE=$P(PATTERN," ",3),PATMETHOD=$P(PATTERN," "),PATTERN=$P(PATTERN," ",2),FAIL=0
 . I $E(PATTERN)="/" S PATTERN=$E(PATTERN,2,$L(PATTERN))
 . I $L(PATTERN,"/")'=$L(PATH,"/") S ROUTINE="" Q  ; must have same number segments
 . F I=1:1:$L(PATH,"/") D  Q:FAIL
 . . S PATHSEG=$$URLDEC^%webutils($P(PATH,"/",I),1)
 . . S PATTSEG=$$URLDEC^%webutils($P(PATTERN,"/",I),1)
 . . I $E(PATTSEG)'="{" S FAIL=($$LOW^%webutils(PATHSEG)'=$$LOW^%webutils(PATTSEG)) Q
 . . S PATTSEG=$E(PATTSEG,2,$L(PATTSEG)-1) ; get rid of curly braces
 . . S ARGUMENT=$P(PATTSEG,"?"),TEST=$P(PATTSEG,"?",2)
 . . I $L(TEST) S FAIL=(PATHSEG'?@TEST) Q:FAIL
 . . S ARGS(ARGUMENT)=PATHSEG
 . I 'FAIL I PATMETHOD'=METHOD S FAIL=1
 . S:FAIL ROUTINE="" S:'FAIL DONE=1
 QUIT
 ;
MATCHFS(ROUTINE) ; Match against the file system
 N ARGS S ARGS("*")=$E(HTTPREQ("path"),2,9999)
 D FILESYS^%webapi(.HTTPRSP,.ARGS)
 I $O(HTTPRSP(0)) S ROUTINE="FILESYS^%webapi"
 quit
 ;
SENDATA ; write out the data as an HTTP response
 ; expects HTTPERR to contain the HTTP error code, if any
 ; RSPTYPE=1  local variable
 ; RSPTYPE=2  data in ^TMP($J)
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
 S RSPTYPE=$S($ZE($G(HTTPRSP))'="^":1,$D(HTTPRSP("pageable")):3,1:2)
 I RSPTYPE=1 S SIZE=$$VARSIZE^%webutils(.HTTPRSP)
 I RSPTYPE=2 S SIZE=$$REFSIZE^%webutils(.HTTPRSP)
 ;
 ; TODO: Handle 201 responses differently (change simple OK to created)
 ;
 D W($$RSPLINE()_$C(13,10)) ; Status Line (200, 404, etc)
 D W("Date: "_$$GMT^%webutils_$C(13,10)) ; RFC 1123 date
 I $D(HTTPREQ("location")) D W("Location: "_HTTPREQ("location")_$C(13,10))  ; Response Location
 I $D(HTTPRSP("auth")) D W("WWW-Authenticate: "_HTTPRSP("auth")_$C(13,10)) K HTTPRSP("auth") ; Authentication
 I $D(HTTPRSP("cache")) D W("Cache-Control: max-age="_HTTPRSP("cache")_$C(13,10)) K HTTPRSP("cache") ; Browser caching
 I $D(HTTPRSP("mime")) D  ; Stack $TEST for the ELSE below
 . D W("Content-Type: "_HTTPRSP("mime")_$C(13,10)) K HTTPRSP("mime") ; Mime-type
 E  D W("Content-Type: application/json; charset=utf-8"_$C(13,10))
 ;
 ; Add CORS Header
 I $G(HTTPREQ("method"))="OPTIONS" D W("Access-Control-Allow-Methods: OPTIONS, POST"_$C(13,10))
 I $G(HTTPREQ("method"))="OPTIONS" D W("Access-Control-Allow-Headers: Content-Type"_$C(13,10))
 I $G(HTTPREQ("method"))="OPTIONS" D W("Access-Control-Max-Age: 86400"_$C(13,10))
 D W("Access-Control-Allow-Origin: *"_$C(13,10))
 ;
 I $P($SY,",")=47,'$G(NOGZIP),$G(HTTPREQ("header","accept-encoding"))["gzip" GOTO GZIP  ; If on GT.M, and we can zip, let's do that!
 ;
 D W("Content-Length: "_SIZE_$C(13,10)_$C(13,10))
 I 'SIZE!(HTTPREQ("method")="HEAD") D FLUSH Q  ; flush buffer and quit if empty
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
 . ; Kill global after sending. https://github.com/shabiel/M-Web-Server/issues/44
 . I HTTPRSP'["^XTMP(" K @HTTPRSP
 D FLUSH ; flush buffer
 Q
 ;
W(DATA) ; EP to write data
 ; ZEXCEPT: %WBUFF - Buffer in Symbol Table
 I $P($SY,",")=47,$ZL(%WBUFF)+$ZL(DATA)>32000 D FLUSH
 I $L($SY,":")=2,$L(%WBUFF)+$L(DATA)>32000 D FLUSH
 S %WBUFF=%WBUFF_DATA
 QUIT
 ;
FLUSH ; EP to flush written data
 ; ZEXCEPT: %WBUFF - Buffer in Symbol Table
 W %WBUFF,!
 S %WBUFF=""
 QUIT
 ;
GZIP ; EP to write gzipped content
 ; Nothing to write?
 I 'SIZE D  QUIT  ; nothing to write!
 . D W("Content-Length: 0"_$C(13,10,13,10))
 . D FLUSH
 ;
 ; zip away - Open gzip and write to it, then read back the zipped file.
 N OLDIO S OLDIO=$IO
 n file
 i $ZV["Linux" s file="/dev/shm/mws-"_$J_"-"_$R(999999)_".dat"
 e  s file="/tmp/mws-"_$J_"-"_$R(999999)_".dat"
 o file:(newversion:stream:nowrap:chset="M")
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
 N I F I=0:0 S I=$O(ZIPPED(I)) Q:'I  S SIZE=SIZE+$ZL(ZIPPED(I))
 ;
 ; Write out the content headings for gzipped file.
 D W("Content-Encoding: gzip"_$C(13,10))
 D W("Content-Length: "_SIZE_$C(13,10)_$C(13,10))
 I HTTPREQ("method")="HEAD" D FLUSH Q  ; flush buffer and quit if empty
 ;
 N I F I=0:0 S I=$O(ZIPPED(I)) Q:'I  D W(ZIPPED(I))
 D FLUSH
 ;
 QUIT
 ;
RSPERROR ; set response to be an error response
 ; Count is a temporary variable to track multiple errors... don't send it back
 ; pageable is VPR code, not used, but kept for now.
 K HTTPERR("count"),HTTPRSP("pageable")
 D encode^%webjson($NAME(HTTPERR),$NAME(HTTPRSP))
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
AUTHEN(HTTPAUTH) ; Authenticate User against VISTA from HTTP Authorization Header
 ;
 ; We only support Basic authentication right now
 N P1,P2 S P1=$P(HTTPAUTH," "),P2=$P(HTTPAUTH," ",2)
 I $$UP^%webutils(P1)'="BASIC" Q 0 ; We don't support that authentication
 ;
 ; Decode Base64 encoded un:pwd
 N ACVC S ACVC=$$DECODE64^%webutils(P2)
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
 ;
 ; Portions of this code are public domain, but it was extensively modified
 ; Copyright 2013-2020 Sam Habiel
 ; Copyright 2018-2019 Christopher Edwards
 ; Copyright 2022 YottaDB LLC
 ;
 ;Licensed under the Apache License, Version 2.0 (the "License");
 ;you may not use this file except in compliance with the License.
 ;You may obtain a copy of the License at
 ;
 ;    http://www.apache.org/licenses/LICENSE-2.0
 ;
 ;Unless required by applicable law or agreed to in writing, software
 ;distributed under the License is distributed on an "AS IS" BASIS,
 ;WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 ;See the License for the specific language governing permissions and
 ;limitations under the License.
