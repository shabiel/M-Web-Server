# Testing
## Automated Testing
%webtest is the main testing routine. It only works on GTM/YDB, and requires
the libcurl plugin (https://github.com/shabiel/fis-gtm-plugins/tree/master/libcurl).

You need to fix the variables acvc and dfn to be valid variables and patient for
your instance.

```
FOIA201805-SYN>D ^%webtest


 ---------------------------------- %webtest ----------------------------------
tdebug - Debug Entry Point..----------------------------------  [OK]  149.808ms
thome - Test Home Page..--------------------------------------  [OK]   37.508ms
tgetr - Test Get Handler Routine..----------------------------  [OK]   81.437ms
tputr - Put a Routine..---------------------------------------  [OK]  221.658ms
tgetxml - Test Get Handler XML..------------------------------  [OK]   75.453ms
tgzip - Test gzip encoding...---------------------------------  [OK]   53.270ms
tping - Ping..------------------------------------------------  [OK]   32.384ms
terr - generating an error.-----------------------------------  [OK]   78.026ms
terr2 - crashing the error trap.------------------------------  [OK]   30.632ms
tlong - get a long message..----------------------------------  [OK]   32.172ms
trpc1 - Run a VistA RPC w/o authentication - should fail.-----  [OK]   77.047ms
trpc2 - Run a VistA RPC (requires authentication - ac/vc provided)...
 -------------------------------------------------------------  [OK]   68.073ms
trpc3 - Run the VPR RPC (XML Version)..-----------------------  [OK]  829.807ms
trpc4 - Run the VPR RPC (JSON Version)..----------------------  [OK]   98.600ms
tParams - Test a web service with parameters...---------------  [OK]   55.788ms
tDC - Test Disconnecting from the Server w/o talking----------  [OK]  102.021ms
tInt - ZInterrupt.--------------------------------------------  [OK]  117.300ms
tLog1 - Set HTTPLOG to 1..------------------------------------  [OK]   46.762ms
tLog2 - Set HTTPLOG to 2..------------------------------------  [OK]   52.635ms
tLog3 - Set HTTPLOG to 3....----------------------------------  [OK]   89.058ms
tDCLog - Test Disconnecting from the Server w/o talking while logging.
 -------------------------------------------------------------  [OK]  206.458ms
tWebPage - Test Getting a web page....------------------------  [OK]   74.997ms
tINIT - Test Fileman INIT code
   Deleting the DATA DICTIONARY.....
This version (#1.0) of '%webINIT' was created on 22-JAN-2019
         (at DEMO.OSEHRA.ORG, by MSC FileMan 22.1061)

I AM GOING TO SET UP THE FOLLOWING FILES:

   17.6001   WEB SERVICE URL HANDLER


...SORRY, LET ME PUT YOU ON 'HOLD' FOR A SECOND........
OK, I'M DONE.
NOTE THAT FILE SECURITY-CODE PROTECTION HAS BEEN MADE..-------  [OK]   34.077ms
CORS - Make sure CORS headers are returned.....---------------  [OK]   32.291ms
USERPASS - Test that passing a username/password works..
STOP issued to process 93579
--------------------------------------------------------------  [OK]  222.275ms
NOGBL - Test to make sure no globals are used during webserver operations..

.......
STOP issued to process 93592
--------------------------------------------------------------  [OK]  398.873ms
tStop - Stop the Server. MUST BE LAST TEST HERE.--------------  [OK]    0.137ms
STOP issued to process 93463


 ----------------------------- %webjsonEncodeTest -----------------------------
NUMERIC - is numeric function............---------------------  [OK]    0.494ms
NEARZERO - encode of numbers near 0.--------------------------  [OK]    0.503ms
JSONESC - create JSON escaped string.........-----------------  [OK]    0.947ms
BASIC - encode basic object as JSON.--------------------------  [OK]    1.081ms
VALS - encode simple values only object as JSON.--------------  [OK]    0.855ms
LONG - encode object with continuation nodes for value....----  [OK]    2.472ms
PRE - encode object where parts are already JSON encoded.-----  [OK]    0.524ms
WP - word processing nodes inside object..--------------------  [OK]    1.740ms
LTZERO - leading / trailing zeros get preserved.--------------  [OK]    0.527ms
STRINGS - force encoding as string..--------------------------  [OK]    0.435ms
LABELS - unusual labels..-------------------------------------  [OK]    0.704ms
EXAMPLE - encode samples that are on JSON.ORG.....------------  [OK]   13.614ms
KEYESC - keys should be escaped.------------------------------  [OK]    0.380ms

 ----------------------------- %webjsonDecodeTest -----------------------------
JSONUES - unescape JSON encoded string........----------------  [OK]    0.648ms
SPLITA - JSON input with escaped characters on single line (uses BUILD)......
 -------------------------------------------------------------  [OK]    1.598ms
SPLITB - multiple line JSON input with lines split across tokens (uses BUILDA)......
 -------------------------------------------------------------  [OK]    1.359ms
SPLITC - multiple line JSON input with lines split inside boolean value......
 -------------------------------------------------------------  [OK]    1.933ms
SPLITD - multiple line JSON input with key split....----------  [OK]    0.778ms
LONG - long document that must be saved across extension nodes.........
 -------------------------------------------------------------  [OK]    9.283ms
FRAC - multiple lines with fractional array elements..--------  [OK]    1.423ms
VALONLY - passing in value only -- not array...---------------  [OK]    1.132ms
NUMERIC - passing in numeric types and strings......----------  [OK]    0.741ms
NEARZERO - decoding numbers near 0......----------------------  [OK]    0.802ms
BADQUOTE - poorly formed JSON (missing close quote on LABEL).-  [OK]    0.872ms
BADSLASH - poorly formed JSON (non-escaped backslash).--------  [OK]    0.919ms
BADBRACE - poorly formed JSON (Extra Brace).------------------  [OK]    0.433ms
BADCOMMA - poorly formed JSON (Extra Comma).------------------  [OK]    0.427ms
PSNUM - subjects that look like a numbers shouldn't be encoded as numbers....
 -------------------------------------------------------------  [OK]    1.232ms
NUMLABEL - label that begins with numeric..-------------------  [OK]    1.412ms
PURENUM - label that is purely numeric.......-----------------  [OK]    3.311ms
STRTYPES - strings that may be confused with other types..----  [OK]    1.927ms
ESTRING - a value that looks like an exponents, other numerics.......
 -------------------------------------------------------------  [OK]    2.287ms
SAM1 - decode sample 1 from JSON.ORG...-----------------------  [OK]    1.637ms
SAM2 - decode sample 2 from JSON.ORG...-----------------------  [OK]    3.434ms
SAM3 - decode sample 3 from JSON.ORG....----------------------  [OK]    4.022ms
SAM4 - decode sample 4 from JSON.ORG......--------------------  [OK]   14.797ms
SAM5 - decode sample 5 from JSON.ORG....----------------------  [OK]    7.136ms
MAXNUM - encode large string that looks like number.....------  [OK]    3.434ms
ESCQ - escaped quote across lines....-------------------------  [OK]    1.414ms
KEYQUOTE - keys with quotes...--------------------------------  [OK]    0.454ms

Ran 3 Routines, 67 Entry Tags
Checked 220 tests, with 0 failures and encountered 0 errors.


ORIG: 1323
LEFT: 259
COVERAGE PERCENTAGE: 80.42


BY ROUTINE:
  %webapi         55.13%  129 out of 234
    ERR              100.00%  2 out of 2
    F                  0.00%  0 out of 11
    FILESYS          100.00%  58 out of 58
    FILESYSE         100.00%  3 out of 3
    FV                 0.00%  0 out of 10
    LISTER             0.00%  0 out of 50
    LISTERT            0.00%  0 out of 6
    POSTTEST           0.00%  0 out of 8
    PR               100.00%  5 out of 5
    R                100.00%  8 out of 8
    REMAP              0.00%  0 out of 9
    RPC              100.00%  28 out of 28
    RPCO               0.00%  0 out of 11
    SAVE             100.00%  10 out of 10
    bigoutput        100.00%  8 out of 8
    rpc2             100.00%  7 out of 7
  %webhome       100.00%  31 out of 31
    en               100.00%  31 out of 31
  %webjson        86.11%  31 out of 36
    DECODE           100.00%  1 out of 1
    ENCODE           100.00%  1 out of 1
    ERRX              87.50%  21 out of 24
    ESC              100.00%  1 out of 1
    UES              100.00%  1 out of 1
    XERRX            100.00%  4 out of 4
    decode           100.00%  1 out of 1
    encode           100.00%  1 out of 1
    esc                0.00%  0 out of 1
    ues                0.00%  0 out of 1
  %webjsonDe      96.43%  162 out of 168
    ADDBUF           100.00%  3 out of 3
    ADDSTR           100.00%  16 out of 16
    CURNODE          100.00%  6 out of 6
    DIRECT            96.67%  29 out of 30
    ERRX             100.00%  2 out of 2
    ISCLOSEQ         100.00%  9 out of 9
    NAMPARS          100.00%  10 out of 10
    NUMPARS          100.00%  7 out of 7
    NXTKN            100.00%  8 out of 8
    OSETBOOL           0.00%  0 out of 5
    REALCHAR         100.00%  12 out of 12
    SAVEBUF          100.00%  4 out of 4
    SETBOOL          100.00%  12 out of 12
    SETNUM           100.00%  5 out of 5
    SETSTR           100.00%  7 out of 7
    UES              100.00%  10 out of 10
    UESEXT           100.00%  22 out of 22
  %webjsonEn      95.70%  89 out of 93
    CONCAT           100.00%  3 out of 3
    DIRECT           100.00%  8 out of 8
    ERRX               0.00%  0 out of 2
    ESC              100.00%  10 out of 10
    ISVALUE          100.00%  5 out of 5
    JNUM             100.00%  5 out of 5
    NUMERIC          100.00%  12 out of 12
    SERARY            91.67%  11 out of 12
    SERNAME          100.00%  4 out of 4
    SEROBJ            92.31%  12 out of 13
    SERVAL           100.00%  17 out of 17
    UCODE            100.00%  2 out of 2
  %webreq         80.53%  182 out of 226
    ADDHEAD           91.67%  11 out of 12
    CHILDDEBUG       100.00%  8 out of 8
    DEBUG             83.33%  5 out of 6
    ETBAIL           100.00%  5 out of 5
    ETCODE            83.33%  10 out of 12
    ETDC             100.00%  4 out of 4
    ETSOCK             0.00%  0 out of 3
    GTMLNX             0.00%  0 out of 6
    INCRLOG          100.00%  12 out of 12
    JOBEXAM          100.00%  4 out of 4
    LOGBODY          100.00%  6 out of 6
    LOGCN              0.00%  0 out of 5
    LOGDC            100.00%  5 out of 5
    LOGERR           100.00%  13 out of 13
    LOGHDR           100.00%  7 out of 7
    LOGRAW           100.00%  8 out of 8
    LOGRSP           100.00%  7 out of 7
    LOOP              70.59%  12 out of 17
    NEXT             100.00%  2 out of 2
    RDCHNKS            0.00%  0 out of 1
    RDCRLF           100.00%  4 out of 4
    RDLEN            100.00%  2 out of 2
    RDLOOP           100.00%  7 out of 7
    TLS               60.00%  3 out of 5
    WAIT              81.08%  30 out of 37
    go                 0.00%  0 out of 3
    job                0.00%  0 out of 4
    start             78.95%  15 out of 19
    stop             100.00%  2 out of 2
  %webrsp         86.94%  233 out of 268
    AUTHEN            72.73%  8 out of 11
    BODYASSTR        100.00%  4 out of 4
    FLUSH            100.00%  3 out of 3
    GZIP              87.50%  28 out of 32
    MATCH             55.88%  19 out of 34
    MATCHF           100.00%  34 out of 34
    MATCHFS          100.00%  4 out of 4
    MATCHR            80.95%  17 out of 21
    PING             100.00%  2 out of 2
    QSPLIT           100.00%  6 out of 6
    RESPOND           91.67%  44 out of 48
    RSPERROR         100.00%  5 out of 5
    RSPLINE          100.00%  7 out of 7
    SENDATA           88.37%  38 out of 43
    W                100.00%  4 out of 4
    XML              100.00%  10 out of 10
  %webutils       77.53%  207 out of 267
    ADDCRLF          100.00%  6 out of 6
    BASE             100.00%  2 out of 2
    CNV              100.00%  3 out of 3
    DEC              100.00%  3 out of 3
    DEC2HEX            0.00%  0 out of 1
    DECODE64         100.00%  10 out of 10
    ENCODE64           0.00%  0 out of 11
    F1               100.00%  1 out of 1
    F2                 0.00%  0 out of 3
    F3                 0.00%  0 out of 3
    F4                 0.00%  0 out of 3
    F5                 0.00%  0 out of 3
    F6                 0.00%  0 out of 3
    F7                 0.00%  0 out of 3
    F8                 0.00%  0 out of 2
    F9                 0.00%  0 out of 2
    FMT               66.67%  2 out of 3
    GMT               81.82%  9 out of 11
    HEX2DEC          100.00%  1 out of 1
    HR               100.00%  1 out of 1
    HTE              100.00%  3 out of 3
    HTFM             100.00%  5 out of 5
    INIT64           100.00%  1 out of 1
    LOW              100.00%  1 out of 1
    LTRIM            100.00%  4 out of 4
    M                100.00%  1 out of 1
    PARSE10          100.00%  11 out of 11
    REFSIZE           54.55%  6 out of 11
    REFSIZEGTM       100.00%  5 out of 5
    T2               100.00%  2 out of 2
    TM                57.14%  4 out of 7
    UNKARGS            0.00%  0 out of 6
    UP               100.00%  1 out of 1
    URLDEC           100.00%  8 out of 8
    URLENC            85.71%  12 out of 14
    VARSIZE           57.14%  4 out of 7
    VARSIZEGTM       100.00%  3 out of 3
    YMD              100.00%  5 out of 5
    addService        87.50%  28 out of 32
    deleteService    100.00%  15 out of 15
    setError         100.00%  1 out of 1
    setError1        100.00%  49 out of 49
```
## Manual Testing
On Cache, there are no manual tests available. Here is a list of manual
tests to perform: Adjust AC/VC, patients, and paths as appropriate.

Tests without VistA:
```
- curl localhost:9080
- curl localhost:9080/ping
- curl localhost:9080/xml
- curl localhost:9080/r/%25webapi
- curl -I localhost:9080/r/%25webapi
- curl localhost:9080/error
- curl localhost:9080/error?foo=crash2
- curl localhost:9080/bigoutput
- nc -v localhost 9080 # CTRL-C after that
- curl -I localhost:9080/r/%25webapi
- do stop^%webreq
- set ^%webhttp(0,"logging")=3
- do ^%webreq
- curl -I localhost:9080/r/%25webapi
- zwrite ^%webhttp("log")
- curl localhost:9080/cache.lck
```


Tests with VistA:
```
- do ^webinit
- curl localhost:9080
- curl localhost:9080/ping
- curl localhost:9080/xml
- do resetURLs^%webtest
- curl localhost:9080/r/%25webapi
- curl -I localhost:9080/r/%25webapi
- curl localhost:9080/error
- curl localhost:9080/error?foo=crash2
- curl localhost:9080/bigoutput
- curl 'http://SM1234:SM1234!!!@localhost:9080/rpc/ORWU%20NEWPERS' -d '["A", "1"]'
- curl 'http://SM1234:SM1234!!!@localhost:9080/rpc/VPR%20GET%20PATIENT%20DATA' -d '[{"patientId":"1","domain":""}]'
- curl 'http://SM1234:SM1234!!!@localhost:9080/rpc2/ORWU%20NEWPERS' -d 'start=A&direction=1'
- nc -v localhost 9080 # CTRL-C after that
- curl 'http://SM1234:SM1234!!!@localhost:9080/rpc2/ORWU%20NEWPERS' -d 'start=A&direction=1'
- do stop^%webreq
- set ^%webhttp(0,"logging")=3
- do ^%webreq
- curl 'http://SM1234:SM1234!!!@localhost:9080/rpc2/ORWU%20NEWPERS' -d 'start=A&direction=1'
- zwrite ^%webhttp("log")
- set ^%webhome="/tmp/"
- curl localhost:9080/%25webinit.rsa
- kill ^%webhome
- curl localhost:9080/cache.lck
```
