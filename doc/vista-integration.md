# VISTA Integration
Documenation Part 3

By this point, I will presume that you are running this on a VISTA system. If
you ran the ^WWWINIT installer, it would have installed the Fileman file data
definition for you; if not, copy the %WINI* routines from the repository in
src/INIT-for-%W into your M environment, and run ^%WINIT.

Install will look like this:

	GTM>D ^%WINIT

	This version (#0.2) of '%WINIT' was created on 22-NOV-2013
			 (at Vista-Office EHR, by VA FILEMAN 22.0)

	I AM GOING TO SET UP THE FOLLOWING FILES:

	   17.6001   WEB SERVICE URL HANDLER
	Note:  You already have the 'WEB SERVICE URL HANDLER' File.


	...SORRY, LET ME THINK ABOUT THAT A MOMENT........
	OK, I'M DONE.
	NOTE THAT FILE SECURITY-CODE PROTECTION HAS BEEN MADE

## VISTA Integration data structures

Let's examine the file data structure and understand how VISTA integration is
achieved.

	.01       HTTP VERB (RS), [0;1]
	1         URI (F), [1;E1,250]
	2         EXECUTION ENDPOINT (F), [2;E1,250]
	11        AUTHENTICATION REQUIRED? (S), [AUTH;1]
	12        KEY (P19.1'), [AUTH;2]
	13        REVERSE KEY (P19.1'), [AUTH;3]
	14        OPTION (P19'), [AUTH;4]

We have seen .01 through 2 in Part 1 of the documentation. They end up getting
stored in the B index where we actually grab them to run the web service.

Let's go through the VISTA fields and how they work:

### AUTHENTICATION REQUIRED
This field protects the web service from being invoked by non-authenticated
users. It is also used with the other fields to get a user against which to
check authorization. Authentication currently works using the HTTP Basic
authentication (you are challenged with a user name and password which map
to access and verify code). Every single time you invoke the web service the
authentication is done again.

### KEY and REVERSE KEY.
Like the VISTA authorization system in the Option file, you can protect a 
web service using a key. Ditto for reverse key, which denies access if present.

### OPTION
This is the best authorization method as it lets you grant access to a user
based on their access to a menu option. This way you can structure authorizations
in a menuman tree structure and combine with with Keys to prevent users walking
down menu trees. Please note that if you use this option, MAKE SURE THAT YOU
RECOMPILE THE MENUS every time you modify the menus. And make sure to recompile
the menus daily.

## Creating a web service that works with VISTA
So, let's start with a very simple web service: one that gets a field from a
specific file from Fileman:

We have to think of a URL to use: how about `v1/fileman/{file}/{iens}/{field}`?
And we will require that users must log-in first before they can use it. v1
is for versioning.

	GTM>D P^DI


	VA FileMan 22.0


	Select OPTION: ENTER OR EDIT FILE ENTRIES  



	INPUT TO WHAT FILE: WEB SERVICE URL HANDLER// 
	EDIT WHICH FIELD: ALL// 


	Select WEB SERVICE URL HANDLER HTTP VERB:    GET
	HTTP VERB: GET// 
	URI: v1/fileman/{file}/{iens}/{fields}  Replace 
	EXECUTION ENDPOINT: gets^kbanfm
	AUTHENTICATION REQUIRED?: YES// 
	KEY: 
	REVERSE KEY: 
	OPTION: 


For now, we will do the simplest thing possible in our routine:

	kbanfm ; ven/smh - fileman WS utilities;2014-12-03  2:34 AM
	 ;
	gets(result,args) ; runs v1/fileman/{file}/{iens}/{fields} to get data
	 ;
	 I $$UNKARGS^%webutils(.args,"file,iens,fields") QUIT  ; Is any of these not passed?
	 ;
	 n file s file=args("file")
	 n iens s iens=args("iens")
	 n fields s fields=args("fields")
	 ;
	 s result=$$GET1^DIQ(file,iens,fields)
	 ;
	 QUIT

Now, let's run it with a VAILD user (I will leave it to the programmer's
imagination on how to create a user):

	$ curl http://shabiel12:catdog.44@localhost:9080/v1/fileman/.85/1/1
	ENGLISH

Great! It works.

The underlying call actually accepts field names as well. So we can use that.

	$ curl http://shabiel12:catdog.44@localhost:9080/v1/fileman/2/1/NAME
	MOUSE,MICKEY

But trying this with fields with spaces:

	$ curl http://shabiel12:catdog.44@localhost:9080/v1/fileman/2/1/SOCIAL+SECURITY+NUMBER

doesn't work. You need to decode these in your code: like this:

	kbanfm ; ven/smh - fileman WS utilities;2014-12-03  2:50 AM
	 ;
	gets(result,args) ; runs v1/fileman/{file}/{iens}/{fields} to get data
	 ;
	 I $$UNKARGS^%webutils(.args,"file,iens,fields") QUIT  ; Is any of these not passed?
	 ;
	 n file s file=args("file")
	 n iens s iens=args("iens")
	 n fields s fields=args("fields")
	 ;
	 n decodedFields s decodedFields=$$URLDEC^%webutils(fields)
	 ;
	 s result=$$GET1^DIQ(file,iens,decodedFields)
	 ;
	 QUIT

So now, it actually works:

	$ curl http://shabiel12:catdog.44@localhost:9080/v1/fileman/2/1/SOCIAL+SECURITY+NUMBER; echo
	505111111P

Let's look at the headers:

	$ curl -i http://shabiel12:catdog.44@localhost:9080/v1/fileman/2/1/SOCIAL+SECURITY+NUMBER; echo
	HTTP/1.1 200 OK
	Date: Wed, 03 Dec 2014 07:58:31 GMT
	WWW-Authenticate: Basic realm="localhost:9080"
	Content-Type: application/json; charset=utf-8
	Content-Length: 10

	505111111P

Every thing looks okay, except for the Content-Type, which is expected to be
JSON. Actually, that was intentional on my part. I wanted to return JSON, but
we need to get this far first.

So, let's see what we can do to get there:

	kbanfm ; ven/smh - fileman WS utilities;2014-12-03  3:03 AM
	 ;
	gets(result,args) ; runs v1/fileman/{file}/{iens}/{fields} to get data
	 ;
	 I $$UNKARGS^%webutils(.args,"file,iens,fields") QUIT  ; Is any of these not passed?
	 ;
	 n file s file=args("file")
	 n iens s iens=args("iens")
	 n fields s fields=args("fields")
	 ;
	 n decodedFields s decodedFields=$$URLDEC^%webutils(fields)
	 ;
	 n value s value=$$GET1^DIQ(file,iens,decodedFields)
	 ;
	 n outArray s outArray(decodedFields)=value
	 ;
	 d ENCODE^%webjson($name(outArray),$name(result))
	 ;
	 QUIT

And the result is:

	$curl http://shabiel12:catdog.44@localhost:9080/v1/fileman/2/1/SOCIAL+SECURITY+NUMBER; echo
	{"SOCIAL SECURITY NUMBER":"505111111P"}

Alright. Next enhancement. Get the contents of a word-processing field. This
can even be a patient note (and that's a security concern, which we can
address later). A little explanation is in order about the output of
`$$GET1^DIQ`. If you pass the 5th parameter as the name of an array to put
the word-processing field in, and the field is actually a word processing
field, then the value of the call would be the name of the array. See below
on how I do that. 

	kbanfm ; ven/smh - fileman WS utilities;2014-12-03  3:21 AM
	 ;
	gets(result,args) ; runs v1/fileman/{file}/{iens}/{fields} to get data
	 ;
	 I $$UNKARGS^%webutils(.args,"file,iens,fields") QUIT  ; Is any of these not passed?
	 ;
	 n file s file=args("file")
	 n iens s iens=args("iens")
	 n fields s fields=args("fields")
	 ;
	 n decodedFields s decodedFields=$$URLDEC^%webutils(fields)
	 ;
	 n wp ; word processing field
	 ;
	 n value s value=$$GET1^DIQ(file,iens,decodedFields,,$name(wp))
	 ;
	 new outArray
	 if value=$name(wp) merge outArray(decodedFields)=wp
	 else  s outArray(decodedFields)=value
	 ;
	 d ENCODE^%webjson($name(outArray),$name(result))
	 ;
	 QUIT

And now time to test it. Note that I am using `python -m json.tool` to pretty
print the output, otherwise it's rather unreadable. I am also using curl -s
since curl seems to want to tell you progress if piping.

	$ curl -s http://shabiel12:catdog.44@localhost:9080/v1/fileman/9.4/140/DESCRIPTION | python -m json.tool
	{
		"DESCRIPTION": [
			"The DHCP Prosthetic package automates many functions for Prosthetics.  The", 
			"record of Prosthetics Service (VA Form 10-2319) and the appropriate", 
			"VAF 1358 obligation, are updated at the time of purchase (entry into the", 
			"computer) of the item or service provided to the veteran.  This update is", 
			"accomplished through direct links to IFCAP and the electronic patient VAF", 
			"10-2319. Purchasing is simplified by entering the information only once", 
			"into the computer and letting it update your 1358 account balances and the", 
			"patient VAF 10-2319.", 
			" ", 
			"   Purchasing Module", 
			" ", 
			"Purchasing interfaces with IFCAP into the IFCAP 1358 module.  Forms ", 
			"printed include the Authorization Invoice (VAF 10-2421), and Authority to", 
			"Exceed Amount on the Service Card (FL 10-55).  For tracking transactions", 
			"associated with purchasing, Prosthetics will accommodate the Prosthetic", 
			"Service Card Invoice (VAF 10-2520), the Prescription and Authorization for", 
			"Eyeglasses (VAF 10-2914), No-Form, Pickup/Delivery Charges, Request for", 
			"Estimate (FL10-90), and Patient Notification Letter.", 
			" ", 
			" ", 
			"   Electronic 10-2319 Module", 
			"  ", 
			"Record of Prosthetics Services is fully incorporated into DHCP displayed in", 
			"multiple terminal screens.  Appliances and services issued are", 
			"automatically recorded to the electronic VAF 10-2319 when purchases are", 
			"obligated or issued from stock.  In addition, PSC Card, Clothing", 
			"Allowance, Auto Adaptive Equipment, Patient Correspondence, and other", 
			"patient data is recorded and displayed within the Electronic VAF 10-2319", 
			"Module.  This is the module that provides the basis for all AMIS reports.", 
			" ", 
			"   Entitlement Records Module", 
			"  ", 
			"Information collected by Medical Administration Service (MAS) to determine", 
			"eligibility of benefits to the veteran is displayed in this module.", 
			"Patient data includes name, social security number, date of birth,", 
			"address, remarks, temporary address, phone, sex, next of kin, military", 
			"service, eligibility status, verification of eligibility, disability", 
			"ratings, diagnostic codes, admission date, discharge date, type of", 
			"discharge, clinic enrollment, and pending appointments.", 
			"  ", 
			"   AMIS Module", 
			"  ", 
			"This module calculates the new and repair work sheets based on the infor-", 
			"mation collected in the electronic 10-2319 file.", 
			"This module also automatically generates Genric Code sheets that will be", 
			"saved for editing and transmission to Austin.", 
			" ", 
			"   Inventory Module", 
			"  ", 
			"Inventory is linked to the Generic Inventory Package.  Each station has the", 
			"option to activate GIP.", 
			" ", 
			" ", 
			"   Correspondence Module", 
			"  ", 
			"Letters sent to patients are generated from this module.  Denial letters", 
			"are counted on AMIS automatically when end-of-quarter AMIS reports are", 
			"run.", 
			"  ", 
			" ", 
			"   Scheduled Meetings and Home/Liaison Visits Module", 
			"  ", 
			"Appointment information for Prosthetics Clinics can be pulled over onto", 
			"the Prosthetics VAF 10-2527 to be printed as Appointment Roster and Clinic", 
			"Action Sheets.", 
			" ", 
			"Home/Liaison visits can also be entered and printed in this module.  All", 
			"Appointment Visits and Home/Liaison Visits will be calculated on AMIS at", 
			"the end of the quarter.", 
			" ", 
			"    Prosthetic Lab Module", 
			" ", 
			"The Prosthetic Lab module automates VA Form 10-2529-3, Request and Receipt", 
			"for Prosthetic Appliances or Services, which is used to maintain a", 
			"consolidated record of prosthetic services furnished to eligible veterans.", 
			"This includes activities at Orthotic Laboratories, Restoration", 
			"Laboratories, Shoe Last Clinics, Wheelchair Repair Shops, National Foot", 
			"Centers, and the Denver Distribution Center."
		]
	}

Okay. Next enhancement: Tell the user if there's an error. This can happen very
easily in case of asking for a field that doesn't exist.

Let's try that:

	kbanfm ; ven/smh - fileman WS utilities;2014-12-03  3:46 AM
	 ;
	gets(result,args) ; runs v1/fileman/{file}/{iens}/{fields} to get data
	 ;
	 I $$UNKARGS^%webutils(.args,"file,iens,fields") QUIT  ; Is any of these not passed?
	 ;
	 n file s file=args("file")
	 n iens s iens=args("iens")
	 n fields s fields=args("fields")
	 ;
	 n decodedFields s decodedFields=$$URLDEC^%webutils(fields)
	 ;
	 n wp ; word processing field
	 ;
	 n value s value=$$GET1^DIQ(file,iens,decodedFields,,$name(wp))
	 ;
	 ; only get the first error in ^TMP("DIERR") if we have an error
	 if $data(DIERR) D SETERROR^%webutils(400,^TMP("DIERR",$J,1,"TEXT",1)) QUIT
	 ;
	 new outArray
	 if value=$name(wp) merge outArray(decodedFields)=wp
	 else  s outArray(decodedFields)=value
	 ;
	 d ENCODE^%webjson($name(outArray),$name(result))
	 ;
	 QUIT

And the output is:

	$ curl -s http://shabiel12:catdog.44@localhost:9080/v1/fileman/9.4/140/BLAH+BLAH | python -m json.tool
	{
		"apiVersion": "1.0", 
		"error": {
			"code": 400, 
			"errors": [
				{
					"domain": "An input variable or parameter is missing or invalid.", 
					"message": "Bad Request", 
					"reason": 400
				}
			], 
			"message": "Bad Request", 
			"request": "GET /v1/fileman/9.4/140/BLAH+BLAH "
		}
	}

I need to go to sleep now, but there are two more enhancements I would like
to make:

 * Support a range of fields or multiple fields
 * Implement Fileman Access Security so that users can only see files they
   are authorized to see.
