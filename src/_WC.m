%WC ; VEN/SMH - Web Services Client using cURL ;2013-10-31  6:18 PM
 ; See accompanying License for terms of use.
 ;
%(RETURN,METHOD,URL,PAYLOAD,MIME,TO,HEADERS) ; General call for any type
 ;
 ;
 ; DEBUG; Test error trapping.
 ; N X S X=1/0
 ; DEBUG
 ;
 ;
 S TO=$G(TO) ; Timeout
 I +TO=0 S TO=30 ; Default timeout
 ;
 ; Write payload to File in shared memory
 I $D(PAYLOAD) N F D
 . S F="/dev/shm/"_$R(987987234)_$J_".DAT"
 . O F:(NEWVERSION) U F
 . I $D(PAYLOAD)#2 W PAYLOAD,!
 . N I F I=0:0 S I=$O(PAYLOAD(I)) Q:'I  W PAYLOAD(I),!
 . C F
 ;
 N CMD S CMD="curl -K -" ; Read options from stdin; GT.M cannot handle a command longer than 255 characters.
 ;
 ; DEBUG ; See if we can get an error if curl isn't found on the Operating System.
 ;N CMD S CMD="curly -si -XPOST --connect-timeout "_TO_" -m "_TO_" -k "_URL_" --header 'Content-Type:"_MIME_"'"_" --data-binary @"_F
 ; DEBUG
 ;
 ; DEBUG
 ; W !,CMD
 ; DEBUG
 ;
 ; TODO: Check curl return status. VEN/SMH - Seems that there is no way to get that from GT.M right now.
 ; VEN/SMH - confirmed with Bhaskar that GT.M doesn't have a way check return status.
 ;
 ; VEN/SMH Okay. This the code is hard to understand. See comments.
 ;
 ; Execute and read back
 N D S D="cURLDevice"
 O D:(shell="/bin/sh":command=CMD:PARSE)::"PIPE" U D
 ;
 ; Write what to do for curl -K -
 ; TODO: not bullet proof. Some characters may need to be escaped.
 N Q S Q=""""
 W "url = ",Q_URL_Q,!
 W "request = ",METHOD,!
 W "connect-timeout = ",TO,!
 W "max-time = ",TO,!
 W "insecure",!
 W "silent",!
 W "include",!
 I $D(MIME)#2 W "header = "_Q_"Content-Type: "_MIME_Q,!
 I $D(PAYLOAD) W "data-binary = "_Q_"@"_F_Q,!
 W /EOF
 ;
 ; Flag to indicate whether a line we are getting a header or not. We are getting headers first, so it's true.
 ; A la State machine.
 N ISHEADER S ISHEADER=1 
 N I F I=1:1 R RETURN(I)#4000:1 Q:$ZEOF  D   ; Read each line up to 4000 characters
 . S RETURN(I)=$$TRIM(RETURN(I),,$C(13)) ; Strip CRs (we are on Unix)
 . I RETURN(I)="",$G(HEADERS("STATUS")) S ISHEADER=0  ; If we get a blank line, and we don't have a status yet (e.g. if we got a 100 which we kill off), we are no longer at the headers
 . I ISHEADER D  QUIT                    ; If we are at the headers, read them & remove them from RETURN array.
 . . ; First Line is like HTTP/1.1 200 OK
 . . I RETURN(I)'[":" S HEADERS("PROTOCOL")=$P(RETURN(I)," "),HEADERS("STATUS")=$P(RETURN(I)," ",2) K RETURN(I)
 . . ; Next lines are key: value pairs. 
 . . E  S HEADERS($P(RETURN(I),":"))=$$TRIM($P(RETURN(I),":",2,99)) K RETURN(I)
 . . I HEADERS("STATUS")=100 K HEADERS("PROTOCOL"),HEADERS("STATUS") QUIT  ; We don't want the continue
 . K:RETURN(I)="" RETURN(I) ; remove empty line
 K:RETURN(I)="" RETURN(I)  ; remove empty line (last line when $ZEOF gets hit)
 C D
 
 ; Delete the file a la %ZISH
 I $D(PAYLOAD) O F C F:(DELETE)
 ;
 ; Comment the zwrites out to see the return vales from the function
 ;DEBUG
 ; ZWRITE HEADERS
 ; ZWRITE RETURN
 ;DEBUG
 ;
 QUIT
 ;
 ;
POST(RETURN,URL,PAYLOAD,MIME,TO,HEADERS) ; Post
 ;D EWD(.RETURN,URL,.PAYLOAD,MIME)
 D CURL(.RETURN,URL,.PAYLOAD,MIME,TO,.HEADERS)
 QUIT
 ;
EWD(RETURN,URL,PAYLOAD,MIME,TO,HEADERS) ; Post using EWD
 N OK S OK=$$httpPOST^%zewdGTM(URL,.PAYLOAD,MIME,.RETURN)
 QUIT
 ;
CURL(RETURN,URL,PAYLOAD,MIME,TO,HEADERS) ; Post using CURL
 ;
 ; DEBUG; Test error trapping.
 ; N X S X=1/0
 ; DEBUG
 ;
 ;
 S TO=$G(TO) ; Timeout
 I +TO=0 S TO=30 ; Default timeout
 ;
 ; Write payload to File in shared memory
 N F S F="/dev/shm/"_$R(987987234)_$J_".DAT"
 O F:(NEWVERSION) U F
 I $D(PAYLOAD)#2 W PAYLOAD,!
 N I F I=0:0 S I=$O(PAYLOAD(I)) Q:'I  W PAYLOAD(I),!
 C F
 ;
 ; Flags: -s : Silent; -X: HTTP POST; -k : Ignore certificate validation.
 ; --connect-timeout: try only for this long; -m: max time to try. Both in sec.
 ; -i: Print headers out in response.
 N CMD S CMD="curl -si -XPOST --connect-timeout "_TO_" -m "_TO_" -k "_URL_" --header 'Content-Type:"_MIME_"'"_" --data-binary @"_F
 ;
 ;
 ; DEBUG ; See if we can get an error if curl isn't found on the Operating System.
 ;N CMD S CMD="curly -si -XPOST --connect-timeout "_TO_" -m "_TO_" -k "_URL_" --header 'Content-Type:"_MIME_"'"_" --data-binary @"_F
 ; DEBUG
 ;
 ; DEBUG
 ; W !,CMD
 ; DEBUG
 ;
 ; TODO: Check curl return status. VEN/SMH - Seems that there is no way to get that from GT.M right now.
 ; VEN/SMH - confirmed with Bhaskar that GT.M doesn't have a way check return status.
 ;
 ; VEN/SMH Okay. This the code is hard to understand. See comments.
 ;
 ; Execute and read back
 N D S D="cURLDevice"
 O D:(shell="/bin/sh":command=CMD:PARSE)::"PIPE" U D
 ;
 ;
 ; Flag to indicate whether a line we are getting a header or not. We are getting headers first, so it's true.
 ; A la State machine.
 N ISHEADER S ISHEADER=1 
 N I F I=1:1 R RETURN(I)#4000:1 Q:$ZEOF  D   ; Read each line up to 4000 characters
 . S RETURN(I)=$$TRIM(RETURN(I),,$C(13)) ; Strip CRs (we are on Unix)
 . I RETURN(I)="",$G(HEADERS("STATUS")) S ISHEADER=0  ; If we get a blank line, and we don't have a status yet (e.g. if we got a 100 which we kill off), we are no longer at the headers
 . I ISHEADER D  QUIT                    ; If we are at the headers, read them & remove them from RETURN array.
 . . ; First Line is like HTTP/1.1 200 OK
 . . I RETURN(I)'[":" S HEADERS("PROTOCOL")=$P(RETURN(I)," "),HEADERS("STATUS")=$P(RETURN(I)," ",2) K RETURN(I)
 . . ; Next lines are key: value pairs. 
 . . E  S HEADERS($P(RETURN(I),":"))=$$TRIM($P(RETURN(I),":",2,99)) K RETURN(I)
 . . I HEADERS("STATUS")=100 K HEADERS("PROTOCOL"),HEADERS("STATUS") QUIT  ; We don't want the continue
 . K:RETURN(I)="" RETURN(I) ; remove empty line
 K:RETURN(I)="" RETURN(I)  ; remove empty line (last line when $ZEOF gets hit)
 C D
 
 ; Delete the file a la %ZISH
 O F C F:(DELETE)
 ;
 ; Comment the zwrites out to see the return vales from the function
 ;DEBUG
 ; ZWRITE HEADERS
 ; ZWRITE RETURN
 ;DEBUG
 ;
 QUIT
 ;
 ; Code below stolen from Kernel. Thanks Wally.
TRIM(%X,%F,%V) ;Trim spaces\char from front(left)/back(right) of string
 N %R,%L
 S %F=$$UP($G(%F,"LR")),%L=1,%R=$L(%X),%V=$G(%V," ")
 ;I %F["R" F %R=$L(%X):-1:1 Q:$E(%X,%R)'=%V  ;take out BT
 I %F["R" F %R=$L(%X):-1:0 Q:$E(%X,%R)'=%V  ;598
 ;I %F["L" F %L=1:1:$L(%X) Q:$E(%X,%L)'=%V  ;take out BT
 I %F["L" F %L=1:1:$L(%X)+1 Q:$E(%X,%L)'=%V  ;598
 I (%L>%R)!(%X=%V) Q ""
 Q $E(%X,%L,%R)
 ;
UP(X) Q $TR(X,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
 ;
TEST ; Unit Tests
 ; Test Get
 N RTN,H D %(.RTN,"GET","https://thebes.smh101.com/r/DIC",,"application/text",5,.H)
 I H("STATUS")'=200 WRITE "FAIL FAIL FAIL",!
 ;
 ; Test Put
 N PAYLOAD,RTN,H
 N R S R=$R(123423421234)
 S PAYLOAD(1)="KBANTEST ; VEN/SMH - Test routine for Sam ;"_R
 S PAYLOAD(2)=" QUIT"
 D %(.RTN,"PUT","https://thebes.smh101.com/r/KBANTEST",.PAYLOAD,"application/text",5,.H)
 I H("STATUS")'=201 WRITE "FAIL FAIL FAIL",!
 ;
 ; Test Get with no mime and no headers to return
 N RTN,H D %(.RTN,"GET","https://thebes.smh101.com/r/KBANTEST")
 I $P(@$Q(RTN),";",3)'=R W "FAIL FAIL FAIL",!
 ;
 QUIT
