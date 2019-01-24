%webtest ; ose/smh - Web Services Tester;Jan 23, 2019@11:56
 ; (c) Sam Habiel 2018
 ; Licensed under Apache 2.0
 ;
 ; Runs only on GTM/YDB
 ; Requires M-Unit
 ;
test if $text(^%ut)="" quit
 if $p($sy,",")'=47 quit
 do EN^%ut($t(+0),3)
 do cov
 quit
 ;
STARTUP ;
 set acvc="SM1234;SM1234!!"
 kill ^%wtrace,^%wcohort,^%wsurv
 VIEW "TRACE":1:"^%wtrace"
 kill ^%webhttp("log")
 kill ^%webhttp(0,"logging")
 do resetURLs
 job start^%webreq(55728,,,,1):(IN="/dev/null":OUT="/dev/null":ERR="/dev/null"):5
 set myJob=$zjob
 hang .1
 quit
 ;
SHUTDOWN ;
 open "p":(command="$gtm_dist/mupip stop "_myJob)::"pipe"
 use "p" r x:1
 close "p"
 w !,x,!
 ;
 kill acvc,myJob
 ;
 VIEW "TRACE":0:"^%wtrace"
 quit
 ;
tdebug ; @TEST Debug Entry Point
 job start^%webreq(55729,1,,,1):(IN="/dev/null":OUT="/dev/null":ERR="/dev/null"):5
 h .1
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55729/")
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(return["MUMPS Restful Web-Services Portal")
 ; and it halts on its own
 quit
 ;
thome ; @TEST Test Home Page
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/")
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(return["MUMPS Restful Web-Services Portal")
 quit
 ;
tgetr ; @TEST Test Get Handler Routine
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/r/%25webapi")
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(return["divergence in case an index is requested")
 quit
 ;
tputr ; @TEST Put a Routine
 i $text(^XUS)="" quit  ; VistA not installed
 n httpStatus,return,headers
 n random s random=$R(9817238947)
 n payload s payload="KBANTESTWEB ;"_random_$C(13,10)_" W ""HELLO WORLD"",!"_$C(13,10)_" QUIT"
 d &libcurl.init
 d &libcurl.auth("Basic",$tr(acvc,";",":"))
 d &libcurl.do(.httpStatus,.return,"PUT","http://127.0.0.1:55728/r/KBANTESTWEB",payload,"application/text",1,.headers)
 do CHKEQ^%ut(httpStatus,201)
 d &libcurl.cleanup
 k httpStatus,return
 d &libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/r/KBANTESTWEB")
 do CHKTF^%ut(return[random)
 quit
 ;
tgetxml ; @TEST Test Get Handler XML
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/xml")
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(return["xml")
 quit
 ;
thead ; #TEST HTTP Verb HEAD (only works with GET queries)
 ; my libcurl doesn't do HEAD :-( - but head works
 n httpStatus,return,headers,status
 d
 . n $et,$es s $et="s ec=$ec,$ec="""""
 . s status=$&libcurl.curl(.httpStatus,.return,"HEAD","http://127.0.0.1:55728/xml",,,1,.headers)
 zwrite ec
 zwrite httpStatus
 zwrite headers
 quit
 ;
tgzip ; @TEST Test gzip encoding
 n httpStatus,return,headers
 d &libcurl.init
 d &libcurl.addHeader("Accept-Encoding: gzip")
 n status s status=$&libcurl.do(.httpStatus,.return,"GET","http://127.0.0.1:55728/r/%25webapi",,,1,.headers)
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(headers["Content-Encoding: gzip")
 view "nobadchar"
 do CHKTF^%ut(return[$C(0))
 view "badchar"
 quit
 ;
tping ; @TEST Ping
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/ping")
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(return["running")
 quit
 ;
terr ; @TEST generating an error
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/error")
 do CHKEQ^%ut(httpStatus,500)
 quit
 ;
terr2 ; @TEST crashing the error trap
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/error?foo=crash2")
 do CHKEQ^%ut(httpStatus,500)
 quit
 ;
trpc1 ; @TEST Run a VistA RPC w/o authentication - should fail
 n httpStatus,return
 i $text(^XUS)="" quit  ; VistA not installed
 n payload s payload="['A','1']"
 n % s %("'")=""""
 s payload=$$REPLACE^XLFSTR(payload,.%)
 d &libcurl.init
 d &libcurl.do(.httpStatus,.return,"POST","http://127.0.0.1:55728/rpc/ORWU%20NEWPERS",payload,"application/json")
 d &libcurl.cleanup
 d CHKEQ^%ut(httpStatus,401)
 quit
 
trpc2 ; @TEST Run a VistA RPC (requires authentication - ac/vc provided)
 n httpStatus,return
 i $text(^XUS)="" quit  ; VistA not installed
 n payload s payload="['A','1']"
 n % s %("'")=""""
 s payload=$$REPLACE^XLFSTR(payload,.%)
 d &libcurl.init
 d &libcurl.auth("Basic",$tr(acvc,";",":"))
 d &libcurl.do(.httpStatus,.return,"POST","http://127.0.0.1:55728/rpc/ORWU%20NEWPERS",payload,"application/json")
 d &libcurl.cleanup
 d CHKEQ^%ut(httpStatus,201)
 ; output like: "63^Cprs,User"_$C(13,10)_"1^Manager,System"_$C(13,10)_"137^Pharmacist,Unknown Synthea"_$C(13,10)_".5^Postmaster"_$C(13,10)_"136^Provider,Unknown Synthea"_$C(13,10)
 d CHKTF^%ut(+return)
 d CHKTF^%ut(return[$C(13,10))
 quit
 ;
trpc3 ; @TEST Run the VPR RPC (XML Version)
 n httpStatus,return
 i $text(^XUS)="" quit  ; VistA not installed
 n payload s payload="[1]"
 d &libcurl.init
 d &libcurl.auth("Basic",$tr(acvc,";",":"))
 d &libcurl.do(.httpStatus,.return,"POST","http://127.0.0.1:55728/rpc/VPR%20GET%20PATIENT%20DATA",payload,"application/json")
 d &libcurl.cleanup
 d CHKEQ^%ut(httpStatus,201)
 d CHKTF^%ut(return["<")
 quit
trpc4 ; @TEST Run the VPR RPC (JSON Version)
 n httpStatus,return
 i $text(^XUS)="" quit  ; VistA not installed
 n payload s payload="[{'patientId': '23', 'domain': ''}]"
 n % s %("'")=""""
 s payload=$$REPLACE^XLFSTR(payload,.%)
 d &libcurl.init
 d &libcurl.auth("Basic",$tr(acvc,";",":"))
 d &libcurl.do(.httpStatus,.return,"POST","http://127.0.0.1:55728/rpc/VPR%20GET%20PATIENT%20DATA%20JSON",payload,"application/json")
 d &libcurl.cleanup
 d CHKEQ^%ut(httpStatus,201)
 d CHKTF^%ut(return["{")
 quit
trpcOptions ; @TEST Get RPC Options
 n httpStatus,return
 i $text(^XUS)="" quit  ; VistA not installed
 d &libcurl.curl(.httpStatus,.return,"OPTIONS","http://127.0.0.1:55728/rpc/ORWU%20NEWPERS")
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(return["NEWPERS(ORY,ORFROM,")
 quit
 ;
tParams ; @TEST Test a web service with parameters
 n httpStatus,return
 i $text(^XUS)="" quit  ; VistA not installed
 n payload s payload="start=A&direction=1"
 d &libcurl.init
 d &libcurl.auth("Basic",$tr(acvc,";",":"))
 d &libcurl.do(.httpStatus,.return,"POST","http://127.0.0.1:55728/rpc2/ORWU%20NEWPERS",payload)
 d &libcurl.cleanup
 d CHKEQ^%ut(httpStatus,201)
 ; output like: "63^Cprs,User"_$C(13,10)_"1^Manager,System"_$C(13,10)_"137^Pharmacist,Unknown Synthea"_$C(13,10)_".5^Postmaster"_$C(13,10)_"136^Provider,Unknown Synthea"_$C(13,10)
 d CHKTF^%ut(+return)
 d CHKTF^%ut(return[$C(13,10))
 quit
 ;
tDC ; @TEST Test Disconnecting from the Server w/o talking
 open "sock":(connect="127.0.0.1:55728:TCP":attach="client"):1:"socket"
 else  D FAIL^%ut("Failed to connect to server") quit
 close "sock"
 quit
 ;
tInt ; @TEST ZInterrupt
 open "p":(command="$gtm_dist/mupip intrpt "_myJob)::"pipe"
 use "p" r x:1
 close "p"
 h .1
 d CHKTF^%ut($d(^%webhttp("processlog",$p($h,","))))
 k ^%webhttp("processlog")
 QUIT
 ;
tLog1 ; @TEST Set HTTPLOG to 1
 S ^%webhttp(0,"logging")=1
 K ^%webhttp("log",+$H)
 n httpStatus,return
 d &libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/ping")
 n s s s=$o(^%webhttp("log",+$h,""))
 d CHKTF^%ut(^%webhttp("log",+$h,s,1,"raw"))
 d CHKTF^%ut(^%webhttp("log",+$h,s,1,"req","header"))
 quit
 ;
tLog2 ; @TEST Set HTTPLOG to 2
 S ^%webhttp(0,"logging")=2
 K ^%webhttp("log",+$H)
 n httpStatus,return
 d &libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/ping")
 n s s s=$o(^%webhttp("log",+$h,""))
 d CHKTF^%ut(^%webhttp("log",+$h,s,1,"raw"))
 d CHKTF^%ut(^%webhttp("log",+$h,s,1,"req","header"))
 quit
 ;
tLog3 ; @TEST Set HTTPLOG to 3
 i $text(^XUS)="" quit  ; VistA not installed
 S ^%webhttp(0,"logging")=3
 K ^%webhttp("log",+$H)
 n httpStatus,return
 n payload s payload="['A','1']"
 n % s %("'")=""""
 s payload=$$REPLACE^XLFSTR(payload,.%)
 d &libcurl.init
 d &libcurl.auth("Basic",$tr(acvc,";",":"))
 d &libcurl.do(.httpStatus,.return,"POST","http://127.0.0.1:55728/rpc/ORWU%20NEWPERS",payload,"application/json")
 d &libcurl.cleanup
 d CHKEQ^%ut(httpStatus,201)
 ; output like: "63^Cprs,User"_$C(13,10)_"1^Manager,System"_$C(13,10)_"137^Pharmacist,Unknown Synthea"_$C(13,10)_".5^Postmaster"_$C(13,10)_"136^Provider,Unknown Synthea"_$C(13,10)
 d CHKTF^%ut(+return)
 d CHKTF^%ut(return[$C(13,10))
 n s s s=$o(^%webhttp("log",+$h,""))
 d CHKTF^%ut($d(^%webhttp("log",+$h,s,1,"response")))
 quit
 ;
tDCLog ; @TEST Test Disconnecting from the Server w/o talking while logging
 S ^%webhttp(0,"logging")=3
 K ^%webhttp("log",+$H)
 open "sock":(connect="127.0.0.1:55728:TCP":attach="client"):1:"socket"
 else  D FAIL^%ut("Failed to connect to server") quit
 close "sock"
 h .1
 n s s s=$o(^%webhttp("log",+$h,""))
 d CHKTF^%ut($d(^%webhttp("log",+$h,s,1,"disconnect")))
 quit
 ;
tWebPage ; @TEST Test Getting a web page
 new oldDir set oldDir=$g(^%webhome)
 set ^%webhome="/tmp/"
 zsy "mkdir -p /tmp/foo"
 new random s random=$R(9817234)
 open "/tmp/foo/boo.html":(newversion)
 use "/tmp/foo/boo.html"
 write "<!DOCTYPE html>",!
 write "<html>",!
 write "<body>",!
 write "<h1>My First Heading</h1>",!
 write "<p>My first paragraph."_random_"</p>",!
 write "</body>",!
 write "</html>",!
 close "/tmp/foo/boo.html"
 n httpStatus,return
 d &libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/foo/boo.html")
 d CHKEQ^%ut(httpStatus,200)
 d CHKTF^%ut(return[random)
 set ^%webhome="/tmp"
 d &libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/foo/boo.html")
 d CHKEQ^%ut(httpStatus,200)
 d CHKTF^%ut(return[random)
 set ^%webhome=oldDir
 quit
 ;
tINIT ; @TEST Test Fileman INIT code
 if $text(^DI)="" quit  ; no fileman
 ;
 ; Delete the old DD
 set DIU="^%web(17.6001,",DIU(0)="ES" do EN^DIU2
 do CHKTF^%ut('$data(^DD(17.6001)))
 do CHKTF^%ut('$data(^DD("IX","F",17.6001)))
 ;
 do ^%webINIT
 do CHKTF^%ut($data(^DD(17.6001)))
 do CHKTF^%ut($data(^DD("IX","F",17.6001)))
 quit
 ;
tStop ; @TEST Stop the Server. MUST BE LAST TEST HERE.
 do stop^%webreq
 quit
 ;
 ;
cov ; [Private: Calculate Coverage]
 n rtn,t1,t2 f i=1:1 s t1=$t(covlist+i),t2=$p(t1,";;",2) quit:t2=""  s rtn(t2)=""
 d RTNANAL^%ut1(.rtn,$na(^%wcohort))
 k ^%wsurv m ^%wsurv=^%wcohort
 d COVCOV^%ut1($na(^%wsurv),$na(^%wtrace)) ; Venn diagram matching between globals
 d COVRPT^%ut1($na(^%wcohort),$na(^%wsurv),$na(^%wtrace),2)
 quit
 ;
resetURLs ; Reset all the URLs; Called upon start-up
 d deleteService^%webutils("GET","r/{routine?.1""%25"".32AN}")
 d deleteService^%webutils("PUT","r/{routine?.1""%25"".32AN}")
 d deleteService^%webutils("GET","error")
 d deleteService^%webutils("POST","rpc/{rpc}")
 d deleteService^%webutils("OPTIONS","rpc/{rpc}")
 d deleteService^%webutils("POST","rpc2/{rpc}")
 ;
 do addService^%webutils("GET","r/{routine?.1""%25"".32AN}","R^%webapi")
 do addService^%webutils("PUT","r/{routine?.1""%25"".32AN}","PR^%webapi",1,"XUPROGMODE")
 do addService^%webutils("GET","error","ERR^%webapi")
 do addService^%webutils("POST","rpc/{rpc}","RPC^%webapi",1)
 do addService^%webutils("OPTIONS","rpc/{rpc}","RPCO^%webapi")
 n params s params(1)="U^rpc",params(2)="F^start",params(3)="F^direction",params(4)="B"
 n ien s ien=$$addService^%webutils("POST","rpc2/{rpc}","rpc2^%webapi",1,"","",.params)
 quit
 ;
XTROU ;
 ;;%webjsonEncodeTest
 ;;%webjsonDecodeTest
 ;;
covlist ; Coverage List for ACTIVE (non-test) routines
 ;;%webreq
 ;;%webrsp
 ;;%webapi
 ;;%webhome
 ;;%webutils
 ;;%webjson
 ;;%webjsonDecode
 ;;%webjsonEncode
 ;;
