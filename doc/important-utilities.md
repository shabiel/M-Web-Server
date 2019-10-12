# Utilities
Documentation Part 2

The main input and output for the web services are expected to be in JSON. We
have so far focused on sending text output to our web service calls; but it's
time to illustrate how to use JSON. In addition, we will show several other
API calls that will help in verifiying that all required data is sent; parsing
text by new lines; and sending error messages back to the client.

## JSON
Let's start by illustrating JSON input and output. In order for the web server
to talk JSON, it needs to be able to encode the data to the browser; and it
needs to be able to decode the data coming from the browser.

Encoding is done using:

`D ENCODE^%webjson(M ARRAY INPUT BY NAME,OUTPUT JSON ARRAY BY NAME,ERROR MESSAGES BY NAME)`

Decoding is done using:

`D DECODE^%webjson(JSON ARRAY INPUT BY NAME, M DEST ARRAY BY NAME, ERROR MESSAGES BY NAME)`

The first two arguments are required; the third argument is optional. If
not supplied, error messages will be dumped into `^TMP("VPRJERR",$J)`.

For novice Mumpsters, an array input by name is something like this:

	S ARRAY(1)="ONE"
	S ARRAY(2)="TWO"
	S ARRAY(3)="THREE"

`DO CALL^ROUTINE("ARRAY")` or `DO CALL^ROUTINE($NAME(ARRAY))`.

On the recieving side, the code looks like this:

	CALL(INPUT) ; Pass INPUT by Name
	 N A,B,C
	 S A=@INPUT@(1)
	 S B=@INPUT@(2)
	 S C=@INPUT@(3)

Okay. Great. So why am I going over this? Well, a problem will happen if you
using the variable INPUT (instead of "ARRAY" above) and send it to CALL. In M,
unless you pass something by reference, the parameter is newed (in this case,
INPUT which is a parameter for CALL. Because it's newed, the original INPUT
which you used instead of ARRAY will disappear since the it will be shadowed
by the new'ed INPUT in CALL.

In practice, it's extremely unlikely that this would occur, but keep them in
mind like you keep C extern variables in mind, since they have a similar
problem.

So back to the main point: The callee in VPRJSON uses arrays starting with VV.
So please don't use these to prevent collisions.

### Encoding
Encoding is mainly used to send data from M to the browser.

Here is an example:

Regular encoding:

	N X,JSON
	S X("myObj","booleanT")="true"
	S X("myObj","booleanF")="false"
	S X("myObj","numeric")=3.1416
	S X("myObj","nullValue")="null"
	S X("myObj","array",1)="one"
	S X("myObj","array",2)="two"
	S X("myObj","array",3)="three"
	S X("myObj","subObject","fieldA")="hello"
	S X("myObj","subObject","fieldB")="world"
	D ENCODE^VPRJSON("X","JSON")

	> zwrite JSON
	JSON(1)="{""myObj"":{""array"":[""one"",""two"",""three""],""booleanF"":false,
	""booleanT"":true,""nullValue"":null,""numeric"":3.1416,
	""subObject"":{""fieldA"":""hello"",""fieldB"":""world""}}}"

The encoding code handles all the trickeries associated with JSON, including
putting a zero in from of number less than zero in M, and escaping quotes, etc.

Encoding code doesn't fail; so passing an error array is unnecessary.

### Decoding
Decoding is done to receive data from the browser and convert it to an M array.

	An example:

	GTM>R JSON(1)                                                    
	{"title":"my array of stuff", "count":3, "items": [
	GTM>R JSON(2)
	{"name":"red", "rating":"ok"},
	GTM>R JSON(3)
	{"name":"blue", "rating":"good"},
	GTM>R JSON(4)
	{"name":"purple", "rating":"outstanding"}
	GTM>R JSON(5)
	]}

	GTM>D DECODE^%webjson($NA(JSON),$NA(OUT),$NA(ERR))

	GTM>ZWRITE OUT
	OUT("count")=3
	OUT("items",1,"name")="red"
	OUT("items",1,"rating")="ok"
	OUT("items",2,"name")="blue"
	OUT("items",2,"rating")="good"
	OUT("items",3,"name")="purple"
	OUT("items",3,"rating")="outstanding"
	OUT("title")="my array of stuff"

	GTM>ZWRITE ERR
	%GTM-E-UNDEF, Undefined local variable: ERR

So far so good. Now, let's try throwing an error by deleting the last brace in
the JSON array:

	GTM>ZWRITE JSON
	JSON(1)="{""title"":""my array of stuff"", ""count"":3, ""items"": ["
	JSON(2)="{""name"":""red"", ""rating"":""ok""},"
	JSON(3)="{""name"":""blue"", ""rating"":""good""},"
	JSON(4)="{""name"":""purple"", ""rating"":""outstanding""}"
	JSON(5)="]}"

	GTM>S JSON(5)="]"

	GTM>K OUT,ERR

	GTM>D DECODE^VPRJSON($NA(JSON),$NA(OUT),$NA(ERR))

	GTM>ZWRITE OUT
	OUT("count")=3
	OUT("items",1,"name")="red"
	OUT("items",1,"rating")="ok"
	OUT("items",2,"name")="blue"
	OUT("items",2,"rating")="good"
	OUT("items",3,"name")="purple"
	OUT("items",3,"rating")="outstanding"
	OUT("title")="my array of stuff"

	GTM>ZWRITE ERR
	ERR(0)=1
	ERR(1)="Stack mismatch - exit stack level was  1"

## Other Utilities
### Check for unwanted argumentsa
You can use `$$UNKARGS^%webutils` to check the input arguments to see if they
are missing. If they are, you need to quit. The HTTP error code is set to 111
automatically.

Below, we are checking that the input variables to a fileman call are all
present. If not, we send back an error code of 111. We don't need to set the
error ourselves. Pass args by reference; and the list of fields as a literal.

	I $$UNKARGS^%webutils(.ARGS,"file,iens,field,screen,match") Q  ; Is any of these not passed?

### Converting a single long line with $C(13,10) (CR/LF) to an array and the converse
This can take the body of a POST/PUT and convert it to a linear array.

Using this call (passing the input and output by reference):

	 D PARSE10^%webutils(.BODY,.PARSED) ; Parser

E.g. 

	BODY(1)="ABC"_CRLF_"DEF"_CRLF_"HIJ"

becomes

	PARSED(1)="ABC"
	PARSED(2)="DEF"
	PARSED(3)="HIJ"

Here's the opposite (again, pass input by reference; will also be output):

	D ADDCRLF^%webutils(.RESULTS) ; crlf the result

Now, gee, why would I want to do that? Well, if you have word processing fields,
where you need to keep the line breaks as Fileman has them, you need to add a
CRLF to each line of the result.

### Sending an HTTP error back to the client
In the middle of processing, if you decide to bail out because of an error,
you can send to the user an HTTP error code and then quit. This looks like this:

Like:

	D SETERROR^%webutils(HTTP code,error description) QUIT appropriately

E.g.

	D SETERROR^%webutils("400","Input parameters not correct") Q:$Q "" Q
