WWWINIT ; VEN/SMH - Initialize %W namespaces for Cache ; 12/18/13 12:08pm
 ;;0.1;MASH WEB SERVER/WEB SERVICES
 ;
 I +$SYSTEM'=0 QUIT  ; Only Cache!
 ;
 ; Get current namespace
 N NMSP S NMSP=$ZU(5)
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
