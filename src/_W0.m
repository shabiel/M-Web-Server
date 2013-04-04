%W0 ; VEN/SMH - Infrastructure web services hooks;2013-04-04  4:17 PM
 ;;
R(RESULT,ARGS) ; GET Mumps Routine
 S RESULT("mime")="text/plain; charset=utf-8"
 S RESULT=$NA(^TMP($J))
 K @RESULT
 N RTN S RTN=$G(ARGS("routine"))
 N OFF,I
 I RTN]""&($T(^@RTN)]"") F I=1:1 S OFF="+"_I,LN=$T(@OFF^@RTN) Q:LN=""  S @RESULT@(I)=LN_$C(13,10)
 E  K RESULT("mime") D SETERROR^VPRJRUT(404,"Routine not found")
 QUIT
 ;
PR(ARGS,BODY,RESULT) ; PUT Mumps Routine
 S HTTPRSP("mime")="text/plain; charset=utf-8" ; Character set of the return URL
 S RESULT="/r/"_ARGS("routine") ; Stored URL
 N PARSED ; Parsed array which stores each line on a separate node.
 D PARSE10^VPRJRUT(.BODY,.PARSED) ; Parser
 N DIE,XCN S DIE="PARSED(",XCN=0 D SAVE(ARGS("routine"))
 Q RESULT
 ;
SAVE(RN)	;Save a routine
 N %,%F,%I,%N,SP,$ETRAP
 S $ETRAP="S $ECODE="""" Q"
 S %I=$I,SP=" ",%F=$$RTNDIR^%ZOSV()_$TR(RN,"%","_")_".m"
 O %F:(newversion:noreadonly:blocksize=2048:recordsize=2044) U %F
 F  S XCN=$O(@(DIE_XCN_")")) Q:XCN'>0  S %=@(DIE_XCN_")") Q:$E(%,1)="$"  I $E(%)'=";" W $P(%,SP)_$C(9)_$P(%,SP,2,99999),!
 C %F ;S %N=$$NULL
 ZLINK RN
 ;C %N
 U %I
 Q
FV(RESULTS,ARGS) ; Get fileman field value.
 I $$UNKARGS^VPRJCU(.ARGS,"file,iens,field") Q  ; Is any of these not passed?
 S RESULTS("mime")="text/plain; charset=utf-8" ; type of data to send browser
 N FILE S FILE=$G(ARGS("file")) ; se
 N IENS S IENS=$G(ARGS("iens")) ; se
 N FIELD S FIELD=$G(ARGS("field")) ; se
 S RESULTS=$$GET1^DIQ(FILE,IENS,FIELD,,$NA(^TMP($J))) ; double trouble.
 I $D(^TMP("DIERR",$J)) D SETERROR^VPRJRUT(404,"File or field not found") QUIT
 ; if results is a regular field, that's the value we will get.
 ; if results is a WP field, RESULTS becomes the global ^TMP($J).
 I $D(^TMP($J)) D ADDCRLF^VPRJRUT(.RESULTS) ; crlf the result
 ZSHOW "D":^KBANDEV
 QUIT
 ;
MOCHA(RESULTS,ARGS) ;
 K RESULTS
 S RESULTS("mime")="text/xml; charset=utf-8"
 N TYPE S TYPE=$G(ARGS("type"))
 I TYPE="" K RESULTS("mime") D SETERROR^VPRJRUT(404,"MOCHA web service not found")
 N XMLRTN D GETXML^KBAIT1(.XMLRTN,TYPE)
 I '$O(XMLRTN("")) K RESULTS("mime") D SETERROR^VPRJRUT(404,"MOCHA sub service not found")
 D ADDCRLF^VPRJRUT(.XMLRTN)
 M RESULTS=XMLRTN
 QUIT
 ;
POSTTEST(ARGS,BODY,RESULT) ; POST XML to a WP field in Fileman; handles /xmlpost
 N IEN S IEN=$O(^%W(6.6002,""),-1)+1
 N %WFDA S %WFDA(6.6002,"?+1,",.01)=IEN D UPDATE^DIE("",$NA(%WFDA))
 S RESULT="/fileman/6.6002/"_IEN_"/"_1 ; Stored URL
 N PARSED ; Parsed array which stores each line on a separate node.
 D PARSE10^VPRJRUT(.BODY,.PARSED) ; Parser
 D WP^DIE(6.6002,IEN_",",1,"K",$NA(PARSED)) ; File WP field; lock record in process.
 ; ZSHOW "V":^KBANPARSED
 S RESULT("mime")="text/plain; charset=utf-8" ; Character set of the return URL
 Q RESULT
 ;
MOCHAP(ARGS,BODY,RESULT) ; POST XML to MOCHA; handles mocha/{type}
 N TYPE S TYPE=$G(ARGS("type"))
 N PARSEDTEXT D PARSE10^VPRJRUT(.BODY,.PARSEDTEXT)
 K ^KBANPARSED M ^KBANPARSED=PARSEDTEXT
 ; ZSHOW "*":^KBANPARSED
 S RESULT("mime")="text/xml; charset=utf-8"
 D GETXRSP^KBAIT1(.RESULT,TYPE)
 I '$D(RESULT(1)) K RESULT("mime") D SETERROR^VPRJRUT("404","Post box location not found") Q ""
 Q "/mocha/"_TYPE
