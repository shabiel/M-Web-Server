VPRJUJ02 ;SLC/KCM -- Sample data for JSON encoding
 ;;1.0;JSON DATA STORE;;Sep 01, 2012
 ;
 ;
 ; expected return data values
 ;
BASIC ;; Basic object
 ;;{"myObj":{"array":["one","two","three"],"booleanF":false,"booleanT":true,"nullValue":null,"numeric":3.1416,"subObject":{"fieldA":"hello","fieldB":"world"}}}
VALS ;; Simple values only object
 ;;{"arr":["apple","orange","pear",{"obj":"4th array item is object"}],"bool1":true,"num1":2.1e3,"prop1":"property1"}
LONG ;; Object with continuation nodes
 ;;{"note":"This is the first line of the note.  Here are \"quotes\" and a \\ and a \/.\nAdditional Line #1, this will extend the line out to at least 78 characters.\nAdditional Line #2,
NODES ;; Nodes preformatted as JSON
 ;;{"value": "New", "onclick": "CreateNewDoc()"}
 ;;{"value": "Open", "onclick": "OpenDoc()"}
 ;;{"value": "Close", "onclick": "CloseDoc()"}
 ;;{"data":"Click Here","size":36,"style":"bold","name":"text1","hOffset":250,"vOffset":100,"alignment":"center","onMouseUp":"sun1.opacity = (sun1.opacity / 100) * 90;"}
PRE ;; Adding already encoded values to object
 ;;{"count":3,"menu":[{"value": "New", "onclick": "CreateNewDoc()"},{"value": "Open", "onclick": "OpenDoc()"},{"value": "Close", "onclick": "CloseDoc()"}],"template":
 ;;{"data":"Click Here","size":36,"style":"bold","name":"text1","hOffset":250,"vOffset":100,"alignment":"center","onMouseUp":"sun1.opacity = (sun1.opacity / 100) * 90;"}}
WPOUT ;; WP field encoded as JSON
 ;;{"dob":"APR 7,1935","gender":"MALE","lastVitals":{"height":{"lastDone":"Aug 24, 2009","value":190},"weight":{"lastDone":"Jul 01, 2011","value":210}},"name":"AVIVAPATIENT,THIRTY","patDemDetails":{"text":"               COORDINATING
 ;; MASTER OF RECORD: ABILENE (CAA)\r\n Address: Any Street                    Temporary: NO TEMPORARY ADDRESS\r\n         Any Town,WV 99998-0071\r\n         \r\n  County: UNSPECIFIED                     From\/To: NOT APPLICABLE\r\n"},
 ;;"uid":"urn:va:F484:8:patient:8"}
LTZERO ;; Leading and trailing zeros
 ;;{"code":".77","count":737,"errors":0,"icd":"626.00","price":0.65,"ssn":"000427930"}
STRINGS ;; strings that look like numbers
 ;;{"count":234567,"hl7Time":"20120919","icd":"722.10","name":"Duck,Donald"}
EX1OUT ;; JSON.org example #1 target
 ;;{"menu":{"id":"file","popup":{"menuitem":[{"onclick":"CreateNewDoc()","value":"New"},{"onclick":"OpenDoc()","value":"Open"},{"onclick":"CloseDoc()","value":"Close"}]},"value":"File"}}
EX2OUT ;; JSON.org example #2 target
 ;;{"glossary":{"GlossDiv":{"GlossList":{"GlossEntry":{"Abbrev":"ISO 8879:1986","Acronym":"SGML","GlossDef":{"GlossSeeAlso":["GML","XML"],"para":"A meta-markup language, used to create markup languages such as DocBook."}
 ;;,"GlossSee":"markup","GlossTerm":"Standard Generalized Markup Language","ID":"SGML","SortAs":"SGML"}},"title":"S"},"title":"example glossary"}}
EX3OUT ;; JSON.org example #3 target
 ;;{"widget":{"debug":"on","image":{"alignment":"center","hOffset":250,"name":"sun1","src":"Images\/Sun.png","vOffset":250},"text":{"alignment":"center","data":"Click Here","hOffset":250,"name":"text1","onMouseUp":
 ;;"sun1.opacity = (sun1.opacity \/ 100) * 90;","size":36,"style":"bold","vOffset":100},"window":{"height":500,"name":"main_window","title":"Sample Konfabulator Widget","width":500}}}
EX4OUT ;; JSON.org example #4 target
 ;;{"web-app":{"servlet":[{"init-param":{"cachePackageTagsRefresh":60,"cachePackageTagsStore":200,"cachePackageTagsTrack":200,"cachePagesDirtyRead":10,"cachePagesRefresh":10,"cachePagesStore":100,"cachePagesTrack":200,
 ;
 ; data values to test long text field input
 ;
WP ;; object with word processing field
 ;;Y("dob")="APR 7,1935"
 ;;Y("gender")="MALE"
 ;;Y("lastVitals","height","lastDone")="Aug 24, 2009"
 ;;Y("lastVitals","height","value")=190
 ;;Y("lastVitals","weight","lastDone")="Jul 01, 2011"
 ;;Y("lastVitals","weight","value")=210
 ;;Y("name")="AVIVAPATIENT,THIRTY"
 ;;Y("patDemDetails","text","\",6)="               COORDINATING MASTER OF RECORD: ABILENE (CAA)"_$C(13,10)
 ;;Y("patDemDetails","text","\",7)=" Address: Any Street                    Temporary: NO TEMPORARY ADDRESS"_$C(13,10)
 ;;Y("patDemDetails","text","\",8)="         Any Town,WV 99998-0071"_$C(13,10)
 ;;Y("patDemDetails","text","\",9)="         "_$C(13,10)
 ;;Y("patDemDetails","text","\",10)="  County: UNSPECIFIED                     From/To: NOT APPLICABLE"_$C(13,10)
 ;;Y("uid")="urn:va:F484:8:patient:8"
 ;;zzzzz
 ;
 ; data values for JSON.ORG examples rendered as M arrays
 ;
EX1IN ;; JSON.org example #1
 ;;Y("menu","id")="file"
 ;;Y("menu","popup","menuitem",1,"onclick")="CreateNewDoc()"
 ;;Y("menu","popup","menuitem",1,"value")="New"
 ;;Y("menu","popup","menuitem",2,"onclick")="OpenDoc()"
 ;;Y("menu","popup","menuitem",2,"value")="Open"
 ;;Y("menu","popup","menuitem",3,"onclick")="CloseDoc()"
 ;;Y("menu","popup","menuitem",3,"value")="Close"
 ;;Y("menu","value")="File"
 ;;zzzzz
EX2IN ;; JSON.org example #2
 ;;Y("glossary","GlossDiv","GlossList","GlossEntry","Abbrev")="ISO 8879:1986"
 ;;Y("glossary","GlossDiv","GlossList","GlossEntry","Acronym")="SGML"
 ;;Y("glossary","GlossDiv","GlossList","GlossEntry","GlossDef","GlossSeeAlso",1)="GML"
 ;;Y("glossary","GlossDiv","GlossList","GlossEntry","GlossDef","GlossSeeAlso",2)="XML"
 ;;Y("glossary","GlossDiv","GlossList","GlossEntry","GlossDef","para")="A meta-markup language, used to create markup languages such as DocBook."
 ;;Y("glossary","GlossDiv","GlossList","GlossEntry","GlossSee")="markup"
 ;;Y("glossary","GlossDiv","GlossList","GlossEntry","GlossTerm")="Standard Generalized Markup Language"
 ;;Y("glossary","GlossDiv","GlossList","GlossEntry","ID")="SGML"
 ;;Y("glossary","GlossDiv","GlossList","GlossEntry","SortAs")="SGML"
 ;;Y("glossary","GlossDiv","title")="S"
 ;;Y("glossary","title")="example glossary"
 ;;zzzzz
EX3IN ;; JSON.org example #3
 ;;Y("widget","debug")="on"
 ;;Y("widget","image","alignment")="center"
 ;;Y("widget","image","hOffset")=250
 ;;Y("widget","image","name")="sun1"
 ;;Y("widget","image","src")="Images/Sun.png"
 ;;Y("widget","image","vOffset")=250
 ;;Y("widget","text","alignment")="center"
 ;;Y("widget","text","data")="Click Here"
 ;;Y("widget","text","hOffset")=250
 ;;Y("widget","text","name")="text1"
 ;;Y("widget","text","onMouseUp")="sun1.opacity = (sun1.opacity / 100) * 90;"
 ;;Y("widget","text","size")=36
 ;;Y("widget","text","style")="bold"
 ;;Y("widget","text","vOffset")=100
 ;;Y("widget","window","height")=500
 ;;Y("widget","window","name")="main_window"
 ;;Y("widget","window","title")="Sample Konfabulator Widget"
 ;;Y("widget","window","width")=500
 ;;zzzzz
EX4IN ;; JSON.org example #4
 ;;Y("web-app","servlet",1,"init-param","cachePackageTagsRefresh")=60
 ;;Y("web-app","servlet",1,"init-param","cachePackageTagsStore")=200
 ;;Y("web-app","servlet",1,"init-param","cachePackageTagsTrack")=200
 ;;Y("web-app","servlet",1,"init-param","cachePagesDirtyRead")=10
 ;;Y("web-app","servlet",1,"init-param","cachePagesRefresh")=10
 ;;Y("web-app","servlet",1,"init-param","cachePagesStore")=100
 ;;Y("web-app","servlet",1,"init-param","cachePagesTrack")=200
 ;;Y("web-app","servlet",1,"init-param","cacheTemplatesRefresh")=15
 ;;Y("web-app","servlet",1,"init-param","cacheTemplatesStore")=50
 ;;Y("web-app","servlet",1,"init-param","cacheTemplatesTrack")=100
 ;;Y("web-app","servlet",1,"init-param","configGlossary:adminEmail")="ksm@pobox.com"
 ;;Y("web-app","servlet",1,"init-param","configGlossary:installationAt")="Philadelphia, PA"
 ;;Y("web-app","servlet",1,"init-param","configGlossary:poweredBy")="Cofax"
 ;;Y("web-app","servlet",1,"init-param","configGlossary:poweredByIcon")="/images/cofax.gif"
 ;;Y("web-app","servlet",1,"init-param","configGlossary:staticPath")="/content/static"
 ;;Y("web-app","servlet",1,"init-param","dataStoreClass")="org.cofax.SqlDataStore"
 ;;Y("web-app","servlet",1,"init-param","dataStoreConnUsageLimit")=100
 ;;Y("web-app","servlet",1,"init-param","dataStoreDriver")="com.microsoft.jdbc.sqlserver.SQLServerDriver"
 ;;Y("web-app","servlet",1,"init-param","dataStoreInitConns")=10
 ;;Y("web-app","servlet",1,"init-param","dataStoreLogFile")="/usr/local/tomcat/logs/datastore.log"
 ;;Y("web-app","servlet",1,"init-param","dataStoreLogLevel")="debug"
 ;;Y("web-app","servlet",1,"init-param","dataStoreMaxConns")=100
 ;;Y("web-app","servlet",1,"init-param","dataStoreName")="cofax"
 ;;Y("web-app","servlet",1,"init-param","dataStorePassword")="dataStoreTestQuery"
 ;;Y("web-app","servlet",1,"init-param","dataStoreTestQuery")="SET NOCOUNT ON;select test='test';"
 ;;Y("web-app","servlet",1,"init-param","dataStoreUrl")="jdbc:microsoft:sqlserver://LOCALHOST:1433;DatabaseName=goon"
 ;;Y("web-app","servlet",1,"init-param","dataStoreUser")="sa"
 ;;Y("web-app","servlet",1,"init-param","defaultFileTemplate")="articleTemplate.htm"
 ;;Y("web-app","servlet",1,"init-param","defaultListTemplate")="listTemplate.htm"
 ;;Y("web-app","servlet",1,"init-param","jspFileTemplate")="articleTemplate.jsp"
 ;;Y("web-app","servlet",1,"init-param","jspListTemplate")="listTemplate.jsp"
 ;;Y("web-app","servlet",1,"init-param","maxUrlLength")=500
 ;;Y("web-app","servlet",1,"init-param","redirectionClass")="org.cofax.SqlRedirection"
 ;;Y("web-app","servlet",1,"init-param","searchEngineFileTemplate")="forSearchEngines.htm"
 ;;Y("web-app","servlet",1,"init-param","searchEngineListTemplate")="forSearchEnginesList.htm"
 ;;Y("web-app","servlet",1,"init-param","searchEngineRobotsDb")="WEB-INF/robots.db"
 ;;Y("web-app","servlet",1,"init-param","templateLoaderClass")="org.cofax.FilesTemplateLoader"
 ;;Y("web-app","servlet",1,"init-param","templateOverridePath")=""
 ;;Y("web-app","servlet",1,"init-param","templatePath")="templates"
 ;;Y("web-app","servlet",1,"init-param","templateProcessorClass")="org.cofax.WysiwygTemplate"
 ;;Y("web-app","servlet",1,"init-param","useDataStore")="true"
 ;;Y("web-app","servlet",1,"init-param","useJSP")="false"
 ;;Y("web-app","servlet",1,"servlet-class")="org.cofax.cds.CDSServlet"
 ;;Y("web-app","servlet",1,"servlet-name")="cofaxCDS"
 ;;Y("web-app","servlet",2,"init-param","mailHost")="mail1"
 ;;Y("web-app","servlet",2,"init-param","mailHostOverride")="mail2"
 ;;Y("web-app","servlet",2,"servlet-class")="org.cofax.cds.EmailServlet"
 ;;Y("web-app","servlet",2,"servlet-name")="cofaxEmail"
 ;;Y("web-app","servlet",3,"servlet-class")="org.cofax.cds.AdminServlet"
 ;;Y("web-app","servlet",3,"servlet-name")="cofaxAdmin"
 ;;Y("web-app","servlet",4,"servlet-class")="org.cofax.cds.FileServlet"
 ;;Y("web-app","servlet",4,"servlet-name")="fileServlet"
 ;;Y("web-app","servlet",5,"init-param","adminGroupID")=4
 ;;Y("web-app","servlet",5,"init-param","betaServer")="true"
 ;;Y("web-app","servlet",5,"init-param","dataLog")=1
 ;;Y("web-app","servlet",5,"init-param","dataLogLocation")="/usr/local/tomcat/logs/dataLog.log"
 ;;Y("web-app","servlet",5,"init-param","dataLogMaxSize")=""
 ;;Y("web-app","servlet",5,"init-param","fileTransferFolder")="/usr/local/tomcat/webapps/content/fileTransferFolder"
 ;;Y("web-app","servlet",5,"init-param","log")=1
 ;;Y("web-app","servlet",5,"init-param","logLocation")="/usr/local/tomcat/logs/CofaxTools.log"
 ;;Y("web-app","servlet",5,"init-param","logMaxSize")=""
 ;;Y("web-app","servlet",5,"init-param","lookInContext")=1
 ;;Y("web-app","servlet",5,"init-param","removePageCache")="/content/admin/remove?cache=pages&id="
 ;;Y("web-app","servlet",5,"init-param","removeTemplateCache")="/content/admin/remove?cache=templates&id="
 ;;Y("web-app","servlet",5,"init-param","templatePath")="toolstemplates/"
 ;;Y("web-app","servlet",5,"servlet-class")="org.cofax.cms.CofaxToolsServlet"
 ;;Y("web-app","servlet",5,"servlet-name")="cofaxTools"
 ;;Y("web-app","servlet-mapping","cofaxAdmin")="/admin/*"
 ;;Y("web-app","servlet-mapping","cofaxCDS")="/"
 ;;Y("web-app","servlet-mapping","cofaxEmail")="/cofaxutil/aemail/*"
 ;;Y("web-app","servlet-mapping","cofaxTools")="/tools/*"
 ;;Y("web-app","servlet-mapping","fileServlet")="/static/*"
 ;;Y("web-app","taglib","taglib-location")="/WEB-INF/tlds/cofax.tld"
 ;;Y("web-app","taglib","taglib-uri")="cofax.tld"
 ;;zzzzz
