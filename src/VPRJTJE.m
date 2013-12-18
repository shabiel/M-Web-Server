VPRJTJE ;SLC/KCM -- Unit tests for JSON encoding
 ;;1.0;JSON DATA STORE;;Sep 01, 2012
 ;
 D EN^XTMUNIT($T(+0),1) ; Run Unit Tests
 QUIT
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
 D ASSERT($$TARGET("BASIC"),JSON(1))
 Q
VALS ;; @TEST encode simple values only object as JSON
 N X,JSON
 S X("prop1")="property1"
 S X("bool1")="true"
 S X("num1")="2.1e3"
 S X("arr",1)="apple"
 S X("arr",2)="orange"
 S X("arr",3)="pear"
 S X("arr",4,"obj")="4th array item is object"
 D ENCODE^VPRJSON("X","JSON")
 D ASSERT($$TARGET("VALS"),JSON(1))
 Q
LONG ;; @TEST encode object with continuation nodes for value
 N X,I,JSON,FILLER,TARGET
 S FILLER=", this will extend the line out to at least 78 characters."_$C(10)
 S X("title")="My note test title"
 S X("note")="This is the first line of the note.  Here are ""quotes"" and a \ and a /."_$C(10)
 F I=1:1:60 S X("note","\",I)="Additional Line #"_I_FILLER
 D ENCODE^VPRJSON("X","JSON")
 S TARGET=$$TARGET("LONG")
 D ASSERT(TARGET,$E(JSON(1),1,$L(TARGET)))
 D ASSERT(1,$D(JSON(2)))
 D ASSERT(0,$D(JSON(3)))
 S TARGET="s.\n"",""title"":""My note test title""}"
 D ASSERT(TARGET,$E(JSON(2),$L(JSON(2))-$L(TARGET)+1,$L(JSON(2))))
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
 D ASSERT(TARGET,JSON(1))
 Q
WP ;; @TEST word processing nodes inside object
 N Y,JSON,TARGET
 D BUILDY("WP")
 D ENCODE^VPRJSON("Y","JSON")
 S TARGET=$$TARGET("WPOUT")_$$TARGET("WPOUT",2)_$$TARGET("WPOUT",3)
 D ASSERT(TARGET,JSON(1))
 Q
LTZERO ;; @TEST leading / trailing zeros get preserved
 N Y,JSON,TARGET
 S Y("count")=737
 S Y("ssn")="000427930"
 S Y("icd")="626.00"
 S Y("price")=".65"
 S Y("errors")=0
 D ENCODE^VPRJSON("Y","JSON")
 D ASSERT($$TARGET("LTZERO"),JSON(1))
 ;W !,"Y ---",! ZW Y W !,"JSON ---",! W JSON(1)
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
 ;
QUOTE ;; @TEST - quotes in subject are properly escaped.
 N Y,JSON,TARGET,ERR
 S Y("DDOUT(""0.85,0.01"")")=1
 D ENCODE^VPRJSON("Y","JSON","ERR")
 D ASSERT(0,$D(ERR))
 D ASSERT($$TARGET("QUOTE"),JSON(1))
 QUIT
 ;
EXAMPLE ;; @TEST encode samples that are on JSON.ORG
 N Y,JSON,TARGET
 D BUILDY("EX1IN")
 D ENCODE^VPRJSON("Y","JSON")
 S TARGET=$$TARGET("EX1OUT")
 D ASSERT(TARGET,JSON(1))
 D BUILDY("EX2IN")
 D ENCODE^VPRJSON("Y","JSON")
 S TARGET=$$TARGET("EX2OUT")_$$TARGET("EX2OUT",2)
 D ASSERT(TARGET,JSON(1))
 D BUILDY("EX3IN")
 D ENCODE^VPRJSON("Y","JSON")
 S TARGET=$$TARGET("EX3OUT")_$$TARGET("EX3OUT",2)
 D ASSERT(TARGET,JSON(1))
 D BUILDY("EX4IN")
 D ENCODE^VPRJSON("Y","JSON")
 S TARGET=$$TARGET("EX4OUT")
 D ASSERT(TARGET,$E(JSON(1),1,215))
 D ASSERT(2758,$L(JSON(1)))
 Q
BUILDY(LABEL) ; build Y array based on LABEL
 ; expects Y from EXAMPLE
 N I,X
 K Y
 F I=1:1 S X=$P($T(@LABEL+I^VPRJTJED),";;",2,999) Q:X="zzzzz"  X "S "_X
 Q
TARGET(ID,OFFSET) ; values to test against
 S OFFSET=$G(OFFSET,1)
 Q $P($T(@ID+OFFSET^VPRJTJED),";;",2,999)
