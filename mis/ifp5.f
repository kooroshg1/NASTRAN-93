      SUBROUTINE IFP5        
C        
C     ACOUSTIC CAVITY PREFACE ROUTINE        
C        
C     THIS PREFACE MODULE OPERATES ON ACOUSTIC-CAVITY-ANALYSIS DATA     
C     CARDS WHICH AT THIS POINT ARE IN THE FORM OF IFP-OUTPUT IMAGES ON 
C     THE AXIC DATA BLOCK.        
C        
C     THE FOLLOWING LIST GIVES THE CARD IMAGES IFP5 WILL LOOK FOR ON THE
C     AXIC OR GEOM2 DATA BLOCKS,  THE CARD IMAGES IFP5 WILL GENERATE OR 
C     MODIFY, AND THE DATA BLOCKS ONTO WHICH THE GENERATED OR MODIFIED  
C     CARD IMAGES WILL BE PLACED.        
C        
C      IFP5 INPUT         IFP5 OUTPUT        DATA BLOCK        
C      CARD IMAGE         CARD IMAGE         EFFECTED        
C     ------------       -----------        ----------        
C      AXSLOT/AXIC        -NONE-             -NONE-        
C      CAXIF2/GEOM2       PLOTEL             GEOM2        
C      CAXIF3/GEOM2       PLOTEL             GEOM2        
C      CSLOT3/GEOM2       PLOTEL             GEOM2        
C      CSLOT4/GEOM2       PLOTEL             GEOM2        
C      CAXIF4/GEOM2       PLOTEL             GEOM2        
C      GRIDF/AXIC         GRID               GEOM1        
C      GRIDS/AXIC         GRID               GEOM1        
C      SLBDY/AXIC         CELAS2             GEOM2        
C        
C     SOME OF THE ABOVE OUTPUT DATA CARDS ARE A FUNCTION OF MORE THAN   
C     ONE INPUT DATA CARDS        
C        
      LOGICAL         G1EOF    ,G2EOF    ,PLOTEL   ,ANY        
      INTEGER         SYSBUF   ,OUTPUT   ,RD       ,RDREW    ,CLS      ,
     1                BUF(24)  ,Z        ,WRT      ,WRTREW   ,CLSREW   ,
     2                CORE     ,SUBR(2)  ,FLAG     ,        
     3                CAXIF(6) ,CSLOT(4) ,GRID(2)  ,CELAS2(2),PLOTLS(2),
     4                CARD(10) ,EOR      ,GRIDS(2) ,GRIDF(2) ,SLBDY(2) ,
     5                WORDS    ,BUF1     ,BUF2     ,BUF3     ,BUF4     ,
     6                FILE     ,GEOM1    ,GEOM2    ,SCRT1    ,SCRT2    ,
     7                AXSLOT(2),MSG1(2)  ,MSG2(2)  ,AXIC     ,ENTRYS    
      REAL            RZ(4)    ,RBUF(24) ,RR(3)    ,ZZ(3)    ,WW(3)    ,
     1                L1       ,L2       ,L3       ,L1L2     ,KF       ,
     2                LE       ,LC       ,RCARD(10)        
      COMMON /CONDAS/ CONSTS(5)        
      COMMON /SYSTEM/ KSYSTM(65)        
      COMMON /NAMES / RD,RDREW ,WRT      ,WRTREW   ,CLSREW   ,CLS       
CZZ   COMMON /ZZIFP5/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      EQUIVALENCE     (CONSTS(2),TWOPI)  ,(KSYSTM(1),SYSBUF),        
     1                (KSYSTM(2),OUTPUT) ,(Z(1),RZ(1)),        
     2                (BUF(1),RBUF(1))   ,(CARD(1),RCARD(1))        
      DATA    AXSLOT/ 1115,   11 /        
      DATA    SLBDY / 1415,   14 /        
      DATA    CAXIF / 2108,   21        
     1              , 2208,   22        
     2              , 2308,   23 /        
      DATA    CELAS2/  701,    7 /        
      DATA    CSLOT / 4408,   44        
     1              , 4508,   45 /        
      DATA    GRID  / 4501,   45 /        
      DATA    GRIDS / 1315,   13 /        
      DATA    GRIDF / 1215,   12 /        
      DATA    PLOTLS/ 5201,   52 /        
      DATA    SUBR  / 4HIFP5, 4H    /        
      DATA    EOR   , NOEOR / 1, 0  /        
C        
C     NOTE...  SCRATCH2 IN IFP5 AS IN IFP4 IS EQUIVALENCED TO THE       
C     -FORCE- DATA BLOCK.        
C        
      DATA AXIC, GEOM1, GEOM2, SCRT1, SCRT2 / 215, 201, 208, 301, 213 / 
      DATA MSG1/ 4HIFP5, 4HBEGN/, MSG2 /4HIFP5, 4HEND /        
C        
C     DEFINE CORE AND BUFFER POINTERS        
C        
      CALL CONMSG (MSG1,2,0)        
      CORE = KORSZ(Z)        
      BUF1 = CORE - SYSBUF - 2        
      BUF2 = BUF1 - SYSBUF - 2        
      BUF3 = BUF2 - SYSBUF - 2        
      BUF4 = BUF3 - SYSBUF - 2        
      CORE = BUF4 - 1        
      ICRQ = 100  - CORE        
      IF (CORE .LT. 100) GO TO 980        
      PLOTEL = .FALSE.        
C        
C     OPEN AXIC DATA BLOCK. (IF NAME IS NOT IN FIST RETURN - NO MESSAGE)
C        
      CALL PRELOC (*910,Z(BUF1),AXIC)        
C        
C     PICK UP THE AXSLOT CARD AND SAVE THE VALUES ON IT.        
C     RHOD, BD, N, WD, MD (FATAL ERROR IF NOT PRESSENT)        
C        
      CALL LOCATE (*10,Z(BUF1),AXSLOT,FLAG)        
      CALL READ (*920,*30,AXIC,Z(1),6,EOR,WORDS)        
   10 CALL IFP5A (1)        
      WRITE  (OUTPUT,20)        
   20 FORMAT (' AXSLOT DATA CARD IS NOT PRESENT OR IS INCORRECT.')      
C        
C     SET VALUES FOR CONTINUING DATA CHECK        
C        
      RHOD = 0.0        
      BD   = 0.0        
      N    = 0        
      WD   = 1.0        
      MD   = 0        
      GO TO 40        
   30 IF (WORDS .NE. 5) GO TO 10        
      RHOD = RZ(1)        
      BD   = RZ(2)        
      J    = 3        
      N    = Z(J)        
      WD   = RZ(4)        
      MD   = Z(J+2)        
C        
C     READ GRIDS DATA CARDS INTO CORE FROM AXIC DATA BLOCK.        
C        
   40 IGRIDS = 1        
      NGRIDS = IGRIDS - 1        
      CALL LOCATE (*70,Z(BUF1),GRIDS,FLAG)        
      CALL READ (*920,*60,AXIC,Z(IGRIDS),CORE,EOR,WORDS)        
      CALL IFP5A (2)        
      WRITE  (OUTPUT,50)        
   50 FORMAT (49H INSUFFICIENT CORE TO HOLD ALL GRIDS CARD IMAGES.)     
      WRITE  (OUTPUT,431) CORE        
      GO TO 70        
   60 NGRIDS = NGRIDS + WORDS        
C        
C     READ GRIDF DATA CARDS INTO CORE FROM AXIC DATA BLOCK.        
C        
   70 IGRIDF = NGRIDS + 1        
      NGRIDF = IGRIDF - 1        
      CALL LOCATE (*100,Z(BUF1),GRIDF,FLAG)        
      CALL READ (*920,*90,AXIC,Z(IGRIDF),CORE-NGRIDS,EOR,WORDS)        
      CALL IFP5A (3)        
      WRITE  (OUTPUT,80)        
   80 FORMAT (49H INSUFFICIENT CORE TO HOLD ALL GRIDF CARD IMAGES.)     
      ICRQ = CORE - NGRIDS        
      WRITE (OUTPUT,431) ICRQ        
      GO TO 100        
   90 NGRIDF = NGRIDF + WORDS        
C        
C     INSERT DEFAULT SLOT WIDTH INTO ANY GRIDS IMAGE HAVING NONE        
C     SPECIFIED BY THE USER.        
C        
  100 IF (NGRIDS .LT. IGRIDS) GO TO 170        
      DO 110 I = IGRIDS,NGRIDS,5        
      IF (Z(I+3) .EQ. 1) RZ(I+3) = WD        
  110 CONTINUE        
C        
C     CREATE A GRIDF CARD FOR EACH GRIDS DATA CARD THAT HAS A NON-ZERO  
C     IDF        
C        
      DO 140 I = IGRIDS,NGRIDS,5        
      IF (Z(I+4)) 140,140,130        
  130 NGRIDF = NGRIDF + 3        
      IF (NGRIDF .GT. CORE) GO TO 150        
      Z(NGRIDF-2) = Z(I+4)        
      Z(NGRIDF-1) = Z(I+1)        
      Z(NGRIDF  ) = Z(I+2)        
  140 CONTINUE        
      GO TO 170        
  150 CALL IFP5A (4)        
      WRITE  (OUTPUT,160)        
  160 FORMAT (' INSUFFICIENT CORE TO HOLD ALL GRIDF CARD IMAGES BEING ',
     1       'CREATED INTERNALLY DUE TO GRIDS CARDS SPECIFYING AN IDF.')
      ICRQ = NGRIDF - CORE        
      WRITE (OUTPUT,431) ICRQ        
      NGRIDF = NGRIDF - 3        
C        
C     SORT THE GRIDF CARDS ON THEIR ID.        
C        
  170 IF (NGRIDF .GT. IGRIDF)        
     1    CALL SORT (0,0,3,1,Z(IGRIDF),NGRIDF-IGRIDF+1)        
C        
C     OPEN GEOM1 AND SCRATCH1, COPY HEADER REC FROM GEOM1 TO SCRATCH1.  
C        
      CALL IFP4C (GEOM1,SCRT1,Z(BUF2),Z(BUF3),G1EOF)        
C        
C     COPY ALL DATA FROM GEOM1 TO SCRATCH1 UP TO FIRST GRID CARD.       
C        
      CALL IFP4B (GEOM1,SCRT1,ANY,Z(NGRIDF+1),CORE-NGRIDF,GRID,G1EOF)   
      FILE = GEOM1        
C        
C     CREATE GRID CARDS FROM GRIDS AND GRIDF CARDS.        
C     MERGE THESE INTO EXISTING GRID CARDS CHECKING FOR DUPLICATE ID-S. 
C        
      IGF  = IGRIDF        
      IDGF = 0        
      IGS  = IGRIDS        
      IDGS = 0        
      IF (IGF .LT. NGRIDF) IDGF = Z(IGF)        
      IF (IGS .LT. NGRIDS) IDGS = Z(IGS)        
      CARD(2) = 0        
      CARD(6) =-1        
      CARD(7) = 0        
      CARD(8) = 0        
C        
C     READ A GRID CARD INTO BUF.        
C        
      IF (.NOT.ANY) GO TO 190        
  180 CALL READ (*940,*190,GEOM1,BUF,8,NOEOR,WORDS)        
      IDG = BUF(1)        
      GO TO 200        
  190 IDG = 0        
C        
C     DETERMINE WHETHER GRID, GRIDF, OR GRIDS CARD IS TO OUTPUT NEXT.   
C        
  200 IF (  IDG    ) 210,210,250        
  210 IF (  IDGF   ) 220,220,230        
  220 IF (  IDGS   ) 390,390,370        
  230 IF (  IDGS   ) 360,360,240        
  240 IF (IDGF-IDGS) 360,330,370        
  250 IF (  IDGF   ) 260,260,280        
  260 IF (  IDGS   ) 350,350,270        
  270 IF (IDG -IDGS) 350,330,370        
  280 IF (IDG -IDGF) 310,330,290        
  290 IF (  IDGS   ) 360,360,300        
  300 IF (IDGF-IDGS) 360,330,370        
  310 IF (  IDGS   ) 360,360,320        
  320 IF (IDG -IDGS) 350,330,370        
C        
C     ERROR - DUPLICATE ID-S ENCOUNTERED        
C        
  330 CALL IFP5A (10)        
      WRITE  (OUTPUT,340) IDG,IDGS,IDGF        
  340 FORMAT (' ONE OF THE FOLLOWING NON-ZERO IDENTIFICATION NUMBERS ', 
     1        'APPEARS ON SOME COMBINATION', /,' OF GRID, GRIDS, OR ',  
     2        'GRIDF BULK DATA CARDS.',3(6H   ID=,I12))        
      IF (IDG .EQ. IDGF) GO TO 350        
      IF (IDG .EQ. IDGS) GO TO 350        
      GO TO 370        
C        
C     OUTPUT GRID CARD AND READ ANOTHER        
C        
  350 CALL WRITE (SCRT1,BUF,8,NOEOR)        
      GO TO 180        
C        
C     OUTPUT A GRID FROM GRIDF CARD.        
C        
  360 CARD(1)  = IDGF        
      RCARD(3) = RZ(IGF+1)        
      RCARD(4) = RZ(IGF+2)        
      RCARD(5) = 0.0        
      IGF = IGF + 3        
      IF (IGF .GT. NGRIDF) IDGF = 0        
      IF (IDGF .NE. 0) IDGF = Z(IGF)        
      GO TO 380        
C        
C     OUTPUT A GRID FROM GRIDS CARD.        
C        
  370 CARD(1)  = IDGS        
      RCARD(3) = RZ(IGS+1)        
      RCARD(4) = RZ(IGS+2)        
      RCARD(5) = RZ(IGS+3)        
      IGS = IGS + 5        
      IF (IGS .GT. NGRIDS) IDGS = 0        
      IF (IDGS .NE. 0) IDGS = Z(IGS)        
  380 CALL WRITE (SCRT1,CARD,8,NOEOR)        
      GO TO 200        
C        
C     ALL GRID CARDS HAVE BEEN OUPTUT, WRITE EOR.        
C        
  390 CALL WRITE (SCRT1,0,0,EOR)        
C        
C     COPY BALANCE OF GEOM1 TO SCRT1, WRAP UP AND COPY BACK.        
C        
      CALL IFP4B (GEOM1,SCRT1,ANY,Z(IGRIDF),CORE-IGRIDF,-1,G1EOF)       
C        
C     SLBDY CARD IMAGES ARE NOW PROCESSED AND A BOUNDARY TABLE IS FORMED
C     IN CORE.  EACH ENTRY IN THE TABLE CONTAINS,        
C        
C              IDS , IDS   , IDS   , RHO, M        
C                 I     I-1     I+1        
C        
C     IDS    = -1 IF IDS  IS THE FIRST ID ON SLBDY CARD.        
C        I-1            I        
C        
C     IDS    = -1 IF IDS  IS THE LAST ID ON SLBDY CARD.        
C        I+1            I        
C        
      ISLBDY = NGRIDS + 1        
      NSLBDY = ISLBDY - 1        
      CALL LOCATE (*440,Z(BUF1),SLBDY,FLAG)        
  400 CALL READ (*920,*440,AXIC,BUF,2,NOEOR,WORDS)        
      RHO = RBUF(1)        
      M   = BUF(2)        
      IDSL1 = -1        
      CALL READ (*920,*930,AXIC,IDS,1,NOEOR,WORDS)        
  410 CALL READ (*920,*930,AXIC,IDSP1,1,NOEOR,WORDS)        
C        
C     PLACE 5 WORD ENTRY INTO CORE        
C        
      NSLBDY = NSLBDY + 5        
      IF (NSLBDY .GT. CORE) GO TO 420        
      Z(NSLBDY-4) = IDS        
      Z(NSLBDY-3) = IDSL1        
      Z(NSLBDY-2) = IDSP1        
      RZ(NSLBDY-1) = RHO        
      Z(NSLBDY   ) = M        
      IDSL1 = IDS        
      IDS   = IDSP1        
      IF (IDSP1+1) 410,400,410        
C        
C     OUT OF CORE        
C        
  420 CALL IFP5A (5)        
      WRITE  (OUTPUT,430)        
  430 FORMAT (' INSUFFICIENT CORE TO CONSTRUCT ENTIRE BOUNDARY TABLE ', 
     1        'FOR SLBDY CARDS PRESENT.')        
      ICRQ = NSLBDY - CORE        
      WRITE  (OUTPUT,431) ICRQ        
  431 FORMAT (5X,24HADDITIONAL CORE NEEDED =,I8,7H WORDS.)        
      NSLBDY = NSLBDY - 5        
C        
C     SKIP BALANCE OF SLBDY DATA.        
C        
      CALL READ (*920,*440,AXIC,BUF,1,EOR,WORDS)        
C        
C     SORT BOUNDARY TABLE ON IDS . (FIRST WORD OF EACH ENTRY)        
C                               I        
C        
  440 IF (NSLBDY .GT. ISLBDY)        
     1    CALL SORT (0,0,5,1,Z(ISLBDY),NSLBDY-ISLBDY+1)        
C/////        
C     CALL BUG (10H BOUNDRY      ,440,Z(ISLBDY),NSLBDY-ISLBDY+1)        
C        
C     OPEN GEOM2, OPEN SCRATCH2, COPY HEADER REC FROM GEOM2 TO SCRATCH2.
C        
      FILE = GEOM2        
      CALL IFP4C (GEOM2,SCRT2,Z(BUF2),Z(BUF3),G2EOF)        
C        
C     OPEN SCRATCH1, FOR TEMPORARY OUTPUT OF PLOTEL IMAGES CREATED FROM 
C     CAXIF2, CAXIF3, CAXIF4, CSLOT3, AND CSLOT4 CARDS.        
C        
      FILE = SCRT1        
      CALL OPEN (*960,SCRT1,Z(BUF4),WRTREW)        
C        
C     CREATE PLOTEL IMAGES FROM CAXIF2, CAXIF3, AND CAXIF4 AT THIS TIME 
C        
      FILE = GEOM2        
      DO 490 I = 1,3        
      IBASE = (I-1)*1000000        
      IF (I .EQ. 3) IBASE = 4000000        
      K  = 2*I - 1        
      K4 = I + 5        
C        
C     CHECK TRAILER TO SEE IF CAXIF(I+1) EXISTS        
C        
      CALL IFP4F (CAXIF(K+1),GEOM2,ANY)        
      IF (.NOT.ANY) GO TO 490        
C        
C     COPY ALL DATA FROM GEOM2 TO SCRATCH2 UP TO FIRST CAXIF(I+1) IMAGE.
C        
      CALL IFP4B(GEOM2,SCRT2,ANY,Z(NSLBDY+1),CORE-NSLBDY,CAXIF(K),G2EOF)
      IF (.NOT.ANY) GO TO 1610        
C        
C     COPY EACH IMAGE TO SCRATCH2 AND CREATE PLOTELS AT SAME TIME.      
C        
  460 CALL READ (*940,*480,GEOM2,BUF,K4,NOEOR,WORDS)        
      CALL WRITE (SCRT2,BUF,K4,NOEOR)        
      NLINES = I + 1        
      IF (I .EQ. 1) NLINES = 1        
      DO 470 J = 1,NLINES        
      CARD(1) = BUF(1) + IBASE + J*1000000        
      CARD(2) = BUF(J+1)        
      JJ = J + 1        
      IF (JJ.GT.NLINES .AND. NLINES.NE.1) JJ = 1        
      CARD(3) = BUF(JJ+1)        
      CALL WRITE (SCRT1,CARD,3,NOEOR)        
  470 CONTINUE        
      PLOTEL = .TRUE.        
      GO TO 460        
C        
C     END OF RECORD HIT ON GEOM2.  COMPLETE RECORD ON SCRATCH2        
C        
  480 CALL WRITE (SCRT2,0,0,EOR)        
  490 CONTINUE        
C        
C     COPY ALL DATA FROM GEOM2 TO SCRATCH2 UP TO FIRST CELAS2 CARD      
C     IMAGE.        
C        
      CALL IFP4B (GEOM2,SCRT2,ANY,Z(NSLBDY+1),CORE-NSLBDY,CELAS2,G2EOF) 
C        
C     COPY ANY CELAS2 DATA CARDS, MAKE SURE ALL ID ARE LESS THAN        
C     10000001.        
C        
      IF (.NOT.ANY) GO TO 540        
  510 CALL READ (*940,*540,GEOM2,BUF,8,NOEOR,WORDS)        
      IF (BUF(1) .LT. 10000001) GO TO 530        
      CALL IFP5A (6)        
      WRITE  (OUTPUT,520) BUF(1)        
  520 FORMAT (' CELAS2 DATA CARD HAS ID =',I14,        
     1  ', WHICH IS GREATER THAN 10000000,', /,' AND 10000000 IS THE ', 
     2  'LIMIT FOR CELAS2 ID WITH ACOUSTIC ANALYSIS DATA CARDS PRESENT')
  530 CALL WRITE (SCRT2,BUF,8,NOEOR)        
      GO TO 510        
C        
C     OUTPUT THREE CELAS2 IMAGES FOR EACH ENTRY IN THE BOUNDARY TABLE.  
C        
  540 IF (NSLBDY .LT. ISLBDY) GO TO 800        
      ENTRYS = (NGRIDS-IGRIDS+1)/5        
C/////        
C     CALL BUG(10H BOUNDRY      ,540,Z(ISLBDY),NSLBDY-ISLBDY+1)        
C     CALL BUG(10H GRIDS        ,540,Z(IGRIDS),NGRIDS-IGRIDS+1)        
      IDE = 10000000        
      DO 790 I = ISLBDY,NSLBDY,5        
C        
C     FIND  R, Z, W FOR IDS , IDS   , IDS    RESPECTIVELY.        
C                          I     I-1     I+1        
C        
      K   = 0        
      IS1 = I        
      IS3 = I + 2        
      DO 600 J = IS1,IS3        
      K = K + 1        
      IF (Z(J)  ) 570,580,550        
  550 IF (ENTRYS) 580,580,560        
  560 KID = Z(J)        
      CALL BISLOC (*580,KID,Z(IGRIDS),5,ENTRYS,JPOINT)        
      NTEMP = IGRIDS + JPOINT        
C        
C     NTEMP NOW POINTS TO THE SECOND WORD OF THE GRIDS ENTRY HAVING     
C     THE ID SPECIFIED BY Z(J).  (1ST,2ND,OR 3RD ID IN SLBDY ENTRY)     
C        
C        
C     NO CELAS2 CARDS ARE GENERATED IF GRIDS FOR IDS  HAS NO IDF.       
C                                                   I        
C        
      IF (K .EQ. 1) IDF = Z(NTEMP+3)        
      IF (K.EQ.1 .AND. IDF.LE.0) GO TO 790        
      RR(K) = RZ(NTEMP  )        
      ZZ(K) = RZ(NTEMP+1)        
      WW(K) = RZ(NTEMP+2)        
      GO TO 600        
C        
C     IDS = -1        
C        
  570 RR(K) = RR(1)        
      ZZ(K) = ZZ(1)        
      WW(K) = WW(1)        
      GO TO 600        
C        
C     IDS COULD NOT BE FOUND IN GRIDS ENTRYS.        
C        
  580 CALL IFP5A (7)        
      WRITE  (OUTPUT,590) Z(J)        
  590 FORMAT (11H SLBDY ID =,I12,        
     1        ' DOES NOT APPEAR ON ANY GRIDS DATA CARD.')        
      RR(K) = 0.0        
      ZZ(K) = 0.0        
      WW(K) = 0.0        
  600 CONTINUE        
C        
C     COMPUTE GEOMETRY AND OTHER DATA.        
C        
      L1 = SQRT((ZZ(3)-ZZ(1))**2 + (RR(3)-RR(1))**2)        
      L2 = SQRT((ZZ(2)-ZZ(1))**2 + (RR(2)-RR(1))**2)        
      L3 = SQRT((ZZ(3)-ZZ(2))**2 + (RR(3)-RR(2))**2)/2.0        
C        
      L1L2 = (L1 + L2)*4.0        
      IF (L1L2) 610,610,630        
C        
C     ERROR, ZERO OR NEGATIVE LENGTH        
C        
  610 CALL IFP5A (8)        
      WRITE  (OUTPUT,620) Z(I),Z(I+1),Z(I+2)        
  620 FORMAT (' ONE OR MORE OF THE FOLLOWING ID-S NOT EQUAL TO -1 HAVE',
     1       ' INCORRECT OR NO GEOMETRY DATA',/3(10X,4HID = ,I10))      
      GO TO 790        
C        
C     COMPUTE W-BAR AND R-BAR        
C        
  630 WBAR = (L1*WW(3) + L2*WW(2))/L1L2 + 0.75*WW(1)        
      RBAR = (L1*RR(3) + L2*RR(2))/L1L2 + 0.75*RR(1)        
C        
      IF (WBAR  ) 640,610,640        
  640 IF (RBAR  ) 650,610,650        
  650 IF (Z(I+4)) 660,740,660        
C        
C     COMPUTE BETA,LC        
C        
  660 BETA = (TWOPI*RBAR)/(FLOAT(Z(I+4))*WBAR)        
      IF (BETA - 1.0) 610,610,670        
  670 BL1 = BETA - 1.0        
      BP1 = BETA + 1.0        
      LC  = WBAR/TWOPI        
      LC  = LC*((BETA+1.0/BETA)*ALOG(BP1/BL1) +        
     1          2.0*ALOG(BP1*BL1/(4.0*BETA)))        
      TERM = 0.01*WBAR        
      LE  = AMAX1(LC,TERM)        
      IF (LE) 680,610,680        
  680 IF (RZ(I+3)) 710,690,710        
  690 CALL IFP5A (9)        
      WRITE  (OUTPUT,700) Z(I)        
  700 FORMAT (' RHO AS SPECIFIED ON SLBDY OR AXSLOT CARD IS 0.0 FOR ID',
     1        ' =',I12)        
      GO TO 790        
C        
C     FIND F  = M, IF N=0 OR N=M/2  OTHERWISE F  = M/2        
C           I                                  I        
C        
  710 IF (N.EQ.0 .OR. 2*N.EQ.Z(I+4)) GO TO 720        
      FI = FLOAT(Z(I+4))/2.0        
      GO TO 730        
  720 FI = Z(I+4)        
  730 KF = (WBAR*L3*FI)/(RZ(I+3)*LE)        
      GO TO 750        
C        
C     M = 0, THUS K  = 0.0        
C                  F        
C        
  740 KF = 0.0        
C        
C                           N WBAR        
C                      SIN( ------ )        
C                           2 RBAR        
C     COMPUTE  ALPHA = --------------        
C                           N WBAR        
C                         ( ------ )        
C                           2 RBAR        
C        
  750 TERM = (FLOAT(N)*WBAR)/(2.0*RBAR)        
      IF (TERM) 760,770,760        
  760 ALPHA = SIN(TERM)/TERM        
      GO TO 780        
  770 ALPHA = 1.0        
C        
C  OUTPUT THE 3 CELAS2 CARDS        
C        
  780 BUF( 1) = IDE + 1        
      RBUF(2) = KF*(1.0 - ALPHA)        
      BUF( 3) = Z(I)        
      BUF( 4) = 0        
      BUF( 5) = 1        
      BUF( 6) = 0        
      BUF( 7) = 0        
      BUF( 8) = 0        
      BUF( 9) = IDE + 2        
      RBUF(10)= KF*ALPHA        
      BUF(11) = Z(I)        
      BUF(12) = IDF        
      BUF(13) = 1        
      BUF(14) = 1        
      BUF(15) = 0        
      BUF(16) = 0        
      BUF(17) = IDE + 3        
      RBUF(18)= KF*ALPHA*(ALPHA - 1.0)        
      BUF(19) = IDF        
      BUF(20) = 0        
      BUF(21) = 1        
      BUF(22) = 0        
      BUF(23) = 0        
      BUF(24) = 0        
      CALL WRITE (SCRT2,BUF,24,NOEOR)        
      IDE = IDE + 3        
  790 CONTINUE        
C        
C     COMPLETE THE CELAS2 RECORD.        
C        
  800 CALL WRITE (SCRT2,0,0,EOR)        
C        
C     CREATE PLOTEL IMAGES FROM CSLOT3, AND CSLOT4 AT THIS TIME IF ANY  
C        
      DO 840 I = 1,2        
      IBASE = 3000000*I + 5000000        
      K  = 2*I - 1        
      K6 = I + 7        
C        
C     CHECK TRAILER BIT TO SEE IF CSLOT(I+2) EXISTS.        
C        
      CALL IFP4F (CSLOT(K+1),GEOM2,ANY)        
      IF (.NOT.ANY) GO TO 840        
C        
C     COPY ALL DATA FROM GEOM2 TO SCRATCH2 UP TO FIRST CSLOT(I+2) IMAGE.
C        
      CALL IFP4B (GEOM2,SCRT2,ANY,Z(IGRIDS),CORE-IGRIDS,CSLOT(K),G2EOF) 
      IF (.NOT.ANY) GO TO 1610        
C        
C     COPY EACH IMAGE TO SCRATCH2 AND CREATE PLOTELS AT SAME TIME.      
C        
  810 CALL READ (*940,*830,GEOM2,BUF,K6,NOEOR,WORDS)        
      CALL WRITE (SCRT2,BUF,K6,NOEOR)        
      NLINES = I + 2        
      DO 820 J = 1,NLINES        
      CARD(1) = BUF(1) + IBASE + J*1000000        
      CARD(2) = BUF(J+1)        
      JJ = J + 1        
      IF (JJ .GT. NLINES) JJ = 1        
      CARD(3) = BUF(JJ+1)        
      CALL WRITE (SCRT1,CARD,3,NOEOR)        
  820 CONTINUE        
      PLOTEL = .TRUE.        
      GO TO 810        
C        
C     END OF RECORD ON GEOM2.  COMPLETE RECORD ON SCRATCH2.        
C        
  830 CALL WRITE (SCRT2,0,0,EOR)        
  840 CONTINUE        
C        
C     APPEND PLOTELS ON SCRATCH1 TO ANY PLOTELS ON GEOM2.        
C     MAKE SURE ALL PLOTEL ID-S ARE .LE. 1000000        
C     /// ID CHECK NOT IN YET.        
C     POSITION TO PLOTELS ON GEOM2 IF ANY ARE ON SCRATCH1        
C        
      IF (.NOT. PLOTEL) GO TO 900        
      CALL IFP4B (GEOM2,SCRT2,ANY,Z(IGRIDS),CORE-IGRIDS,PLOTLS,G2EOF)   
      IF (.NOT.ANY) GO TO 870        
C        
C     BLAST COPY PLOTELS FROM GEOM2 TO SCRATCH2        
C        
  850 CALL READ (*940,*860,GEOM2,Z(IGRIDS),CORE-IGRIDS,NOEOR,WORDS)     
      CALL WRITE (SCRT2,Z(IGRIDS),CORE-IGRIDS,NOEOR)        
      GO TO 850        
  860 CALL WRITE (SCRT2,Z(IGRIDS),WORDS,NOEOR)        
C        
C     CLOSE AND OPEN SCRATCH1 CONTAINING GENERATED PLOTEL IMAGES.       
C        
  870 FILE = SCRT1        
      CALL CLOSE (SCRT1,CLSREW)        
      CALL OPEN (*960,SCRT1,Z(BUF4),RDREW)        
C        
C     BLAST COPY PLOTELS FROM SCRATCH1 TO SCRATCH2.        
C        
  880 CALL READ (*890,*890,SCRT1,Z(IGRIDS),CORE-IGRIDS,NOEOR,WORDS)     
      CALL WRITE (SCRT2,Z(IGRIDS),CORE-IGRIDS,NOEOR)        
      GO TO 880        
  890 CALL WRITE (SCRT2,Z(IGRIDS),WORDS,EOR)        
  900 CALL CLOSE (SCRT1,CLSREW)        
C        
C     ALL PROCESSING OF GEOM2 IS COMPLETE SO COPY BALANCE OF GEOM2 TO   
C     SCRATCH2, WRAP UP, AND COPY BACK.        
C        
      CALL IFP4B (GEOM2,SCRT2,ANY,Z(IGRIDS),CORE-IGRIDS,-1,G2EOF)       
C        
C     ALL PROCESSING COMPLETE.        
C        
  910 CALL CLOSE (AXIC,CLSREW)        
      CALL CONMSG (MSG2,2,0)        
      RETURN        
C        
C     END OF FILE ON AXIC.        
C        
  920 FILE = AXIC        
      GO TO 940        
C        
C     END OF RECORD ON AXIC        
C        
  930 FILE = AXIC        
      IER  = -3        
      GO TO 2000        
C        
C     END OF FILE OR END OF RECORD ON -FILE-.        
C        
  940 IER = -2        
      GO TO 2000        
C        
C     FILE NOT IN FIST        
C        
  960 IER = -1        
      GO TO 2000        
C        
C     INSUFFICIENT CORE        
C        
  980 IER = -8        
      FILE = ICRQ        
      GO TO 2000        
C        
C     BISLOC EXIT        
C        
 1610 IER = -37        
C        
 2000 CALL MESAGE (IER,FILE,SUBR)        
      RETURN        
      END        
