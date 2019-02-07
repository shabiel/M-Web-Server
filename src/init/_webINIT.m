%webINIT ; ;Feb 07, 2019@11:09
 ;;1.0;MUMPS WEB SERVER;;JAN 22, 2019
 ;
 ; Copyright 2013-2019 Sam Habiel
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
 K DIF,DIFQ,DIFQR,DIFQN,DIK,DDF,DDT,DTO,D0,DLAYGO,DIC,DIDUZ,DIR,DA,DIFROM,DFR,DTN,DIX,DZ,DIRUT,DTOUT,DUOUT
 S DIOVRD=1,U="^",DIFQ=0,DIFROM="1.0" W !,"This version (#1.0) of '%webINIT' was created on 22-JAN-2019"
 W !?9,"(at DEMO.OSEHRA.ORG, by MSC FileMan 22.1061)",!
 I $D(^DD("VERSION")),^("VERSION")'<22.0 G GO
 ;W !,"FIRST, I'LL FRESHEN UP YOUR VA FILEMAN...." D N^DINIT
 I ^DD("VERSION")<22.2 W !,"but I need version 22.2 of the VA FileMan!" G Q
GO ;
EN ; ENTER HERE TO BYPASS THE PRE-INIT PROGRAM
 S DIFQ=0 K DIRUT,DTOUT,DUOUT
 F DIFRIR=1:1:1 S DIFRRTN="^%webINI"_$E("5",DIFRIR) D @DIFRRTN
 W:1 !,"I AM GOING TO SET UP THE FOLLOWING FILES:" F I=1:2:2 S DIF(I)=^UTILITY("DIF",$J,I) D 1 G Q:DIFQ!$D(DIRUT) K DIF(I)
 S DIFROM="1.0" D PKG:'$D(DIFROM(0)),^%webINI1 G Q:'$D(DIFQ) S DIK(0)="AB"
 F DIF=1:2:2 S %=^UTILITY("DIF",$J,DIF),DIK=$P(%,";",5),N=$P(%,";",3),D=$P(%,";",4)_U_N D D K DIFQ(N)
 K DIFQR D ^%webINI2,^%webINI3
 L  S DUZ=DIDUZ W:1 !,$C(7),"OK, I'M DONE.",!,"NO"_$P("TE THAT FILE",U,DSEC)_" SECURITY-CODE PROTECTION HAS BEEN MADE"
 I DIFROM F DIF=1:2:2 S %=^UTILITY("DIF",$J,DIF),N=+$P(%,";",3) I N,$P(%,";",8)="y" S ^DD(N,0,"VR")=DIFROM
 I DIFROM(0)>0 F %="PRE","INI","INIT" S:$D(DIFROM(%)) $P(^DIC(9.4,DIFROM(0),%),U,2)=DIFROM(%)
 I $G(DIFQN) S $P(^(0),U,3,4)=$P(DIFQN,U,2)_U_($P(^DIC(0),U,4)+DIFQN) K DIFQN
 S:DIFROM(0)>0 ^DIC(9.4,DIFROM(0),"VERSION")=DIFROM G Q^DIFROM0
D S:$D(^DIC(+N,0))[0 ^(0)=D S X=$D(@(DIK_"0)")),^(0)=D_U_$S(X#2:$P(^(0),U,3,9),1:U)
 S DIFQR=DIFQR(+N) I ^DD("VERSION")>17.5,$D(^DD(+N,0,"DIK"))#2 S X=^("DIK"),Y=+N,DMAX=^DD("ROU") D EN^DIKZ
 I DIFQR D IXALL^DIK:$O(@(DIK_"0)")) W "."
 Q
R G REP^%webINI2
 ;
1 S N=+$P(DIF(I),";",3),DIF=$P(DIF(I),";",4),S=$P(DIF(I),";",5)
 W !!?3,N,?13,DIF,$P("  (Partial Definition)",U,$P(DIF(I),";",6)),$P("  (including data)",U,$P(DIF(I),";",13)="y") S Z=$S($D(^DIC(N,0))#2:^(0),1:"")
 I Z="" S DIFQ(N)=1,DIFQN=$G(DIFQN)+1_U_N G S
 I $L($P(Z,DIF)) W $C(7),!,"*BUT YOU ALREADY HAVE '",$P(Z,U),"' AS FILE #",N,"!" D R Q:DIFQ  G S:$D(DIFKEP(N)),1
 S DIFQ(N)=$P(DIF(I),";",7)'="n"
 I $L(Z) W $C(7),!,"Note:  You already have the '",$P(Z,U),"' File." S DIFQ(0)=1
 S %=$E(^UTILITY("DIF",$J,I+1),4,245) I %]"" X % S DIFQ(N)=$T W:'$T !,"Screen on this Data Dictionary did not pass--DD will not be installed!" G S
 I $L(Z),$P(DIF(I),";",10)="y" S DIR("A")="Shall I write over the existing Data Definition",DIR("??")="^D DD^DIFROMH1",DIR("B")="YES",DIR(0)="Y" D ^DIR S DIFQ(N)=Y
S S DIFQR(N)=0 Q:$P(DIF(I),";",13)'="y"!$D(DIRUT)
 I $P(DIF(I),";",15)="y",$O(@(S_"0)"))>0 S DIF=$P(DIF(I),";",14)="o",DIR("A")="Want my data "_$P("merged with^to overwrite",U,DIF+1)_" yours",DIR("??")="^D DTA^DIFROMH1",DIR(0)="Y" D ^DIR S DIFQR(N)=$S('Y:Y,1:Y+DIF) Q
 S %=$P(DIF(I),";",14)="o" W !,$C(7),"I will ",$P("MERGE^OVERWRITE",U,%+1)," your data with mine." S DIFQR(N)=%+1
 Q
Q W $C(7),!!,"NO UPDATING HAS OCCURRED!" G Q^DIFROM0
 ;
PKG S X=$P($T(IXF),";",3),DIC="^DIC(9.4,",DIC(0)="",DIC("S")="I $P(^(0),U,2)="""_$P(X,U,2)_"""",X=$P(X,U) D ^DIC S DIFROM(0)=+Y K DIC
 Q
 ;
IXF ;;;1
