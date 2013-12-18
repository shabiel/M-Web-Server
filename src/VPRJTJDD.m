VPRJTJDD ;SLC/KCM -- Unit test data for JSON decoding
 ;;1.0;JSON DATA STORE;;Sep 01, 2012
 ;
 ;
 ; --- Data for multi-line tests
 ;
SPLIT ;
 ;;{"name":"value","comments":"here comes some whitespace"     
 ;;    ,  "next"  :  "this is a new line", "wp":"this is a 
 ;;string that goes across two lines", "esc": "this string contains \\
 ;;and other escaped characters such as \n  and a few tabs \t\t\t\t and
 ;; a piece of \"quoted text\"", "nextLineQuote":"here is another string
 ;;"} 
 ;;#####
 ;
VALONLY ;
 ;;{"uid":"urn:va:param:F484:1120:VPR USER PREF:1120","entity":"USR","entityId":"1120","param":"VPR USER PREF","instance":"1120","vals":{"ext.libver":"/lib/ext-4.0.7/ext-all-dev.js","cpe.patientpicker.loc":"north"}}
 ;
NUMERIC ;
 ;;{"name":"Duck,Donald","hl7Time":"20120919","count":234567,"icd":"722.10"}
BADQUOTE ;
 ;;{"name":"value","comments":"here comes some whitespace"     
 ;;    ,  "next"  :  "this is a new line", "wp":"this is a 
 ;;string that goes across two lines", "esc: "this string contains \\
 ;;and other escaped characters such as \n  and a few tabs \t\t\t\t and
 ;; a piece of \"quoted text\"", "nextLineQuote":"here is another string
 ;;"} 
 ;;#####
 ;
BADSLASH ;
 ;;{"name":"value","comments":"here comes some whitespace"     
 ;;    ,  "next"  :  "this is a new line", "wp":"this is a 
 ;;string that goes across two lines", "esc": "this string contains \
 ;;and other escaped characters such as \n  and a few tabs \t\t\t\t and
 ;; a piece of \"quoted text\"", "nextLineQuote":"here is another string
 ;;"} 
 ;;#####
 ;
 ; --- SAMPLE JSON strings
 ;
SAM1 ;
 ;;{"menu":{"id":"file","popup":{"menuitem":[{"value": "New","onclick":"CreateNewDoc()"},
 ;;{"value": "Open","onclick": "OpenDoc()"},{"value": "Close","onclick": "CloseDoc()"}]} ,
 ;;"value":"File"}}
 ;;#####
 ;
SAM2 ;
 ;;    {
 ;;        "glossary": {
 ;;            "title": "example glossary",
 ;;            "GlossDiv": {
 ;;                "title": "S",
 ;;                "GlossList": {
 ;;                    "GlossEntry": {
 ;;                        "ID": "SGML",
 ;;                        "SortAs": "SGML",
 ;;                        "GlossTerm": "Standard Generalized Markup Language",
 ;;                        "Acronym": "SGML",
 ;;                        "Abbrev": "ISO 8879:1986",
 ;;                        "GlossDef": {
 ;;                            "para": "A meta-markup language, used to create markup languages such as DocBook.",
 ;;                            "GlossSeeAlso": ["GML", "XML"]
 ;;                        },
 ;;                        "GlossSee": "markup"
 ;;                    }
 ;;                }
 ;;            }
 ;;        }
 ;;    }
 ;;#####
 ;    
SAM3 ;
 ;;    {"widget": {
 ;;        "debug": "on",
 ;;        "window": {
 ;;            "title": "Sample Konfabulator Widget",
 ;;            "name": "main_window",
 ;;            "width": 500,
 ;;            "height": 500
 ;;        },
 ;;        "image": { 
 ;;            "src": "Images/Sun.png",
 ;;            "name": "sun1",
 ;;            "hOffset": 250,
 ;;            "vOffset": 250,
 ;;            "alignment": "center"
 ;;        },
 ;;        "text": {
 ;;            "data": "Click Here",
 ;;            "size": 36,
 ;;            "style": "bold",
 ;;            "name": "text1",
 ;;            "hOffset": 250,
 ;;            "vOffset": 100,
 ;;            "alignment": "center",
 ;;            "onMouseUp": "sun1.opacity = (sun1.opacity / 100) * 90;"
 ;;        }
 ;;    }}    
 ;;#####
 ;
SAM4 ;    
 ;;    {"web-app": {
 ;;      "servlet": [   
 ;;        {
 ;;          "servlet-name": "cofaxCDS",
 ;;          "servlet-class": "org.cofax.cds.CDSServlet",
 ;;          "init-param": {
 ;;            "configGlossary:installationAt": "Philadelphia, PA",
 ;;            "configGlossary:adminEmail": "ksm@pobox.com",
 ;;            "configGlossary:poweredBy": "Cofax",
 ;;            "configGlossary:poweredByIcon": "/images/cofax.gif",
 ;;            "configGlossary:staticPath": "/content/static",
 ;;            "templateProcessorClass": "org.cofax.WysiwygTemplate",
 ;;            "templateLoaderClass": "org.cofax.FilesTemplateLoader",
 ;;            "templatePath": "templates",
 ;;            "templateOverridePath": "",
 ;;            "defaultListTemplate": "listTemplate.htm",
 ;;            "defaultFileTemplate": "articleTemplate.htm",
 ;;            "useJSP": false,
 ;;            "jspListTemplate": "listTemplate.jsp",
 ;;            "jspFileTemplate": "articleTemplate.jsp",
 ;;            "cachePackageTagsTrack": 200,
 ;;            "cachePackageTagsStore": 200,
 ;;            "cachePackageTagsRefresh": 60,
 ;;            "cacheTemplatesTrack": 100,
 ;;            "cacheTemplatesStore": 50,
 ;;            "cacheTemplatesRefresh": 15,
 ;;            "cachePagesTrack": 200,
 ;;            "cachePagesStore": 100,
 ;;            "cachePagesRefresh": 10,
 ;;            "cachePagesDirtyRead": 10,
 ;;            "searchEngineListTemplate": "forSearchEnginesList.htm",
 ;;            "searchEngineFileTemplate": "forSearchEngines.htm",
 ;;            "searchEngineRobotsDb": "WEB-INF/robots.db",
 ;;            "useDataStore": true,
 ;;            "dataStoreClass": "org.cofax.SqlDataStore",
 ;;            "redirectionClass": "org.cofax.SqlRedirection",
 ;;            "dataStoreName": "cofax",
 ;;            "dataStoreDriver": "com.microsoft.jdbc.sqlserver.SQLServerDriver",
 ;;            "dataStoreUrl": "jdbc:microsoft:sqlserver://LOCALHOST:1433;DatabaseName=goon",
 ;;            "dataStoreUser": "sa",
 ;;            "dataStorePassword": "dataStoreTestQuery",
 ;;            "dataStoreTestQuery": "SET NOCOUNT ON;select test='test';",
 ;;            "dataStoreLogFile": "/usr/local/tomcat/logs/datastore.log",
 ;;            "dataStoreInitConns": 10,
 ;;            "dataStoreMaxConns": 100,
 ;;            "dataStoreConnUsageLimit": 100,
 ;;            "dataStoreLogLevel": "debug",
 ;;            "maxUrlLength": 500}},
 ;;        {
 ;;          "servlet-name": "cofaxEmail",
 ;;          "servlet-class": "org.cofax.cds.EmailServlet",
 ;;          "init-param": {
 ;;          "mailHost": "mail1",
 ;;          "mailHostOverride": "mail2"}},
 ;;        {
 ;;          "servlet-name": "cofaxAdmin",
 ;;          "servlet-class": "org.cofax.cds.AdminServlet"},
 ;;     
 ;;        {
 ;;          "servlet-name": "fileServlet",
 ;;          "servlet-class": "org.cofax.cds.FileServlet"},
 ;;        {
 ;;          "servlet-name": "cofaxTools",
 ;;          "servlet-class": "org.cofax.cms.CofaxToolsServlet",
 ;;          "init-param": {
 ;;            "templatePath": "toolstemplates/",
 ;;            "log": 1,
 ;;            "logLocation": "/usr/local/tomcat/logs/CofaxTools.log",
 ;;            "logMaxSize": "",
 ;;            "dataLog": 1,
 ;;            "dataLogLocation": "/usr/local/tomcat/logs/dataLog.log",
 ;;            "dataLogMaxSize": "",
 ;;            "removePageCache": "/content/admin/remove?cache=pages&id=",
 ;;            "removeTemplateCache": "/content/admin/remove?cache=templates&id=",
 ;;            "fileTransferFolder": "/usr/local/tomcat/webapps/content/fileTransferFolder",
 ;;            "lookInContext": 1,
 ;;            "adminGroupID": 4,
 ;;            "betaServer": true}}],
 ;;      "servlet-mapping": {
 ;;        "cofaxCDS": "/",
 ;;        "cofaxEmail": "/cofaxutil/aemail/*",
 ;;        "cofaxAdmin": "/admin/*",
 ;;        "fileServlet": "/static/*",
 ;;        "cofaxTools": "/tools/*"},
 ;;     
 ;;      "taglib": {
 ;;        "taglib-uri": "cofax.tld",
 ;;        "taglib-location": "/WEB-INF/tlds/cofax.tld"}}}
 ;;#####
 ;
SAM5 ;    
 ;;    {"menu": {
 ;;        "header": "SVG Viewer",
 ;;        "items": [
 ;;            {"id": "Open"},
 ;;            {"id": "OpenNew", "label": "Open New"},
 ;;            null,
 ;;            {"id": "ZoomIn", "label": "Zoom In"},
 ;;            {"id": "ZoomOut", "label": "Zoom Out"},
 ;;            {"id": "OriginalView", "label": "Original View"},
 ;;            null,
 ;;            {"id": "Quality"},
 ;;            {"id": "Pause"},
 ;;            {"id": "Mute"},
 ;;            null,
 ;;            {"id": "Find", "label": "Find..."},
 ;;            {"id": "FindAgain", "label": "Find Again"},
 ;;            {"id": "Copy"},
 ;;            {"id": "CopyAgain", "label": "Copy Again"},
 ;;            {"id": "CopySVG", "label": "Copy SVG"},
 ;;            {"id": "ViewSVG", "label": "View SVG"},
 ;;            {"id": "ViewSource", "label": "View Source"},
 ;;            {"id": "SaveAs", "label": "Save As"},
 ;;            null,
 ;;            {"id": "Help"},
 ;;            {"id": "About", "label": "About Adobe CVG Viewer..."}
 ;;        ]
 ;;    }}
 ;;#####
PSNUM ; Psudo-neumeric tests
 ;;{
 ;;"0.85,0.01":{"AUDIT":"TEST1","AUDIT CONDITION":"TEST2"},
 ;;"0.85,0.02":{"AUDIT":"TEST3","AUDIT CONDITION":"TEST4"},
 ;;"0.85,0.03":{"AUDIT":"TEST5","AUDIT CONDITION":"TEST6"}
 ;;}
 ;;#####
