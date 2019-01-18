%webtest ; ose/smh - Web Services Tester;2019-01-17  2:40 PM
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
 kill ^%wtrace,^%wcohort,^%wsurv
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
tgetxml ; @TEST Test Get Handler XML
 n httpStatus,return
 n status s status=$&libcurl.curl(.httpStatus,.return,"GET","http://[::1]:55728/xml")
 do CHKEQ^%ut(httpStatus,200)
 do CHKTF^%ut(return["xml")
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
cov ;
 h 2
 n rtn
 s rtn("VPRJREQ")=""
 s rtn("VPRJRSP")=""
 s rtn("%webutils0")=""
 d RTNANAL^%ut1(.rtn,$na(^%wcohort))
 k ^%wsurv m ^%wsurv=^%wcohort
 d COVCOV^%ut1($na(^%wsurv),$na(^%wtrace)) ; Venn diagram matching between globals
 d COVRPT^%ut1($na(^%wcohort),$na(^%wsurv),$na(^%wtrace),2)
 quit
