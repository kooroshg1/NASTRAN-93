      SUBROUTINE APDCS        
      INTEGER CP,ACSID,CSTMA,IZ(1)        
      REAL           RCP1(3),RCP4(3),RB1(3),RB4(3),RX1(3),RX4(3)        
     1,              RA2(3),RA3(3),RA4(3),RB2(3),RB3(3),VX1(3),VX2(3)   
     2,   VX3(3),ACPL(3,3),V1(3),V2(3)        
      COMMON /APD1C/ EID,PID,CP,NSPAN,NCHORD,LSPAN,LCHORD,IGID        
     1,              X1,Y1,Z1,X12,X4,Y4,Z4,X43,XOP,X1P,ALZO,MCSTM       
     2,              NCST1,NCST2,CIDBX,ACSID,IACS,SILB,NCRD        
     3,              SCR1,SCR2,SCR3,SCR4,SCR5,ECTA,BGPA,GPLA,USETA,SILA 
     4,              CSTMA,ACPT,BUF10,BUF11,BUF12,NEXT,LEFT,ISILN       
      COMMON /APD1D/ ICPL(14),YP4,SG,CG,XP2,XP3,XP4,RA1(3)        
CZZ   COMMON /ZZAPDX/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      EQUIVALENCE (Z(1),IZ(1))        
      EQUIVALENCE (ICPL(3),RB1(1)),(ICPL(6),ACPL(1,1))        
     1, (V1(1),RCP1(1)),(V2(1),RCP4(1))        
      DATA DEGR/.017453293/        
      ICPL(2) = 1        
C CREATE PANEL COORDINATE SYSTEM        
C FIND CP TRANSFORMATION AND CONVERT POINT 1 AND 4 TO BASIC        
      IF(CP.EQ.0) GO TO 120        
      IF(NCST1.EQ.0) GO TO 470        
      DO 40 ICP=NCST1,NCST2,14        
      IF(IZ(ICP).EQ.CP) GO TO 50        
   40 CONTINUE        
      GO TO 470        
   50 IF(IZ(ICP+1)-2) 60,70,80        
C CP RECTANGULAR        
   60 RCP1(1)=X1        
      RCP1(2)=Y1        
      RCP1(3)=Z1        
      RCP4(1)=X4        
      RCP4(2)=Y4        
      RCP4(3)=Z4        
      GO TO 90        
C CP CYLINDRICAL        
   70 RCP1(1)=X1*COS(Y1*DEGR)        
      RCP1(2)=X1*SIN(Y1*DEGR)        
      RCP1(3)=Z1        
      RCP4(1)=X4*COS(Y4*DEGR)        
      RCP4(2) = X4*SIN(Y4*DEGR)        
      RCP4(3)=Z4        
      GO TO 90        
C CP SPHERICAL        
   80 RCP1(1)=X1*SIN(Y1*DEGR)*COS(Z1*DEGR)        
      RCP1(2)=X1*SIN(Y1*DEGR)*SIN(Z1*DEGR)        
      RCP1(3)=X1*COS(Y1*DEGR)        
      RCP4(1)=X4*SIN(Y4*DEGR)*COS(Z4*DEGR)        
      RCP4(2)=X4*SIN(Y4*DEGR)*SIN(Z4*DEGR)        
      RCP4(3)=X4*COS(Y4*DEGR)        
C CONVERT TO BASIC        
   90 CALL GMMATS(Z(ICP+5),3,3,0,RCP1,3,1,0,RB1)        
      CALL GMMATS(Z(ICP+5),3,3,0,RCP4,3,1,0,RB4)        
      J=ICP+1        
      DO 100 I=1,3        
      K=J+I        
  100 RB1(I)=RB1(I)+Z(K)        
      DO 110 I=1,3        
      K=J+I        
  110 RB4(I)=RB4(I)+Z(K)        
      GO TO 130        
C COORDS ARE IN BASIC        
  120 RB1(1)=X1        
      RB1(2)=Y1        
      RB1(3)=Z1        
      RB4(1)=X4        
      RB4(2)=Y4        
      RB4(3)=Z4        
C FIND R1 THRU IN R4 AERO CS        
  130 IF(ACSID.EQ.0) GO TO 150        
      J=IACS+1        
      DO 140 I=1,3        
      K=J+I        
      RX1(I)=RB1(I)-Z(K)        
  140 RX4(I)=RB4(I)-Z(K)        
      CALL GMMATS(Z(IACS+5),3,3,1,RX1,3,1,0,RA1)        
      CALL GMMATS (Z(IACS+5),3,3,1,RX4,3,1,0,RA4)        
      GO TO 170        
  150 DO 160 I=1,3        
      RA1(I)=RB1(I)        
  160 RA4(I)=RB4(I)        
C        
C     STOP IF BODY        
C        
      IF(IGID.LT.0) GO TO 1000        
C CALCULATE R2 AND R3 IN AC CS        
  170 DO 180 I=2,3        
      RA2(I)=RA1(I)        
  180 RA3(I)=RA4(I)        
      RA2(1)=RA1(1)+X12        
      RA3(1)=RA4(1)+X43        
      EE=SQRT((RA4(3)-RA1(3))**2 + (RA4(2)-RA1(2))**2)        
      SG=(RA4(3)-RA1(3))/EE        
      CG=(RA4(2)-RA1(2))/EE        
C LOCATE POINTS 2,3,4 IN PANEL CORDINATE SYSTEM        
      XP2=X12        
      XP4=RA4(1)-RA1(1)        
      XP3=RA3(1)-RA1(1)        
      YP4=EE        
C TRANSFORM R2 AND R3 INTO BASIC        
      IF(ACSID.EQ.0) GO TO 200        
      CALL GMMATS(Z(IACS+5),3,3,0,RA2,3,1,0,RB2)        
      CALL GMMATS(Z(IACS+5),3,3,0,RA3,3,1,0,RB3)        
      J=IACS+1        
      DO 190 I=1,3        
      K=J+I        
      RB2(I) = RB2(I) + Z(K)        
  190 RB3(I) = RB3(I) + Z(K)        
      GO TO 220        
  200 DO 210 I=1,3        
      RB2(I)=RA2(I)        
  210 RB3(I)=RA3(I)        
C FIND PANEL COORDINATE SYSTEM        
  220 DO 230 I=1,3        
      VX1(I)=RB2(I)-RB1(I)        
      VX2(I)=RB4(I)-RB1(I)        
      VX3(I) = RB3(I) - RB1(I)        
  230 IF ( X12. EQ. 0.0 ) VX1(I) = VX3(I)        
      CALL SAXB(VX1,VX2,V1)        
      SX1=SADOTB(V1,V1)        
      CALL SAXB(VX1,VX3,V2)        
      SX2=SADOTB(V2,V2)        
      IF(SX1.LT.SX2) GO TO 250        
      SX1=1.0/SQRT(SX1)        
      DO 240 I=1,3        
  240 VX3(I)=V1(I)*SX1        
      GO TO 270        
  250 SX2=1.0/SQRT(SX2)        
      DO 260 I=1,3        
  260 VX3(I)=V2(I)*SX2        
  270 IF(ACSID .NE. 0) GO TO 275        
      VX1(1) = 1.0        
      VX1(2) = 0.0        
      VX1(3) = 0.0        
      GO TO 285        
  275 J=IACS+5        
      DO 280 I=1,3        
      K=J+3*(I-1)        
  280 VX1(I)=Z(K)        
  285 CONTINUE        
      CALL SAXB(VX3,VX1,VX2)        
      DO 290 I=1,3        
      ACPL(1,I)=VX1(I)        
      ACPL(2,I)=VX2(I)        
  290 ACPL(3,I)=VX3(I)        
C WRITE TRANSFORMATION ON CSTMA        
      ICPL(1)=MCSTM        
      CALL WRITE(CSTMA,ICPL(1),14,0)        
 1000 RETURN        
  470 CALL MESAGE(-30,25,CP)        
      GO TO 1000        
      END        