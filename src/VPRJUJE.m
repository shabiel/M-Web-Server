VPRJUJE ;SLC/KCM -- Unit tests for JSON encoding
 ;;1.0;JSON DATA STORE;;Sep 01, 2012
 ;
 D EN^%ut($T(+0),3)
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
NUMERIC ;; @TEST is numeric function
 D ASSERT(0,$$NUMERIC^VPRJSONE("2COWS"))
 D ASSERT(0,$$NUMERIC^VPRJSONE("007"))
 D ASSERT(0,$$NUMERIC^VPRJSONE(".4"))
 D ASSERT(1,$$NUMERIC^VPRJSONE("0.4"))
 D ASSERT(0,$$NUMERIC^VPRJSONE("-.4"))
 D ASSERT(1,$$NUMERIC^VPRJSONE("-0.4"))
 D ASSERT(1,$$NUMERIC^VPRJSONE(0))
 D ASSERT(0,$$NUMERIC^VPRJSONE(".0"))
 D ASSERT(1,$$NUMERIC^VPRJSONE(3.1416))
 D ASSERT(1,$$NUMERIC^VPRJSONE("2.3E-2"))
 D ASSERT(1,$$NUMERIC^VPRJSONE(0.4E12))
 D ASSERT(0,$$NUMERIC^VPRJSONE(".4E-12"))
 Q
NEARZERO ;; @TEST encode of numbers near 0
 ;;{"s":"0.5","t":"-0.6","x":0.42,"y":-0.44}
 N X,JSON,ERR
 S X("s")="0.5",X("s","\s")=""
 S X("t")="-0.6",X("t","\s")=""
 S X("x")=0.42
 S X("y")=-0.44
 D ENCODE^VPRJSON("X","JSON","ERR")
 D ASSERT($P($T(NEARZERO+1),";;",2,99),JSON(1))
 Q
JSONESC ;; @TEST create JSON escaped string
 N X
 S X=$$ESC^VPRJSON("String with \ in the middle")
 D ASSERT("String with \\ in the middle",X)
 S X=$$ESC^VPRJSON("\ is the first character of this string")
 D ASSERT("\\ is the first character of this string",X)
 S X=$$ESC^VPRJSON("The last character of this string is \")
 D ASSERT("The last character of this string is \\",X)
 S X=$$ESC^VPRJSON("\one\two\three\")
 D ASSERT("\\one\\two\\three\\",X)
 S X=$$ESC^VPRJSON("A vee shape: \/"_$C(9)_"TABBED"_$C(9)_"and line endings."_$C(10,13,12))
 D ASSERT("A vee shape: \\\/\tTABBED\tand line endings.\n\r\f",X)
 S X=$$ESC^VPRJSON("""This text is quoted""")
 D ASSERT("\""This text is quoted\""",X)
 S X=$$ESC^VPRJSON("This text contains an embedded"_$C(26)_" control character")
 D ASSERT("This text contains an embedded\u001A control character",X)
 S X=$$ESC^VPRJSON("This contains tab"_$C(9)_" and control"_$C(22)_" characters")
 D ASSERT("This contains tab\t and control\u0016 characters",X)
 S X=$$ESC^VPRJSON("This has embedded NUL"_$C(0)_" character.")
 D ASSERT("This has embedded NUL character.",X)
 Q
BASIC ;; @TEST encode basic object as JSON
 N X,JSON
 S X("myObj","booleanT")="true"
 S X("myObj","booleanF")="false"
 S X("myObj","numeric")=3.1416
 S X("myObj","nullValue")="null"
 S X("myObj","array",1)="one"
 S X("myObj","array",2)="two"
 S X("myObj","array",3)="three"
 S X("myObj","subObject","fieldA")="hello"
 S X("myObj","subObject","fieldB")="world"
 D ENCODE^VPRJSON("X","JSON")
 D ASSERT($$TARGET("BASIC"),JSON(1)_JSON(2))
 Q
VALS ;; @TEST encode simple values only object as JSON
 N X,JSON
 S X("prop1")="property1"
 S X("bool1")="true"
 S X("num1")="2.1e3",X("num1","\n")=""
 S X("arr",1)="apple"
 S X("arr",2)="orange"
 S X("arr",3)="pear"
 S X("arr",4,"obj")="4th array item is object"
 D ENCODE^VPRJSON("X","JSON")
 D ASSERT($$TARGET("VALS"),JSON(1)_JSON(2))
 Q
LONG ;; @TEST encode object with continuation nodes for value
 N X,I,JSON,FILLER,TARGET
 S FILLER=", this will extend the line out to at least 78 characters."_$C(10)
 S X("title")="My note test title"
 S X("note")="This is the first line of the note.  Here are ""quotes"" and a \ and a /."_$C(10)
 F I=1:1:60 S X("note","\",I)="Additional Line #"_I_FILLER
 D ENCODE^VPRJSON("X","JSON")
 S TARGET=$$TARGET("LONG")
 D ASSERT(TARGET,$E(JSON(1)_JSON(2)_JSON(3),1,$L(TARGET)))
 D ASSERT(1,$D(JSON(62)))
 D ASSERT(0,$D(JSON(63)))
 S TARGET="t least 78 characters.\n"",""title"":"
 D ASSERT(TARGET,$E(JSON(61),$L(JSON(61))-$L(TARGET)+1,$L(JSON(61))))
 Q
PRE ;; @TEST encode object where parts are already JSON encoded
 N X,JSON,TARGET
 S X("count")=3
 S X("menu",1,":",1)=$$TARGET("NODES",1)
 S X("menu",2,":",1)=$$TARGET("NODES",2)
 S X("menu",3,":",1)=$$TARGET("NODES",3)
 S X("template",":")=$$TARGET("NODES",4)
 D ENCODE^VPRJSON("X","JSON")
 S TARGET=$$TARGET("PRE",1)_$$TARGET("PRE",2)
 D ASSERT(TARGET,JSON(1)_JSON(2)_JSON(3))
 Q
WP ;; @TEST word processing nodes inside object
 N Y,JSON,TARGET,ERR
 D BUILDY("WP")
 D ENCODE^VPRJSON("Y","JSON","ERR")
 D ASSERT(0,$D(ERR))
 S TARGET=$$TARGET("WPOUT")_$$TARGET("WPOUT",2)_$$TARGET("WPOUT",3)
 D ASSERT(TARGET,JSON(1)_JSON(2)_JSON(3)_JSON(4)_JSON(5)_JSON(6)_JSON(7))
 Q
LTZERO ;; @TEST leading / trailing zeros get preserved
 N Y,JSON,TARGET
 S Y("count")=737
 S Y("ssn")="000427930"
 S Y("icd")="626.00"
 S Y("price")=".65" ;M still treats this as a number, so in JSON it's 0.65
 S Y("code")=".77",Y("code","\s")=""
 S Y("errors")=0
 D ENCODE^VPRJSON("Y","JSON")
 D ASSERT($$TARGET("LTZERO"),JSON(1))
 Q
STRINGS ;; @TEST force encoding as string
 N Y,JSON,TARGET,ERR
 S Y("count")=234567
 S Y("hl7Time")="20120919"
 S Y("hl7Time","\s")=""
 S Y("icd")="722.10"
 S Y("name")="Duck,Donald"
 D ENCODE^VPRJSON("Y","JSON","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT($$TARGET("STRINGS"),JSON(1))
 Q
LABELS ;; @TEST unusual labels
 ;;{"top":[{"10":"number 10",",":"comma",":":"colon","\":"backslash","a":"normal letter"}]}
 ;
 ; NOTE: we don't allow a label to contain a quote (")
 N Y,JSON,ERR,Y2
 S Y("top",1,":")="colon"
 S Y("top",1,"\")="backslash"
 S Y("top",1,",")="comma"
 S Y("top",1,"a")="normal letter"
 S Y("top",1,"""10")="number 10"
 D ENCODE^VPRJSON("Y","JSON","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT($P($T(LABELS+1),";;",2,99),JSON(1))
 Q
EXAMPLE ;; @TEST encode samples that are on JSON.ORG
 N Y,JSON,TARGET
 D BUILDY("EX1IN")
 D ENCODE^VPRJSON("Y","JSON")
 S TARGET=$$TARGET("EX1OUT")
 D ASSERT(TARGET,JSON(1)_JSON(2))
 D BUILDY("EX2IN")
 D ENCODE^VPRJSON("Y","JSON")
 S TARGET=$$TARGET("EX2OUT")_$$TARGET("EX2OUT",2)
 D ASSERT(TARGET,JSON(1)_JSON(2)_JSON(3)_JSON(4)_JSON(5))
 D BUILDY("EX3IN")
 D ENCODE^VPRJSON("Y","JSON")
 S TARGET=$$TARGET("EX3OUT")_$$TARGET("EX3OUT",2)
 D ASSERT(TARGET,JSON(1)_JSON(2)_JSON(3)_JSON(4))
 D BUILDY("EX4IN")
 D ENCODE^VPRJSON("Y","JSON")
 S TARGET=$$TARGET("EX4OUT")
 D ASSERT(TARGET,$E(JSON(1)_JSON(2)_JSON(3),1,215))
 D ASSERT(95,$L(JSON(1)))
 Q
BUILDY(LABEL) ; build Y array based on LABEL
 ; expects Y from EXAMPLE
 N I,X
 K Y
 F I=1:1 S X=$P($T(@LABEL+I^VPRJUJ02),";;",2,999) Q:X="zzzzz"  X "S "_X
 Q
TARGET(ID,OFFSET) ; values to test against
 S OFFSET=$G(OFFSET,1)
 Q $P($T(@ID+OFFSET^VPRJUJ02),";;",2,999)
