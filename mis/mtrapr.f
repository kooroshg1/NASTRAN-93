      SUBROUTINE MTRAPR        
C        
C     THIS ROUTINE COMPUTES THE MASS MATRIX FOR A AXI-SYMMETRIC RING    
C     WITH A TRAPEZOIDAL CROSS SECTION        
C        
C     ECPT FOR THE TRAPEZOIDAL RING        
C                                                          TYPE        
C     ECPT( 1) ELEMENT IDENTIFICATION                        I        
C     ECPT( 2) SCALAR INDEX NO. FOR GRID POINT A             I        
C     ECPT( 3) SCALAR INDEX NO. FOR GRID POINT B             I        
C     ECPT( 4) SCALAR INDEX NO. FOR GRID POINT C             I        
C     ECPT( 5) SCALAR INDEX NO. FOR GRID POINT D             I        
C     ECPT( 6) MATERIAL ORIENTATION ANGLE(DEGREES)           R        
C     ECPT( 7) MATERIAL IDENTIFICATION                       I        
C     ECPT( 8) COOR. SYS. ID. FOR GRID POINT A               I        
C     ECPT( 9) X-COOR. OF GRID POINT A (IN BASIC COOR.)      R        
C     ECPT(10) Y-COOR. OF GRID POINT A (IN BASIC COOR.)      R        
C     ECPT(11) Z-COOR. OF GRID POINT A (IN BASIC COOR.)      R        
C     ECPT(12) COOR. SYS. ID. FOR GRID POINT B               I        
C     ECPT(13) X-COOR. OF GRID POINT B (IN BASIC COOR.)      R        
C     ECPT(14) Y-COOR. OF GRID POINT B (IN BASIC COOR.)      R        
C     ECPT(15) Z-COOR. OF GRID POINT B (IN BASIC COOR.)      R        
C     ECPT(16) COOR. SYS. ID. FOR GRID POINT C               I        
C     ECPT(17) X-COOR. OF GRID POINT C (IN BASIC COOR.)      R        
C     ECPT(18) Y-COOR. OF GRID POINT C (IN BASIC COOR.)      R        
C     ECPT(19) Z-COOR. OF GRID POINT C (IN BASIC COOR.)      R        
C     ECPT(20) COOR. SYS. ID. FOR GRID POINT D               I        
C     ECPT(21) X-COOR. OF GRID POINT D (IN BASIC COOR.)      R        
C     ECPT(22) Y-COOR. OF GRID POINT D (IN BASIC COOR.)      R        
C     ECPT(23) Z-COOR. OF GRID POINT D (IN BASIC COOR.)      R        
C     ECPT(24) EL. TEMPERATURE FOR MATERIAL PROPERTIES       R        
C        
      DOUBLE PRECISION CONSTD,D2PI,D,GAMBQ,R,Z,DELINT,AK,AKI,AKT,AM,    
     1                 R1,R2,R3,R4,Z1,Z2,Z3,Z4,ZMIN,DGAMA,RZINTD,       
     2                 RMIN,RMAX,RHOD,TWOPI        
      DIMENSION        JRZ(2),IECPT(24),AM(64)        
      COMMON /SYSTEM/  IBUF,IOUT        
      COMMON /CONDAD/  CONSTD(5)        
      COMMON /SMA2IO/  DUM1(10),IFMGG,DUM2(25)        
      COMMON /SMA2CL/  DUM3(2),NPVT,DUM4(7),LINK(10),NOGO        
      COMMON /SMA2ET/  ECPT(24),DUM5(76)        
      COMMON /MATIN /  MATIDC,MATFLG,ELTEMP,STRESS,SINTH,COSTH        
      COMMON /MATOUT/  E(3),ANU(3),RHO,G(3),ALF(3),TZERO        
      COMMON /SMA2DP/  D(64),GAMBQ(64),R(4),Z(4),DELINT(12),AK(64),     
     1                 AKI(36),AKT(9),DGAMA,ZMIN,RHOD,TWOPI,IGP(4),     
     2                 ICS(4),SP(24),TEMPE        
      EQUIVALENCE      (IECPT(1),ECPT(1)),(R(1),R1),(R(2),R2),(R(3),R3),
     1                 (R(4),R4),(Z(1),Z1),(Z(2),Z2),(Z(3),Z3),(Z(4),Z4)
     2,                (AM(1),AK(1)),(CONSTD(2),D2PI)        
C        
C     STORE ECPT PARAMETERS IN LOCAL VARIABLES        
C        
      IDEL   = IECPT( 1)        
      IGP(1) = IECPT( 2)        
      IGP(2) = IECPT( 3)        
      IGP(3) = IECPT( 4)        
      IGP(4) = IECPT( 5)        
      MATID  = IECPT( 7)        
      ICS(1) = IECPT( 8)        
      ICS(2) = IECPT(12)        
      ICS(3) = IECPT(16)        
      ICS(4) = IECPT(20)        
      R(1)   = ECPT( 9)        
      D(1)   = ECPT(10)        
      Z(1)   = ECPT(11)        
      R(2)   = ECPT(13)        
      D(2)   = ECPT(14)        
      Z(2)   = ECPT(15)        
      R(3)   = ECPT(17)        
      D(3)   = ECPT(18)        
      Z(3)   = ECPT(19)        
      R(4)   = ECPT(21)        
      D(4)   = ECPT(22)        
      Z(4)   = ECPT(23)        
      TEMPE  = ECPT(24)        
      DGAMA  = ECPT( 6)        
C        
C     CHECK INTERNAL GRID POINTS FOR PIVOT POINT        
C        
      IPP = 0        
      DO 100 I = 1,4        
      IF (NPVT .EQ. IGP(I)) IPP = I        
  100 CONTINUE        
      IF (IPP .EQ. 0) CALL MESAGE (-30,34,IDEL)        
C        
C     TEST THE VALIDITY OF THE GRID POINT COORDINATES        
C        
      DO 200 I = 1,4        
      IF (R(I) .LT. 0.0D0) GO TO 910        
      IF (D(I) .NE. 0.0D0) GO TO 910        
  200 CONTINUE        
C        
C     COMPUTE THE ELEMENT COORDINATES        
C        
      ZMIN = DMIN1(Z1,Z2,Z3,Z4)        
      Z1 = Z1 - ZMIN        
      Z2 = Z2 - ZMIN        
      Z3 = Z3 - ZMIN        
      Z4 = Z4 - ZMIN        
C        
C     FATAL IF RATIO OF RADII IS TO LARGE FOR GUASS QUADRATURE FOR IP=-1
C        
      RMIN = DMIN1(R1,R2,R3,R4)        
      RMAX = DMAX1(R1,R2,R3,R4)        
      IF (RMIN .EQ. 0.D0) GO TO 206        
      IF (RMAX/RMIN .GT. 10.D0) GO TO 930        
C        
  206 CONTINUE        
      D(5) = (R1+R4)/2.0D0        
      D(6) = (R2+R3)/2.0D0        
      IF (D(5) .EQ. 0.0D0) GO TO 210        
      IF (DABS((R1-R4)/D(5)) .GT. 0.5D-2) GO TO 210        
      R1 = D(5)        
      R4 = D(5)        
  210 CONTINUE        
      IF (D(6) .EQ. 0.0D0) GO TO 220        
      IF (DABS((R2-R3)/D(6)) .GT. 0.5D-2) GO TO 220        
      R2 = D(6)        
      R3 = D(6)        
  220 CONTINUE        
C        
      ICORE = 0        
      J = 1        
      DO 230 I = 1,4        
      IF (R(I) .NE. 0.0D0) GO TO 230        
      ICORE = ICORE + 1        
      JRZ(J) = I        
      J = 2        
  230 CONTINUE        
      IF (ICORE.NE.0 .AND. ICORE.NE.2) GO TO 910        
C        
C     FORM THE TRANSFORMATION MATRIX (8X8) FROM FIELD COORDINATES TO    
C     GRID POINT DEGREES OF FREEDOM        
C        
      DO 300 I = 1,64        
      GAMBQ(I) = 0.0D0        
  300 CONTINUE        
      GAMBQ( 1) = 1.0D0        
      GAMBQ( 2) = R1        
      GAMBQ( 3) = Z1        
      GAMBQ( 4) = R1*Z1        
      GAMBQ(13) = 1.0D0        
      GAMBQ(14) = R1        
      GAMBQ(15) = Z1        
      GAMBQ(16) = GAMBQ(4)        
      GAMBQ(17) = 1.0D0        
      GAMBQ(18) = R2        
      GAMBQ(19) = Z2        
      GAMBQ(20) = R2*Z2        
      GAMBQ(29) = 1.0D0        
      GAMBQ(30) = R2        
      GAMBQ(31) = Z2        
      GAMBQ(32) = GAMBQ(20)        
      GAMBQ(33) = 1.0D0        
      GAMBQ(34) = R3        
      GAMBQ(35) = Z3        
      GAMBQ(36) = R3*Z3        
      GAMBQ(45) = 1.0D0        
      GAMBQ(46) = R3        
      GAMBQ(47) = Z3        
      GAMBQ(48) = GAMBQ(36)        
      GAMBQ(49) = 1.0D0        
      GAMBQ(50) = R4        
      GAMBQ(51) = Z4        
      GAMBQ(52) = R4*Z4        
      GAMBQ(61) = 1.0D0        
      GAMBQ(62) = R4        
      GAMBQ(63) = Z4        
      GAMBQ(64) = GAMBQ(52)        
C        
C     NO NEED TO COMPUTE DETERMINANT SINCE IT IS NOT USED SUBSEQUENTLY. 
C        
      ISING = -1        
      CALL INVERD (8,GAMBQ(1),8,D(10),0,D(11),ISING,SP)        
      IF (ISING .EQ. 2) GO TO 920        
C        
C     MODIFY THE TRANSFORMATION MATRIX IF ELEMENT IS A CORE ELEMENT     
C        
      IF (ICORE .EQ. 0) GO TO 305        
      JJ1 = 2*JRZ(1) - 1        
      JJ2 = 2*JRZ(2) - 1        
C        
      DO 303 I = 1,8        
      J = 8*(I-1)        
      GAMBQ(I    ) = 0.0D0        
      GAMBQ(I+ 16) = 0.0D0        
      GAMBQ(J+JJ1) = 0.0D0        
      GAMBQ(J+JJ2) = 0.0D0        
  303 CONTINUE        
  305 CONTINUE        
C        
C     CALCULATE THE INTEGRAL VALUES IN ARRAY DELINT WHERE THE ORDER IS  
C     INDICATED BY THE FOLLOWING TABLE        
C        
C     DELINT(1) - (1,0)        
C     DELINT(2) - (1,1)        
C     DELINT(3) - (1,2)        
C     DELINT(4) - (2,0)        
C     DELINT(5) - (2,1)        
C     DELINT(6) - (2,2)        
C     DELINT(7) - (3,0)        
C     DELINT(8) - (3,1)        
C     DELINT(9) - (3,2)        
C        
      I1 = 0        
      DO 400 I = 1,3        
      IP = I        
      DO 350 J = 1,3        
      IQ = J - 1        
      I1 = I1 + 1        
      DELINT(I1) = RZINTD(IP,IQ,R,Z,4)        
  350 CONTINUE        
  400 CONTINUE        
C        
C     LOCATE THE MATERIAL PROPERTIES IN THE MAT1 OR MAT3 TABLE        
C        
      MATIDC = MATID        
      MATFLG = 7        
      ELTEMP = TEMPE        
      CALL MAT (IDEL)        
C        
C    SET MATERIAL PROPERTIES IN DOUBLE PRECISION VARIABLES        
C        
      RHOD = RHO        
C        
C     GENERATE THE CONSISTENT MASS MATRIX IN FIELD COORDINATES        
C        
      DO 600 I = 1,64        
      AM(I) = 0.0D0        
  600 CONTINUE        
      TWOPI  = D2PI*RHOD        
      AM( 1) = TWOPI*DELINT(1)        
      AM( 2) = TWOPI*DELINT(4)        
      AM( 3) = TWOPI*DELINT(2)        
      AM( 4) = TWOPI*DELINT(5)        
      AM( 9) = AM( 2)        
      AM(10) = TWOPI*DELINT(7)        
      AM(11) = TWOPI*DELINT(5)        
      AM(12) = TWOPI*DELINT(8)        
      AM(17) = AM( 3)        
      AM(18) = AM(11)        
      AM(19) = TWOPI*DELINT(3)        
      AM(20) = TWOPI*DELINT(6)        
      AM(25) = AM( 4)        
      AM(26) = AM(12)        
      AM(27) = AM(20)        
      AM(28) = TWOPI*DELINT(9)        
      DO 650 I = 1,4        
      K = (I-1)*8        
      DO 650 J = 1,4        
      K = K + 1        
      AM(K+36) = AM(K)        
  650 CONTINUE        
C        
C     TRANSFORM THE ELEMENT MASS MATRIX FROM FIELD COORDINATES TO GRID  
C     POINT DEGREES OF FREEDOM        
C        
      CALL GMMATD (GAMBQ,8,8,1, AK,8,8,0, D)        
      CALL GMMATD (D,8,8,0, GAMBQ,8,8,0, AK)        
C        
C     ZERO OUT THE (6X6) MATRIX USED AS INPUT TO THE INSERTION ROUTINE  
C        
      DO 700 I = 1,36        
      AKI(I) = 0.0D0        
  700 CONTINUE        
C        
C     LOCATE THE TRANSFORMATION MATRICES FOR THE FOUR  GRID POINTS      
C        
      DO 800 I = 1,4        
      IF (ICS(I) .EQ. 0) GO TO 800        
      K = 9*(I-1) + 1        
      CALL TRANSD (ICS(I),D(K))        
  800 CONTINUE        
C        
C     START THE LOOP FOR INSERTION OF THE FOUR  (6X6) MATRICES INTO THE 
C     MASTER MASS MATRIX        
C        
      IR1  = 2*IPP - 1        
      IAPP = 9*(IPP-1) + 1        
      DO 900 I = 1,4        
C        
C     PLACE THE APPROIATE (2X2) SUBMATRIX OF THE MASS MATRIX IN A (3X3) 
C     MATRIX FOR TRANSFORMATION        
C        
      IC1    = 2*I - 1        
      IRC    = (IR1-1)*8 + IC1        
      AKT(1) = AK(IRC)        
      AKT(2) = 0.0D0        
      AKT(3) = AK(IRC+1)        
      AKT(4) = 0.0D0        
      AKT(5) = 0.0D0        
      AKT(6) = 0.0D0        
      AKT(7) = AK(IRC+8)        
      AKT(8) = 0.0D0        
      AKT(9) = AK(IRC+9)        
C        
C     TRANSFORM THE (3X3) MASS MATRIX        
C        
      IF (ICS(IPP) .EQ. 0) GO TO 820        
      CALL GMMATD (D(IAPP),3,3,1, AKT(1),3,3,0, D(37))        
      DO 810 J = 1,9        
      AKT(J) = D(J+36)        
  810 CONTINUE        
  820 CONTINUE        
      IF (ICS(I) .EQ. 0) GO TO 840        
      IAI = 9*(I-1) + 1        
      CALL GMMATD (AKT(1),3,3,0, D(IAI),3,3,0, D(37))        
      DO 830 J = 1,9        
      AKT(J) = D(J+36)        
  830 CONTINUE        
  840 CONTINUE        
C        
C     PLACE THE TRANSFORMED (3X3) MATRIX INTO A (6X6) MATRIX FOR THE    
C     INSERTION ROUTINE        
C        
      J = 0        
      DO 850 J1 = 1,18,6        
      DO 850 J2 = 1,3        
      J = J  + 1        
      K = J1 + J2 - 1        
      AKI(K) = AKT(J)        
  850 CONTINUE        
C        
C     CALL THE INSERTION ROUTINE        
C        
      CALL SMA2B (AKI(1),IGP(I),-1,IFMGG,0.0D0)        
  900 CONTINUE        
      RETURN        
C        
C     SET FLAG FOR FATAL ERROR WHILE ALLOWING ERROR MESSAGES TO        
C     ACCUMULATE        
C        
  910 I = 37        
      GO TO 950        
  920 I = 26        
      GO TO 950        
  930 I = 218        
      GO TO 960        
C        
C     ERROR TYPE 218 HAD BEEN ISSUED BY KTRAPR ALREADY.        
C        
  950 CALL MESAGE (30,I,IDEL)        
  960 NOGO = 1        
      RETURN        
C        
      END        
