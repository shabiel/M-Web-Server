%webtest ; ose/smh - Web Services Tester;2019-01-21  4:41 PM
 ; (c) Sam Habiel 2018
 ; Licensed under Apache 2.0
 ;
 ; Runs only on GTM/YDB
 ; Requires M-Unit
 ;
test if $text(^%ut)="" quit
 do EN^%ut($t(+0),3)
 do cov
 quit
 ;
STARTUP ;
 set acvc="SM1234;CATDOG.44"
 kill ^%wtrace,^%wcohort,^%wsurv
 kill ^VPRHTTP("log")
 kill ^VPRHTTP(0,"logging")
 job START^VPRJREQ(55728,,,,1):(IN="/dev/null":OUT="/dev/null":ERR="/dev/null"):5
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
 quit
 ;
tdebug ; @TEST Debug Entry Point
 job START^VPRJREQ(55729,1,,,1):(IN="/dev/null":OUT="/dev/null":ERR="/dev/null"):5
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
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://[::1]:55728/r/%25webutils0")
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
 d &libcurl.do(.httpStatus,.return,"PUT","http://[::1]:55728/r/KBANTESTWEB",payload,"application/text",1,.headers)
 do CHKEQ^%ut(httpStatus,201)
 d &libcurl.cleanup
 k httpStatus,return
 d &libcurl.curl(.httpStatus,.return,"GET","http://[::1]:55728/r/KBANTESTWEB")
 do CHKTF^%ut(return[random)
 quit
 ;
tgetxml ; @TEST Test Get Handler XML
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://[::1]:55728/xml")
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(return["xml")
 quit
 ;
thead ; #TEST HTTP Verb HEAD (only works with GET queries)
 ; my libcurl doesn't do HEAD :-( - but head works
 n httpStatus,return,headers,status
 d
 . n $et,$es s $et="s ec=$ec,$ec="""""
 . s status=$&libcurl.curl(.httpStatus,.return,"HEAD","http://[::1]:55728/xml",,,1,.headers)
 zwrite ec
 zwrite httpStatus
 zwrite headers
 quit
 ;
tgzip ; @TEST Test gzip encoding
 n httpStatus,return,headers
 d &libcurl.init
 d &libcurl.addHeader("Accept-Encoding: gzip")
 n status s status=$&libcurl.do(.httpStatus,.return,"GET","http://[::1]:55728/r/%25webutils0",,,1,.headers)
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(headers["Content-Encoding: gzip")
 do CHKTF^%ut(return[$C(0))
 quit
 ;
tping ; @TEST Ping
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://[::1]:55728/ping")
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(return["running")
 quit
 ;
terr ; @TEST generating an error
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://[::1]:55728/error")
 do CHKEQ^%ut(httpStatus,500)
 quit
 ;
terr2 ; @TEST crashing the error trap
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://[::1]:55728/error?foo=crash2")
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
 d &libcurl.do(.httpStatus,.return,"POST","http://[::1]:55728/rpc/ORWU%20NEWPERS",payload,"application/json")
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
 d &libcurl.do(.httpStatus,.return,"POST","http://[::1]:55728/rpc/ORWU%20NEWPERS",payload,"application/json")
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
 d &libcurl.do(.httpStatus,.return,"POST","http://[::1]:55728/rpc/VPR%20GET%20PATIENT%20DATA",payload,"application/json")
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
 d &libcurl.do(.httpStatus,.return,"POST","http://[::1]:55728/rpc/VPR%20GET%20PATIENT%20DATA%20JSON",payload,"application/json")
 d &libcurl.cleanup
 d CHKEQ^%ut(httpStatus,201)
 d CHKTF^%ut(return["{")
 quit
trpcOptions ; @TEST Get RPC Options
 n httpStatus,return
 i $text(^XUS)="" quit  ; VistA not installed
 d &libcurl.curl(.httpStatus,.return,"OPTIONS","http://[::1]:55728/rpc/ORWU%20NEWPERS")
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
 d &libcurl.do(.httpStatus,.return,"POST","http://[::1]:55728/rpc2/ORWU%20NEWPERS",payload)
 d &libcurl.cleanup
 d CHKEQ^%ut(httpStatus,201)
 ; output like: "63^Cprs,User"_$C(13,10)_"1^Manager,System"_$C(13,10)_"137^Pharmacist,Unknown Synthea"_$C(13,10)_".5^Postmaster"_$C(13,10)_"136^Provider,Unknown Synthea"_$C(13,10)
 d CHKTF^%ut(+return)
 d CHKTF^%ut(return[$C(13,10))
 quit
 ;
tDC ; @TEST Test Disconnecting from the Server w/o talking
 open "sock":(connect="[::1]:55728:TCP":attach="client"):1:"socket"
 else  D FAIL^%ut("Failed to connect to server") quit
 close "sock"
 quit
 ;
tInt ; @TEST ZInterrupt
 open "p":(command="$gtm_dist/mupip intrpt "_myJob)::"pipe"
 use "p" r x:1
 close "p"
 h .1
 d CHKTF^%ut($d(^VPRHTTP("processlog",$p($h,","))))
 k ^VPRHTTP("processlog")
 QUIT
 ;
tLog1 ; @TEST Set HTTPLOG to 1
 S ^VPRHTTP(0,"logging")=1
 K ^VPRHTTP("log",+$H)
 n httpStatus,return
 d &libcurl.curl(.httpStatus,.return,"GET","http://[::1]:55728/ping")
 n s s s=$o(^VPRHTTP("log",+$h,""))
 d CHKTF^%ut(^VPRHTTP("log",+$h,s,1,"raw"))
 d CHKTF^%ut(^VPRHTTP("log",+$h,s,1,"req","header"))
 quit
 ;
tLog2 ; @TEST Set HTTPLOG to 2
 S ^VPRHTTP(0,"logging")=2
 K ^VPRHTTP("log",+$H)
 n httpStatus,return
 d &libcurl.curl(.httpStatus,.return,"GET","http://[::1]:55728/ping")
 n s s s=$o(^VPRHTTP("log",+$h,""))
 d CHKTF^%ut(^VPRHTTP("log",+$h,s,1,"raw"))
 d CHKTF^%ut(^VPRHTTP("log",+$h,s,1,"req","header"))
 quit
 ;
tLog3 ; @TEST Set HTTPLOG to 3
 i $text(^XUS)="" quit  ; VistA not installed
 S ^VPRHTTP(0,"logging")=3
 K ^VPRHTTP("log",+$H)
 n httpStatus,return
 n payload s payload="['A','1']"
 n % s %("'")=""""
 s payload=$$REPLACE^XLFSTR(payload,.%)
 d &libcurl.init
 d &libcurl.auth("Basic",$tr(acvc,";",":"))
 d &libcurl.do(.httpStatus,.return,"POST","http://[::1]:55728/rpc/ORWU%20NEWPERS",payload,"application/json")
 d &libcurl.cleanup
 d CHKEQ^%ut(httpStatus,201)
 ; output like: "63^Cprs,User"_$C(13,10)_"1^Manager,System"_$C(13,10)_"137^Pharmacist,Unknown Synthea"_$C(13,10)_".5^Postmaster"_$C(13,10)_"136^Provider,Unknown Synthea"_$C(13,10)
 d CHKTF^%ut(+return)
 d CHKTF^%ut(return[$C(13,10))
 n s s s=$o(^VPRHTTP("log",+$h,""))
 d CHKTF^%ut($d(^VPRHTTP("log",+$h,s,1,"response")))
 quit
 ;
tDCLog ; @TEST Test Disconnecting from the Server w/o talking while logging
 S ^VPRHTTP(0,"logging")=3
 K ^VPRHTTP("log",+$H)
 open "sock":(connect="[::1]:55728:TCP":attach="client"):1:"socket"
 else  D FAIL^%ut("Failed to connect to server") quit
 close "sock"
 h .1
 n s s s=$o(^VPRHTTP("log",+$h,""))
 d CHKTF^%ut($d(^VPRHTTP("log",+$h,s,1,"disconnect")))
 quit
 ;
tStop ; @TEST Stop the Server. MUST BE LAST TEST HERE.
 VIEW "TRACE":1:"^%wtrace"
 do STOP^VPRJREQ
 VIEW "TRACE":0:"^%wtrace"
 quit
 ;
 ;
cov ; [Private: Calculate Coverage]
 n rtn
 s rtn("VPRJREQ")=""
 s rtn("VPRJRSP")=""
 s rtn("%webutils0")=""
 d RTNANAL^%ut1(.rtn,$na(^%wcohort))
 k ^%wsurv m ^%wsurv=^%wcohort
 d COVCOV^%ut1($na(^%wsurv),$na(^%wtrace)) ; Venn diagram matching between globals
 d COVRPT^%ut1($na(^%wcohort),$na(^%wsurv),$na(^%wtrace),2)
 quit
