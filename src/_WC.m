%WC ; Web Services Client;2013-04-02  11:57 PM
 ;
 ; httpPOST(url,payload,mimeType,html,headerArray,timeout,test,rawResponse,respHeaders,sslHost,sslPort)
 ; Let's post using EWD
EWD ; Post using EWD
 N URL S URL="https://mocha.vistaewd.net:9281/mocha/duplicateGcn"
 N PAYLOAD D GETXML^KBAIT1(.PAYLOAD,"duplicateGcn")
 N MIME S MIME="text/xml"
 N RTN
 N OK S OK=$$httpPOST^%zewdGTM(URL,.PAYLOAD,"text/xml",.RTN)
 ZWRITE RTN
 QUIT
CURL ; Post using CURL
 N PAYLOAD D GETXML^KBAIT1(.PAYLOAD,"duplicateGcn")
 ;
 N F S F="/tmp/"_$R(987987234)_$J_".DAT"
 O F:(NEWVERSION) U F
 F I=0:0 S I=$O(PAYLOAD(I)) Q:'I  W PAYLOAD(I),!
 C F
 ;
 N URL S URL="https://mocha.vistaewd.net:9281/mocha/duplicateGcn"
 N MIME S MIME="text/xml"
 ; CURL parameters: TODO
 N CMD S CMD="curl -s -XPOST -k "_URL_" --header 'Content-Type:"_MIME_"'"_" --data-binary @"_F
 ;
 N D S D="cURLDevice"
 O D:(shell="/bin/sh":command=CMD)::"PIPE" U D
 N X F I=1:1 R X(I):1 Q:$ZEOF  K:X(I)="" X(I)
 K:X(I)="" X(I)
 C D
 ;
 ZWRITE X
 ;
 O F
 C F:(DELETE)
 ;
 QUIT
