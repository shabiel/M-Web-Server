%webI001 ; ; 22-JAN-2019
 ;;1.0;MUMPS WEB SERVER;;JAN 22, 2019
 Q:'DIFQ(17.6001)  F I=1:2 S X=$T(Q+I) Q:X=""  S Y=$E($T(Q+I+1),4,999),X=$E(X,4,999) S:$A(Y)=126 I=I+1,Y=$E(Y,2,999)_$E($T(Q+I+1),5,999) S:$A(Y)=61 Y=$E(Y,2,999) X NO E  S @X=Y
Q Q
 ;;^DIC(17.6001,0,"GL")
 ;;=^%web(17.6001,
 ;;^DIC("B","WEB SERVICE URL HANDLER",17.6001)
 ;;=
 ;;^DD(17.6001,0)
 ;;=FIELD^^20^8
 ;;^DD(17.6001,0,"DT")
 ;;=3190121
 ;;^DD(17.6001,0,"NM","WEB SERVICE URL HANDLER")
 ;;=
 ;;^DD(17.6001,.01,0)
 ;;=HTTP VERB^RS^POST:POST;PUT:PUT;GET:GET;DELETE:DELETE;OPTIONS:OPTIONS;HEAD:HEAD;TRACE:TRACE;CONNECT:CONNECT;^0;1^Q
 ;;^DD(17.6001,.01,1,0)
 ;;=^.1^^0
 ;;^DD(17.6001,.01,3)
 ;;=
 ;;^DD(17.6001,.01,"DT")
 ;;=3190117
 ;;^DD(17.6001,1,0)
 ;;=URI^F^^1;E1,250^K:$L(X)>250!($L(X)<1) X
 ;;^DD(17.6001,1,3)
 ;;=
 ;;^DD(17.6001,1,"DT")
 ;;=3190117
 ;;^DD(17.6001,2,0)
 ;;=EXECUTION ENDPOINT^F^^2;E1,250^K:$L(X)>250!($L(X)<1) X
 ;;^DD(17.6001,2,3)
 ;;=
 ;;^DD(17.6001,2,"DT")
 ;;=3190117
 ;;^DD(17.6001,11,0)
 ;;=AUTHENTICATION REQUIRED?^S^1:YES;^AUTH;1^Q
 ;;^DD(17.6001,11,"DT")
 ;;=3130506
 ;;^DD(17.6001,12,0)
 ;;=KEY^P19.1'^DIC(19.1,^AUTH;2^Q
 ;;^DD(17.6001,12,"DT")
 ;;=3130506
 ;;^DD(17.6001,13,0)
 ;;=REVERSE KEY^P19.1'^DIC(19.1,^AUTH;3^Q
 ;;^DD(17.6001,13,"DT")
 ;;=3130507
 ;;^DD(17.6001,14,0)
 ;;=OPTION^P19'^DIC(19,^AUTH;4^Q
 ;;^DD(17.6001,14,"DT")
 ;;=3130506
 ;;^DD(17.6001,20,0)
 ;;=PARAMETERS^17.60012S^^PARAMS;0
 ;;^DD(17.60012,0)
 ;;=PARAMETERS SUB-FIELD^^.001^3
 ;;^DD(17.60012,0,"DT")
 ;;=3190121
 ;;^DD(17.60012,0,"NM","PARAMETERS")
 ;;=
 ;;^DD(17.60012,0,"UP")
 ;;=17.6001
 ;;^DD(17.60012,.001,0)
 ;;=NUMBER^NJ2,0^^ ^K:+X'=X!(X>50)!(X<1)!(X?.E1"."1N.N) X
 ;;^DD(17.60012,.001,3)
 ;;=Type a number between 1 and 50, 0 decimal digits.
 ;;^DD(17.60012,.001,21,0)
 ;;=^^1^1^3190121^
 ;;^DD(17.60012,.001,21,1,0)
 ;;=Order of the Parameter to be passed.
 ;;^DD(17.60012,.001,"DT")
 ;;=3190121
 ;;^DD(17.60012,.01,0)
 ;;=PARAMETER TYPE^MS^Q:HTTP QUERY;F:URL ENCODED FORM;B:BODY;H:HEADER;U:URL COMPONENT;^0;1^Q
 ;;^DD(17.60012,.01,1,0)
 ;;=^.1^^0
 ;;^DD(17.60012,.01,3)
 ;;=Enter a parameter type.
 ;;^DD(17.60012,.01,21,0)
 ;;=^.001^2^2^3190121^^
 ;;^DD(17.60012,.01,21,1,0)
 ;;=This field allows you to add parameters that get called to your routine 
 ;;^DD(17.60012,.01,21,2,0)
 ;;=rather than everything going into ARGS and the rest into BODY.
 ;;^DD(17.60012,.01,"DT")
 ;;=3190121
 ;;^DD(17.60012,.02,0)
 ;;=PARAMETER NAME^FJ16^^0;2^K:$L(X)>16!($L(X)<1) X
 ;;^DD(17.60012,.02,3)
 ;;=Answer must be 1-16 characters in length.
 ;;^DD(17.60012,.02,21,0)
 ;;=^^4^4^3190117^
 ;;^DD(17.60012,.02,21,1,0)
 ;;=This field contains the parameter name for headers, form fields, and HTTP 
 ;;^DD(17.60012,.02,21,2,0)
 ;;=Query parameters. For example, if you pass a=12&b=22 as an HTTP query,
 ;;^DD(17.60012,.02,21,3,0)
 ;;=this field should be either a or b, depending on which parameter this
 ;;^DD(17.60012,.02,21,4,0)
 ;;=should be.
 ;;^DD(17.60012,.02,"DT")
 ;;=3190117
 ;;^UTILITY("KX",$J,"IX",17.6001,17.6001,"B",0)
 ;;=17.6001^B^Uniqueness Index for Key 'A' of File #17.6001^MU^^R^IR^I^17.6001^^^^^LS
 ;;^UTILITY("KX",$J,"IX",17.6001,17.6001,"B",1)
 ;;=S ^%web(17.6001,"B",X(1),X(2),X(3),DA)=""
 ;;^UTILITY("KX",$J,"IX",17.6001,17.6001,"B",2)
 ;;=K ^%web(17.6001,"B",X(1),X(2),X(3),DA)
 ;;^UTILITY("KX",$J,"IX",17.6001,17.6001,"B",2.5)
 ;;=K ^%web(17.6001,"B")
 ;;^UTILITY("KX",$J,"IX",17.6001,17.6001,"B",11.1,0)
 ;;=^.114IA^3^3
 ;;^UTILITY("KX",$J,"IX",17.6001,17.6001,"B",11.1,1,0)
 ;;=1^F^17.6001^.01^^1^F
 ;;^UTILITY("KX",$J,"IX",17.6001,17.6001,"B",11.1,1,3)
 ;;=
 ;;^UTILITY("KX",$J,"IX",17.6001,17.6001,"B",11.1,2,0)
 ;;=2^F^17.6001^1^^2^F
 ;;^UTILITY("KX",$J,"IX",17.6001,17.6001,"B",11.1,2,3)
 ;;=
 ;;^UTILITY("KX",$J,"IX",17.6001,17.6001,"B",11.1,3,0)
 ;;=3^F^17.6001^2^^3^F
 ;;^UTILITY("KX",$J,"IX",17.6001,17.6001,"B",11.1,3,3)
 ;;=
