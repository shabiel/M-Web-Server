%webtest ; ose/smh - Web Services Tester;Jun 20, 2022@15:59
 ; Runs only on GTM/YDB
 ; Requires M-Unit
 ;
test if $text(^%ut)="" quit
 if $p($sy,",")'=47 quit
 do EN^%ut($t(+0),3)
 do cov
 quit
 ;
STARTUP ; [Adjust the acvc and dfn to suit your environment]
 set acvc="SM1234;SM1234!!"
 set dfn=1
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
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/test/xml")
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(return["xml")
 quit
 ;
thead ; #TEST HTTP Verb HEAD (only works with GET queries)
 ; my libcurl doesn't do HEAD :-( - but head works
 n httpStatus,return,headers,status
 d
 . n $et,$es s $et="s ec=$ec,$ec="""""
 . s status=$&libcurl.curl(.httpStatus,.return,"HEAD","http://127.0.0.1:55728/test/xml",,,1,.headers)
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
tnogzipflag ; @TEST Test nogzip flag
 k ^%webhttp("log",+$H)
 n gzipflagjob
 ;
 ; Now start a webserver with a passed username/password
 j start^%webreq(55732,"",,,,,1)
 h .1
 s gzipflagjob=$zjob
 ;
 n httpStatus,return,headers
 d &libcurl.init
 d &libcurl.addHeader("Accept-Encoding: gzip") ; This must be sent to properly test as the server is smart and if we don't send that we support gzip it won't gzip
 n status s status=$&libcurl.do(.httpStatus,.return,"GET","http://127.0.0.1:55732/r/%25webapi",,,1,.headers)
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(headers'["Content-Encoding: gzip")
 do CHKTF^%ut(return["webapi ; OSE/SMH - Infrastructure web services hooks")
 ;
 ; now stop the webserver again
 open "p":(command="$gtm_dist/mupip stop "_gzipflagjob)::"pipe"
 use "p" r x:1
 close "p"
 w !,x,!
 ;
 kill gzipflagjob
 quit
 ;
temptynogzip ; @TEST Empty response with no gzip encoding
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/test/empty")
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(return="")
 quit
 ;
temptygzip ; @TEST Empty response with gzip
 n httpStatus,return
 d &libcurl.init
 d &libcurl.addHeader("Accept-Encoding: gzip")
 n status s status=$&libcurl.do(.httpStatus,.return,"GET","http://127.0.0.1:55728/test/empty",,,1,.headers)
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(headers'["Content-Encoding: gzip")
 do CHKTF^%ut(return="")
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
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/test/error")
 do CHKEQ^%ut(httpStatus,500)
 do CHKTF^%ut(return["DIVZERO")
 quit
 ;
terr2 ; @TEST crashing the error trap
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/test/error?foo=crash2")
 do CHKEQ^%ut(httpStatus,500)
 quit
 ;
tcustomError ; @TEST Custom Error
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/test/customerror")
 do CHKTF^%ut(return["OperationOutcome")
 do CHKEQ^%ut(httpStatus,400)
 quit
 ;
tlong ; @TEST get a long message
 ; Exercises the flushing
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/test/bigoutput")
 do CHKEQ^%ut(httpStatus,200)
 do CHKEQ^%ut($l(return),32769)
 quit
 ;
tKillGlo ; @TEST kill global after sending result in it
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/test/gloreturn")
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(return["coo")
 do CHKTF^%ut('$d(^web("%webapi")))
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
 n payload s payload="[{'patientId': '"_dfn_"', 'domain': ''}]"
 n % s %("'")=""""
 s payload=$$REPLACE^XLFSTR(payload,.%)
 d &libcurl.init
 d &libcurl.auth("Basic",$tr(acvc,";",":"))
 d &libcurl.do(.httpStatus,.return,"POST","http://127.0.0.1:55728/rpc/VPR%20GET%20PATIENT%20DATA%20JSON",payload,"application/json")
 d &libcurl.cleanup
 d CHKEQ^%ut(httpStatus,201)
 d CHKTF^%ut(return["{")
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
tHomePage ; @Test Getting index.html page
 new oldDir set oldDir=$g(^%webhome)
 set ^%webhome="/tmp/"
 new random s random=$R(9817234)
 open "/tmp/index.html":(newversion)
 use "/tmp/index.html"
 write "<!DOCTYPE html>",!
 write "<html>",!
 write "<body>",!
 write "<h1>My First Heading</h1>",!
 write "<p>My first paragraph."_random_"</p>",!
 write "</body>",!
 write "</html>",!
 close "/tmp/index.html"
 n httpStatus,return
 d &libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55728/")
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
CORS ; @TEST Make sure CORS headers are returned
 k ^%webhttp("log",+$H)
 n httpStatus,return,headers,headerarray
 d &libcurl.curl(.httpStatus,.return,"OPTIONS","http://127.0.0.1:55728/r/kbbotest.m",,,,.headers)
 ;
 ; Split the headers apart using carriage return line feed delimiter
 f i=1:1:$L(headers,$C(13,10)) D
 . ; Change to name based subscripts by using ": " delimiter
 . s:($p($p(headers,$C(13,10),i),": ",1)'="")&($p($p(headers,$C(13,10),i),": ",2)'="") headerarray($p($p(headers,$C(13,10),i),": ",1))=$p($p(headers,$C(13,10),i),": ",2)
 ;
 ; Now make sure all required bits are correct
 d CHKEQ^%ut(httpStatus,200)
 d CHKEQ^%ut($g(headerarray("Access-Control-Allow-Methods")),"OPTIONS, POST")
 d CHKEQ^%ut($g(headerarray("Access-Control-Allow-Headers")),"Content-Type")
 d CHKEQ^%ut($g(headerarray("Access-Control-Max-Age")),"86400")
 d CHKEQ^%ut($g(headerarray("Access-Control-Allow-Origin")),"*")
 quit
 ;
USERPASS ; @TEST Test that passing a username/password works
 k ^%webhttp("log",+$H)
 n passwdJob
 ;
 ; Now start a webserver with a passed username/password
 j start^%webreq(55730,"",,,,"admin:admin")
 h .1
 s passwdJob=$zjob
 ;
 n httpStatus,return
 ;
 ; Positive test
 d &libcurl.init
 d &libcurl.auth("Basic","admin:admin")
 d &libcurl.do(.httpStatus,.return,"GET","http://127.0.0.1:55730/ping")
 d &libcurl.cleanup
 d CHKEQ^%ut(httpStatus,200)
 ;
 ; Negative test
 d &libcurl.init
 d &libcurl.auth("Basic","admin:12345")
 d &libcurl.do(.httpStatus,.return,"GET","http://127.0.0.1:55730/ping")
 d &libcurl.cleanup
 d CHKEQ^%ut(httpStatus,401)
 ;
 ; now stop the webserver again
 open "p":(command="$gtm_dist/mupip stop "_passwdJob)::"pipe"
 use "p" r x:1
 close "p"
 w !,x,!
 ;
 kill passwdJob
 quit
 ;
tpost ; @TEST simple post
 n httpStatus,return
 n random set random=$random(99999999)
 n payload s payload="{ ""random"" : """_random_""" } "
 d &libcurl.init
 d &libcurl.do(.httpStatus,.return,"POST","http://127.0.0.1:55728/test/post",payload,"application/json")
 d &libcurl.cleanup
 do CHKTF^%ut(return[random)
 quit
 ;
NOGBL ; @TEST Test to make sure no globals are used during webserver operations
 k ^%webhttp("log",+$H)
 k ^%webhttp(0,"listener")
 n nogblJob
 ;
 ; Now start a webserver with "nogbl" set to 1
 j start^%webreq(55731,"",,1)
 h .1
 s nogblJob=$zjob
 ;
 n httpStatus,return,headers
 ;
 ; check to make sure ^%webhome isn't used
 ; The default is the current directory
 new random s random=$R(9817234)
 new oldDir set oldDir=$g(^%webhome)
 s ^%webhome="/tmp/"_random
 open "test.html":(newversion)
 use "test.html"
 write "<!DOCTYPE html>",!
 write "<html>",!
 write "<body>",!
 write "<h1>My First Heading</h1>",!
 write "<p>My first paragraph."_random_"</p>",!
 write "</body>",!
 write "</html>",!
 close "test.html"
 d &libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55731/test.html")
 d CHKEQ^%ut(httpStatus,200)
 d CHKTF^%ut(return[random)
 open "p":(command="rm test.html")::"pipe"
 use "p" r x:1
 close "p"
 w !,x,!
 ;
 ; Make sure that the default index.html isn't returned
 k httpStatus,return
 d &libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55731/index.html")
 d CHKEQ^%ut(httpStatus,404,"index.html found")
 ;
 ; Make sure HTTP Listener status doesn't control anything
 d CHKEQ^%ut($d(^%webhttp(0,"listener")),0)
 s ^%webhttp(0,"listener")="stop"
 h .1
 k httpStatus,return
 d &libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55731/ping")
 d CHKEQ^%ut(httpStatus,200,"ping failed")
 ;
 ; Make sure ^%web(17.6001) isn't used
 k httpStatus,return
 d &libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55731/test/bigoutput")
 do CHKEQ^%ut(httpStatus,404,"bigoutput shouldn't be found")
 ;
 ; now stop the webserver again
 open "p":(command="$gtm_dist/mupip stop "_nogblJob)::"pipe"
 use "p" r x:1
 close "p"
 w !,x,!
 set ^%webhome=oldDir
 kill nogblJob
 quit
 ;
NOGBLERR ; @TEST No globals properly reports errors (Issue #50)
 n nogblJob
 ;
 ; Now start a webserver with "nogbl" set to 1
 j start^%webreq(55731,"",,1)
 h .1
 s nogblJob=$zjob
 ;
 ;generating an error
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55731/test/error")
 do CHKEQ^%ut(httpStatus,500,"/error needs to return 500")
 do CHKTF^%ut(return["DIVZERO")
 ;
 ;crashing the error trap
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55731/test/error?foo=crash2")
 do CHKEQ^%ut(httpStatus,500,"crashing error trap needs to return 500")
 do CHKTF^%ut(return="")
 ;
 ; Custom Error
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://127.0.0.1:55731/test/customerror")
 do CHKTF^%ut(return["OperationOutcome","Setting a custom error should work")
 do CHKEQ^%ut(httpStatus,400,"Custom error status should be 400")
 ; 
 ; now stop the webserver again
 open "p":(command="$gtm_dist/mupip stop "_nogblJob)::"pipe"
 use "p" r x:1
 close "p"
 w !,x,!
 quit
 ;
NOGBLPOST ; @TEST No globals properly works with HTTP POST
 n nogblJob
 ;
 ; Now start a webserver with "nogbl" set to 1
 j start^%webreq(55731,"",,1)
 h .1
 s nogblJob=$zjob
 ;
 n httpStatus,return
 n random set random=$random(99999999)
 n payload s payload="{ ""random"" : """_random_""" } "
 d &libcurl.init
 d &libcurl.do(.httpStatus,.return,"POST","http://127.0.0.1:55731/test/post",payload,"application/json")
 d &libcurl.cleanup
 do CHKTF^%ut(return[random)
 ;
 ; now stop the webserver again
 open "p":(command="$gtm_dist/mupip stop "_nogblJob)::"pipe"
 use "p" r x:1
 close "p"
 w !,x,!
 quit
 ;
tStop ; @TEST Stop the Server. MUST BE LAST TEST HERE.
 do stop^%webreq
 quit
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
 d deleteService^%webutils("GET","/test/error")
 d deleteService^%webutils("GET","test/bigoutput")
 d deleteService^%webutils("GET","test/gloreturn")
 d deleteService^%webutils("POST","rpc/{rpc}")
 d deleteService^%webutils("POST","/rpc2/{rpc}")
 ;
 do addService^%webutils("GET","r/{routine?.1""%25"".32AN}","R^%webapi")
 do addService^%webutils("PUT","r/{routine?.1""%25"".32AN}","PR^%webapi",1,"XUPROGMODE")
 do addService^%webutils("GET","/test/error","ERR^%webapi")
 do addService^%webutils("GET","test/bigoutput","bigoutput^%webapi")
 do addService^%webutils("GET","test/gloreturn","gloreturn^%webapi")
 do addService^%webutils("POST","rpc/{rpc}","RPC^%webapi",1)
 n params s params(1)="U^rpc",params(2)="F^start",params(3)="F^direction",params(4)="B"
 n ien s ien=$$addService^%webutils("POST","/rpc2/{rpc}","rpc2^%webapi",1,"","",.params)
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
EOR ;
 ;
 ; Copyright 2018-2020 Sam Habiel
 ; Copyright 2019 Christopher Edwards
 ; Copyright 2022 YottaDB LLC
 ;
 ;Licensed under the Apache License, Version 2.0 (the "License");
 ;you may not use this file except in compliance with the License.
 ;You may obtain a copy of the License at
 ;
 ;    http://www.apache.org/licenses/LICENSE-2.0
 ;
 ;Unless required by applicable law or agreed to in writing, software
 ;distributed under the License is distributed on an "AS IS" BASIS,
 ;WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 ;See the License for the specific language governing permissions and
 ;limitations under the License.
