%WC ; Web Services Client;2013-05-14  9:34 AM
 ;
POST(RETURN,URL,PAYLOAD,MIME) ; Post
 ;D EWD(.RETURN,URL,.PAYLOAD,MIME)
 D CURL(.RETURN,URL,.PAYLOAD,MIME)
 QUIT
 ;
EWD(RETURN,URL,PAYLOAD,MIME) ; Post using EWD
 N OK S OK=$$httpPOST^%zewdGTM(URL,.PAYLOAD,MIME,.RETURN)
 QUIT
 ;
CURL(RETURN,URL,PAYLOAD,MIME) ; Post using CURL
 ;
 ; Write payload to File in shared memory
 N F S F="/dev/shm/"_$R(987987234)_$J_".DAT"
 O F:(NEWVERSION) U F
 I $D(PAYLOAD)#2 W PAYLOAD,!
 F I=0:0 S I=$O(PAYLOAD(I)) Q:'I  W PAYLOAD(I),!
 C F
 ;
 ; Flags: -s : Silent; -X: HTTP POST; -k : Ignore certificate validation.
 N CMD S CMD="curl -s -XPOST -k "_URL_" --header 'Content-Type:"_MIME_"'"_" --data-binary @"_F
 ;
 ; Execute and read back
 N D S D="cURLDevice"
 O D:(shell="/bin/sh":command=CMD)::"PIPE" U D
 F I=1:1 R RETURN(I)#4000:1 Q:$ZEOF  K:RETURN(I)="" RETURN(I)
 K:RETURN(I)="" RETURN(I)
 C D
 ;
 O F
 C F:(DELETE)
 ;
 QUIT
 ;
TEST(TYPE) ; Test this routine
 N PAYLOAD D GETXML^KBAIT1(.PAYLOAD,TYPE)
 N URL S URL="https://mocha.vistaewd.net:9281/mocha/"_TYPE
 N MIME S MIME="text/xml"
 N RETURN
 D POST^%WC(.RETURN,URL,.PAYLOAD,MIME)
 ZWRITE RETURN
 QUIT
