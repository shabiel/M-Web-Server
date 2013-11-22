%WINI002 ; ; 22-NOV-2013
 ;;0.2;MASH WEB SERVER;;NOV 22, 2013
 I DSEC F I=1:2 S X=$T(Q+I) Q:X=""  S Y=$E($T(Q+I+1),4,999),X=$E(X,4,999) S:$A(Y)=126 I=I+1,Y=$E(Y,2,999)_$E($T(Q+I+1),5,999) S:$A(Y)=61 Y=$E(Y,2,999) X NO E  S @X=Y
Q Q
 ;;^DIC(17.6001,0,"AUDIT")
 ;;=@
 ;;^DIC(17.6001,0,"DD")
 ;;=@
 ;;^DIC(17.6001,0,"DEL")
 ;;=@
 ;;^DIC(17.6001,0,"LAYGO")
 ;;=@
 ;;^DIC(17.6001,0,"RD")
 ;;=@
 ;;^DIC(17.6001,0,"WR")
 ;;=@
