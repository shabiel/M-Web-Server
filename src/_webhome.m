%webhome ; VEN/SMH - Home page processor;Jun 20, 2022@15:59
 ;;
 ; Copyright 2013-2019 Sam Habiel
 ; Copyright 2022 YottaDB LLC
 ;
 ;Licensed under the Apache License, Version 2.0 (the "License");
 ;you may not use this file except in compliance with the License.
 ;You may obtain a copy of the License at
 ;
 ;    http://www.apache.org/licenses/LICENSE-2.0
 ;
 ;Unless required by applicable law or agreed to in writing, software
 ;distributed under the License is distributed on an "AS IS" BASIS,
 ;WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 ;See the License for the specific language governing permissions and
 ;limitations under the License.
 ;
en(RESULT) ; PEP
 S RESULT("mime")="text/html; charset=utf-8"
 N CRLF S CRLF=$C(13,10)
 N ARGS S ARGS("*")="index.html"
 ; Retrieve index.html from filesystem before returning default page
 D FILESYS^%webapi(.RESULT,.ARGS)
 ; If we have an error, it means we don't have an index page; ignore and return handlers page instead
 I HTTPERR S HTTPERR=0 K RESULT
 ; If we found an index.html don't return the default
 I $D(RESULT) QUIT
 ; If we are in no global mode quit as well as the below loop won't tell us anything
 I $G(NOGBL) S RESULT(1)="NO INDEX FOUND!" QUIT
 ; return default index.html
 S RESULT("mime")="text/html; charset=utf-8"
 N I F I=1:1 S RESULT(I)=$P($TEXT(HTML+I),";;",2,99) Q:RESULT(I)=""  D
 . I RESULT(I)["<%TABLEDATA%>" D
 .. I '$DATA(^%web(17.6001)) SET RESULT(I)="<strong>No web request handlers installed.</strong>"
 .. N IEN S IEN=0 F J=I:.0001 S IEN=$O(^%web(17.6001,IEN)) Q:'IEN  D
 ... S RESULT(J)="<tr>",J=J+.0001
 ... S RESULT(J)="<td>"_^%web(17.6001,IEN,0)_"</td>",J=J+.0001
 ... S RESULT(J)="<td>"_^%web(17.6001,IEN,1)_"</td>",J=J+.0001
 ... ;
 ... N EP S EP=^%web(17.6001,IEN,2) N RTN S RTN=$P(EP,"^",2),RTN=$$URLENC^%webutils(RTN)
 ... S RESULT(J)="<td><a href=""r/"_RTN_""">"_EP_"</td>",J=J+.0001
 ... ;
 ... N AUTH S AUTH=$P($G(^%web(17.6001,IEN,"AUTH")),"^",1),AUTH=$S(AUTH:"YES",1:"NO")
 ... S RESULT(J)="<td>"_AUTH_"</td>",J=J+.0001
 ... ;
 ... N KEY S KEY=$P($G(^%web(17.6001,IEN,"AUTH")),"^",2) I KEY S KEY=$P($G(^DIC(19.1,KEY,0)),"^")
 ... S RESULT(J)="<td>"_KEY_"</td>",J=J+.0001
 ... ;
 ... N RKEY S RKEY=$P($G(^%web(17.6001,IEN,"AUTH")),"^",3) I RKEY S RKEY=$P($G(^DIC(19.1,RKEY,0)),"^")
 ... S RESULT(J)="<td>"_RKEY_"</td>",J=J+.0001
 ... ;
 ... N OPT S OPT=$P($G(^%web(17.6001,IEN,"AUTH")),"^",4) I OPT S OPT=$P($G(^DIC(19,OPT,0)),"^")
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
