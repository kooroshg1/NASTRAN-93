      SUBROUTINE PLOD4S        
C        
C     ROUTINE TO PROCESS PLOAD4 BULK DATA TO CREATE LOADS ON        
C     QUAD4 ELEMENTS        
C        
C     SINGLE PRECISION VERSION.        
C        
C     GRID POINT NUMBERING IS COUNTER-CLOCKWISE        
C     GRIDS 1,2,3, AND 4 ARE AT THE CORNERS        
C        
      INTEGER         NEST(125),IORDER(4),SIL(4),KSIL(4),NOUT,CID,      
     1                NSURF,SWP,SYSBUF,IZ(1),ITGRID(4,4),IBGPDT(4,4),   
     2                ISLT(11),NOGO        
      REAL            PE(3,4),BGPDT(4,4),PPP(4),NV(3),NVX(3),LOCATE(3)  
      REAL            DPE(3,4),WEIGHT,XSI,ETA,EPS,AREA,SHP(4),        
     1                DSHP(8),TMPSHP(4),DSHPTP(8),VI(3),VJ(3),V3T(3),   
     2                GAUSS(3),WTGAUS(3)        
      COMMON /LOADX / IDUM1(4),CSTM,IDUM2(13),ICM        
      COMMON /PINDEX/ BEST(45),SLT(11)        
CZZ   COMMON /ZZSSA1/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /SYSTEM/ SYSBUF,NOUT,NOGO        
      EQUIVALENCE     (IZ(1)  ,Z(1)   ), (SLT(1),ISLT(1) )        
      EQUIVALENCE     (NEST(1),BEST(1)), (NUMINT,NEST(25))        
      EQUIVALENCE     (SIL(1) ,NEST(2)), (BGPDT(1,1),BEST(29))        
      EQUIVALENCE     (IBGPDT(1,1),BGPDT(1,1))        
      EQUIVALENCE     (PE(1,1),DPE(1,1))        
C        
      DATA    NDOF  / 3 /        
C        
C                 EST LISTING        
C     ----------------------------------------------------------        
C      1          EID        
C      2 THRU 5   SILS, GRIDS 1 THRU 4        
C      6 THRU 9   T (MEMBRANE), GRIDS 1 THRU 4        
C     10          THETA (MATERIAL)        
C     11          TYPE FLAG FOR WORD 10        
C     12          ZOFF  (OFFSET)        
C     13          MATERIAL ID FOR MEMBRANE        
C     14          T (MEMBRANE)        
C     15          MATERIAL ID FOR BENDING        
C     16          I FACTOR (BENDING)        
C     17          MATERIAL ID FOR TRANSVERSE SHEAR        
C     18          FACTOR FOR T(S)        
C     19          NSM (NON-STRUCTURAL MASS)        
C     20 THRU 21  Z1, Z2  (STRESS FIBRE DISTANCES)        
C     22          MATERIAL ID FOR MEMBRANE-BENDING COUPLING        
C     23          THETA (MATERIAL) FROM PSHELL CARD        
C     24          TYPE FLAG FOR WORD 23        
C     25          INTEGRATION ORDER        
C     26          THETA (STRESS)        
C     27          TYPE FLAG FOR WORD 26        
C     28          ZOFF1 (OFFSET)  OVERRIDDEN BY EST(12)        
C     29 THRU 44  CID,X,Y,Z - GRIDS 1 THRU 4        
C     45          ELEMENT TEMPERATURE        
C        
C        
C          DATA FROM THE PLOAD4 CARD DESCRIBED HERE        
C     ----------------------------------------------------------        
C     EID  ELEMENT ID        
C     P1,P2,P3,P4 CORNER GRID POINT PRESSURES PER UNIT SURFACE AREA     
C     G1,G3  DEFINES QUADRILATERAL SURFACE OF HEXA, QUAD8, AND        
C                 PENTA SURFACES ON WHICH PRESSURE LOADS EXIST        
C                 OTHERWISE SURFACE IS TRIANGULAR IF G3 IS ZERO OR      
C                 BLANK, SURFACE IS TRIANGULAR        
C     CID  COORDINATE SYSTEM FOR DEFINITION OF PRESSURE VECTOR        
C     N1,N2,N3 COMPONENTS OF PRESSURE DIRECTION VECTOR IF CID        
C                 'BLANK' OR ZERO, THE PRESSURE ACTS NORMAL TO THE      
C                 SURFACE OF THE ELEMENT        
C        
C     EQUIVALENT NUMERICAL INTEGRATION POINT LOADS PP(III) ARE        
C     OBTAINED VIA BI-LINEAR INTERPOLATION        
C*****        
C     GENERAL INITIALIZATION.        
C*****        
C     BEST(45) IS THE DATA FOR EST WHICH IS READ IN EXTERN AND IS       
C     READY TO BE USED.        
C        
C     READ FROM PLOAD4 CARDS        
C     P1 = PPP(1)        
C     P2 = PPP(2)        
C     P3 = PPP(3)        
C     P4 = PPP(4)        
C     CID,N1,N2,N3        
C*****        
C        
C        
C     X WILL BE THE LENGTH OF THE PRESSURE VECTOR FOR NORMALIZATION.    
C     NV(I) WILL BE THE NORMALIZED PRESSURE VECTOR        
C        
      X = 0.0        
      DO 10 I = 1,4        
   10 PPP(I) = SLT(I+1)        
      DO 20 I = 1,3        
      NV(I)  = SLT(I+8)        
      X = X + NV(I)**2        
   20 CONTINUE        
      CID = ISLT(8)        
C        
      IF (X .EQ. 0.0) GO TO 40        
      X = SQRT( X )        
      DO 30 I = 1,3        
   30 NV(I) = NV(I) / X        
C        
   40 NCRD = 3        
C*****        
C     PERFORM TEST FOR PRESENCE OF CONSTANT PRESSURE SET SWP        
C*****        
      SWP = 1        
      IF (PPP(2).EQ.0. .AND. PPP(3).EQ.0. .AND. PPP(4).EQ.0.)        
     1    SWP = 0        
      NSURF = 4        
C        
C     THE ARRAY IORDER STORES THE ELEMENT NODE ID IN        
C     INCREASING SIL ORDER.        
C        
C     IORDER(1) = NODE WITH LOWEST  SIL NUMBER        
C     IORDER(4) = NODE WITH HIGHEST SIL NUMBER        
C        
C     ELEMENT NODE NUMBER IS THE INTEGER FROM THE NODE LIST G1,G2,G3,G4.
C     THAT IS, THE 'I' PART OF THE 'GI' AS THEY ARE LISTED ON THE       
C     CONNECTIVITY BULK DATA CARD DESCRIPTION.        
C        
      KSILD = 99999995        
      DO 100 I=1,4        
      IORDER(I) = 0        
      KSIL(I) = SIL(I)        
  100 CONTINUE        
      DO 120 I=1,4        
      ITEMP = 1        
      ISIL  = KSIL(1)        
      DO 110 J=2,4        
      IF (ISIL.LE.KSIL(J)) GO TO 110        
      ITEMP = J        
      ISIL  = KSIL(J)        
  110 CONTINUE        
      IORDER(I) = ITEMP        
      KSIL(ITEMP) = 99999999        
  120 CONTINUE        
C*****        
C     ADJUST EST DATA        
C        
C     USE THE POINTERS IN IORDER TO COMPLETELY REORDER THE        
C     GEOMETRY DATA INTO INCREASING SIL ORDER.        
C*****        
      DO 140 I=1,4        
      KSIL(I) = SIL(I)        
      DO 130 J=1,4        
      ITGRID(J,I) = IBGPDT(J,I)        
  130 CONTINUE        
  140 CONTINUE        
      DO 160 I=1,4        
      IPOINT = IORDER(I)        
      SIL(I) = KSIL(IPOINT)        
      DO 150 J=1,4        
      IBGPDT(J,I) = ITGRID(J,IPOINT)        
  150 CONTINUE        
  160 CONTINUE        
C        
      NVCT = NCRD*4        
      EPS  = 0.001        
C*****        
C     SET VALUES FOR NUMERICAL INTEGRATION POINTS AND WEIGHT FACTORS    
C        
C     DEFAULT INTEGRATION ORDER IS 2X2        
C*****        
      NUMINT = 2        
      GAUSS(1) = -0.57735026918962        
      GAUSS(2) = +0.57735026918962        
      WTGAUS(1) = 1.0        
      WTGAUS(2) = 1.0        
C*****        
C     ZERO OUT THE LOAD ROW SET        
C*****        
      DO 170 I=1,NDOF        
      DO 170 J=1,4        
  170 DPE(I,J) = 0.0        
C*****        
C     SET UP THE LOOPS FOR NUMERICAL INTEGRATION        
C*****        
      DO 350 IETA=1,NUMINT        
      ETA = GAUSS(IETA)        
      DO 350 IXSI=1,NUMINT        
      XSI = GAUSS(IXSI)        
      WEIGHT = WTGAUS(IXSI)*WTGAUS(IETA)        
      P = 0.0        
C*****        
C     P1,P2,P3,P4 ARE THE GRID POINT PRESSURE LOADS PER UNIT        
C     AREA FROM THE PLOAD4 CARD.  THESE WILL BE USED WITH A        
C     BILINEAR SHAPE FUNCTION ROUTINE TO CALCULATE THE NODAL        
C     LOADS.        
C        
C     BILINEAR CASE WHERE THE VALUES OF XSI,ETA ARE INPUT IN        
C     EXPLICIT FORM DEPENDING UPON WHICH NUMERICAL INTEGRATION        
C     SCHEME IS BEING USED.        
C        
C        
C     NSURF IS AN INTEGER WHICH KEEPS TRACK OF THE SURFACE TYPE        
C              NSURF = 3 . . .  TRIANGULAR SURFACE        
C              NSURF = 4 . . .  QUADRILATERAL SURFACE        
C        
C*****        
C     CALL SHAPE FCN. ROUTINE FOR THE BILINEAR QUAD4.  INPUT IS        
C     XSI,ETA,III AND EVALUATION OF SHAPE FCN. AT INTEG.PTS        
C     WILL BE PERFORMED.        
C*****        
      CALL Q4SHPS (XSI,ETA,SHP,DSHP)        
C        
      IF (SWP .EQ. 0) P=PPP(1)        
      IF (SWP .EQ. 0) GO TO 200        
C        
      DO 180 III=1,NSURF        
  180 P = P + SHP(III)*PPP(III)        
  200 CONTINUE        
C        
C     SORT THE SHAPE FUNCTIONS AND THEIR DERIVATIVES INTO SIL ORDER.    
C        
      DO 210 I=1,4        
      TMPSHP(I) = SHP(I)        
      DSHPTP(I) = DSHP(I)        
  210 DSHPTP(I+4) = DSHP(I+4)        
      DO 220 I=1,4        
      KK = IORDER(I)        
      SHP (I  ) = TMPSHP(KK)        
      DSHP(I  ) = DSHPTP(KK)        
  220 DSHP(I+4) = DSHPTP(KK+4)        
C*****        
C     COMPUTE THE UNIT NORMALS V3T AT EACH GRID POINT.  THESE WILL      
C     BE USED TO GET COMPONENTS OF PRESSURE VECTOR ACTING NORMAL TO     
C     THE SURFACE.  AREA CALCULATION CHECKS THE GEOMETRY OF THE        
C     ELEMENT.        
C*****        
      DO 230 I=1,3        
      VI(I) = 0.0        
      VJ(I) = 0.0        
      DO 230 J=1,4        
      II=I+1        
      VI(I) = VI(I) + BGPDT(II,J) * DSHP(J)        
  230 VJ(I) = VJ(I) + BGPDT(II,J) * DSHP(J+4)        
C        
C     CHECK FOR USER INPUT VECTOR TO ROTATE LOADS        
C        
      CALL SAXB (VI,VJ,V3T)        
      AREA = SQRT(V3T(1)**2+V3T(2)**2+V3T(3)**2)        
      IF (AREA .GT. 0.0) GO TO 300        
C        
      WRITE (NOUT,240) NEST(1)        
  240 FORMAT ('0*** SYSTEM FATAL ERROR.  BAD GEOMETRY DETECTED FOR ',   
     1        'QUAD4 ELEMENT ',I8,' WHILE PROCESSING PLOAD4 DATA.')     
      NOGO = 1        
      RETURN        
C        
  300 CONTINUE        
      IF (X .EQ. 0.0) GO TO 330        
C        
C     CHECK FOR NON-ZERO CID AND NEED TO ROTATE USER'S VECTOR        
C        
      IF (CID .EQ. 0) GO TO 320        
C        
C     COMPUTE THE LOCATION OF THE INTEGRATION POINT SO THAT WE CAN      
C     ROTATE THE USER VECTOR PER CID. THIS LOCATION REQUIRED ONLY IF    
C     CID IS CYLINDRICAL OR SPHERICAL.        
C        
      LOCATE(1) = 0.        
      LOCATE(2) = 0.        
      LOCATE(3) = 0.        
      DO 310 J=1,4        
      LOCATE(1) = LOCATE(1) + BGPDT(2,J) * SHP(J)        
      LOCATE(2) = LOCATE(2) + BGPDT(3,J) * SHP(J)        
      LOCATE(3) = LOCATE(3) + BGPDT(4,J) * SHP(J)        
  310 CONTINUE        
      CALL GLBBAS (NV(1),NVX(1),LOCATE(1),CID)        
C        
C     NOW ROTATE THE PRESSURE LOAD        
C        
      V3T(1) = NVX(1) * AREA        
      V3T(2) = NVX(2) * AREA        
      V3T(3) = NVX(3) * AREA        
      GO TO 330        
  320 CONTINUE        
C        
C     NOW ROTATE THE PRESSURE LOAD        
C        
      V3T(1) = NV(1) * AREA        
      V3T(2) = NV(2) * AREA        
      V3T(3) = NV(3) * AREA        
  330 CONTINUE        
C        
C*****        
C     COMPUTE THE CONTRIBUTION TO THE LOAD MATRIX FROM THIS        
C     INTEGRATION POINT AS NT * P * V3T        
C*****        
      DO 340 I=1,4        
      DO 340 J=1,NDOF        
  340 DPE(J,I) = DPE(J,I) + WEIGHT * P * SHP(I) * V3T(J)        
  350 CONTINUE        
C*****        
C     END OF NUMERICAL INTEGRATION LOOPS        
C        
C     MOVE DATA FROM REAL ARRAY DPE TO SINGLE PRECISION PE        
C     (NO MOVE, SINCE DPE IS EQUIVALENT TO PE)        
C*****        
C     DO 400 J=1,4        
C     PE(1,J) = DPE(1,J)        
C     PE(2,J) = DPE(2,J)        
C     PE(3,J) = DPE(3,J)        
C 400 CONTINUE        
C*****        
C     ADD ELEMENT LOAD TO OVERALL LOAD.        
C*****        
      JB = 25        
      DO 430 J=1,4        
      JB = JB + 4        
      IF (NEST(JB) .EQ. 0) GO TO 410        
      CALL BASGLB (PE(1,J),PE(1,J),BEST(JB+1),NEST(JB))        
  410 CONTINUE        
      JP = SIL(J) - 1        
      DO 420 I=1,3        
      Z(JP+I) = Z(JP+I) + PE(I,J)        
  420 CONTINUE        
  430 CONTINUE        
      RETURN        
      END        
