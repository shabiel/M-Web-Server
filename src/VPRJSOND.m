VPRJSOND ;SLC/KCM -- Decode JSON
 ;;1.0;VIRTUAL PATIENT RECORD;**2**;Sep 01, 2011;Build 50
 ;
DECODE(VVJSON,VVROOT,VVERR) ; Set JSON object into closed array ref VVROOT
 ;
DIRECT ; TAG for use by DECODE^VPRJSON
 ;
 ; Examples: D DECODE^VPRJSON("MYJSON","LOCALVAR","LOCALERR")
 ;           D DECODE^VPRJSON("^MYJSON(1)","^GLO(99)","^TMP($J)")
 ;
 ; VVJSON: string/array containing serialized JSON object
 ; VVROOT: closed array reference for M representation of object
 ;  VVERR: contains error messages, defaults to ^TMP("VPRJERR",$J)
 ;
 ;   VVIDX: points to next character in JSON string to process
 ; VVSTACK: manages stack of subscripts
 ;  VVPROP: true if next string is property name, otherwise treat as value
 ;
 N VVMAX S VVMAX=4000 ; limit document lines to 4000 characters
 S VVERR=$G(VVERR,"^TMP(""VPRJERR"",$J)")
 ; If a simple string is passed in, move it to an temp array (VVINPUT)
 ; so that the processing is consistently on an array.
 I $D(@VVJSON)=1 N VVINPUT S VVINPUT(1)=@VVJSON,VVJSON="VVINPUT"
 S VVROOT=$NA(@VVROOT@("Z")),VVROOT=$E(VVROOT,1,$L(VVROOT)-4) ; make open array ref
 N VVLINE,VVIDX,VVSTACK,VVPROP,VVTYPE,VVERRORS
 S VVLINE=$O(@VVJSON@("")),VVIDX=1,VVSTACK=0,VVPROP=0,VVERRORS=0
 F  S VVTYPE=$$NXTKN() Q:VVTYPE=""  D  I VVERRORS Q
 . I VVTYPE="{" S VVSTACK=VVSTACK+1,VVSTACK(VVSTACK)="",VVPROP=1 D:VVSTACK>64 ERRX("STL{") Q
 . I VVTYPE="}" D:VVSTACK(VVSTACK) ERRX("OBM") S VVSTACK=VVSTACK-1 D:VVSTACK<0 ERRX("SUF}") Q
 . I VVTYPE="[" S VVSTACK=VVSTACK+1,VVSTACK(VVSTACK)=1 D:VVSTACK>64 ERRX("STL[") Q
 . I VVTYPE="]" D:'VVSTACK(VVSTACK) ERRX("ARM") S VVSTACK=VVSTACK-1 D:VVSTACK<0 ERRX("SUF]") Q
 . I VVTYPE="," D  Q
 . . I VVSTACK(VVSTACK) S VVSTACK(VVSTACK)=VVSTACK(VVSTACK)+1  ; next in array
 . . E  S VVPROP=1                                   ; or next property name
 . I VVTYPE=":" S VVPROP=0 D:'$L($G(VVSTACK(VVSTACK))) ERRX("MPN") Q
 . I VVTYPE="""" D  Q
 . . I VVPROP S VVSTACK(VVSTACK)=$$NAMPARS() I 1
 . . E  D ADDSTR
 . S VVTYPE=$TR(VVTYPE,"TFN","tfn")
 . I VVTYPE="t" D  Q
 . . I $TR($E(@VVJSON@(VVLINE),VVIDX,VVIDX+2),"RUE","rue")="rue" D SETBOOL("true") I 1
 . . E  D ERRX("EXT",VVTYPE)
 . I VVTYPE="f" D  Q
 . . I $TR($E(@VVJSON@(VVLINE),VVIDX,VVIDX+3),"ALSE","alse")="alse" D SETBOOL("false") I 1
 . . E  D ERRX("EXF",VVTYPE)
 . I VVTYPE="n" D  Q
 . . I $TR($E(@VVJSON@(VVLINE),VVIDX,VVIDX+2),"ULL","ull")="ull" D SETBOOL("null") I 1
 . . E  D ERRX("EXN",VVTYPE)
 . I "0123456789+-.eE"[VVTYPE S @$$CURNODE()=$$NUMPARS(VVTYPE) Q
 . D ERRX("TKN",VVTYPE)
 I VVSTACK'=0 D ERRX("SCT",VVSTACK)
 Q
NXTKN() ; Move the pointers to the beginning of the next token
 N VVDONE,VVEOF,VVTOKEN
 S VVDONE=0,VVEOF=0 F  D  Q:VVDONE!VVEOF  ; eat spaces & new lines until next visible char
 . I VVIDX>$L(@VVJSON@(VVLINE)) S VVLINE=$O(@VVJSON@(VVLINE)),VVIDX=1 I 'VVLINE S VVEOF=1 Q
 . I $A(@VVJSON@(VVLINE),VVIDX)>32 S VVDONE=1 Q
 . S VVIDX=VVIDX+1
 Q:VVEOF ""  ; we're at the end of input
 S VVTOKEN=$E(@VVJSON@(VVLINE),VVIDX),VVIDX=VVIDX+1
 Q VVTOKEN
 ;
ADDSTR ; Add string value to current node, escaping text along the way
 ; Expects VVLINE,VVIDX to reference that starting point of the index
 ; TODO: add a mechanism to specify names that should not be escaped
 ;       just store as ":")= and ":",n)=
 ;
 ; Happy path -- we find the end quote in the same line
 N VVEND,VVX
 S VVEND=$F(@VVJSON@(VVLINE),"""",VVIDX)
 I VVEND,($E(@VVJSON@(VVLINE),VVEND-2)'="\") D SETSTR  QUIT  ;normal
 I VVEND,$$ISCLOSEQ(VVLINE) D SETSTR QUIT  ;close quote preceded by escaped \
 ;
 ; Less happy path -- first quote wasn't close quote
 N VVDONE,VVTLINE
 S VVDONE=0,VVTLINE=VVLINE ; VVTLINE for temporary increment of VVLINE
 F  D  Q:VVDONE  Q:VVERRORS
 . ;if no quote on current line advance line, scan again
 . I 'VVEND S VVTLINE=VVTLINE+1,VVEND=1 I '$D(@VVJSON@(VVTLINE)) D ERRX("EIQ") Q
 . S VVEND=$F(@VVJSON@(VVTLINE),"""",VVEND)
 . I VVEND,$E(@VVJSON@(VVTLINE),VVEND-2)'="\" S VVDONE=1 Q  ; found quote position
 . S VVDONE=$$ISCLOSEQ(VVTLINE) ; see if this is an escaped quote or closing quote
 Q:VVERRORS
 ; unescape from VVIDX to VVEND, using \-extension nodes as necessary
 D UESEXT
 ; now we need to move VVLINE and VVIDX to next parsing point
 S VVLINE=VVTLINE,VVIDX=VVEND
 Q
SETSTR ; Set simple string value from within same line
 ; expects VVJSON, VVLINE, VVINX, VVEND
 N VVX
 S VVX=$E(@VVJSON@(VVLINE),VVIDX,VVEND-2),VVIDX=VVEND
 S @$$CURNODE()=$$UES(VVX)
 I +VVX=VVX S @$$CURNODE()@("\s")=""
 ;S vX=$S(+vX=vX:$C(186)_vX,1:$$UES(vX))
 ;S @$$CURNODE()=vX
 I VVIDX>$L(@VVJSON@(VVLINE)) S VVLINE=VVLINE+1,VVIDX=1
 Q
UESEXT ; unescape from VVLINE,VVIDX to VVTLINE,VVEND & extend (\) if necessary
 ; expects VVLINE,VVIDX,VVTLINE,VVEND
 N VVI,VVY,VVSTART,VVSTOP,VVDONE,VVBUF,VVNODE,VVMORE,VVTO
 S VVNODE=$$CURNODE(),VVBUF="",VVMORE=0,VVSTOP=VVEND-2
 S VVI=VVIDX,VVY=VVLINE,VVDONE=0
 F  D  Q:VVDONE  Q:VVERRORS
 . S VVSTART=VVI,VVI=$F(@VVJSON@(VVY),"\",VVI)
 . ; if we are on the last line, don't extract past VVSTOP
 . I (VVY=VVTLINE) S VVTO=$S('VVI:VVSTOP,VVI>VVSTOP:VVSTOP,1:VVI-2) I 1
 . E  S VVTO=$S('VVI:99999,1:VVI-2)
 . D ADDBUF($E(@VVJSON@(VVY),VVSTART,VVTO))
 . I (VVY'<VVTLINE),(('VVI)!(VVI>VVSTOP)) S VVDONE=1 QUIT  ; now past close quote
 . I 'VVI S VVY=VVY+1,VVI=1 QUIT  ; nothing escaped, go to next line
 . I VVI>$L(@VVJSON@(VVY)) S VVY=VVY+1,VVI=1 I '$D(@VVJSON@(VVY)) D ERRX("EIU")
 . D ADDBUF($$REALCHAR($E(@VVJSON@(VVY),VVI)))
 . S VVI=VVI+1
 . I (VVY'<VVTLINE),(VVI>VVSTOP) S VVDONE=1 ; VVI incremented past stop
 Q:VVERRORS
 D SAVEBUF
 Q
ADDBUF(VVX) ; add buffer of characters to destination
 ; expects VVBUF,VVMAX,VVNODE,VVMORE to be defined
 ; used directly by ADDSTR
 I $L(VVX)+$L(VVBUF)>VVMAX D SAVEBUF
 S VVBUF=VVBUF_VVX
 Q
SAVEBUF ; write out buffer to destination
 ; expects VVBUF,VVMAX,VVNODE,VVMORE to be defined
 ; used directly by ADDSTR,ADDBUF
 I 'VVMORE S @VVNODE=VVBUF S:+VVBUF=VVBUF @VVNODE@("\s")="" I 1 ;$S(+VVBUF=VVBUF:$C(186)_VVBUF,1:VVBUF)
 E  S @VVNODE@("\",VVMORE)=VVBUF
 S VVMORE=VVMORE+1,VVBUF=""
 Q
ISCLOSEQ(VVBLINE) ; return true if this is a closing, rather than escaped, quote
 ; expects VVJSON, VVIDX, VVEND
 ; always called directly from ADDSTR
 N VVBACK,VVBIDX
 S VVBACK=0,VVBIDX=VVEND-2
 ; starting at VVEND-2 means looking at the char right before the \
 ; if it is not \, then the \ was escaping the quote
 F  D  Q:$E(@VVJSON@(VVBLINE),VVBIDX)'="\"  Q:VVERRORS
 . S VVBACK=VVBACK+1,VVBIDX=VVBIDX-1
 . I (VVBLINE=VVLINE),(VVBIDX=VVIDX) Q  ; back at the open quote
 . Q:VVBIDX
 . ; when VVBIDX<1 go back a line
 . S VVBLINE=VVBLINE-1 I VVBLINE<VVLINE D ERRX("RSB") Q
 . S VVBIDX=$L(@VVJSON@(VVBLINE))
 Q VVBACK#2=0  ; VVBACK is even if this is a close quote
 ;
NAMPARS() ; Return parsed name, advancing index past the close quote
 ; -- This assumes no embedded quotes are in the name itself --
 N VVEND,VVDONE,VVNAME
 S VVDONE=0,VVNAME=""
 F  D  Q:VVDONE  Q:VVERRORS
 . S VVEND=$F(@VVJSON@(VVLINE),"""",VVIDX)
 . I VVEND S VVNAME=VVNAME_$E(@VVJSON@(VVLINE),VVIDX,VVEND-2),VVIDX=VVEND,VVDONE=1
 . I 'VVEND S VVNAME=VVNAME_$E(@VVJSON@(VVLINE),VVIDX,$L(@VVJSON@(VVLINE)))
 . I 'VVEND!(VVEND>$L(@VVJSON@(VVLINE))) S VVLINE=VVLINE+1,VVIDX=1 I '$D(@VVJSON@(VVLINE)) D ERRX("ORN")
 Q VVNAME
 ;
NUMPARS(VVDIGIT) ; Return parsed number, advancing index past the end of the number
 ; VVIDX intially references the second digit
 N VVDONE,VVNUM
 S VVDONE=0,VVNUM=VVDIGIT
 F  D  Q:VVDONE  Q:VVERRORS
 . I '("0123456789+-.eE"[$E(@VVJSON@(VVLINE),VVIDX)) S VVDONE=1 Q
 . S VVNUM=VVNUM_$E(@VVJSON@(VVLINE),VVIDX)
 . S VVIDX=VVIDX+1 I VVIDX>$L(@VVJSON@(VVLINE)) S VVLINE=VVLINE+1,VVIDX=1 I '$D(@VVJSON@(VVLINE)) D ERRX("OR#")
 Q VVNUM
 ;
SETBOOL(VVX) ; set a value and increment VVIDX
 S @$$CURNODE()=VVX
 S VVIDX=VVIDX+$L(VVX)-1
 N VVDIFF S VVDIFF=VVIDX-$L(@VVJSON@(VVLINE))  ; in case VVIDX moves to next line
 I VVDIFF>0 S VVLINE=VVLINE+1,VVIDX=VVDIFF I '$D(@VVJSON@(VVLINE)) D ERRX("ORB")
 Q
CURNODE() ; Return a global/local variable name based on VVSTACK
 ; Expects VVSTACK to be defined already
 N VVI,VVSUBS
 S VVSUBS=""
 F VVI=1:1:VVSTACK S:VVI>1 VVSUBS=VVSUBS_"," D
 . I VVSTACK(VVI) S VVSUBS=VVSUBS_VVSTACK(VVI)
 . E  S VVSUBS=VVSUBS_""""_VVSTACK(VVI)_""""
 Q VVROOT_VVSUBS_")"
 ;
UES(X) ; Unescape JSON string
 ; copy segments from START to POS-2 (right before \)
 ; translate target character (which is at $F position)
 N POS,Y,START
 S POS=0,Y=""
 F  S START=POS+1 D  Q:START>$L(X)
 . S POS=$F(X,"\",POS+1) ; find next position
 . I 'POS S Y=Y_$E(X,START,$L(X)),POS=$L(X) I 1
 . E  S Y=Y_$E(X,START,POS-2)_$$REALCHAR($E(X,POS))
 . ;S:'POS POS=$L(X)+2  ; get the rest of the string
 . ;S Y=Y_$E(X,START,POS-2)_$$REALCHAR($E(X,POS))
 Q Y
 ;
REALCHAR(C) ; Return actual character from escaped
 I C="""" Q """"
 I C="/" Q "/"
 I C="\" Q "\"
 I C="b" Q $C(8)
 I C="f" Q $C(12)
 I C="n" Q $C(10)
 I C="r" Q $C(13)
 I C="t" Q $C(9)
 I C="u" ;TODO add case for 4-hex-digits (U000A, for example)
 ;otherwise
 I $L($G(VVERR)) D ERRX("ESC",C)
 Q C
 ;
ERRX(ID,VAL) ; Set the appropriate error message
 D ERRX^VPRJSON(ID,$G(VAL))
 Q