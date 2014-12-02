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
