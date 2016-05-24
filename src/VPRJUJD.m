VPRJUJD ;SLC/KCM -- Unit tests for JSON decoding
 ;;1.0;JSON DATA STORE;;Sep 01, 2012
 ;
 d EN^%ut($t(+0),3)
 quit
 ;
STARTUP  ; Run once before all tests
 Q
SHUTDOWN ; Run once after all tests
 Q
SETUP    ; Run before each test
 Q
TEARDOWN ; Run after each test
 Q
ASSERT(EXPECT,ACTUAL) ; convenience
 D CHKEQ^%ut(EXPECT,ACTUAL)
 Q
 ;
JSONUES ;; @TEST unescape JSON encoded string
 N X
 S X=$$UES^VPRJSON("String with \\ in the middle")
 D ASSERT("String with \ in the middle",X)
 S X=$$UES^VPRJSON("\\ is the first character of this string")
 D ASSERT("\ is the first character of this string",X)
 S X=$$UES^VPRJSON("The last character of this string is \\")
 D ASSERT("The last character of this string is \",X)
 S X=$$UES^VPRJSON("\\one\\two\\three\\")
 D ASSERT("\one\two\three\",X)
 S X=$$UES^VPRJSON("A vee shape: \\\/\tTABBED\tand line endings.\n\r\f")
 D ASSERT("A vee shape: \/"_$C(9)_"TABBED"_$C(9)_"and line endings."_$C(10,13,12),X)
 S X=$$UES^VPRJSON("\""This text is quoted\""")
 D ASSERT("""This text is quoted""",X)
 S X=$$UES^VPRJSON("This text contains an embedded\u001A control character")
 D ASSERT("This text contains an embedded"_$C(26)_" control character",X)
 S X=$$UES^VPRJSON("This contains tab\t and control\u0016 characters")
 D ASSERT("This contains tab"_$C(9)_" and control"_$C(22)_" characters",X)
 Q
SPLITA ;; @TEST JSON input with escaped characters on single line (uses BUILD)
 N JSON,Y,ERR,ESC
 ; V4W/DLW - Removed "string" from SPLIT+3^VPRJUJ01
 S ESC="this contains \and other escaped characters such as "_$c(10)
 ; V4W/DLW - Removed "a piece of" from SPLIT+5^VPRJUJ01
 S ESC=ESC_"  and a few tabs "_$c(9,9,9,9)_" and ""quoted text"""
 D BUILD("SPLIT",.JSON)
 D ASSERT(0,$D(JSON(2)))
 D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(ESC,$G(Y("esc")))
 D ASSERT("this is a new line",$G(Y("next")))
 D ASSERT("this is a string that goes across two lines",$G(Y("wp")))
 D ASSERT("here is another string",$G(Y("nextLineQuote")))
 Q
SPLITB ;; @TEST multiple line JSON input with lines split across tokens (uses BUILDA)
 N JSON,Y,ERR,ESC
 ; V4W/DLW - Removed "string" from SPLIT+3^VPRJUJ01
 S ESC="this contains \and other escaped characters such as "_$c(10)
 ; V4W/DLW - Removed "a piece of" from SPLIT+5^VPRJUJ01
 S ESC=ESC_"  and a few tabs "_$c(9,9,9,9)_" and ""quoted text"""
 D BUILDA("SPLIT",.JSON)
 D ASSERT(1,$D(JSON(2)))
 D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(ESC,$G(Y("esc")))
 D ASSERT("this is a new line",$G(Y("next")))
 D ASSERT("this is a string that goes across two lines",$G(Y("wp")))
 D ASSERT("here is another string",$G(Y("nextLineQuote")))
 Q
SPLITC ;; @TEST multiple line JSON input with lines split inside boolean value
 N JSON,Y,ERR,ESC
 D BUILDA("SPLITC",.JSON)
 D ASSERT(1,$D(JSON(4)))
 D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT("false",$G(Y("completed")))
 D ASSERT("urn:va:user:2C0A:1134",$G(Y("ownerCode")))
 D ASSERT("SQA,ONE",$G(Y("assignToName")))
 D ASSERT("urn:va:user:2C0A:1134",$G(Y("assignToCode")))
 Q
LONG ;; @TEST long document that must be saved across extension nodes
 N JSON,Y,ERR,I,LINE,CCNT1,CCNT2
 S JSON(1)="{""title"":""long document"",""size"":""rather large"",""document"":"""
 S LINE="This is a line of text intended to test longer documents.\r\n  It will be repeated so that there are several nodes that must be longer than 4000 kilobytes."
 F I=2:1:100 S JSON(I)=LINE
 S JSON(101)="\r\nThis line ends with a control character split over to the next line.\u0"
 S JSON(102)="016The last line has a control character.\u001A"
 S JSON(103)=""",""author"":""WINDED,LONG""}"
 D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 S CCNT1=0 F I=2:1:102  S CCNT1=CCNT1+$L(JSON(I))
 S CCNT2=$L(Y("document")) F I=1:1:199 S CCNT2=CCNT2+$L(Y("document","\",I))
 D ASSERT(210,CCNT1-CCNT2) ; 100 \r\n->$C(13,10), 1 \u001a->$C(26), 1 \u0016->$C(22) = 210 less chars
 D ASSERT(59,$L(Y("document")))
 D ASSERT(94,$L(Y("document","\",3)))
 D ASSERT(1,Y("document","\",198)[$C(22))
 D ASSERT($C(26),$E(Y("document","\",199),$L(Y("document","\",199))))
 D ASSERT(0,$D(Y("document",4)))
 D ASSERT("WINDED,LONG",Y("author"))
 D ASSERT("rather large",Y("size"))
 Q
FRAC ;; @TEST multiple lines with fractional array elements
 ;; {"title":"my array of stuff", "count":3, "items": [
 ;; {"name":"red", "rating":"ok"},
 ;; {"name":"blue", "rating":"good"},
 ;; {"name":"purple", "rating":"outstanding"}
 ;; ]}
 N JSON,Y,ERR
 S JSON(0)=$P($T(FRAC+1),";;",2,99)
 S JSON(.5)=$P($T(FRAC+2),";;",2,99)
 S JSON(1)=$P($T(FRAC+3),";;",2,99)
 S JSON(1.1)=$P($T(FRAC+4),";;",2,99)
 S JSON(1.2)=$P($T(FRAC+5),";;",2,99)
 S JSON("JUNK")="Junk non-numeric node -- this should be ignored"
 D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT("purple",Y("items",3,"name"))
 Q
VALONLY ;; @TEST passing in value only -- not array
 N JSON,Y,ERR
 S JSON=$P($T(VALONLY+1^VPRJUJ01),";;",2,999)
 D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT("urn:va:param:F484:1120:VPR USER PREF:1120",Y("uid"))
 D ASSERT("north",Y("vals","cpe.patientpicker.loc"))
 Q
NUMERIC ;; @TEST passing in numeric types and strings
 N JSON,Y,ERR
 S JSON=$P($T(NUMERIC+1^VPRJUJ01),";;",2,999)
 D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(234567,+Y("count")) ; make sure it's numeric
 D ASSERT(20120919,Y("hl7Time"))
 D ASSERT(1,$D(Y("hl7Time","\s")))
 D ASSERT("722.10",Y("icd"))
 D ASSERT(0,+Y("icd")="722.10") ; make sure it's a string
 Q
NEARZERO ;; @TEST decoding numbers near 0
 ;; {"x":0.42, "y":-0.44, "s":"0.5", "t":"-0.6"}
 N JSON,JSON2,Y,ERR
 S JSON=$P($T(NEARZERO+1),";;",2,999)
 D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(1,$D(Y("x","\n")))
 D ASSERT(1,$D(Y("y","\n")))
 D ASSERT(.42,Y("x"))
 D ASSERT(-.44,Y("y"))
 D ASSERT(0,Y("s")=.5)
 D ASSERT(0,Y("t")=-.6)
 Q
BADQUOTE ;; @TEST poorly formed JSON (missing close quote on LABEL)
 N JSON,Y,ERR
 D BUILD("BADQUOTE",.JSON) D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(1,$D(ERR)>0)
 Q
BADSLASH ;; @TEST poorly formed JSON (non-escaped backslash)
 N JSON,Y,ERR
 D BUILD("BADSLASH",.JSON) D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(1,$D(ERR)>0)
 Q
PSNUM ;; @TEST subjects that look like a numbers shouldn't be encoded as numbers
 N JSON,Y,ERR
 D BUILD("PSNUM",.JSON)
 D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(Y("0.85,0.01","AUDIT"),"TEST1")
 D ASSERT(Y("0.85,0.02","AUDIT"),"TEST3")
 D ASSERT(Y("0.85,0.03","AUDIT"),"TEST5")
 Q
NUMLABEL ;; @TEST label that begins with numeric
 N JSON,Y,ERR
 D BUILD("NUMLABEL",.JSON) D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(46570,Y("syncStatusByVistaSystemId","9E99","dfn"))
 Q
PURENUM ;; @TEST label that is purely numeric
 N JSON1,JSON2,Y,RSLT,ERR
 D BUILD("PURENUM1",.JSON1)
 D DECODE^VPRJSON("JSON1","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(100,Y("syncStatusByVistaSystemId","""1234","domainExpectedTotals","bar","total"))
 D ASSERT(1,$D(Y("forOperational","\s"))) ; appears boolean but really a string
 D ENCODE^VPRJSON("Y","JSON2","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(1,($L(JSON1(1))=($L(JSON2(1))+$L(JSON2(2))+$L(JSON2(3)))))
 D ASSERT(1,(JSON2(2)[":{""1234"":{"))
 D BUILD("PURENUM2",.RSLT)
 D ASSERT(RSLT(1),JSON2(1)_JSON2(2)_JSON2(3))
 Q
STRTYPES ;; @TEST strings that may be confused with other types
 N JSON,Y,ERR
 D BUILD("STRTYPES",.JSON)
 D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(1,$D(Y("syncStatusByVistaSystemId","""1234","syncComplete","\s")))
 Q
ESTRING ;; @TEST a value that looks like an exponents, other numerics
 N JSON,Y,JSON2,ERR
 D BUILD("ESTRING",.JSON) D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT("32E497ABC",Y("b"))
 D ASSERT(.123,Y("c"))
 D ASSERT(3E22,Y("g"))
 D ASSERT(1,$D(Y("g","\n")))
 D ASSERT(0,Y("h")=2E8)
 D ENCODE^VPRJSON("Y","JSON2","ERR")
 D ASSERT(1,JSON(1)=(JSON2(1)_JSON2(2)))
 Q
SAM1 ;; @TEST decode sample 1 from JSON.ORG
 N JSON,Y,ERR
 D BUILD("SAM1",.JSON) D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT("file",$G(Y("menu","id")))
 D ASSERT("OpenDoc()",$G(Y("menu","popup","menuitem",2,"onclick")))
 Q
SAM2 ;; @TEST decode sample 2 from JSON.ORG
 N JSON,Y,ERR
 D BUILD("SAM2",.JSON) D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT("XML",$G(Y("glossary","GlossDiv","GlossList","GlossEntry","GlossDef","GlossSeeAlso",2)))
 D ASSERT("SGML",$G(Y("glossary","GlossDiv","GlossList","GlossEntry","SortAs")))
 Q
SAM3 ;; @TEST decode sample 3 from JSON.ORG
 N JSON,Y,ERR
 D BUILD("SAM3",.JSON) D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(500,$G(Y("widget","window","width")))
 D ASSERT("sun1.opacity = (sun1.opacity / 100) * 90;",$G(Y("widget","text","onMouseUp")))
 D ASSERT("Sample Konfabulator Widget",$G(Y("widget","window","title")))
 Q
SAM4 ;; @TEST decode sample 4 from JSON.ORG
 N JSON,Y,ERR
 D BUILD("SAM4",.JSON) D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(0,$D(Y("web-app","servlet",6)))  ; should only be 5 servlets
 D ASSERT(1,$G(Y("web-app","servlet",5,"init-param","log")))
 D ASSERT("/usr/local/tomcat/logs/CofaxTools.log",$G(Y("web-app","servlet",5,"init-param","logLocation")))
 D ASSERT("/",$G(Y("web-app","servlet-mapping","cofaxCDS")))
 D ASSERT("/WEB-INF/tlds/cofax.tld",$G(Y("web-app","taglib","taglib-location")))
 Q
SAM5 ;; @TEST decode sample 5 from JSON.ORG
 N JSON,Y,ERR
 D BUILD("SAM5",.JSON) D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(0,$D(Y("menu","items",23)))  ; should only be 22 items
 D ASSERT("About Adobe CVG Viewer...",$G(Y("menu","items",22,"label")))
 D ASSERT("null",$G(Y("menu","items",3)))
 Q
 ;
MAXNUM ;; @TEST encode large string that looks like number
 N I,X,Y,JSON,ERR,OUT
 F I=0:1 S X=$P($T(MAXNUM+(I+1)^VPRJUJ01),";;",2,999) Q:X="#####"  S JSON(I)=X
 D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(217,$L(Y("taskName","\",1)))
 D ENCODE^VPRJSON("Y","OUT","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(1,$L(OUT(1))=93)
 D ASSERT(1,OUT(3)["""facilityCode"":""500")
 Q
ESCQ ;; @TEST escaped quote across lines
 N JSON,Y,ERR
 D BUILDA("ESCQ",.JSON) D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(55,$L(Y("comments")))
 K JSON,Y,ERR
 D BUILDA("ESCQ2",.JSON) D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(42,$L(Y("bjw")))
 Q
BUILD(TAG,JSON) ; Build array of strings in JSON for TAG
 N X,I,LINE
 S LINE=1,JSON(LINE)=""
 F I=1:1 S X=$E($T(@TAG+I^VPRJUJ01),4,999) Q:X="#####"  D
 . I $L(JSON(LINE))+$L(X)>4000 S LINE=LINE+1,JSON(LINE)=""
 . S JSON(LINE)=JSON(LINE)_X
 Q
BUILDA(TAG,JSON) ; Build array of string in JSON with splits preserved
 N X,I
 F I=1:1 S X=$E($T(@TAG+I^VPRJUJ01),4,999) Q:X="#####"  S JSON(I)=X
 Q
