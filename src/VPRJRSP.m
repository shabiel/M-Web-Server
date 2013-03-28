VPRJRSP ;SLC/KCM -- Handle HTTP Response
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
 D MATCH(.ROUTINE,.HTTPARGS) I $G(HTTPERR) QUIT
 D QSPLIT(.HTTPARGS) I $G(HTTPERR) QUIT
 S HTTPREQ("paging")=$G(HTTPARGS("start"),0)_":"_$G(HTTPARGS("limit"),999999)
 S HTTPREQ("store")=$S($$LOW^VPRJRUT($E(HTTPREQ("path"),2,4))="vpr":"vpr",1:"data")
 I "PUT,POST"[HTTPREQ("method") D
 . N BODY
 . M BODY=HTTPREQ("body") K HTTPREQ("body")
 . X "S LOCATION=$$"_ROUTINE_"(.HTTPARGS,.BODY)"
 . I $L(LOCATION) S HTTPREQ("location")=$S($D(HTTPREQ("header","host")):"http://"_HTTPREQ("header","host")_LOCATION,1:LOCATION)
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
 ; TODO: this needs some work so that it will accomodate patterns shorter than the path
 ; expects HTTPREQ to contain "path" and "method" nodes
 ; ROUTINE contains the TAG^ROUTINE to execute for this path, otherwise empty
 ; .ARGS will contain an array of resolved path arguments
 ;
 N SEQ,PATH,PATTERN,DONE,FAIL,I,PATHSEG,PATTSEG,TEST,ARGUMENT,METHOD,PATHOK
 S DONE=0,PATH=HTTPREQ("path"),PATHOK=0
 S:$E(PATH)="/" PATH=$E(PATH,2,$L(PATH))
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
 . I 'FAIL S PATHOK=1 I METHOD'=HTTPREQ("method") S FAIL=1
 . S:FAIL ROUTINE="" S:'FAIL DONE=1
 I PATHOK,ROUTINE="" D SETERROR^VPRJRUT(405,"Method Not Allowed") QUIT
 I ROUTINE="" D SETERROR^VPRJRUT(404,"Not Found") QUIT
 Q
SENDATA ; write out the data as an HTTP response
 ; expects HTTPERR to contain the HTTP error code, if any
 ; RSPTYPE=1  local variable
 ; RSPTYPE=2  data in ^TMP($J)
 ; RSPTYPE=3  pageable data in ^TMP($J,"data") or ^VPRTMP(hash,"data")
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
 W $$RSPLINE(),$C(13,10)
 W "Date: "_$$GMT^VPRJRUT_$C(13,10)
 I $D(HTTPREQ("location")) W "Location: "_HTTPREQ("location")_$C(13,10)
 W "Content-Type: application/json"_$C(13,10)
 W "Content-Length: ",SIZE,$C(13,10)_$C(13,10)
 I 'SIZE W $C(13,10),! Q  ; flush buffer and quit
 ;
 N I,J
 I RSPTYPE=1 D            ; write out local variable
 . I $D(HTTPRSP)#2 W HTTPRSP
 . I $D(HTTPRSP)>1 S I=0 F  S I=$O(HTTPRSP(I)) Q:'I  W HTTPRSP(I)
 I RSPTYPE=2 D            ; write out global using indirection
 . I $D(@HTTPRSP)#2 W @HTTPRSP
 . I $D(@HTTPRSP)>1 S I=0 F  S I=$O(@HTTPRSP@(I)) Q:'I  W @HTTPRSP@(I)
 I RSPTYPE=3 D            ; write out pageable records
 . W PREAMBLE
 . F I=START:1:(START+LIMIT-1) Q:'$D(@HTTPRSP@($J,I))  D
 . . I I>START W "," ; separate items with a comma
 . . S J="" F  S J=$O(@HTTPRSP@($J,I,J)) Q:'J  W @HTTPRSP@($J,I,J)
 . W "]}}"
 . K @HTTPRSP@($J)
 W $C(13,10),!  ; flush buffer
 I RSPTYPE=3,($E(HTTPRSP,1,4)="^TMP") D UPDCACHE
 Q
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
 I '$G(HTTPERR),'$D(HTTPREQ("location")) Q "HTTP/1.1 200 OK"
 I '$G(HTTPERR),$D(HTTPREQ("location")) Q "HTTP/1.1 201 Created"
 I $G(HTTPERR)=400 Q "HTTP/1.1 400 Bad Request"
 I $G(HTTPERR)=404 Q "HTTP/1.1 404 Not Found"
 I $G(HTTPERR)=405 Q "HTTP/1.1 405 Method Not Allowed"
 Q "HTTP/1.1 500 Internal Server Error"
 ;
PING(RESULT,ARGS) ; writes out a ping response
 S RESULT="{""status"":""running""}"
 Q
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