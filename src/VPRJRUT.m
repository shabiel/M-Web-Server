VPRJRUT ;SLC/KCM -- Utilities for HTTP communications
 ;;1.0;JSON DATA STORE;;Sep 01, 2012
 ;
LOW(X) Q $TR(X,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
 ;
LTRIM(%X) ; Trim whitespace from left side of string
 ; derived from XLFSTR, but also removes tabs
 N %L,%R
 S %L=1,%R=$L(%X)
 F %L=1:1:$L(%X) Q:$A($E(%X,%L))>32
 Q $E(%X,%L,%R)
 ;
URLENC(X) ; Encode a string for use in a URL
 ; Q $ZCONVERT(X,"O","URL")  ; uncomment for fastest performance on Cache
 ; =, &, %, +, non-printable 
 ; {, } added JC 7-24-2012
 N I,Y,Z,LAST
     S Y=$P(X,"%") F I=2:1:$L(X,"%") S Y=Y_"%25"_$P(X,"%",I)
 S X=Y,Y=$P(X,"&") F I=2:1:$L(X,"&") S Y=Y_"%26"_$P(X,"&",I)
 S X=Y,Y=$P(X,"=") F I=2:1:$L(X,"=") S Y=Y_"%3D"_$P(X,"=",I)
 S X=Y,Y=$P(X,"+") F I=2:1:$L(X,"+") S Y=Y_"%2B"_$P(X,"+",I)
 S X=Y,Y=$P(X,"{") F I=2:1:$L(X,"{") S Y=Y_"%7B"_$P(X,"{",I)
 S X=Y,Y=$P(X,"}") F I=2:1:$L(X,"}") S Y=Y_"%7D"_$P(X,"}",I)
 S Y=$TR(Y," ","+")
 S Z="",LAST=1
 F I=1:1:$L(Y) I $A(Y,I)<32 D
 . S CODE=$$DEC2HEX($A(Y,I)),CODE=$TR($J(CODE,2)," ","0")
 . S Z=Z_$E(Y,LAST,I-1)_"%"_CODE,LAST=I+1
 S Z=Z_$E(Y,LAST,$L(Y))
 Q Z
 ;
URLDEC(X,PATH) ; Decode a URL-encoded string
 ; Q $ZCONVERT(X,"I","URL")  ; uncomment for fastest performance on Cache
 ;
 N I,OUT,FRAG,ASC
 S:'$G(PATH) X=$TR(X,"+"," ") ; don't convert '+' in path fragment
 F I=1:1:$L(X,"%") D
 . I I=1 S OUT=$P(X,"%") Q
 . S FRAG=$P(X,"%",I),ASC=$E(FRAG,1,2),FRAG=$E(FRAG,3,$L(FRAG))
 . I $L(ASC) S OUT=OUT_$C($$HEX2DEC(ASC))
 . S OUT=OUT_FRAG
 Q OUT
 ;
REFSIZE(ROOT) ; return the size of glvn passed in ROOT
 Q:'$D(ROOT) 0 Q:'$L(ROOT) 0
 N SIZE,I
 S SIZE=0
 I $D(@ROOT)#2 S SIZE=$L(@ROOT)
 I $D(@ROOT)>1 S I=0 F  S I=$O(@ROOT@(I)) Q:'I  S SIZE=SIZE+$L(@ROOT@(I))
 Q SIZE
 ;
VARSIZE(V) ; return the size of a variable
 Q:'$D(V) 0
 N SIZE,I
 S SIZE=0
 I $D(V)#2 S SIZE=$L(V)
 I $D(V)>1 S I="" F  S I=$O(V(I)) Q:'I  S SIZE=SIZE+$L(V(I))
 Q SIZE
 ;
PAGE(ROOT,START,LIMIT,SIZE,PREAMBLE) ; create the size and preamble for a page of data
 Q:'$D(ROOT) 0 Q:'$L(ROOT) 0
 N I,J,KEY,KINST,COUNT,TEMPLATE,PID
 K @ROOT@($J)
 S SIZE=0,COUNT=0,TEMPLATE=$G(@ROOT@("template"),0),PID=$G(@ROOT@("pid"))
 F I=START:1:(START+LIMIT-1) Q:'$D(@ROOT@("data",I))  S COUNT=COUNT+1 D
 . S KEY="" F  S KEY=$O(@ROOT@("data",I,KEY)) Q:KEY=""  D
 . . S KINST="" F  S KINST=$O(@ROOT@("data",I,KEY,KINST)) Q:KINST=""  D
 . . . S PID=^(KINST)  ; null if non-pt data
 . . . D TMPLT(ROOT,TEMPLATE,I,KEY,KINST,PID)
 . . . S J="" F  S J=$O(@ROOT@($J,I,J)) Q:'J  S SIZE=SIZE+$L(@ROOT@($J,I,J))
 S PREAMBLE=$$BLDHEAD(@ROOT@("total"),COUNT,START,LIMIT)
 ; add 3 for "]}}", add COUNT-1 for commas
 S SIZE=SIZE+$L(PREAMBLE)+3+COUNT-$S('COUNT:0,1:1)
 Q
TMPLT(ROOT,TEMPLATE,ITEM,KEY,KINST,PID) ; set template
 I HTTPREQ("store")="data" G TLT4DATA
TLT4VPR ;
 ; called from PAGE
 I $G(TEMPLATE)="uid" S @ROOT@($J,ITEM,1)="{""uid"":"""_KEY_"""}" Q
 ; other template
 I $L(TEMPLATE),$D(^VPRPT("TEMPLATE",PID,KEY,TEMPLATE)) M @ROOT@($J,ITEM)=^(TEMPLATE) Q
 ; else full object
 M @ROOT@($J,ITEM)=^VPRPT("JSON",PID,KEY)
 Q
TLT4DATA ;
 ; called from PAGE
 I $G(TEMPLATE)="uid" S @ROOT@($J,ITEM,1)="{""uid"":"""_KEY_"""}" Q
 ; other template
 I $L(TEMPLATE),$D(^VPRJD("TEMPLATE",KEY,TEMPLATE)) M @ROOT@($J,ITEM)=^(TEMPLATE) Q
 ; else full object
 M @ROOT@($J,ITEM)=^VPRJD("JSON",KEY)
 Q
BLDHEAD(TOTAL,COUNT,START,LIMIT) ; Build the object header
 N X,UPDATED
 S UPDATED=$P($$FMTHL7^XLFDT($$NOW^XLFDT),"+")
 S X="{""apiVersion"":""1.0"",""data"":{""updated"":"_UPDATED_","
 S X=X_"""totalItems"":"_TOTAL_","
 S X=X_"""currentItemCount"":"_COUNT_","
 I LIMIT'=999999 D  ; only set thise if paging
 . S X=X_"""itemsPerPage"":"_LIMIT_","
 . S X=X_"""startIndex"":"_START_","
 . S X=X_"""pageIndex"":"_(START\LIMIT)_","
 . S X=X_"""totalPages"":"_(TOTAL\LIMIT+$S(TOTAL#LIMIT:1,1:0))_","
 S X=X_"""items"":["
 Q X
 ;
SETERROR(ERRCODE,MESSAGE) ; set error info into ^TMP("HTTPERR",$J)
 ; causes HTTPERR system variable to be set
 ; ERRCODE:  query errors are 100-199, update errors are 200-299, M errors are 500
 ; MESSAGE:  additional explanatory material
 N NEXTERR,ERRNAME,TOPMSG
 S HTTPERR=400,TOPMSG="Bad Request"
 ; query errors (100-199)
 I ERRCODE=101 S ERRNAME="Missing name of index"
 I ERRCODE=102 S ERRNAME="Invalid index name"
 I ERRCODE=103 S ERRNAME="Parameter error"
 I ERRCODE=104 S HTTPERR=404,TOPMSG="Not Found",ERRNAME="Bad key"
 I ERRCODE=105 S ERRNAME="Template required"
 I ERRCODE=106 S ERRNAME="Bad Filter Parameter"
 I ERRCODE=107 S ERRNAME="Unsupported Field Name"
 I ERRCODE=108 S ERRNAME="Bad Order Parameter"
 I ERRCODE=109 S ERRNAME="Operation not supported with this index"
 I ERRCODE=110 S ERRNAME="Order field unknown"
 I ERRCODE=111 S ERRNAME="Unrecognized parameter"
 I ERRCODE=112 S ERRNAME="Filter required"
 ; update errors (200-299)
 I ERRCODE=201 S ERRNAME="Unknown collection" ; unused?
 I ERRCODE=202 S ERRNAME="Unable to decode JSON"
 I ERRCODE=203 S HTTPERR=404,TOPMSG="Not Found",ERRNAME="Unable to determine patient"
 I ERRCODE=204 S HTTPERR=404,TOPMSG="Not Found",ERRNAME="Unable to determine collection" ; unused?
 I ERRCODE=205 S ERRNAME="Patient mismatch with object"
 I ERRCODE=207 S ERRNAME="Missing UID"
 I ERRCODE=209 S ERRNAME="Missing range or index" ; unused?
 I ERRCODE=210 S ERRNAME="Unknown UID format"
 I ERRCODE=211 S HTTPERR=404,TOPMSG="Not Found",ERRNAME="Missing patient identifiers"
 I ERRCODE=212 S ERRNAME="Mismatch of patient identifiers"
 I ERRCODE=213 S ERRNAME="Delete demographics only not allowed"
 I ERRCODE=214 S HTTPERR=404,ERRNAME="Patient ID not found in database"
 I ERRCODE=215 S ERRNAME="Missing collection name"
 I ERRCODE=216 S ERRNAME="Incomplete deletion of collection"
 ; HTTP errors
 I ERRCODE=400 S ERRNAME="Bad Request"
 I ERRCODE=404 S ERRNAME="Not Found"
 I ERRCODE=405 S ERRNAME="Method Not Allowed"
 ; system errors (500-599)
 I ERRCODE=501 S ERRNAME="M execution error"
 I ERRCODE=502 S ERRNAME="Unable to lock record"
 I '$L($G(ERRNAME)) S ERRNAME="Unknown error"
 ;
 I ERRCODE>500 S HTTPERR=500,TOPMSG="Internal Server Error"  ; M Server Error
 I ERRCODE<500,ERRCODE>400 S HTTPERR=ERRCODE,TOPMSG=ERRNAME  ; Other HTTP Errors 
 S NEXTERR=$G(^TMP("HTTPERR",$J,0),0)+1,^TMP("HTTPERR",$J,0)=NEXTERR
 S ^TMP("HTTPERR",$J,1,"apiVersion")="1.0"
 S ^TMP("HTTPERR",$J,1,"error","code")=HTTPERR
 S ^TMP("HTTPERR",$J,1,"error","message")=TOPMSG
 S ^TMP("HTTPERR",$J,1,"error","request")=$G(HTTPREQ("method"))_" "_$G(HTTPREQ("path"))_" "_$G(HTTPREQ("query"))
 S ^TMP("HTTPERR",$J,1,"error","errors",NEXTERR,"reason")=ERRCODE
 S ^TMP("HTTPERR",$J,1,"error","errors",NEXTERR,"message")=ERRNAME
 I $L($G(MESSAGE)) S ^TMP("HTTPERR",$J,1,"error","errors",NEXTERR,"domain")=MESSAGE
 Q
 ;
 ; Cache specific functions
 ;
LCLHOST() ; return TRUE if the peer connection is localhost
 I $E($I,1,5)'="|TCP|" Q 0
 N VER,ADDR
 S VER=$P($P($ZV,") ",2),"(")
 I VER<2011 S ADDR=$ZU(111,0),ADDR=$A(ADDR,1)_"."_$A(ADDR,2)_"."_$A(ADDR,3)_"."_$A(ADDR,4) I 1
 E  S ADDR=$SYSTEM.TCPDevice.PeerAddr(0)
 I ADDR="127.0.0.1" Q 1
 I ADDR="0:0:0:0:0:0:0:1" Q 1
 I ADDR="::1" Q 1
 Q 0
 ;
HASH(X) ; return CRC-32 of string contained in X
 Q $ZCRC(X,7) ; return the CRC-32 value
 ;
GMT() ; return HTTP date string (this is really using UTC instead of GMT)
 N TM,DAY
 S TM=$ZTIMESTAMP,DAY=$ZDATETIME(TM,11)
 Q $P(DAY," ")_", "_$ZDATETIME(TM,2)_" GMT"
 ;
SYSID() ; return a likely unique system ID
 N X
 S X=$ZUTIL(110)_":"_$G(^VPRHTTP("port"),9080)
 Q $ZHEX($ZCRC(X,6))
 ;
DEC2HEX(NUM) ; return a decimal number as hex
 Q $ZHEX(NUM)
 ;
HEX2DEC(HEX) ; return a hex number as decimal
 Q $ZHEX(HEX_"H")
 ;
WR4HTTP ; open file to save HTTP response
 O "VPRJT.TXT":"WNS"  ; open for writing
 U "VPRJT.TXT"
 Q
RD4HTTP() ; read HTTP body from file and return as value
 N X
 O "VPRJT.TXT":"RSD" ; for reading and delete when done
 U "VPRJT.TXT"
 F  R X:1 Q:'$L(X)  ; read lines until there is an empty one
 R X:2              ; now read the JSON object
 D C4HTTP
 Q X
 ;
C4HTTP ; close file used for HTTP response
 C "VPRJT.TXT"
 U $P
 Q