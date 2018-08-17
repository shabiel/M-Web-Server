# Installation instructions

**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

* [Installation for GT.M](#installation-for-gtm)
* [Installation on Cache/Windows](#installation-on-cachewindows)
* [Installation on Cache/Unix](#installation-on-cacheunix)
* [Starting and Stopping the Server](#starting-and-stopping-the-server)

While installation is intended to be mostly automatic, you need to download
the boostrap routine that will automate all of this first.

In addition the bootstrap routine will ask you a couple of questions for which
it has default answers. The questions are:

	Enter Directory: <default guess based on your configuration>// 
	Enter a port number between 1024 and 65535: 9080//

The directory will contain your web pages, stylesheets, javascript, and other
web resources. The port (defaulting to 9080) is the port number on which to
start listening. Once you are done, you can visit http://localhost:port/ to
see the home page.

To stop the web server after it is automatically started, type

	D STOP^VPRJREQ

The installation is divided into 3 sections. One for GT.M/Any Unix, one for
Cache/Windows, and one for Cache/Any Unix.

## Installation for GT.M
Open a linux terminal and source your GT.M environment file first. To check
that that has happened properly, type

	echo $gtmroutines

in your shell. If you see anything other than a blank, you are ready to go.

On the linux terminal, Use cURL to download the bootstrap routine.

    curl -L https://raw.github.com/shabiel/M-Web-Server/0.1.4/dist/WWWINIT.RSA > /tmp/WWWINIT.RSA

Run GT.M using `$gtm_dist/mumps -dir`.

Once inside GT.M, find your routine directory in GT.M:
    
    GTM>W $ZRO
    o(r) /usr/lib/fis-gtm/V6.1-000_x86_64/libgtmutil.so

Your results will differ. In my case, the routines directory is just `r`.

Import `WWWINIT.RSA` into your routines directory. DO NOT FORGET THE TRAILING
SLASH IN YOUR OUTPUT DIRECTORY:
    
    GTM>D ^%RI
    
    Routine Input Utility - Converts RO file to *.m files.
    
    Formfeed delimited <No>? 
    Input device: <terminal>: /tmp/WWWINIT.RSA
    
    Init routine for 0.1.4
    GT.M 01-JAN-2014 14:03:54
    
    
    Output directory : r/
    
    WWWINIT   
    
    
    Restored 482 lines in 1 routine.

Now run ^WWWINIT to install and configure the server. ^WWWINIT will download
the necessary files and configure the system.

It's a good idea to accept the defaults. If you have Fileman installed, 
^WWWINIT will configure the Web Services file.

    GTM>D ^WWWINIT
             Q:+$SY=0 $ZU(168)
                       ^-----
                    At column 12, line 54, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-INVFCN, Invalid function name
             . new OS set OS=$zversion(1)
                              ^-----
                    At column 19, line 62, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-INVFCN, Invalid function name
             . . N % S %=$ZU(168,"C:\TEMP\")
                          ^-----
                    At column 15, line 65, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-INVFCN, Invalid function name
             . . N % S %=$ZU(168,"/tmp/")
                          ^-----
                    At column 15, line 67, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-INVFCN, Invalid function name
             I +$SY=0 N % S %=$ZU(168,DIR) QUIT
                               ^-----
                    At column 20, line 72, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-INVFCN, Invalid function name
             N NMSP S NMSP=$NAMESPACE
                            ^-----
                    At column 17, line 78, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-INVSVN, Invalid special variable name
             ZN "%SYS" ; Go to SYS
             ^-----
                    At column 2, line 81, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-INVCMD, Invalid command keyword encountered
             N % S %=##class(Config.Configuration).GetGlobalMapping(NMSP,"%W*","",NMSP,NMSP)
                     ^-----
                    At column 10, line 82, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EXPR, Expression expected but not found
             I '% S %=##class(Config.Configuration).AddGlobalMapping(NMSP,"%W*","",NMSP,NMSP)
                      ^-----
                    At column 11, line 83, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EXPR, Expression expected but not found
             I '% W !,"Error="_$SYSTEM.Status.GetErrorText(%) QUIT
                                      ^-----
                    At column 27, line 84, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-SPOREOL, Either a space or an end-of-line was expected but not found
             N % S %=##Class(Config.MapRoutines).Get(NMSP,"%W*",.A)
                     ^-----
                    At column 10, line 88, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EXPR, Expression expected but not found
             I '% S %=##Class(Config.MapRoutines).Create(NMSP,"%W*",.A)
                      ^-----
                    At column 11, line 90, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EXPR, Expression expected but not found
             I '% W !,"Error="_$SYSTEM.Status.GetErrorText(%) QUIT
                                      ^-----
                    At column 27, line 91, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-SPOREOL, Either a space or an end-of-line was expected but not found
             ZN NMSP ; Go back
             ^-----
                    At column 2, line 92, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-INVCMD, Invalid command keyword encountered
             N NMSP S NMSP=$NAMESPACE
                            ^-----
                    At column 17, line 98, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-INVSVN, Invalid special variable name
             ZN "%SYS"
             ^-----
                    At column 2, line 99, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-INVCMD, Invalid command keyword encountered
             n % s %=##class(Security.SSLConfigs).Exists("client",.config,.status) ; check if config exists
                     ^-----
                    At column 10, line 101, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EXPR, Expression expected but not found
             . s %=##class(Security.SSLConfigs).Create("client",.prop) ; create a default ssl config
                   ^-----
                    At column 8, line 104, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EXPR, Expression expected but not found
             . i '% w $SYSTEM.Status.GetErrorText(%) s $ec=",u-cache-error,"
                             ^-----
                    At column 18, line 105, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-SPOREOL, Either a space or an end-of-line was expected but not found
             . s %=##class(Security.SSLConfigs).Exists("client",.config,.status) ; get config
                   ^-----
                    At column 8, line 106, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EXPR, Expression expected but not found
             e  s %=config.Activate()
                          ^-----
                    At column 15, line 107, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-SPOREOL, Either a space or an end-of-line was expected but not found
             d config.TestConnection("173.194.33.4",443,.rtn)
                     ^-----
                    At column 10, line 111, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-SPOREOL, Either a space or an end-of-line was expected but not found
             ZN NMSP
             ^-----
                    At column 2, line 114, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-INVCMD, Invalid command keyword encountered
             set httprequest=##class(%Net.HttpRequest).%New()
                             ^-----
                    At column 18, line 124, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EXPR, Expression expected but not found
             . set httprequest.Https=1
                              ^-----
                    At column 19, line 126, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EQUAL, Equal sign expected but not found
             . set httprequest.SSLConfiguration="client"
                              ^-----
                    At column 19, line 127, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EQUAL, Equal sign expected but not found
             set httprequest.Server=server
                            ^-----
                    At column 17, line 132, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EQUAL, Equal sign expected but not found
             if port set httprequest.Port=port
                                    ^-----
                    At column 25, line 133, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EQUAL, Equal sign expected but not found
             set httprequest.Timeout=5
                            ^-----
                    At column 17, line 134, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EQUAL, Equal sign expected but not found
             new status set status=httprequest.Get(filepath)
                                              ^-----
                    At column 35, line 135, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-SPOREOL, Either a space or an end-of-line was expected but not found
             new response set response=httprequest.HttpResponse.Data
                                                  ^-----
                    At column 39, line 136, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-SPOREOL, Either a space or an end-of-line was expected but not found
             new sysfile set sysfile=##class(%Stream.FileBinary).%New()
                                     ^-----
                    At column 26, line 137, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EXPR, Expression expected but not found
             set status=sysfile.FilenameSet(filename)
                               ^-----
                    At column 20, line 138, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-SPOREOL, Either a space or an end-of-line was expected but not found
             set status=sysfile.CopyFromAndSave(response)
                               ^-----
                    At column 20, line 139, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-SPOREOL, Either a space or an end-of-line was expected but not found
             set status=sysfile.%Close()
                               ^-----
                    At column 20, line 140, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-SPOREOL, Either a space or an end-of-line was expected but not found
             D $SYSTEM.Process.SetZEOF(1) ; Cache stuff!!
               ^-----
                    At column 4, line 231, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-LABELEXPECTED, Label expected in this context
             O ROPATH:("RS"):0 E  S $EC=",U-ERR-OPEN-FILE,"
                       ^-----
                    At column 12, line 236, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-DEVPARUNK, Deviceparameter unknown
             O DIR_"test.txt":"NWS":0
                              ^-----
                    At column 19, line 269, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-DEVPARUNK, Deviceparameter unknown
             C DIR_"test.txt":"D"
                              ^-----
                    At column 19, line 273, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-DEVPARUNK, Deviceparameter unknown
             . O TCPIO:(:PORT:"ACT"):2
                        ^-----
                    At column 13, line 369, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-DEVPARUNK, Deviceparameter unknown
             D CHKTF^XTMUNIT('$D(^$R("%ZVEMD")))
                                  ^-----
                    At column 23, line 422, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-GBLNAME, Either an identifier or a left parenthesis is expected after a ^ in this context
             N NS S NS=$NAMESPACE
                        ^-----
                    At column 13, line 431, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-INVSVN, Invalid special variable name
             ZN "%SYS"
             ^-----
                    At column 2, line 432, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-INVCMD, Invalid command keyword encountered
             S %=##class(Config.Configuration).AddGlobalMapping(NS,"%Z*","",NS,NS)
                 ^-----
                    At column 6, line 433, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EXPR, Expression expected but not found
             S A("Database")=NS S %=##Class(Config.MapRoutines).Create(NS,"%Z*",.A)
                                    ^-----
                    At column 25, line 434, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-EXPR, Expression expected but not found
             ZN NS
             ^-----
                    At column 2, line 435, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-INVCMD, Invalid command keyword encountered
             D CHKTF^XTMUNIT($D(^$R("%ZVEMD")))
                                 ^-----
                    At column 22, line 438, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-GBLNAME, Either an identifier or a left parenthesis is expected after a ^ in this context
             D:$D(^$R(R))  F  S R=$O(^$R(R)) Q:R=""  Q:($P(R,NMSP,2)="")  D
                   ^-----
                    At column 8, line 446, source module /var/local/wvtest/r/WWWINIT.m
    %GTM-E-GBLNAME, Either an identifier or a left parenthesis is expected after a ^ in this context
    
    This version (#0.2) of '%WINIT' was created on 22-NOV-2013
             (at Vista-Office EHR, by VA FILEMAN 22.0)
    
    I AM GOING TO SET UP THE FOLLOWING FILES:
    
       17.6001   WEB SERVICE URL HANDLER
    
    
    ...SORRY, JUST A MOMENT PLEASE........
    OK, I'M DONE.
    NOTE THAT FILE SECURITY-CODE PROTECTION HAS BEEN MADE
    
    Enter the home directory where you will store the html, js, and css files
    
    Make sure this is a directory where you have write permissions.
    
    To help you, I am going to try to test various directories I think
    may work
    
    /var/local/wvtest/                                [OK]
    /var/www/                                         [NOT OK]
    C:\Inetpub\www\                                   [OK]
    
    Enter Directory: /var/local/wvtest/// 
    Enter a port number between 1024 and 65535: 9080//       I %WOS="CACHE" O TCPIO:(:TCPPORT:"ACT"):15 E  U 0 W !,"error cannot open port "_TCPPORT Q
                                     ^-----
                    At column 26, line 27, source module /var/local/wvtest/r/VPRJREQ.m
    %GTM-E-DEVPARUNK, Deviceparameter unknown
             . J CHILD:(:4:TCPIO:TCPIO):10 ; Send off the device to another job for input and output.
                        ^-----
                    At column 13, line 44, source module /var/local/wvtest/r/VPRJREQ.m
    %GTM-E-JOBPARUNK, Job parameter unknown
    
    
    Mumps Web Services is now listening to port 9080
    Visit http://localhost:9080/ to see the home page.
    Also, try the sample web services...
     - http://localhost:9080/xml
     - http://localhost:9080/ping

## Installation on Cache/Windows
Before starting, make sure you have enough licenses to run the web server. 
I generally recommend having at least 5 licenses.

If the output of `Write $System.License.LUAvailable()` is less than 5, I don't
recommend continuing. Use GT.M instead.

Because I use Unix utitlies to download files and zip/unzip, you need to
install those first. Download <https://github.com/downloads/bmatzelle/gow/Gow-0.5.0.exe>
and install. YOU MUST INSTALL THIS VERSION AS IT IS THE LATEST ONE THAT 
CONTAINS UNZIP. Once you are done, follow the following instructions.

Type Windows-R to open the run box.

Type `cmd`, then hit enter.

Then download the bootstrap file as follows:

	C:\Users\VISTAEXPERTISE>cd %temp%

	C:\Users\VISTAE~1\AppData\Local\Temp>curl -k -L -O https://raw.github.com/shabiel/M-Web-Server/0.1.4/dist/WWWINIT.RSA

Open the Cache Terminal from the Cache Cube, or use another method to get in. Read the routine archive in. Cache will complain that it doesn't recoginze GT.M's format. Ignore this error.

	TEST1>D ^%RI
	 
	Input routines from Sequential
	Device: C:\Users\VISTAE~1\AppData\Local\Temp\WWWINIT.RSA
	Parameters? "R" =>
	 
		*****  W A R N I N G   *****
	 
	File Header: Init routine for 0.1.4
	Date Stamp: GT.M 01-JAN-2014 14:03:54
	 
	This file may not be a %RO output file.
	Override and use this File with %RI? No => yes
	%RI has detected a routine written with UNKNOWN mode.
	   0) Cache
	   1) DSM-11
	   2) DTM
	   3) Ipsum
	   4) Cobra
	   5) DSM-VMS
	   6) DSM-J
	   7) DTM-J
	   8) MSM
	   9) BASIC
	  10) U2/M
	  11) MVBASIC
	 
	Please enter a number from the above list: <0> 0
	 
	File written by OLD GT.M 01-JAN-2014 14:03:54 with description:
	Init routine for 0.1.4
	 
	( All Select Enter List Quit )
	 
	Routine Input Option: All Routines
	 
	If a selected routine has the same name as one already on file,
	shall it replace the one on file? No => yes
	Recompile? Yes => Yes
	Display Syntax Errors? Yes => Yes
	 
	^ indicates routines which will replace those now on file.
	@ indicates routines which have been [re]compiled.
	- indicates routines which have not been filed.
	 
	 
	WWWINIT.INT@
	 
	1 routine processed.

Once done, run the bootstrap routine to download everything else and start the server.

	TEST1>D ^WWWINIT
	TLS/SSL client configured on Cache as config name 'client'
	Enter the home directory where you will store the html, js, and css files
	 
	Make sure this is a directory where you have write permissions.
	 
	To help you, I am going to try to test various directories I think
	may work
	 
	c:\intersystems\cache\mgr\test1\                  [OK]
	/var/www/                                         [NOT OK]
	C:\Inetpub\www\                                   [NOT OK]
	 
	Enter Directory: c:\intersystems\cache\mgr\test1\//
	Enter a port number between 1024 and 65535: 9080//
	 
	Mumps Web Services is now listening to port 9080
	Visit http://localhost:9080/ to see the home page.
	Also, try the sample web services...
	 - http://localhost:9080/xml
	 - http://localhost:9080/ping

## Installation on Cache/Unix
Before starting, make sure you have enough licenses to run the web server. 
I generally recommend having at least 5 licenses.

If the output of `Write $System.License.LUAvailable()` is less than 5, I don't
recommend continuing. Use GT.M instead.

Open the Linux Terminal.

Use cURL to download the bootstrap routine.

    curl -L https://raw.github.com/shabiel/M-Web-Server/0.1.4/dist/WWWINIT.RSA > /tmp/WWWINIT.RSA

Open the Cache Terminal using `csession CACHE`, and switch to the appropriate
namespace.

Import the routine. Cache will complain that it doesn't recoginze GT.M's format. 
Ignore this error.

	TEST2>D ^%RI

	Input routines from Sequential
	Device: /tmp/WWWINIT.RSA
	Parameters? "R" => 

		*****  W A R N I N G   *****

	File Header: Init routine for 0.1.4
	Date Stamp: GT.M 01-JAN-2014 14:03:54

	This file may not be a %RO output file.
	Override and use this File with %RI? No => yes
	%RI has detected a routine written with UNKNOWN mode.
	   0) Cache
	   1) DSM-11
	   2) DTM
	   3) Ipsum
	   4) Cobra
	   5) DSM-VMS
	   6) DSM-J
	   7) DTM-J
	   8) MSM
	   9) BASIC
	  10) U2/M
	  11) MVBASIC

	Please enter a number from the above list: <0> 0

	File written by OLD GT.M 01-JAN-2014 14:03:54 with description:
	Init routine for 0.1.4

	( All Select Enter List Quit )

	Routine Input Option: All Routines

	If a selected routine has the same name as one already on file,
	shall it replace the one on file? No => yes
	Recompile? Yes => Yes
	Display Syntax Errors? Yes => Yes

	^ indicates routines which will replace those now on file.
	@ indicates routines which have been [re]compiled.
	- indicates routines which have not been filed.


	WWWINIT.INT@    

	1 routine processed.
	TEST2>D ^WWWINIT
	TLS/SSL client configured on Cache as config name 'client'
	Enter the home directory where you will store the html, js, and css files

	Make sure this is a directory where you have write permissions.

	To help you, I am going to try to test various directories I think
	may work

	/var2/local/mws-test2-cache/                      [OK]
	/var/www/                                         [NOT OK]
	C:\Inetpub\www\                                   [OK]

	Enter Directory: /var2/local/mws-test2-cache/// 
	Enter a port number between 1024 and 65535: 9080// 

	Mumps Web Services is now listening to port 9080
	Visit http://localhost:9080/ to see the home page.
	Also, try the sample web services...
	 - http://localhost:9080/xml
	 - http://localhost:9080/ping

## Starting and Stopping the Server
Once you are done having fun, you can stop the server using `STOP^VPRJREQ`.

To start it again, run `D JOB^VPRJREQ(portno)`, substituting a port number
of your choice. If you run `D ^VPRJREQ`, it will start at port number 9080.
