%W0 ; VEN/SMH - Infrastructure web services hooks;2018-09-07  11:52 AM
 ;;1.0;MUMPS ADVANCED SHELL;;Sep 01, 2012;Build 6
 ;
R(RESULT,ARGS) ; GET Mumps Routine
 S RESULT("mime")="text/plain; charset=utf-8"
 S RESULT=$NA(^TMP($J))
 K @RESULT
 N RTN S RTN=$G(ARGS("routine"))
 N OFF,I
 I RTN]""&($T(^@RTN)]"") F I=1:1 S OFF="+"_I,LN0=OFF_"^"_RTN,LN=$T(@LN0) Q:LN=""  S @RESULT@(I)=LN_$C(13,10)
 E  K RESULT("mime") D SETERROR^VPRJRUT(404,"Routine not found")
 QUIT
 ;
PR(ARGS,BODY,RESULT) ; PUT Mumps Routine
 S HTTPRSP("mime")="text/plain; charset=utf-8" ; Character set of the return URL
 N PARSED ; Parsed array which stores each line on a separate node.
 D PARSE10^VPRJRUT(.BODY,.PARSED) ; Parser
 N DIE,XCN S DIE="PARSED(",XCN=0 D SAVE(ARGS("routine"))
 Q RESULT
 ;
SAVE(RN)        ;Save a routine
 Q:$E(RN,1,4)'="KBAN"  ; Just for this server, don't do this.
 N %,%F,%I,%N,SP,$ETRAP
 S $ETRAP="S $ECODE="""" Q"
 S %I=$I,SP=" ",%F=$$RTNDIR^%ZOSV()_$TR(RN,"%","_")_".m"
 O %F:(newversion:noreadonly:blocksize=2048:recordsize=2044) U %F
 F  S XCN=$O(@(DIE_XCN_")")) Q:XCN'>0  S %=@(DIE_XCN_")") Q:$E(%,1)="$"  I $E(%)'=";" W %,!
 C %F ;S %N=$$NULL
 ZLINK RN
 ;C %N
 U %I
 Q
FV(RESULTS,ARGS) ; Get fileman field value, handles fileman/file/iens/field
 I $$UNKARGS^VPRJRUT(.ARGS,"file,iens,field,screen,match") Q  ; Is any of these not passed?
 S RESULTS("mime")="text/plain; charset=utf-8" ; type of data to send browser
 N FILE S FILE=$G(ARGS("file")) ; se
 N IENS S IENS=$G(ARGS("iens")) ; se
 N FIELD S FIELD=$G(ARGS("field")) ; se
 I IENS?1A.AN D LISTER(.RESULTS,.ARGS) QUIT
 S RESULTS=$$GET1^DIQ(FILE,IENS,FIELD,,$NA(^TMP($J))) ; double trouble.
 I $D(^TMP("DIERR",$J)) D SETERROR^VPRJRUT(404,"File or field not found") QUIT
 ; if results is a regular field, that's the value we will get.
 ; if results is a WP field, RESULTS becomes the global ^TMP($J).
 I $D(^TMP($J)) D ADDCRLF^VPRJRUT(.RESULTS) ; crlf the result
 ;ZSHOW "D":^KBANDEV
 QUIT
 ;
LISTER(RESULTS,ARGS) ; FV divergence in case an index is requested.
 K RESULTS("mime")
 N FILE S FILE=$G(ARGS("file"))
 N INDEX S INDEX=$G(ARGS("iens"))
 N FROM S FROM=$G(ARGS("field"))
 ; I $L(FROM) D 
 ; . I +FROM'=FROM S FROM=$E(FROM,1,$L(FROM)-1)_"              " ; backtrack in index alpha style
 ; . E  S FROM=FROM-1   ; backtrack numeric style
 ;
 N SCREEN S SCREEN=$G(ARGS("screen"))
 I $L(SCREEN) D
 . N Q S Q=""""
 . N FLD,VAL
 . S FLD=$P(SCREEN,":")
 . S VAL=$P(SCREEN,":",2)
 . I VAL'=+VAL S VAL=Q_VAL_Q ; Quote literal values
 . N FLDNUM S FLDNUM=$O(^DD(FILE,"B",FLD,""))
 . Q:'FLDNUM
 . N GL S GL=$P(^DD(FILE,FLDNUM,0),U,4)
 . N GLN S GLN=$P(GL,";")
 . I GLN'=+GLN S GLN=Q_GLN_Q ; Quote literal nodes
 . N GLP S GLP=$P(GL,";",2)
 . I $E(GLP)="E" D
 . . N START S START=$P(GLP,","),START=$E(GLP,2,99)
 . . N END S END=$P(GLP,",",2)
 . . S SCREEN="I $E(^("_GLN_"),"_START_","_END_")="_VAL
 . E  D
 . . S SCREEN="I $P(^("_GLN_"),U,"_GLP_")="_VAL
 ;
 N FLAGS S FLAGS="QP" ; Default flag
 ; 
 ; TODO: if index is not compound, don't apply matching below; send X flag to finder instead.
 ; I $G(ARGS("match"))="exact" S FLAGS=FLAGS_"X"
 N %WRES,%WERR
 ; %WRES("DILIST",0)="200^200^1^"
 ; %WRES("DILIST",0,"MAP")="IEN^IX(1)^.01^FID(.12)^FID(.13)^FID(.14)"
 ; %WRES("DILIST",1,0)="8870^CA - CALCIUM^1895^SNOMEDCT^SY^5540006"
 ; %WRES("DILIST",2,0)="60527^CA - CHOLIC ACID^20969^SNOMEDCT^SY^17147002"
 ; %WRES("DILIST",3,0)="606334^CA 1000/MAGNESIUM 400/ZINC 15M^810433^VANDF^AB^40252
 I FROM="" D
 . D LIST^DIC(FILE,,"IX;FID",FLAGS,200,,,INDEX,SCREEN,"",$NA(%WRES),$NA(%WERR))
 E  D FIND^DIC(FILE,,"IX;FID",FLAGS,FROM,200,INDEX,SCREEN,"",$NA(%WRES),$NA(%WERR))
 ;
 ; 
 ; Filter only for exact matches if requested. 
 ; Get IX(1) entries and make sure they are the same as the original values.
 I $G(ARGS("match"))="exact" D
 . ; I looper to set IX(1) piece location
 . N I F I=1:1:$L(%WRES("DILIST",0,"MAP"),U) Q:$P(%WRES("DILIST",0,"MAP"),U,I)="IX(1)"
 . N IX1P S IX1P=I ; IX(1) piece location
 . N I S I=0 F  S I=$O(%WRES("DILIST",I)) Q:'I  D  ; Remove IX(1)'s that don't match
 . . I $P(%WRES("DILIST",I,0),U,IX1P)'=FROM K %WRES("DILIST",I,0)
 ;
 ;
 ; K ^KBANRPC ZSHOW "*":^KBANRPC
 ;
 ;
 I $D(DIERR) D SETERROR^VPRJRUT("500","Lister error") Q
 N MAP S MAP=%WRES("DILIST",0,"MAP")
 S MAP=$$REMAP(MAP,FILE)
 N %WRES2
 N I S I=0
 F  S I=$O(%WRES("DILIST",I)) Q:'I  D
 . N IEN
 . S NODE=%WRES("DILIST",I,0)
 . N P F P=1:1:$L(MAP,U) I $P(MAP,U,P)["IEN" S IEN=$P(NODE,U,P)
 . N P F P=1:1:$L(MAP,U) S %WRES2(IEN,$P(MAP,U,P))=$P(NODE,U,P)
 . K %WRES("DILIST",I,0)
 K %WRES("DILIST",0)
 N %WJSON,%WERR
 D ENCODE^VPRJSON($NA(%WRES2),$NA(%WJSON),$NA(%WERR))
 I $D(%WERR) D SETERROR^VPRJRUT("500","Error in JSON conversion") Q
 M RESULTS=%WJSON
 QUIT
 ;
REMAP(MAP,FILE) ; Private $$ - Remap the map from the lister
 N NEWMAP
 N I F I=1:1:$L(MAP,U) D
 . N P S P=$P(MAP,U,I)
 . I P["IX(" S P="INDEX VALUE "_+$P(P,"IX(",2)
 . I $E(P,1,3)=".01" S P="#"_P_" "_$$GET1^DID(FILE,.01,"","LABEL")
 . I P["FID(" N FLD S FLD=+$P(P,"FID(",2),P="#"_FLD_" "_$$GET1^DID(FILE,FLD,"","LABEL")
 . I P="IEN" S P="#.001 IEN"
 . S $P(NEWMAP,U,I)=P
 Q NEWMAP
 ;
LISTERT 
 N ARGS S ARGS("file")=176.001,ARGS("iens")="STR",ARGS("field")="CA"
 D LISTER(,.ARGS)
 N ARGS S ARGS("file")=176.005,ARGS("iens")="B",ARGS("field")="87795"
 D LISTER(,.ARGS)
 QUIT
 ;
F(RESULT,ARGS) ; handles fileman/{file}/{iens}
 I $$UNKARGS^VPRJRUT(.ARGS,"file,iens") Q  ; Is any of these not passed?
 N FILE S FILE=$G(ARGS("file")) ; se
 N IENS S IENS=$G(ARGS("iens")) ; se
 N %WRTN,%WERR
 N DIERR
 D GETS^DIQ(FILE,IENS,"*","RN",$NA(%WRTN),$NA(%WERR))
 I $D(DIERR) D SETERROR^VPRJRUT("500","Error in GETS^DIQ Selection") Q
 N %WERR
 D ENCODE^VPRJSON($NA(%WRTN(FILE,IENS_",")),$NA(RESULT),$NA(%WERR))
 ; debug
 ;K ^KBANRPC 
 ;ZSHOW "V":^KBANRPC
 ; debug
 I $D(%WERR) D SETERROR^VPRJRUT("500","Error in JSON conversion") Q
 QUIT
 ;
MOCHA(RESULTS,ARGS) ;
 K RESULTS
 S RESULTS("mime")="text/xml; charset=utf-8"
 N TYPE S TYPE=$G(ARGS("type"))
 I TYPE="" K RESULTS("mime") D SETERROR^VPRJRUT(404,"MOCHA web service not found")
 N XMLRTN D GETXML^KBAIT1(.XMLRTN,TYPE)
 I '$O(XMLRTN("")) K RESULTS("mime") D SETERROR^VPRJRUT(404,"MOCHA sub service not found")
 D ADDCRLF^VPRJRUT(.XMLRTN)
 M RESULTS=XMLRTN
 QUIT
 ;
POSTTEST(ARGS,BODY,RESULT) ; POST XML to a WP field in Fileman; handles /xmlpost
 N IEN S IEN=$O(^%W(6.6002,""),-1)+1
 N %WFDA S %WFDA(6.6002,"?+1,",.01)=IEN D UPDATE^DIE("",$NA(%WFDA))
 S RESULT="/fileman/6.6002/"_IEN_"/"_1 ; Stored URL
 N PARSED ; Parsed array which stores each line on a separate node.
 D PARSE10^VPRJRUT(.BODY,.PARSED) ; Parser
 D WP^DIE(6.6002,IEN_",",1,"K",$NA(PARSED)) ; File WP field; lock record in process.
 ; ZSHOW "V":^KBANPARSED
 S RESULT("mime")="text/plain; charset=utf-8" ; Character set of the return URL
 Q RESULT
 ;
MOCHAP(ARGS,BODY,RESULT) ; POST XML to MOCHA; handles MOCHA/ordercheck
 ; N TYPE S TYPE=$G(ARGS("type"))
 N DIQUIET S DIQUIET=1 D DT^DICRW
 N PARSEDTEXT D PARSE10^VPRJRUT(.BODY,.PARSEDTEXT)
 ; K ^KBANPARSED M ^KBANPARSED=PARSEDTEXT
 ; D GETXRSP^KBAIT1(.RESULT,TYPE)
 ;
 ; Put the parsed XML in a global
 N R S R=$NA(^TMP($J,"MOCHA","ORDERCHECK"))
 K @R 
 M @R=PARSEDTEXT
 ;
 ; Parse it
 N DOCHANDLE S DOCHANDLE=$$EN^MXMLDOM(R,"W")
 I 'DOCHANDLE D SETERROR^VPRJRUT("500","XML not parsable") Q ""
 ;
 ; Process it
 D EN^KBANMOCHA(.RESULT,DOCHANDLE)
 ; ZSHOW "*":^KBANPARSED
 ;
 ; Clean-up
 D DELETE^MXMLDOM(DOCHANDLE)
 K @R
 Q ""
 ;
RPC(ARGS,BODY,RESULT) ; POST to execute Remote Procedure Calls; handles POST rpc/{rpc}
 ; Very simple... no security checking
 N RP S RP=$G(ARGS("rpc"))
 I '$L(RP) D SETERROR^VPRJRUT("400","Remote procedure not specified") Q ""
 ;
 N DIQUIET S DIQUIET=1 D DT^DICRW ; Set up "^" as U
 ;
 N XWB
 S XWB(2,"RPC")=RP
 N % S %=$$RPC^XWBPRS()
 I % D SETERROR^VPRJRUT("404","Remote procedure not found") Q ""
 ;
 N PARAMS,%WERR
 I $D(BODY) D DECODE^VPRJSON($NA(BODY),$NA(PARAMS),$NA(%WERR))
 I $D(%WERR) D SETERROR^VPRJRUT("400","Input parameters not correct")
 ;
 ; Loop through the PARAMS and construct an argument list
 ; TODO: Two uncommonly used types are global and reference parameter. Need to do if we want to emulate broker completely.
 N ARGLIST S ARGLIST=""  ; Argument list, starting empty
 ;
 I $D(PARAMS) F I=1:1:$O(PARAMS(""),-1) N @("A"_I)  ; New parameter variables, stored in A1,A2,A3 etc.
 D:$D(PARAMS)
 . N I F I=0:0 S I=$O(PARAMS(I)) Q:'I  D
 . . I $D(PARAMS(I))[0 D  ; Reference Parameter
 . . . M @("A"_I)=PARAMS(I) S ARGLIST=ARGLIST_".A"_I_","
 . . E  D  ; Literal Param
 . . . S @("A"_I)=PARAMS(I),ARGLIST=ARGLIST_"A"_I_","
 ;
 S ARGLIST=$E(ARGLIST,1,$L(ARGLIST)-1) ; Remove trailing comma
 ;
 N %WCALL 
 I $L(ARGLIST) S %WCALL="D "_XWB(2,"RTAG")_"^"_XWB(2,"RNAM")_"(.RESULT,"_ARGLIST_")" ; Routine call with arguments
 E  S %WCALL="D "_XWB(2,"RTAG")_"^"_XWB(2,"RNAM")_"(.RESULT)" ; Routine call with no arguments
 ;
 X %WCALL ; Action!
 ;
 D ADDCRLF^VPRJRUT(.RESULT) ; Add CRLF to each line
 ;
 ; debug
 ;K ^KBANRPC 
 ;M ^KBANRPC=BODY,^KBANRPC=RP
 ;ZSHOW "V":^KBANRPC
 ; debug
 ;
 S RESULT("mime")="text/plain; charset=utf-8" ; Character set of the return
 Q "/rpc/"_RP
 ;
RPCO(RESULT,ARGS) ; Get Remote Procedure Information; handles OPTIONS rpc/{rpc}
 ; Very simple... no security checking
 N RP S RP=$G(ARGS("rpc"))
 I '$L(RP) D SETERROR^VPRJRUT("400","Remote procedure not specified") Q
 ;
 N RPIEN S RPIEN=$$FIND1^DIC(8994,,"QX",RP,"B") ; Find eXact, Quick (no transforms) in B index
 I 'RPIEN D SETERROR^VPRJRUT("404","Remote procedure not found") Q
 ;
 ;
 N %WRTN,%WERR
 D GETS^DIQ(8994,RPIEN,"**","RN",$NA(%WRTN)) ; Get all fields; resolve to external names and omit nulls
 N ROU,TAG S ROU=%WRTN(8994,RPIEN_",","ROUTINE"),TAG=%WRTN(8994,RPIEN_",","TAG")
 I $L($T(@(TAG_"^"_ROU))) S %WRTN(8994,RPIEN_",","FORMALLINE")=$T(@(TAG_"^"_ROU))
 D ENCODE^VPRJSON($NA(%WRTN(8994,RPIEN_",")),$NA(RESULT),$NA(%WERR))
 ; debug
 ;K ^KBANRPC 
 ;S ^KBANRPC=RP
 ;ZSHOW "V":^KBANRPC
 ; debug
 I $D(%WERR) D SETERROR^VPRJRUT("500","Error in JSON conversion") Q
 ;
 QUIT
 ;
FILESYS(RESULT,ARGS) ; Handle filesystem/*
 I '$D(ARGS)&$D(PATHSEG) S ARGS("*")=PATHSEG
 N PATH
 ;
 ; Vhere is our home? If any home!
 I $D(^%WHOME)#2 D
 . I +$SY=47 S $ZD=^%WHOME ; GT.M
 . I +$SY=0 N % S %=$ZU(168,^%WHOME) ; Cache
 ;
 ; Ok, get the actual path
 I +$SY=47 S PATH=$ZDIRECTORY_ARGS("*") ; GT.M Only!
 I +$SY=0 S PATH=$ZU(168)_ARGS("*") ; Cache Only!
 ;
 ; GT.M errors out on FNF; Cache blocks. Need timeout and else.
 N $ET S $ET="G FILESYSE"
 ; Fixed prevents Reads to terminators on SD's. CHSET makes sure we don't analyze UTF.
 I +$SY=47 O PATH:(REWIND:READONLY:FIXED:CHSET="M") 
 ;
 ; This mess for Cache!
 N POP S POP=0
 I +$SY=0 O PATH:("RU"):0  E  S POP=1  ; Cache must have a timeout; U = undefined.
 I POP G FILESYSE
 ;
 ; Prevent End of file Errors for Cache. Set DSM mode for that.
 I +$SY=0 D $SYSTEM.Process.SetZEOF(1) ; Cache stuff!!
 ;
 ; Set content-cache value; defaults to one week.
 set RESULT("cache")=604800
 ;
 ; Get mime type
 ; TODO: Really really needs to be in a file
 ; This isn't complete, by any means; it just grabs the most likely types to be
 ; found on an M Web Server. A few common Microsoft types are supported, but
 ; few other vendor-specific types are. Also, there are a few Mumps-centric
 ; types added below (under the x- prefix). If it's an unrecognized file
 ; extension, no MIME type is set.
 new MIMELKUP
 set MIMELKUP("aif")="audio/aiff"
 set MIMELKUP("aiff")="audio/aiff"
 set MIMELKUP("au")="audio/basic"
 set MIMELKUP("avi")="video/avi"
 set MIMELKUP("css")="text/css"
 set MIMELKUP("csv")="text/csv"
 set MIMELKUP("doc")="application/msword"
 set MIMELKUP("gif")="image/gif"
 set MIMELKUP("htm")="text/html"
 set MIMELKUP("html")="text/html"
 set MIMELKUP("ico")="image/x-icon"
 set MIMELKUP("jpe")="image/jpeg"
 set MIMELKUP("jpeg")="image/jpeg"
 set MIMELKUP("jpg")="image/jpeg"
 set MIMELKUP("js")="application/javascript"
 set MIMELKUP("kid")="text/x-mumps-kid"
 set MIMELKUP("m")="text/x-mumps"
 set MIMELKUP("mov")="video/quicktime"
 set MIMELKUP("mp3")="audio/mpeg3"
 set MIMELKUP("pdf")="application/pdf"
 set MIMELKUP("png")="image/png"
 set MIMELKUP("ppt")="application/vnd.ms-powerpoint"
 set MIMELKUP("ps")="application/postscript"
 set MIMELKUP("qt")="video/quicktime"
 set MIMELKUP("svg")="image/svg+xml"
 set MIMELKUP("tex")="application/x-tex"
 set MIMELKUP("tif")="image/tiff"
 set MIMELKUP("tiff")="image/tiff"
 set MIMELKUP("txt")="text/plain"
 set MIMELKUP("log")="text/plain"
 set MIMELKUP("wav")="audio/wav"
 set MIMELKUP("xls")="application/vnd.ms-excel"
 set MIMELKUP("zip")="application/zip"
 new EXT set EXT=$PIECE(PATH,".",$LENGTH(PATH,"."))
 if $DATA(MIMELKUP(EXT)) set RESULT("mime")=MIMELKUP(EXT)
 ;
 ; Read operation
 U PATH
 N C S C=1
 N X F  R X#4079:0 S RESULT(C)=X,C=C+1 Q:$ZEOF
 C PATH
 QUIT
 ;
FILESYSE ; 500
 S $EC=""
 D SETERROR^VPRJRUT("500",$S(+$SY=47:$ZS,1:$ZE))
 QUIT
