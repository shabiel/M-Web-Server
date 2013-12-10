%WHOME ; VEN/SMH - Home page processor; 25 NOV 2013
 ;;
 ;
EN(RESULT) ; PEP
 S RESULT("mime")="text/html; charset=utf-8"
 N CRLF S CRLF=$C(13,10)
 N I F I=1:1 S RESULT(I)=$P($TEXT(HTML+I),";;",2,99) Q:RESULT(I)=""  D
 . I RESULT(I)["<%TABLEDATA%>" D
 .. N IEN S IEN=0 F J=I:.0001 S IEN=$O(^%W(17.6001,IEN)) Q:'IEN  D
 ... S RESULT(J)="<tr>",J=J+.0001
 ... S RESULT(J)="<td>"_^%W(17.6001,IEN,0)_"</td>",J=J+.0001
 ... S RESULT(J)="<td>"_^%W(17.6001,IEN,1)_"</td>",J=J+.0001
 ... ;
 ... N EP S EP=^%W(17.6001,IEN,2) N RTN S RTN=$P(EP,"^",2),RTN=$$URLENC^VPRJRUT(RTN)
 ... S RESULT(J)="<td><a href=""r/"_RTN_""">"_EP_"</td>",J=J+.0001
 ... ;
 ... N AUTH S AUTH=$P($G(^%W(17.6001,IEN,"AUTH")),"^",1),AUTH=$S(AUTH:"YES",1:"NO")
 ... S RESULT(J)="<td>"_AUTH_"</td>",J=J+.0001
 ... ;
 ... N KEY S KEY=$P($G(^%W(17.6001,IEN,"AUTH")),"^",2) I KEY S KEY=$P($G(^DIC(19.1,KEY,0)),"^")
 ... S RESULT(J)="<td>"_KEY_"</td>",J=J+.0001
 ... ;
 ... N RKEY S RKEY=$P($G(^%W(17.6001,IEN,"AUTH")),"^",3) I RKEY S RKEY=$P($G(^DIC(19.1,RKEY,0)),"^")
 ... S RESULT(J)="<td>"_RKEY_"</td>",J=J+.0001
 ... ;
 ... N OPT S OPT=$P($G(^%W(17.6001,IEN,"AUTH")),"^",4) I OPT S OPT=$P($G(^DIC(19,OPT,0)),"^")
 ... S RESULT(J)="<td>"_OPT_"</td>",J=J+.0001
 ... ;
 ... S RESULT(J)="</tr>"
 . I RESULT(I)="<%FOOTER%>" D
 .. S RESULT(I)="$JOB="_$J_" | $SYSTEM="_$SYSTEM_" | ^DD(""SITE"")="_$G(^DD("SITE"))
 .. S RESULT(I)=RESULT(I)_" | ^DD(""SITE"",1)="_$G(^DD("SITE",1))
 . S RESULT(I)=RESULT(I)_CRLF
 KILL RESULT(I) ; Kill last one which is empty.
 QUIT
 ;
HTML ; HTML to Write out
 ;;<!doctype html>
 ;;<html>
 ;;<head>
 ;;<title>MUMPS Restful Web-Services Portal</title>
 ;;<style>
 ;; body {
 ;;     margin: 0 0 0 0;
 ;;     font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;
 ;;     font-size: 14px;
 ;;     line-height: 1.428571429;
 ;;     background-color: rgb(245, 217, 181)
 ;; }
 ;; header {
 ;;     background-color: rgb(92, 81, 37);
 ;;     box-sizing: border-box;
 ;;     color: rgb(253, 252, 245);
 ;;     text-align: center;
 ;;     vertical-align: middle;
 ;;     padding-top: 1.2em;
 ;;     padding-bottom: 0.5em;
 ;;     position: fixed;
 ;;     top: 0;
 ;;     right: 0;
 ;;     left: 0;
 ;;     }
 ;; header > span {
 ;;     font-size: 3em;
 ;;     line-height: 1em;
 ;; }
 ;; footer {
 ;;     background-color: black;
 ;;     box-sizing: border-box;
 ;;     color: white;
 ;;     #position: fixed;
 ;;     #bottom: 0;
 ;;     width: 100%;
 ;;     text-align: center;
 ;;     }
 ;; main {
 ;;     box-sizing: border-box;
 ;;     display: block;
 ;;     font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
 ;;     padding-bottom: 140px;
 ;;     padding-left: 15px;
 ;;     padding-right: 15px;
 ;;     padding-top: 140px;
 ;;     text-align: left;
 ;;     text-shadow: rgba(0, 0, 0, 0.14902) 0px 1px 0px;
 ;; }
 ;; table, td, tr, th {
 ;;     border: 1px solid black;
 ;;     border-collapse:collapse;
 ;;     padding: 15px;
 ;; }
 ;;</style>
 ;;</head>
 ;;<body>
 ;;<header>
 ;; <span>MUMPS Restful Web-Services Portal</span>
 ;;</header>
 ;;<main>
 ;;<p>
 ;; Welcome to the MUMPS Advanced Shell Web Services.
 ;;</p>
 ;;<p>
 ;; Here is a list of web services configured on this server.
 ;; <table>
 ;;  <tr>
 ;;   <th>HTTP VERB</th>
 ;;   <th>URI</th>
 ;;   <th>Execution Endpoint</th>
 ;;   <th>Authentication Required?</th>
 ;;   <th>Security Key</th>
 ;;   <th>Reverse Key</th>
 ;;   <th>Access to Option</th> 
 ;;   <th>Example Call</th>
 ;;   <th>Description</th>
 ;;  </tr>
 ;;    <%TABLEDATA%>
 ;; </table>
 ;;</p>
 ;;</main>
 ;;<footer>
 ;;<span>
 ;;<%FOOTER%>
 ;;</span>
 ;;</footer>
 ;;</body>
 ;;</html>
