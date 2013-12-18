VPRJTJD ;SLC/KCM -- Unit tests for JSON decoding
 ;;1.0;JSON DATA STORE;;Sep 01, 2012
 D EN^XTMUNIT($T(+0),1) QUIT
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
 D CHKEQ^XTMUNIT(EXPECT,ACTUAL)
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
 Q
SPLITA ;; @TEST JSON input with escaped characters on single line
 N JSON,Y,ERR,ESC
 S ESC="this string contains \and other escaped characters such as "_$c(10)
 S ESC=ESC_"  and a few tabs "_$c(9,9,9,9)_" and a piece of ""quoted text"""
 D BUILD("SPLIT",.JSON) D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(ESC,$G(Y("esc")))
 D ASSERT("this is a new line",$G(Y("next")))
 D ASSERT("this is a string that goes across two lines",$G(Y("wp")))
 D ASSERT("here is another string",$G(Y("nextLineQuote")))
 Q
SPLITB ;; @TEST multiple line JSON input with lines split across tokens
 N JSON,Y,ERR,ESC
 S ESC="this string contains \and other escaped characters such as "_$c(10)
 S ESC=ESC_"  and a few tabs "_$c(9,9,9,9)_" and a piece of ""quoted text"""
 D BUILDA("SPLIT",.JSON) D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(ESC,$G(Y("esc")))
 D ASSERT("this is a new line",$G(Y("next")))
 D ASSERT("this is a string that goes across two lines",$G(Y("wp")))
 D ASSERT("here is another string",$G(Y("nextLineQuote")))
 Q
LONG ;; @TEST long document that must be saved across extension nodes
 N JSON,Y,ERR,I,LINE
 S JSON(1)="{""title"":""long document"",""size"":""rather large"",""document"":"""
 S LINE="This is a line of text intended to test longer documents.\r\n  It will be repeated so that there are several nodes that must be longer than 4000 kilobytes."
 F I=2:1:100 S JSON(I)=LINE
 S JSON(101)=""",""author"":""WINDED,LONG""}"
 D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(3978,$L(Y("document")))
 D ASSERT(3213,$L(Y("document","\",3)))
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
 S JSON=$P($T(VALONLY+1^VPRJTJDD),";;",2,999)
 D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT("urn:va:param:F484:1120:VPR USER PREF:1120",Y("uid"))
 D ASSERT("north",Y("vals","cpe.patientpicker.loc"))
 Q
NUMERIC ;; @TEST passing in numeric types and strings
 N JSON,Y,ERR
 S JSON=$P($T(NUMERIC+1^VPRJTJDD),";;",2,999)
 D DECODE^VPRJSON("JSON","Y","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT(234567,+Y("count")) ; make sure it's numeric
 D ASSERT(20120919,Y("hl7Time"))
 D ASSERT(1,$D(Y("hl7Time","\s")))
 D ASSERT("722.10",Y("icd"))
 D ASSERT(0,+Y("icd")="722.10") ; make sure it's a string
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
 QUIT
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
BUILD(TAG,JSON) ; Build array of strings in JSON for TAG
 N X,I,LINE
 S LINE=1,JSON(LINE)=""
 F I=1:1 S X=$E($T(@TAG+I^VPRJTJDD),4,999) Q:X="#####"  D
 . I $L(JSON(LINE))+$L(X)>4000 S LINE=LINE+1,JSON(LINE)=""
 . S JSON(LINE)=JSON(LINE)_X
 Q
BUILDA(TAG,JSON) ; Build array of string in JSON with splits preserved
 N X,I
 F I=1:1 S X=$E($T(@TAG+I^VPRJTJDD),4,999) Q:X="#####"  S JSON(I)=X
 Q
