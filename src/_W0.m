%W0 ; VEN/SMH - Infrastructure web services hooks;2013-03-28  2:58 AM
 ;;
R(RESULT,ARGS) ; Get Mumps routine
 S HTTPRSP("mime")="text/plain; charset=utf-8"
 S RESULT=$NA(^TMP($J))
 K @RESULT
 N RTN S RTN=$G(ARGS("routine"))
 N OFF,I
 I RTN]""&($T(^@RTN)]"") F I=1:1 S OFF="+"_I,LN=$T(@OFF^@RTN) Q:LN=""  S @RESULT@(I)=LN_$C(13,10)
 E  K HTTPRSP("mime") D SETERROR^VPRJRUT(404,"Routine not found")
 QUIT
 ;
FV(RESULTS,ARGS) ; Get fileman field value.
 S HTTPRSP("mime")="text/plain; charset=utf-8" ; type of data to send browser
 I $$UNKARGS^VPRJCU(.ARGS,"file,iens,field") K HTTPRSP("mime") Q  ; Is any of these not passed?
 N FILE S FILE=$G(ARGS("file")) ; se
 N IENS S IENS=$G(ARGS("iens")) ; se
 N FIELD S FIELD=$G(ARGS("field")) ; se
 S RESULTS=$$GET1^DIQ(FILE,IENS,FIELD,,$NA(^TMP($J))) ; double trouble.
 ; if results is a regular field, that's the value we will get.
 ; if results is a WP field, RESULTS becomes the global ^TMP($J).
 I $D(^TMP($J)) S HTTPRSP("nl")=$C(13,10) ; crlf the result (doensn't work now)
 QUIT
 ;
MOCHA(RESULTS,ARGS) ;
 K RESULTS
 S HTTPRSP("mime")="text/xml; charset=utf-8"
 N TYPE S TYPE=$G(ARGS("type"))
 I TYPE="" K HTTPRSP("mime") D SETERROR^VPRJRUT(404,"MOCHA web service not found")
 D GETXML^KBAIT1(.RESULTS,TYPE)
 I '$O(RESULTS("")) K HTTPRSP("mime") D SETERROR^VPRJRUT(404,"MOCHA sub service not found")
 S HTTPRSP("nl")=$C(13,10) ; (doesn't work now)
 QUIT
