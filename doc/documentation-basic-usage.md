# Programmer Documentation
Part 1: Basic Usage

## Pre-requisites
Knowledge of the HyperText Transfer Protocol. See <http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol>,
especially, <http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods>.

Passing familiarity with Mumps.

## Before we get started
You need to verify the operation of the web server after installation. The
intrinsic method /ping will do a simple ping of the server.

If you accepted the default port, you will be listening on 9080. Typing 
<http://localhost:9080/ping> will enable you to test the server. Here's an
example using my favorite http command line program, cURL:

	$ curl http://localhost:9080/ping
	{"status":"11312 running"}

The JSON object returned includes the job number on the M side.

## Overview of how M Web Services work
The core of the server is the file ^%web(17.6001). This file ties URL patterns
to M routines to be executed. The base server comes with three entries. Here's
the entire global for reference.

	^%web(17.6001,0)="WEB SERVICE URL HANDLER^17.6001S^6^6"
	^%web(17.6001,1,0)="GET"
	^%web(17.6001,1,1)="r/{routine?.1""%25"".32AN}"
	^%web(17.6001,1,2)="R^%webapi"
	^%web(17.6001,2,0)="PUT"
	^%web(17.6001,2,1)="r/{routine?.1""%25"".32AN}"
	^%web(17.6001,2,2)="PR^%webapi"
	^%web(17.6001,2,"AUTH")="1^3"
	^%web(17.6001,3,0)="GET"
	^%web(17.6001,3,1)="error"
	^%web(17.6001,3,2)="ERR^%webapi"
	^%web(17.6001,4,0)="GET"
	^%web(17.6001,4,1)="bigoutput"
	^%web(17.6001,4,2)="bigoutput^%webapi"
	^%web(17.6001,5,0)="POST"
	^%web(17.6001,5,1)="rpc/{rpc}"
	^%web(17.6001,5,2)="RPC^%webapi"
	^%web(17.6001,5,"AUTH")=1
	^%web(17.6001,6,0)="POST"
	^%web(17.6001,6,1)="rpc2/{rpc}"
	^%web(17.6001,6,2)="rpc2^%webapi"
	^%web(17.6001,6,"AUTH")=1
	^%web(17.6001,6,"PARAMS",0)="^17.60012S^4^4"
	^%web(17.6001,6,"PARAMS",1,0)="U^rpc"
	^%web(17.6001,6,"PARAMS",2,0)="F^start"
	^%web(17.6001,6,"PARAMS",3,0)="F^direction"
	^%web(17.6001,6,"PARAMS",4,0)="B"
	^%web(17.6001,"B","GET","bigoutput","bigoutput^%webapi",4)=""
	^%web(17.6001,"B","GET","error","ERR^%webapi",3)=""
	^%web(17.6001,"B","GET","r/{routine?.1""%25"".32AN}","R^%webapi",1)=""
	^%web(17.6001,"B","POST","rpc/{rpc}","RPC^%webapi",5)=""
	^%web(17.6001,"B","POST","rpc2/{rpc}","rpc2^%webapi",6)=""
	^%web(17.6001,"B","PUT","r/{routine?.1""%25"".32AN}","PR^%webapi",2)=""


### HTTP GET
Let's examine how the server figures out which routine to invoke in those simple examples using HTTP GET. 
Let's start with the simplest entry:

	^%web(17.6001,"B","GET","bigoutput","bigoutput^%webapi",4)=""

Let's say that your server is listening at <http://localhost:9080>. If you
type <http://localhost:9080/bigoutput>, the server is going to look at the HTTP
method first, `GET`, then it will try to match the path, `bigoutput`, and from there
grab the routine name.  In this case, it will just run the routine
bigoutput^%webapi. We will also talk about how to write such a routine later.

Let's check the second example:

	^%web(17.6001,"B","GET","r/{routine?.1""%25"".32AN}","R^%webapi",1)=""

In this case, the server will accept GET HTTP requests in the variable format
`r/routine-name`. That brings us to how we can receive parameters from URLs:

	r/{routine}...

Matches anything that is r/routine-name.

	r/{routine?.1"%25".32AN}"

Matches routines names as long as they fit the pattern of 0-1 % and 0-32
characters. If a routine doesn't match this pattern, then a 404 error is
returned. Entering a routine name of `1AAAA` (an invalid routine name by the
way) will cause a 404 error.

An example we will discuss later in more detail will look like this:

	fileman/{file}/{iens}/{field}

Obviously, this is going to work only if you have Fileman installed. This gives
you an ingenious way to get data from Fileman. Requesting fileman/2/200/.01 
will let you obtain data from file 2 (Patient), IEN 200, and the .01 field
(name). The reason we use IENS rather than IEN in the name is to indicate that
you can supply a path to a subfile if you need an entry from a subfile.

The last pattern of note is 

	^%W(17.6001,"B","GET","filesystem/*","FILESYS^%W0",3)=""

In this case, it's use to serve a file from the file system; but concept
applies in general. If you put \* after a path, you will be able to grab the
rest of the path so that you can parse it in M code.

One last thing before we move on: You can supply URL arguments to the server,
and you will be able to grab them: e.g. fileman/2/200/.01?format=external.

### POST and PUT
HTTP verbs POST and PUT are used to amend or add data. If you follow a rigid
RESTful model, POST is used to amend data or add data when the addition
location is not known; versus PUT which is used to add/overwrite data when
the location of the data is known. Thus a POST can be used to add data to a
database where you don't care which record number you get, and a PUT can be
used to overwrite this record number's data.

In any case, the core software handles them the same way. It's up to you to
stick to the semantics. Here's an example:

	^%W(17.6001,"B","POST","rpc/{rpc}","RPC^%W0",8)=""

This says that if I enter an rpc/rpc_name, and supply the arguments as the POST
data to the RPC (in a format of your choosing, which depends on how you write 
your routine), the code RPC^%W0 will be executed. The code will return two
items: The Location header telling the user where the new data is (if
applicable) and the text of the data.

## Creating a new entry for the web server and handling it.
If you installed the server using the automated installation script `WWWINIT`,
you will have a full Fileman file if you have Fileman installed (e.g in a VISTA
environment). If not, you can still create services by setting the global
yourself.

For all the following examples, we will use a very simple web service that
just multiples two numbers. Let's say that the service will look like this

	/multiply/5/8  # 40

Let's say that the 5 is the multiplier and 8 is multiplicand.

### Setting the global directly when Fileman is not present

	SET ^%W(17.6001,"B","GET","multiply/{multiplier}/{multiplicand}","m^mul",0)=""

Don't forget to set the zero at the last subscript, since we depend on that IEN if
Fileman is installed.

### Setting the global when Fileman is present

All you have to do is add an entry to file 17.6001.

	GTM>D P^DI


	VA FileMan 22.0

	Your Identity(DUZ) is 0(zero).
	Please identify yourself.

	Access Code: *********

	Select OPTION: ENTER OR EDIT FILE ENTRIES  



	INPUT TO WHAT FILE: WEB SERVICE URL HANDLER// 17.6001  WEB SERVICE URL HANDLER
											  (0 entries)
	EDIT WHICH FIELD: ALL// 


	Select WEB SERVICE URL HANDLER HTTP VERB: GET
										 URI: multiply/{multiplier}/{multiplicand}
						  EXECUTION ENDPOINT: m^mul

	  Are you adding 'GET' as a new WEB SERVICE URL HANDLER (the 1ST)? No// y
	  (Yes)
	URI: multiply/{multiplier}/{multiplicand}  Replace 
	EXECUTION ENDPOINT: m^mul// 
	... (leave rest of fields blanks)


	Select WEB SERVICE URL HANDLER HTTP VERB: 

At this point, we now have the definition for a simple web service. Let's now
create a routine that will handle this.

### Creating handling routine
Here's the routine.

	mul ; Web Server Math Routine;2014-11-28  5:58 PM
	 ;
	m(result,arguments) ; multiplication
	 ; result is passed by reference from VPRJRSP
	 ; arguments is also passed by reference
	 ;
	 ; result is where you return the result
	 ; result("mime") is where you specify the mime type for the client
	 ; if you don't specify a mime, application/json; charset=utf-8 is returned.
	 ;
	 ; Get our arguments
	 new m1 set m1=$get(arguments("multiplier"))
	 new m2 set m2=$get(arguments("multiplicand"))
	 ;
	 ; If for some reason our arguments are empty, don't go any further
	 if (m1="")!(m2="")  do SETERROR^VPRJRUT(400,"Input parameters are not correct") QUIT
	 ;
	 set result=m1*m2
	 ;
	 set result("mime")="text/plain; charset=utf-8"
	 ;
	 quit

And I always always recommend running it from the command line so that we
won't chase phantoms later on.

	GTM>set a("multiplier")=5,a("multiplicand")=40

	GTM>kill res

	GTM>do m^mul(.res,.a)

	GTM>zwrite res
	res=200
	res("mime")="text/plain; charset=utf-8"

Every thing looks correct so far.

### Running the code from the Web Server.
Let's use cURL:

	$ curl http://localhost:9081/multiply/5/8
	{"apiVersion":"1.0","error":{"code":404,"errors":[{"domain":"Not Found","message":"Not Found","reason":404}],"message":"Not Found","request":"GET \/multiply\/5\/8 "}}

Contrary to what I expected, this actually failed in a mapping failure! 
Let me find out why.

Okay, I entered a leading slash into the URI in the definiton, as follows:

	/multiply/{multiplier}/{multiplicand}

It's supposed to be:

	multiply/{multiplier}/{multiplicand}

From the error, it's easy to see that nothing matched; so that's why you get a
404.

I tried it again after this, and here's the result:

	$ curl http://localhost:9081/multiply/5/8
	40

Hurray! Success.

### A discussion of the various interesting points
I hope the actual routine is self-explanatory. The input variables though need
a lot more explanation: result and arguments. Obviously, this is what I called
them, but since they are parameters you can call them anything you like.

#### `arguments`
Let's start with the easier one. When you invoke the url:

	multiply/{multiplier}/{multiplicand}

with:

	multiply/5/8

arguments will have the value of:

	arguments("multiplier")=5
	arguments("multiplicand")=8

In addition, if you pass in URL query parameters (let's say that you want the
result in a certain base), like this:

	multiply/5/8?base=2

arguments will not look like this:

	arguments("multiplier")=5
	arguments("multiplicand")=8
	arguments("base")=2

Just for the hell of it, I decided to actually modify the routine to handle the
base argument. I am too stupid to write a base converter, so I stole the one
from the VISTA kernel math functions:

	mul ; Web Server Math Routine;2014-11-28  6:31 PM
	 ;
	m(result,arguments) ; multiplication
	 ; result is passed by reference from VPRJRSP
	 ; arguments is also passed by reference
	 ;
	 ; result is where you return the result
	 ; result("mime") is where you specify the mime type for the client
	 ; if you don't specify a mime, application/json; charset=utf-8 is returned.
	 ;
	 ; Get our arguments
	 new m1 set m1=$get(arguments("multiplier"))
	 new m2 set m2=$get(arguments("multiplicand"))
	 new base set base=$get(arguments("base"))
	 ;
	 ; If for some reason our arguments are empty, don't go any further
	 if (m1="")!(m2="")  do SETERROR^VPRJRUT(400,"Input parameters are not correct") QUIT
	 ;
	 set result=m1*m2 ; tata
	 ;
	 if +base set result=$$BASE(result,10,base) ; convert to the requested base
	 ;
	 set result("mime")="text/plain; charset=utf-8"
	 ;
	 quit
	 ;
	BASE(%X1,%X2,%X3) ;Convert %X1 from %X2 base to %X3 base
	 I (%X2<2)!(%X2>16)!(%X3<2)!(%X3>16) Q -1
	 Q $$CNV($$DEC(%X1,%X2),%X3)
	DEC(N,B) ;Cnv N from B to 10
	 Q:B=10 N N I,Y S Y=0
	 F I=1:1:$L(N) S Y=Y*B+($F("0123456789ABCDEF",$E(N,I))-2)
	 Q Y
	CNV(N,B) ;Cnv N from 10 to B
	 Q:B=10 N N I,Y S Y=""
	 F I=1:1 S Y=$E("0123456789ABCDEF",N#B+1)_Y,N=N\B Q:N<1
	 Q Y

The the result is...

	$ curl http://localhost:9081/multiply/5/8?base=2
	101000

Let's translate that for me:

	2**(6-1) + 2**(4-1) = 40.

Yup. Looks like the right answer.
	
#### `result`
That's the more difficult one, since it could have many formats. The simplest
one, which we saw above, is to return a "scalar" value. 

	set result=5
	set result("mime")="text/plain; charset=utf-8"

If we want to return an array, there are several ways to do this.

The simplest way is to subscript the result with 1,2,3 etc.

	set result(1)="Mary has"
	set result(2)="a little"
	set result(3)="lamb"
	set result("mime")="text/plain; charset=utf-8"

If you have a huge amount of data that you want to transfer, you can use a
global:

	set result=$name(^temp($job))
	set @result@(1)="Mary has"
	set @result@(2)="a little"
	set @result@(3)="lamb"
	set ...
	set @result@("mime")="text/plain; charset=utf-8"

In the unstable version of the code (not installed by the WWWINIT routine
by default), you can do any subscripts (not just single file numeric ones) 
since we $query through them.

Let's look at a few examples:

XML in VPRJRSP (uses a global):

	XML(RESULT,ARGS) ; text XML
	 S RESULT=("mime")="text/xml"
	 S RESULT=$NA(^TMP($J))
	 S ^TMP($J,1)="<?xml version=""1.0"" encoding=""UTF-8""?>"
	 S ^TMP($J,2)="<note>"
	 S ^TMP($J,3)="<to>Tovaniannnn</to>"
	 S ^TMP($J,4)="<from>Jani</from>"
	 S ^TMP($J,5)="<heading>Remindersss</heading>"
	 S ^TMP($J,6)="<body>Don't forget me this weekend!</body>"
	 S ^TMP($J,7)="</note>"
	 QUIT

Retriving a file from the File system (uses sequential numbering in `result`)

	FILESYS(RESULT,ARGS) ; Handle filesystem/*
	 N PATH S PATH=$ZDIRECTORY_ARGS("*") ; GT.M Only!
	 N EXT S EXT=$P(PATH,".",$L(PATH,"."))
	 I $E(EXT,1,3)="htm" S RESULT("mime")="text/html"
	 I EXT="js" S RESULT("mime")="application/javascript"
	 I EXT="css" S RESULT("mime")="text/css"
	 I EXT="pdf" S RESULT("mime")="application/pdf"
	 N $ET S $ET="G FILESYSE"
	 O PATH:(REWIND:READONLY:FIXED:CHSET="M") ; Fixed prevents Reads to terminators on SD's. CHSET makes sure we don't analyze UTF.
	 U PATH
	 N C S C=1
	 N X F  R X#4079:0 S RESULT(C)=X,C=C+1 Q:$ZEOF
	 C PATH
	 QUIT
	 ;
     ;
	FILESYSE ; 500
	 S $EC=""
	 D SETERROR^VPRJRUT("500",$ZS)
	 QUIT

### POST and PUT
Alrighty. We just did a GET. Let's try doing a POST and a PUT.

So let's say we want to put a bunch of text in a certain global. Let say that
the global storing the text is called ^text. And let's say that each entry will
be subscripted by the entry number and then the text will be stored under that
entry number. Here's an example:

	^text(3,1)="It was the best of times"
	^text(3,2)="and"
	^text(3,3)="It was the worst of times."

So let's create two methods on the server, one for POST and one for PUT. The
POST method will add text to the next available entry, and the PUT method
will add/replace text for a specific entry. And for completeness, let's do
a GET too.
	
	SET ^%W(17.6001,"B","POST","text","post^text",0)=""
	SET ^%W(17.6001,"B","PUT","text/{ien}","put^text",0)=""
	SET ^%W(17.6001,"B","GET","text/{ien}","get^text",0)=""

And then let's write the routine for it. By deault, the web server will read
4000 characters per node; and for sanity's sake, we won't try to parse it by
new lines.

I have written the routine, and verified its operation:

	text ; ven/smh - post and put data into global ^text;2014-11-28  7:37 PM
	 ;
	post(args,body,result) ; handles POST /text/
	 ; args is arguments, just like in GET HTTP verb
	 ; body is text being posted to us
	 ; result is where we return the URL where the user can grab the text later
	 ; result can be set to "" if this is meaningless.
	 new ien
	 set ien=$o(^text(""),-1)+1  ; last sub + 1
	 new i for i=0:0 set i=$order(body(i)) quit:'i  set ^text(ien,i)=body(i) ; put data into text
	 set ^text(ien)=$o(^text(ien," "),-1) ; make header node the last sub number in the text
	 set result="/text/"_ien
	 quit result
	 ;
	put(args,body,result) ; handles PUT /text/{ien}
	 ; ditto. See above
	 new ien set ien=$g(args("ien"))
	 if ien<1 do SETERROR^VPRJRUT(400,"invalid ien") quit ""
	 kill ^text(ien) ; bye bye. We are replacing you.
	 new i for i=0:0 set i=$order(body(i)) quit:'i  set ^text(ien,i)=body(i) ; put data into text
	 set ^text(ien)=$o(^text(ien," "),-1) ; make header node the last sub number in the text
	 set result="/text/"_ien
	 quit result
	 ;
	get(result,args) ; handles GET /text/{ien}
	 new ien set ien=$g(args("ien"))
	 if ien<1 do SETERROR^VPRJRUT(400,"invalid ien") quit
	 if '$data(^text(ien)) do SETERROR^VPRJRUT("404","No such entry exists") quit
	 new i for i=1:1:^text(ien) set result(i)=^text(ien,i)
	 set result("mime")="text/html"
	 quit
	 ;

I downloaded three texts from the internet, and put them in the temp directory
so that I can curl them in.

	$ ls /tmp/*.txt
	/tmp/gettysburg_address.txt  /tmp/oratio_in_l_catilinam_para.txt  /tmp/varsari_da_vinci.txt

Let's try the POST first:

	$ curl -X POST --data-binary @gettysburg_address.txt http://localhost:9081/text

	HTTP/1.1 201 Created
	Date: Sat, 29 Nov 2014 00:50:29 GMT
	Location: https://localhost:9081/text/1
	Content-Type: application/json; charset=utf-8
	Content-Length: 7

	/text/1

On the M database:

	^text(1)=1
	^text(1,1)="Four score and seven years ago our fathers brought forth on this con
			  tinent a new nation, conceived in liberty, and dedicated to the propos
			  ition that all men are created equal."_$C(10,10)_"Now we are engaged i
			  n a great civil war, testing whether that nation, or any nation so con
			  ceived and so dedicated, can long endure. We are met on a great battle
			  field of that war. We have come to dedicate a portion of that field, a

Now let's try PUT:

	$ curl -X PUT --data-binary @varsari_da_vinci.txt http://localhost:9081/text/5

	HTTP/1.1 201 Created
	Date: Sat, 29 Nov 2014 00:56:23 GMT
	Location: https://localhost:9081/text/5
	Content-Type: application/json; charset=utf-8
	Content-Length: 7

	/text/5

On the M database:

	^text(5)=4
	^text(5,1)=" LIFE OF LEONARDO DA VINCI: Painter and Sculptor of Florence"_$C(10,
			  10)_"The greatest gifts are often seen, in the course of nature, raine
			  d by celestial influences on human creatures; and sometimes, in supern
			  atural fashion, beauty, grace, and talent are united beyond measure in
	....
	....
           and I have one, a head drawn with"
	^text(5,2)=" the style in chiaroscuro, which is divine."_$C(10,10)_"And there wa
          s infused in that brain such grace from God, and a power of expression
           in such sublime accord with the intellect and memory that served it, 
          and he knew so well how to express his conceptions by draughtmanship, 
          that he vanquished with his discourse, and confuted with his reasoning
	....
	....
          him, not thinking himself capable of imagining features that should"
	^text(5,3)=" represent the countenance of him who, after so many benefits receiv
          ed, had a mind so cruel as to resolve to betray his Lord, the Creator 
          of the world. However, he would seek out a model for the latter; but i
          f in the end he could not find a better, he should not want that of th
	....
	....
	
Each time we get the URL of the saved destination back. We can use that with GET:

	$ curl http://localhost:9081/text/5

	LIFE OF LEONARDO DA VINCI: Painter and Sculptor of Florence

	The greatest gifts are often seen, in the course of nature, rained by celestial influences on human creatures; ...

Now, let's try Cicero's speech using a POST, which we expect will go into slot
6, since the last entry was PUT'ted into slot 5:

	$ curl -X POST --data-binary @oratio_in_l_catilinam_para.txt http://localhost:9081/text

	HTTP/1.1 201 Created
	Date: Sat, 29 Nov 2014 01:07:23 GMT
	Location: https://localhost:9081/text/6
	Content-Type: application/json; charset=utf-8
	Content-Length: 7

	/text/6

M says:
	
	^text(6)=6
	^text(6,1)=" [1] I. Quo usque tandem abutere, Catilina, patientia nostra?
	quam diu etiam furor iste tuus nos eludet? quem ad finem sese effrenata iactabit
	audacia? Nihilne te nocturnum praesidium Palati, nihil urbis vigiliae, nihil
	timor populi, nihil con cursus bonorum omnium, nihil hic munitissimus habendi
	senatus locus, nihil horum ora voltusque moverunt? Patere tua consilia non
	sentis, constrictam iam horum omnium scientia teneri coniurationem tuam non
	vides? Quid proxima, quid superiore noct...

Now, let's try confusing the server, and hopefully it won't crash. Actually,
when it 'crashes' it sends a '500' error.  It's much harder to write code that
handles errors than code that works correctly for the expected cases.

	$ curl http://localhost:9081/text/10
	{"apiVersion":"1.0","error":{"code":404,"errors":[{"domain":"No such entry exists","message":"Not Found","reason":404}],"message":"Not Found","request":"GET \/text\/10 "}}
	
Ok. So far so good.

	$ curl -X PUT --data-binary @varsari_da_vinci.txt http://localhost:9081/text

	HTTP/1.1 404 Not Found
	Date: Sat, 29 Nov 2014 01:15:47 GMT
	Content-Type: application/json; charset=utf-8
	Content-Length: 156

	{"apiVersion":"1.0","error":{"code":404,"errors":[{"domain":"Not Found","message":"Not Found","reason":404}],"message":"Not Found","request":"PUT \/text "}}

Very good.

### An examination of the code:

	post(args,body,result) ; handles POST /text/
	 ; args is arguments, just like in GET HTTP verb
	 ; body is text being posted to us
	 ; result is where we return the URL where the user can grab the text later
	 ; result can be set to "" if this is meaningless.
	 new ien
	 set ien=$o(^text(""),-1)+1  ; last sub + 1
	 new i for i=0:0 set i=$order(body(i)) quit:'i  set ^text(ien,i)=body(i) ; put data into text
	 set ^text(ien)=$o(^text(ien," "),-1) ; make header node the last sub number in the text
	 set result="/text/"_ien
	 quit result
	 ;

The code is not hard. There is a significant difference from the `GET` method
though:

 * There are 3 arguments instead of 2.
 * arguments is the first parameter, rather than the second; and result is the third.
 * result is both the output of the extrinsic $$post and the return value.

   On the last point: this is not necessary. The value of the extrinsic fucntion goes
into the Location header, just in case you want to grab the location for future
data manipulation; and result is the actual text that goes to the end user.  If 
you looked carefully at the result, you will notice that I made a mistake here. 
I didn't specify the return type of the result. The mime returned by default is
`application/json`.

The big gotcha is that $$post and $$put are extrinsic functions; and you must
quit with any value, even the empty string. 

