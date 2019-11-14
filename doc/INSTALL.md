# Installation instructions

**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

* [Platform and Dependencies](#platform-and-dependencies)
* [Installation for GT.M](#installation-for-gtm)
* [Installation on Cache/Windows](#installation-on-cachewindows)
* [Installation on Cache/Unix](#installation-on-cacheunix)
* [Manual Install from Source](#manual-install-from-source)
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

	D stop^%webreq

The installation is divided into 3 sections. One for GT.M/Any Unix, one for
Cache/Windows, and one for Cache/Any Unix.

## Platform and Dependencies
The M Web Server (MWS) runs on GT.M (Unix) and Caché (Windows and Unix). The
instructions assume a GT.M or equivalent YottaDB version >= 6.1; however, it
possible to run it as well with xinetd for any GT.M version.

MWS is completely self-contained and does not have any internal dependencies on
VistA. However, if VistA is present, the follow features are enabled:

- Web Server URLs are stored in a Fileman file
- BASIC HTTP Authentication is enabled against VistA's File 200
- The RPC web service is operational

MWS has some external dependencies

- GT.M/YottaDB: Operational: gzip, date, sed. Installer only: curl, perl, mkdir.
- Caché: Operational: none. Installer only: mkdir.

## Installation for GT.M
Open a linux terminal and source your GT.M environment file first. To check
that that has happened properly, type

	echo $gtmroutines

in your shell. If you see anything other than a blank, you are ready to go.

On the linux terminal, Use cURL to download the bootstrap routine.

    curl -L https://github.com/shabiel/M-Web-Server/releases/download/1.1.1/webinit.rsa > /tmp/webinit.rsa

Run GT.M using `$gtm_dist/mumps -dir`.

Once inside GT.M, find your routine directory in GT.M:
    
    GTM>W $ZRO
    o(r) /usr/lib/fis-gtm/V6.1-000_x86_64/libgtmutil.so

Your results will differ. In my case, the routines directory is just `r`.

Import `webinit.rsa` into your routines directory. DO NOT FORGET THE TRAILING
SLASH IN YOUR OUTPUT DIRECTORY:
    
    GTM>D ^%RI
    
    Routine Input Utility - Converts RO file to *.m files.
    
    Formfeed delimited <No>? 
    Input device: <terminal>: /tmp/webinit.rsa
    
    Init routine for 0.1.5
    GT.M 01-JAN-2014 14:03:54
    
    
    Output directory : r/
    
    webinit   
    
    
    Restored 524 lines in 1 routine.

Now run ^webinit to install and configure the server. ^webinit will download
the necessary files and configure the system.

It's a good idea to accept the defaults. If you have Fileman installed, 
^webinit will configure the Web Services file.

	FOIA>zl "webinit":"-nowarning"

	FOIA>do ^webinit

	This version (#1.0) of '%webINIT' was created on 22-JAN-2019
					 (at DEMO.OSEHRA.ORG, by MSC FileMan 22.1061)

	I AM GOING TO SET UP THE FOLLOWING FILES:

		 17.6001   WEB SERVICE URL HANDLER


	...HMMM, JUST A MOMENT PLEASE........
	OK, I'M DONE.
	NOTE THAT FILE SECURITY-CODE PROTECTION HAS BEEN MADE
		 I $$UP($ZV)["CACHE" D  Q $P(DAY," ")_", "_$ZDATETIME(TM,2)_" GMT"
																								^-----
			At column 45, line 148, source module /home/foia/p/_webutils.m
	%YDB-E-INVFCN, Invalid function name
		 . S TM=$ZTIMESTAMP,DAY=$ZDATETIME(TM,11)
														 ^-----
			At column 26, line 149, source module /home/foia/p/_webutils.m
	%YDB-E-INVFCN, Invalid function name



	Enter the home directory where you will store the html, js, and css files

	Make sure this is a directory where you have write permissions.

	To help you, I am going to try to test various directories I think
	may work

	/home/foia/                                       [OK]
	/var/www/                                         [NOT OK]
	C:\Inetpub\www\                                   [OK]

	Enter Directory: /home/foia///
	Enter a port number between 1024 and 65535: 9080//
		 I %WOS="CACHE" O TCPIO:(:TCPPORT:"ACT"):15 E  U 0 W !,"error cannot open port "_TCPPORT Q
														 ^-----
			At column 26, line 43, source module /home/foia/p/_webreq.m
	%YDB-E-DEVPARUNK, Deviceparameter unknown
		 . J CHILD($G(TLSCONFIG),$G(NOGBL),$G(TRACE),$G(USERPASS)):(:4:TCPIO:TCPIO):10 ; Send off the device to another job for input and output.
																																^-----
			At column 61, line 65, source module /home/foia/p/_webreq.m
	%YDB-E-JOBPARUNK, Job parameter unknown
		 . I %WOS="CACHE" U %WTCP:(::"-M":/TLS=TLSCONFIG)
															 ^-----
			At column 28, line 157, source module /home/foia/p/_webreq.m
	%YDB-E-DEVPARUNK, Deviceparameter unknown


	Mumps Web Services is now listening to port 9080
	Visit http://localhost:9080/ to see the home page.
	Also, try the sample web services...
	 - http://localhost:9080/test/xml
	 - http://localhost:9080/ping

	FOIA>

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

	C:\Users\VISTAE~1\AppData\Local\Temp>curl -k -L -O https://github.com/shabiel/M-Web-Server/releases/download/1.1.1/webinit.rsa

Open the Cache Terminal from the Cache Cube, or use another method to get in. Read the routine archive in. Cache will complain that it doesn't recoginze GT.M's format. Ignore this error.

	TEST1>D ^%RI
	 
	Input routines from Sequential
	Device: C:\Users\VISTAE~1\AppData\Local\Temp\webinit.rsa
	Parameters? "R" =>
	 
		*****  W A R N I N G   *****
	 
	File Header: Init routine for 0.1.5
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
	Init routine for 0.1.5
	 
	( All Select Enter List Quit )
	 
	Routine Input Option: All Routines
	 
	If a selected routine has the same name as one already on file,
	shall it replace the one on file? No => yes
	Recompile? Yes => Yes
	Display Syntax Errors? Yes => Yes
	 
	^ indicates routines which will replace those now on file.
	@ indicates routines which have been [re]compiled.
	- indicates routines which have not been filed.
	 
	 
	webinit.rsa@
	 
	1 routine processed.

Once done, run the bootstrap routine to download everything else and start the server.

	TEST1>D ^webinit
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
	 - http://localhost:9080/test/xml
	 - http://localhost:9080/ping

## Installation on Cache/Unix
Before starting, make sure you have enough licenses to run the web server. 
I generally recommend having at least 5 licenses.

If the output of `Write $System.License.LUAvailable()` is less than 5, I don't
recommend continuing. Use GT.M instead.

Open the Linux Terminal.

Use cURL to download the bootstrap routine.

    curl -L https://github.com/shabiel/M-Web-Server/releases/download/1.1.1/webinit.rsa > /tmp/webinit.rsa

Open the Cache Terminal using `csession CACHE`, and switch to the appropriate
namespace.

Import the routine. Cache will complain that it doesn't recoginze GT.M's format. 
Ignore this error.

	TEST2>D ^%RI

	Input routines from Sequential
	Device: /tmp/webinit.rsa
	Parameters? "R" => 

		*****  W A R N I N G   *****

	File Header: Init routine for 0.1.5
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
	Init routine for 0.1.5

	( All Select Enter List Quit )

	Routine Input Option: All Routines

	If a selected routine has the same name as one already on file,
	shall it replace the one on file? No => yes
	Recompile? Yes => Yes
	Display Syntax Errors? Yes => Yes

	^ indicates routines which will replace those now on file.
	@ indicates routines which have been [re]compiled.
	- indicates routines which have not been filed.


	webinit.INT@    

	1 routine processed.
	TEST2>D ^webinit
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
	 - http://localhost:9080/test/xml
	 - http://localhost:9080/ping

## Installation as a YottaDB Plugin

When installed as a YottaDB plugin the %W.zwr is not imported.

Also, the tests and other initialization routines are not imported as the
plugin support is intended to be ran on production envrionments.

Create a build directory:

    mkdir build
    cd build

Run cmake to generate the Makefiles

    cmake ../

Install the plugin

    make install

## Manual Install from Source
You can import all the M files to your M implementation. Next, run the following:

```
I $D(^DD) D ^%webINIT
D LOADHAND^webinit
```

## Uninstalling
Run the following
```
do uninstallMWS^webinit
```

## Starting and Stopping the Server
You can stop the server using `do stop^%webreq`.

To start it again, run `D job^%webreq(portno)`, substituting a port number
of your choice. If you run `D [go]^%webreq`, it will start at port number 9080.
