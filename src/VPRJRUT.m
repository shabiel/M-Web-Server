VPRJRUT ;SLC/KCM -- Utilities for HTTP communications ;2018-08-17  9:18 AM
 ;;1.0;JSON DATA STORE;;Sep 01, 2012
 ;
 ; Various mods to support GT.M. See diff with original for full listing.
 ;
UP(X) Q $TR(X,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
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
 Q:$G(ROOT)="" 0
 N SIZE,I
 S SIZE=0
 S ROOT=$NA(@ROOT)
 I $D(@ROOT)#2 S SIZE=$L(@ROOT)
 ; I $D(@ROOT)>1 S I=0 F  S I=$O(@ROOT@(I)) Q:'I  S SIZE=SIZE+$L(@ROOT@(I))
 N ORIG,OL S ORIG=ROOT,OL=$QL(ROOT) ; Orig, Orig Length
 F  S ROOT=$Q(@ROOT) Q:ROOT=""  Q:($NA(@ROOT,OL)'=$NA(@ORIG,OL))  S SIZE=SIZE+$L(@ROOT)
 S ROOT=ORIG
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
SETERROR(ERRCODE,MESSAGE,ERRARRAY) ; set error info into ^TMP("HTTPERR",$J)
 ; causes HTTPERR system variable to be set
 ; ERRCODE:  query errors are 100-199, update errors are 200-299, M errors are 500
 ; MESSAGE:  additional explanatory material
 ; ERRARRAY: An Array to use instead of the Message for information to the user.
 ;
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
 I ERRCODE=401 S ERRNAME="Unauthorized" ; VEN/SMH
 I ERRCODE=404 S ERRNAME="Not Found"
 I ERRCODE=405 S ERRNAME="Method Not Allowed"
 ; system errors (500-599)
 I ERRCODE=501 S ERRNAME="M execution error"
 I ERRCODE=502 S ERRNAME="Unable to lock record"
 I '$L($G(ERRNAME)) S ERRNAME="Unknown error"
 ;
 I ERRCODE>500 S HTTPERR=500,TOPMSG="Internal Server Error"  ; M Server Error
 I ERRCODE<500,ERRCODE>400 S HTTPERR=ERRCODE,TOPMSG=ERRNAME  ; Other HTTP Errors
 Q:$G(NOGBL)
 S NEXTERR=$G(^TMP("HTTPERR",$J,0),0)+1,^TMP("HTTPERR",$J,0)=NEXTERR
 S ^TMP("HTTPERR",$J,1,"apiVersion")="1.0"
 S ^TMP("HTTPERR",$J,1,"error","code")=HTTPERR
 S ^TMP("HTTPERR",$J,1,"error","message")=TOPMSG
 S ^TMP("HTTPERR",$J,1,"error","request")=$G(HTTPREQ("method"))_" "_$G(HTTPREQ("path"))_" "_$G(HTTPREQ("query"))
 I $D(ERRARRAY) M ^TMP("HTTPERR",$J,1,"error","errors",NEXTERR)=ERRARRAY  ; VEN/SMH
 E  S ^TMP("HTTPERR",$J,1,"error","errors",NEXTERR,"reason")=ERRCODE
 E  S ^TMP("HTTPERR",$J,1,"error","errors",NEXTERR,"message")=ERRNAME
 I $L($G(MESSAGE)) S ^TMP("HTTPERR",$J,1,"error","errors",NEXTERR,"domain")=MESSAGE
 Q
 ;
 ; Cache specific functions (selected one support GT.M too!)
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
 Q $$CRC32(X) ; return the CRC-32 value; works on both Cache 
 ;
GMT() ; return HTTP date string (this is really using UTC instead of GMT)
 N TM,DAY
 I $$UP($ZV)["CACHE" D  Q $P(DAY," ")_", "_$ZDATETIME(TM,2)_" GMT"
 . S TM=$ZTIMESTAMP,DAY=$ZDATETIME(TM,11)
 ;
 N OUT
 I $$UP($ZV)["GT.M" D  Q OUT
 . N D S D="datetimepipe"
 . N OLDIO S OLDIO=$I
 . O D:(shell="/bin/sh":comm="date -u +'%a, %d %b %Y %H:%M:%S %Z'|sed 's/UTC/GMT/g'")::"pipe"
 . U D R OUT:1 
 . U OLDIO C D
 ;
 QUIT "UNIMPLEMENTED"
 ;
SYSID() ; return a likely unique system ID
 S X=$SYSTEM_":"_$G(^VPRHTTP("port"),9080) ; VPR web server port number
 QUIT $$CRC16HEX(X) ; return CRC-16 in hex
 ;
 ;
CRC16HEX(X) ; return CRC-16 in hexadecimal
 QUIT $$BASE($$CRC16(X),10,16) ; return CRC-16 in hex
 ;
 ;
CRC32HEX(X) ; return CRC-32 in hexadecimal
 QUIT $$BASE($$CRC32(X),10,16) ; return CRC-32 in hex
 ;
 ;
 ;
DEC2HEX(NUM) ; return a decimal number as hex
 Q $$BASE(NUM,10,16)
 ;Q $ZHEX(NUM)
 ;
HEX2DEC(HEX) ; return a hex number as decimal
 Q $$BASE(HEX,16,10)
 ;Q $ZHEX(HEX_"H")
 ;
WR4HTTP ; open file to save HTTP response
 I $$UP($ZV)["CACHE" O "VPRJT.TXT":"WNS"
 I $$UP($ZV)["GT.M" O "VPRJT.TXT":(newversion)
 U "VPRJT.TXT"
 Q
RD4HTTP() ; read HTTP body from file and return as value
 N X
 I $$UP($ZV)["CACHE" O "VPRJT.TXT":"RSD" ; read sequential and delete afterwards
 I $$UP($ZV)["GT.M" O "VPRJT.TXT":(readonly:rewind) ; read sequential from the top.
 U "VPRJT.TXT"
 F  R X:1 S X=$TR(X,$C(13)) Q:'$L(X)  ; read lines until there is an empty one ($TR for GT.M)
 R X:2              ; now read the JSON object
 I $$UP($ZV)["GT.M" C "VPRJT.TXT":(delete) U $P
 I $$UP($ZV)["CACHE" D C4HTTP
 Q X
 ;
C4HTTP ; close file used for HTTP response
 C "VPRJT.TXT" U $P
 Q
CRC32(string,seed) ;
 ; Polynomial X**32 + X**26 + X**23 + X**22 +
 ;          + X**16 + X**12 + X**11 + X**10 +
 ;          + X**8  + X**7  + X**5  + X**4 +
 ;          + X**2  + X     + 1
 N I,J,R
 I '$D(seed) S R=4294967295
 E  I seed'<0,seed'>4294967295 S R=4294967295-seed
 E  S $ECODE=",M28,"
 F I=1:1:$L(string) D
 . S R=$$XOR($A(string,I),R,8)
 . F J=0:1:7 D
 . . I R#2 S R=$$XOR(R\2,3988292384,32)
 . . E  S R=R\2
 . . Q
 . Q
 Q 4294967295-R
XOR(a,b,w) N I,M,R
 S R=b,M=1
 F I=1:1:w D
 . S:a\M#2 R=R+$S(R\M#2:-M,1:M)
 . S M=M+M
 . Q
 Q R
BASE(%X1,%X2,%X3) ;Convert %X1 from %X2 base to %X3 base
 I (%X2<2)!(%X2>16)!(%X3<2)!(%X3>16) Q -1
 Q $$CNV($$DEC(%X1,%X2),%X3)
DEC(N,B) ;Cnv N from B to 10
 Q:B=10 N N I,Y S Y=0
 F I=1:1:$L(N) S Y=Y*B+($F("0123456789ABCDEF",$E(N,I))-2)
 Q Y
CNV(N,B) ;Cnv N from 10 to B
 Q:B=10 N N I,Y S Y=""
 F I=1:1 S Y=$E("0123456789ABCDEF",N#B+1)_Y,N=N\B Q:N<1
 Q Y
CRC16(string,seed) ;
 ; Polynomial x**16 + x**15 + x**2 + x**0
 N I,J,R
 I '$D(seed) S R=0
 E  I seed'<0,seed'>65535 S R=seed\1
 E  S $ECODE=",M28,"
 F I=1:1:$L(string) D
 . S R=$$XOR($A(string,I),R,8)
 . F J=0:1:7 D
 . . I R#2 S R=$$XOR(R\2,40961,16)
 . . E  S R=R\2
 . . Q
 . Q
 Q R
 ;
HTFM(%H,%F) ;$H to FM, %F=1 for date only
 N X,%,%T,%Y,%M,%D S:'$D(%F) %F=0
 I $$HR(%H) Q -1 ;Check Range
 I '%F,%H[",0" S %H=(%H-1)_",86400"
 D YMD S:%T&('%F) X=X_%T
 Q X
YMD ;21608 = 28 feb 1900, 94657 = 28 feb 2100, 141 $H base year
 S %=(%H>21608)+(%H>94657)+%H-.1,%Y=%\365.25+141,%=%#365.25\1
 S %D=%+306#(%Y#4=0+365)#153#61#31+1,%M=%-%D\29+1
 S X=%Y_"00"+%M_"00"+%D,%=$P(%H,",",2)
 S %T=%#60/100+(%#3600\60)/100+(%\3600)/100 S:'%T %T=".0"
 Q
HR(%V) ;Check $H in valid range
 Q (%V<2)!(%V>99999)
 ;
HTE(%H,%F) ;$H to external
 Q:$$HR(%H) %H ;Range Check
 N Y,%T,%R
 S %F=$G(%F,1) S Y=$$HTFM(%H,0)
T2 S %T="."_$E($P(Y,".",2)_"000000",1,7)
 D FMT Q %R
FMT ;
 N %G S %G=+%F
 G F1:%G=1,F2:%G=2,F3:%G=3,F4:%G=4,F5:%G=5,F6:%G=6,F7:%G=7,F8:%G=8,F9:%G=9,F1
 Q
 ;
F1 ;Apr 10, 2002
 S %R=$P($$M()," ",$S($E(Y,4,5):$E(Y,4,5)+2,1:0))_$S($E(Y,4,5):" ",1:"")_$S($E(Y,6,7):$E(Y,6,7)_", ",1:"")_($E(Y,1,3)+1700)
 ;
TM ;All formats come here to format Time.
 N %,%S Q:%T'>0!(%F["D")
 I %F'["P" S %R=%R_"@"_$E(%T,2,3)_":"_$E(%T,4,5)_$S(%F["M":"",$E(%T,6,7)!(%F["S"):":"_$E(%T,6,7),1:"")
 I %F["P" D
 . S %R=%R_" "_$S($E(%T,2,3)>12:$E(%T,2,3)-12,+$E(%T,2,3)=0:"12",1:+$E(%T,2,3))_":"_$E(%T,4,5)_$S(%F["M":"",$E(%T,6,7)!(%F["S"):":"_$E(%T,6,7),1:"")
 . S %R=%R_$S($E(%T,2,7)<120000:" am",$E(%T,2,3)=24:" am",1:" pm")
 . Q
 Q
 ;Return Month names
M() Q "  Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"
 ;
F2 ;4/10/02
 S %R=$J(+$E(Y,4,5),2)_"/"_$J(+$E(Y,6,7),2)_"/"_$E(Y,2,3)
 S:%F["Z" %R=$TR(%R," ","0") S:%F'["F" %R=$TR(%R," ")
 G TM
F3 ;10/4/02
 S %R=$J(+$E(Y,6,7),2)_"/"_$J(+$E(Y,4,5),2)_"/"_$E(Y,2,3)
 S:%F["Z" %R=$TR(%R," ","0") S:%F'["F" %R=$TR(%R," ")
 G TM
F4 ;02/4/10
 S %R=$E(Y,2,3)_"/"_$J(+$E(Y,4,5),2)_"/"_$J(+$E(Y,6,7),2)
 S:%F["Z" %R=$TR(%R," ","0") S:%F'["F" %R=$TR(%R," ")
 G TM
F5 ;4/10/2002
 S %R=$J(+$E(Y,4,5),2)_"/"_$J(+$E(Y,6,7),2)_"/"_($E(Y,1,3)+1700)
 S:%F["Z" %R=$TR(%R," ","0") S:%F'["F" %R=$TR(%R," ")
 G TM
F6 ;10/4/2002
 S %R=$J(+$E(Y,6,7),2)_"/"_$J(+$E(Y,4,5),2)_"/"_($E(Y,1,3)+1700)
 S:%F["Z" %R=$TR(%R," ","0") S:%F'["F" %R=$TR(%R," ")
 G TM
F7 ;2002/4/10
 S %R=($E(Y,1,3)+1700)_"/"_$J(+$E(Y,4,5),2)_"/"_$J(+$E(Y,6,7),2)
 S:%F["Z" %R=$TR(%R," ","0") S:%F'["F" %R=$TR(%R," ")
 G TM
F8 ;10 Apr 02
 S %R=$S($E(Y,6,7):$E(Y,6,7)_" ",1:"")_$P($$M()," ",$S($E(Y,4,5):$E(Y,4,5)+2,1:0))_$S($E(Y,4,5):" ",1:"")_$E(Y,2,3)
 G TM
F9 ;10 Apr 2002
 S %R=$S($E(Y,6,7):$E(Y,6,7)_" ",1:"")_$P($$M()," ",$S($E(Y,4,5):$E(Y,4,5)+2,1:0))_$S($E(Y,4,5):" ",1:"")_($E(Y,1,3)+1700)
 G TM
 ;
PARSE10(BODY,PARSED) ; Parse BODY by CRLF and return the array in PARSED
 ; Input: BODY: By Ref - BODY to be parsed
 ; Output: PARSED: By Ref - PARSED Output
 ; E.g. if BODY is ABC_CRLF_DEF_CRLF, PARSED is PARSED(1)="ABC",PARSED(2)="DEF",PARSED(3)=""
 N LL S LL="" ; Last line
 N L S L=1 ; Line counter.
 K PARSED ; Kill return array
 N I S I="" F  S I=$O(BODY(I)) Q:'I  D  ; For each 4000 character block
 . N J F J=1:1:$L(BODY(I),$C(10)) D  ; For each line
 . . S:(J=1&(L>1)) L=L-1 ; Replace old line (see 2 lines below)
 . . S PARSED(L)=$TR($P(BODY(I),$C(10),J),$C(13)) ; Get line; Take CR out if there.
 . . S:(J=1&(L>1)) PARSED(L)=LL_PARSED(L) ; If first line, append the last line before it and replace it.
 . . S LL=PARSED(L) ; Set last line
 . . S L=L+1 ; LineNumber++
 QUIT
 ;
ADDCRLF(RESULT) ; Add CRLF to each line
 I $E($G(RESULT))="^" D  QUIT  ; Global
 . N V,QL S V=RESULT,QL=$QL(V) F  S V=$Q(@V) Q:V=""  Q:$NA(@V,QL)'=RESULT  S @V=@V_$C(13,10)
 E  D  ; Local variable passed by reference
 . I $D(RESULT)#2 S RESULT=RESULT_$C(13,10)
 . N V S V=$NA(RESULT) F  S V=$Q(@V) Q:V=""  S @V=@V_$C(13,10)
 QUIT
 ;
TESTCRLF
 S RESULT=$NA(^TMP($J))
 K @RESULT
 S ^TMP($J,1)="HELLO"
 S ^TMP($J,2)="WORLD"
 S ^TMP($J,3)=""
 D ADDCRLF(.RESULT)
 ZWRITE @RESULT@(*)
 K RESULT
 S RESULT="HELLO"
 S RESULT(1)="WORLD"
 S RESULT(2)="BYE"
 S RESULT(3)=""
 D ADDCRLF(.RESULT)
 ZWRITE RESULT
 QUIT
UNKARGS(ARGS,LIST) ; returns true if any argument is unknown
 N X,UNKNOWN
 S UNKNOWN=0,LIST=","_LIST_","
 S X="" F  S X=$O(ARGS(X)) Q:X=""  I LIST'[(","_X_",") D
 . S UNKNOWN=1
 . D SETERROR^VPRJRUT(111,X)
 Q UNKNOWN
 ;
ENCODE64(X) ;
 N RGZ,RGZ1,RGZ2,RGZ3,RGZ4,RGZ5,RGZ6
 S RGZ=$$INIT64,RGZ1=""
 F RGZ2=1:3:$L(X) D
 .S RGZ3=0,RGZ6=""
 .F RGZ4=0:1:2 D
 ..S RGZ5=$A(X,RGZ2+RGZ4),RGZ3=RGZ3*256+$S(RGZ5<0:0,1:RGZ5)
 .F RGZ4=1:1:4 S RGZ6=$E(RGZ,RGZ3#64+2)_RGZ6,RGZ3=RGZ3\64
 .S RGZ1=RGZ1_RGZ6
 S RGZ2=$L(X)#3
 S:RGZ2 RGZ3=$L(RGZ1),$E(RGZ1,RGZ3-2+RGZ2,RGZ3)=$E("==",RGZ2,2)
 Q RGZ1
DECODE64(X) ;
 N RGZ,RGZ1,RGZ2,RGZ3,RGZ4,RGZ5,RGZ6
 S RGZ=$$INIT64,RGZ1=""
 F RGZ2=1:4:$L(X) D
 .S RGZ3=0,RGZ6=""
 .F RGZ4=0:1:3 D
 ..S RGZ5=$F(RGZ,$E(X,RGZ2+RGZ4))-3
 ..S RGZ3=RGZ3*64+$S(RGZ5<0:0,1:RGZ5)
 .F RGZ4=0:1:2 S RGZ6=$C(RGZ3#256)_RGZ6,RGZ3=RGZ3\256
 .S RGZ1=RGZ1_RGZ6
 Q $E(RGZ1,1,$L(RGZ1)-$L(X,"=")+1)
INIT64() Q "=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
