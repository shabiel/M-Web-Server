WWWINIT ; VEN/SMH - Initialize Web Server; 12/18/13 12:08pm
 ;;0.1;MASH WEB SERVER/WEB SERVICES
 ;
 ; Map %W
 I +$SYSTEM=0 DO CACHEMAP  ; Only Cache!
 ;
 ; Set-up TLS on Cache
 I +$SYSTEM=0 DO CACHETLS
 ;
 ; Download the files from Github
 D DOWNLOAD
 ;
 ; If fileman is installed, do an init for the %W(17.001 file
 I $D(^DD) D ^%WINIT

CACHEMAP ; Map %W* Globals and Routines away from %SYS in Cache
 ; Get current namespace
 N NMSP S NMSP=$NAMESPACE
 ;
 ; Map %W globals away from %SYS
 ZN "%SYS" ; Go to SYS
 N % S %=##class(Config.Configuration).GetGlobalMapping(NMSP,"%W*","",NMSP,NMSP)
 I '% S %=##class(Config.Configuration).AddGlobalMapping(NMSP,"%W*","",NMSP,NMSP)
 I '% W !,"Error="_$SYSTEM.Status.GetErrorText(%) QUIT
 ;
 ; Map %W routines away from %SYS
 N A S A("Database")=NMSP
 N % S %=##Class(Config.MapRoutines).Get(NMSP,"%W*",.A)
 S A("Database")=NMSP
 I '% S %=##Class(Config.MapRoutines).Create(NMSP,"%W*",.A)
 I '% W !,"Error="_$SYSTEM.Status.GetErrorText(%) QUIT
 ZN NMSP ; Go back
 QUIT
 ;
CACHETLS ; Create a client SSL/TLS config on Cache
 ;
 ; Create the configuration
 N NMSP S NMSP=$NAMESPACE
 ZN "%SYS"
 n config,status
 n % s %=##class(Security.SSLConfigs).Exists("client",.config,.status) ; check if config exists
 i '% d
 . n prop s prop("Name")="client"
 . s %=##class(Security.SSLConfigs).Create("client",.prop) ; create a default ssl config
 . i '% w $SYSTEM.Status.GetErrorText(%) s $ec=",u-cache-error,"
 . s %=##class(Security.SSLConfigs).Exists("client",.config,.status) ; get config
 e  s %=config.Activate()
 ;
 ; Test it by connecting to encrypted.google.com
 n rtn
 d config.TestConnection("173.194.33.4",443,.rtn)
 i rtn w "TLS/SSL client configured on Cache as config name 'client'",!
 e  w "Cannot configure TLS/SSL on Cache",! s $ec=",u-cache-error,"
 ZN NMSP
 QUIT
 ;
DOWNLOAD ; Download the files from Github
 N URL S URL="https://github.com/shabiel/M-Web-Server/archive/master.zip"
 D:+$SY=0 DOWNCACH(URL)
 D:+$SY=47 DOWNGTM(URL)
 QUIT
 ;
DOWNCACH(URL) ; Download for Cache
 ; Change directory to temp directory
 new OS set OS=$zversion(1)
 if OS=1 S $EC=",U-VMS-NOT-SUPPORTED,"
 if OS=2 D  ; windows
 . open "|CPIPE|WWW1":("chdir %temp%":"R"):1
 . use "|CPIPE|WWW1"
 . close "|CPIPE|WWW1"
 if OS=3 D  ; UNIX
 . N % S %=$ZU(168,"/tmp/")
 ;
 set httprequest=##class(%Net.HttpRequest).%New()
 set httprequest.Https=1
 set httprequest.SSLConfiguration="client"
 new server set server=$p(URL,"https://",2),server=$p(server,"/")
 new file set file=$p(URL,"https://",2),file=$p(file,"/",2,99)
 set httprequest.Server=server
 set httprequest.Timeout=5
 new status set status=httprequest.Get(file)
 new response set response=httprequest.HttpResponse.Data
 new sysfile set sysfile=##class(%Stream.FileBinary).%New()
 set status=sysfile.FilenameSet("www.rsa")
 set status=sysfile.CopyFromAndSave(response)
 set status=sysfile.%Close()
 QUIT
 ;
DOWNGTM(URL) ; Download for GT.M
 S $ZD="/tmp/"
 N CMD S CMD="curl -s -L -O "_URL
 O "pipe":(shell="/bin/sh":command=CMD)::"pipe"
 U "pipe" C "pipe"
 QUIT

