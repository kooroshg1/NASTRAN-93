      SUBROUTINE DPD1        
C        
C     DPD1 GENERATES THE GRID POINT LIST-DYNAMICS (GPLD),        
C     USET-DYNAMICS (USETD), AND THE SCALAR INDEX LIST-DYNAMICS(SILD).  
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        ANDF  ,ORF        
      LOGICAL         NODYN ,FIRST        
      DIMENSION       BUF(24)  ,EPOINT(2) ,SEQEP(2)     ,MCB(7)       , 
     1                NAM(2)   ,LOADS(32) ,DLOAD(2)     ,FREQ1(2)     , 
     2                FREQ(2)  ,NOLIN(21) ,TIC(2)       ,        
     3                TSTEP(2) ,TF(2)     ,PSD(2)       ,MSG(3)       , 
     4                EIGR(2)  ,EIGB(2)   ,EIGC(2)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / LUSET ,LUSETD,NOTFL ,NODLT ,NOPSDL,NOFRL ,NONLFT, 
     1                NOTRL ,NOEED ,NOSDT ,NBREP        
      COMMON /NAMES / RD    ,RDREW ,WRT   ,WRTREW,CLSREW        
      COMMON /DPDCOM/ DPOOL ,GPL   ,SIL   ,USET  ,GPLD  ,SILD  ,USETD , 
     1                DLT   ,FRL   ,NLFT  ,TFL   ,TRL   ,PSDL  ,EED   , 
     2                SCR1  ,SCR2  ,SCR3  ,SCR4  ,BUF   ,BUF1  ,BUF2  , 
     3                BUF3  ,BUF4  ,EPOINT,SEQEP ,L     ,KN    ,NEQDYN, 
     4                LOADS ,DLOAD ,FREQ1 ,FREQ  ,NOLIN ,NOGO  ,        
     5                MSG   ,TIC   ,TSTEP ,TF    ,PSD   ,EIGR  ,EIGB  , 
     6                EIGC  ,MCB   ,NAM   ,EQDYN ,SDT   ,INEQ        
      COMMON /BITPOS/ UM    ,UO    ,UR    ,USG   ,USB   ,UL    ,UA    , 
     1                UF    ,US    ,UN    ,UG    ,UE    ,UP    ,UNE   , 
     2                UFE   ,UD        
CZZ   COMMON /ZZDPDX/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /TWO   / TWO(32)        
      COMMON /SYSTEM/ SYSBUF,IOUT  ,KS(37),NBPW        
      EQUIVALENCE     (MSG(2),NGRID)        
C        
C        
C     SET NODYN FLAG TO TRUE IF NO DYNAMIC        
C        
      NODYN  = .FALSE.        
      BUF(1) =  DPOOL        
      CALL RDTRL (BUF)        
      IF (BUF(1) .NE. DPOOL) NODYN = .TRUE.        
C        
C     COMPUTE MAXIMUM EPOINT SIZE ALLOWED BY A COMPUTER WORD        
C        
      FIRST = .TRUE.        
      IF (NODYN) GO TO 1020        
      IMAX = 100000000        
      IF (NBPW .EQ. 32) IMAX =  2147493        
      IF (NBPW .EQ. 36) IMAX = 34359738        
C         2147493=2**31/1000   34359738=2**35/1000        
      MAXZ = IMAX        
      MULT = 1000        
C        
C     READ SECOND RECORD OF THE GPL INTO CORE. CREATE TABLE OF TRIPLES -
C     EXTERNAL GRID NO., SEQ. NO., AND INTERNAL GRID NO.        
C        
C     SEQ.NO.= EXTERNAL GIRD NO. * MULT, OR RESEQUENCED GRID PT. NO.    
C     (A MULTIFICATION FACTOR WAS SAVED IN GPL HEADER RECORD BY GP1,    
C      MULT = 10,100,OR 1000,  AND BY SGEN, MULT = 1000)        
C        
 1020 FILE = GPL        
      IF (LUSET .EQ. 0) GO TO 1023        
      CALL OPEN (*1023,GPL,Z(BUF1),RDREW)        
      CALL READ (*2002,*2001,GPL,Z(1),3,1,FALG)        
      CALL FWDREC (*2002,GPL)        
      I = 3        
      MULT = Z(I)        
      IMAX = (IMAX/MULT)*1000        
      MAXZ = IMAX        
      IGPL = 1        
      J = 1        
      I = IGPL        
 1021 CALL READ (*2002,*1022,GPL,Z(I),2,0,FLAG)        
      Z(I+2) = J        
      I = I + 3        
      J = J + 1        
      GO TO 1021        
 1022 NGPL = I - 3        
      CALL CLOSE (GPL,CLSREW)        
      GO TO 1030        
C        
C     INITIALIZE FOR CASE WHERE NO GRID OR SCALAR PTS EXIST.        
C        
 1023 I = 1        
      IGPL  = 1        
      LUSET = 0        
C        
C     READ EXTRA POINTS (IF ANY). ADD TO TABLE IN CORE.        
C     SET INTERNAL GRID NO. OF EXTRA PTS = 0.        
C        
 1030 IF (NODYN) GO TO 1047        
      FILE = DPOOL        
      CALL PRELOC (*2001,Z(BUF1),DPOOL)        
      IEP  = I        
      NOEP = 0        
      CALL LOCATE (*1045,Z(BUF1),EPOINT,FLAG)        
      NOEP = 1        
 1031 CALL READ (*2002,*1032,DPOOL,Z(I),1,0,FLAG)        
      IF (Z(I) .GT. MAXZ) MAXZ = Z(I)        
      Z(I+1) = MULT*Z(I)        
      Z(I+2) = 0        
      I = I + 3        
      GO TO 1031        
 1032 NEP  = I - 3        
      NGPL = NEP        
C        
C     ONE OR MORE EPOINT WITH VERY LARGE EXTERNAL ID        
C     FATAL IF MULTIPLIER IS 10        
C     IF MULT IS 1000 OR 100, TRY TO SHRINK THE GRID POINT SEQ. NO. BY  
C     10 OR 100 IF POSSIBLE, AND RESET MULT.        
C     IF IT IS NOT POSSIBLE, WE HAVE A FATAL CONDITION 2140C        
C        
      IF (MAXZ .EQ. IMAX) GO TO 1040        
      J = 0        
      IF (MULT .EQ.   10) GO TO 1037        
      MULT = 100        
      IF (MAXZ .GT. 10*IMAX) MULT = 10        
      IMAX = (IMAX/MULT)*1000        
      J = 1000/MULT        
      DO 1035 I = IGPL,NEP,3        
      IF (MOD(Z(I+1),J) .NE. 0) GO TO 1037        
      Z(I+1) = Z(I+1)/J        
 1035 CONTINUE        
      GO TO 1040        
 1037 WRITE  (IOUT,1038) UFM        
 1038 FORMAT (A23,' 2140C, ONE OR MORE EPOINTS WITH  EXTERNAL ID TOO ', 
     1       'LARGE.')        
      IF (J .NE. 0) WRITE (IOUT,1039)        
 1039 FORMAT (/5X,'SUGGESTION - RE-RUN NASTRAN JOB WITH ALL THE EPOINT',
     1        ' EXTERNAL ID''S SMALLER THAN THE LARGEST GRID POINT ID', 
     2        /5X,'OR, REDUCE THE SEQID LEVEL IF SEQGP CARDS WERE USED',
     3        '.  I.E. FROM XXX.X.X TO XXX.X OR XXX')        
      CALL CLOSE (DPOOL,CLSREW)        
      CALL MESAGE (-37,0,NAM)        
C        
C     IF EXTRA POINTS PRESENT, READ SEQEP DATA (IF ANY).        
C     REPLACE OLD SEQ NO WITH NEW SEQ NO.        
C        
 1040 CALL LOCATE (*1045,Z(BUF1),SEQEP,FLAG)        
      N1 = I        
      N2 = N1 + 1        
      IFAIL = 0        
 2010 CALL READ (*2002,*2020,DPOOL,Z(N2),BUF1-1,1,FLAG)        
      IFAIL = IFAIL + 1        
      GO TO 2010        
 2020 IF (IFAIL .EQ. 0) GO TO 2060        
      NWDS = (IFAIL-1)*(BUF1-1) + FLAG        
      WRITE  (IOUT,2040) UFM,NWDS        
 2040 FORMAT (A23,' 3139, UNABLE TO PROCESS SEQEP DATA IN SUBROUTINE ', 
     1       'DPD1 DUE TO INSUFFICIENT CORE.', //5X,        
     2       'ADDITIONAL CORE REQUIRED =',I10,7H  WORDS)        
      CALL MESAGE (-61,0,0)        
C        
C     CHECK FOR MULTIPLE REFERENCES TO EXTRA POINT ID NOS. AND        
C     SEQUENCE ID NOS. ON SEQEP CARDS        
C        
 2060 K  = N2        
      KK = N2 + FLAG - 1        
      JJ = KK - 2        
 2080 DO 2285 I = K,JJ,2        
      IF (Z(I).LT.0 .OR. I.GE.KK) GO TO 2275        
      II = I + 2        
      IFAIL = 0        
      DO 2270 J = II,KK,2        
      IF (Z(I) .NE. Z(J)) GO TO 2270        
      IF (IFAIL .NE.   0) GO TO 2260        
      IFAIL = 1        
      NOGO  = 1        
      IF (K .NE. N2) GO TO 2110        
      WRITE  (IOUT,2100) UFM,Z(I)        
 2100 FORMAT (A23,' 3140, MULTIPLE REFERENCES TO EXTRA POINT ID NO.',I9,
     1       ' ON SEQEP CARDS.')        
      GO TO 2260        
 2110 IDSEQ1 = Z(I)/1000        
      IRMNDR = Z(I) - 1000*IDSEQ1        
      IF (IRMNDR.NE.0 .AND. MULT.GE.10) GO TO 2140        
      WRITE  (IOUT,2120) UFM,IDSEQ1        
 2120 FORMAT (A23,' 3141, MULTIPLE REFERENCES TO SEQUENCE ID NO.',I6,6X,
     1       'ON SEQEP CARDS.')        
      GO TO 2260        
 2140 IDSEQ2 = IRMNDR/100        
      IRMNDR = IRMNDR - 100*IDSEQ2        
      IF (IRMNDR.NE.0 .AND. MULT.GE.100) GO TO 2180        
      WRITE  (IOUT,2160) UFM,IDSEQ1,IDSEQ2        
 2160 FORMAT (A23,' 3141, MULTIPLE REFERENCES TO SEQUENCE ID NO.',I6,   
     1       1H.,I1,6X,'ON SEQEP CARDS.')        
      GO TO 2260        
 2180 IDSEQ3 = IRMNDR/10        
      IRMNDR = IRMNDR - 10*IDSEQ3        
      IF (IRMNDR .NE. 0) GO TO 2220        
      WRITE  (IOUT,2200) UFM,IDSEQ1,IDSEQ2,IDSEQ3        
 2200 FORMAT (A23,' 3141, MULTIPLE REFERENCES TO SEQUENCE ID NO.',I6,   
     1        1H.,I1,1H.,I1,4X,'ON SEQEP CARDS.')        
      GO TO 2260        
 2220 WRITE  (IOUT,2240) UFM,IDSEQ1,IDSEQ2,IDSEQ3,IRMNDR        
 2240 FORMAT (A23,' 3141, MULTIPLE REFERENCES TO SEQUENCE ID NO.',I6,   
     1        1H.,I1,1H.,I1,1H.,I1,'  ON SEQEP CARDS.')        
 2260 Z(J) = -Z(J)        
 2270 CONTINUE        
C        
 2275 IF (JJ.LT.KK .OR. MULT.EQ.1 .OR. MULT.EQ.1000) GO TO 2285        
      L = Z(I)        
      IF (MULT   .EQ.   10) GO TO 2280        
      IF (MOD(L,10) .NE. 0) GO TO 2276        
      Z(I) = L / 10        
      GO TO 2285        
 2276 IF (.NOT.FIRST) GO TO 2285        
      FIRST = .FALSE.        
      NOGO  = 1        
      WRITE  (IOUT,2277) UFM        
 2277 FORMAT (A23,' 2140B, ILLEGAL DATA IN SEQEP CARD, POSSIBLY CAUSED',
     1       ' BY LARGE GRID OR SCALAR POINTS')        
      GO TO 2285        
 2280 IF (MOD(L,100) .NE. 0) GO TO 2276        
      Z(I) = L / 100        
 2285 CONTINUE        
C        
      IF (K .NE. N2) GO TO 2290        
      JJ = KK        
      K  = K + 1        
      GO TO 2080        
C        
 2290 DO 2300 I = N2,KK,2        
      IF (Z(I) .LT. 0) Z(I) = -Z(I)        
 2300 CONTINUE        
      IF (NOGO .EQ. 1) GO TO 2400        
C        
C     CHECK TO SEE IF ANY SEQUENCE ID NO. ON SEQEP CARDS IS THE SAME    
C     AS AN EXTRA POINT ID NO. THAT HAS NOT BEEN RESEQUENCED        
C        
      DO 2390 I = K,KK,2        
      IF (Z(I) .LT. 0) GO TO 2390        
      IDSEQ1 = Z(I) / MULT        
      IRMNDR = Z(I) - MULT*IDSEQ1        
      IF (IRMNDR .NE. 0) GO TO 2390        
      DO 2320 J = N2,KK,2        
      IF (IDSEQ1 .EQ. Z(J)) GO TO 2390        
 2320 CONTINUE        
      DO 2340 J = 1,N1,3        
      IF (IDSEQ1 .EQ. Z(J)) GO TO 2360        
 2340 CONTINUE        
      GO TO 2390        
 2360 NOGO = 1        
      WRITE  (IOUT,2380) UFM,IDSEQ1        
 2380 FORMAT (A23,' 3142, SEQUENCE ID NO.',I6,        
     1       '  ON SEQEP CARDS IS THE SAME AS AN ', /5X,        
     2       'EXTRA POINT ID NO. THAT HAS NOT BEEN RESEQUENCED.')       
 2390 CONTINUE        
 2400 CONTINUE        
      I = -1        
 1043 I = I + 2        
      IF (I .GT. FLAG) GO TO 1045        
      BUF(1) = Z(N2+I-1)        
      BUF(2) = Z(N2+I  )        
      DO 1041 J = IEP,NEP,3        
      IF (Z(J) .EQ. BUF(1)) GO TO 1042        
 1041 CONTINUE        
 1044 BUF(2) = 0        
      CALL MESAGE (30,64,BUF)        
      NOGO = 1        
      GO TO 1043        
 1042 IF (Z(J+2) .NE. 0) GO TO 1044        
      Z(J+1) = BUF(2)        
      GO TO 1043        
 1045 CALL CLOSE (DPOOL,CLSREW)        
 1047 IF (LUSET+NOEP .EQ. 0) GO TO 2004        
C        
C     IF EXTRA POINTS PRESENT, SORT THE GPL ON SEQ NO.        
C     REPLACE SEQ NO WITH INTERNAL GRID NO FOR DYNAMICS.        
C        
      N = NGPL + 2        
      IF (NOEP .NE. 0) CALL SORT (0,0,3,2,Z,N)        
      I   = 2        
      Z(I)= 1        
      IF (NGPL .EQ. 1) GO TO 1060        
      DO 1052 I = 4,NGPL,3        
 1052 Z(I+1) = Z(I-2) + 1        
C        
C     WRITE THE GPLD.        
C        
 1060 FILE = GPLD        
      CALL OPEN  (*2001,GPLD,Z(BUF1),WRTREW)        
      CALL FNAME (GPLD,BUF)        
      CALL WRITE (GPLD,BUF,2,1)        
      DO 1061 I = IGPL,NGPL,3        
 1061 CALL WRITE (GPLD,Z(I),1,0)        
      CALL WRITE (GPLD,0,0,1)        
      CALL CLOSE (GPLD,CLSREW)        
      MCB(1) = GPLD        
      MCB(2) = N/3        
      CALL WRTTRL (MCB)        
      KN= MCB(2)        
C        
C     OPEN SILD AND USETD. WRITE HEADER RECORDS.        
C     OPEN SIL  AND USET.  SKIP  HEADER RECORD.        
C     READ SIL INTO CORE.        
C        
      FILE = SILD        
      CALL OPEN  (*2001,SILD,Z(BUF1),WRTREW)        
      CALL FNAME (SILD,BUF)        
      CALL WRITE (SILD,BUF,2,1)        
      IF (LUSET .EQ. 0) GO TO 1082        
      FILE = SIL        
      CALL OPEN (*2001,SIL,Z(BUF2),RDREW)        
      CALL FWDREC (*2002,SIL)        
      ISIL = NGPL + 3        
      CALL READ (*2002,*1081,SIL,Z(ISIL),BUF3-ISIL,1,N)        
      CALL MESAGE (-8,0,NAM)        
 1081 CALL CLOSE  (SIL,CLSREW)        
      NSIL = ISIL + N        
      Z(NSIL)= LUSET + 1        
 1082 FILE = USETD        
      CALL OPEN  (*2001,USETD,Z(BUF3),WRTREW)        
      CALL FNAME (USETD,BUF)        
      CALL WRITE (USETD,BUF,2,1)        
      IF (LUSET .EQ. 0) GO TO 1100        
      FILE = USET        
      CALL OPEN (*2001,USET,Z(BUF2),RDREW)        
      CALL FWDREC (*2002,USET)        
C        
C     INITIALIZE DISPLACEMENT SET BIT MASKS.        
C        
 1100 I = IGPL        
      J = ISIL - 1        
      NBREP = 0        
      BUF(10) = 1        
      DO 1101 K = 2,7        
 1101 MCB(K) = 0        
      MSKUA  = TWO(UA)        
      MSKUN  = TWO(UN)        
      MSKUF  = TWO(UF)        
      MSKUE  = TWO(UE)        
      MSKUP  = TWO(UP)        
      MSKUD  = TWO(UD)        
      MSKUNE = TWO(UNE)        
      MSKUFE = TWO(UFE)        
      MUSETD = ORF(MSKUE,ORF(MSKUNE,ORF(MSKUFE,ORF(MSKUD,MSKUP))))      
C        
C     TEST FOR CURRENT POINT IN G-SET OR IN P-SET (EXTRA POINT).        
C        
 1110 IF (Z(I+2) .EQ. 0) GO TO 1130        
C        
C     POINT IS IN G-SET - READ USET MASKS BELONGING TO POINT.        
C     TURN ON APPROPRIATE BITS FOR P-SET. WRITE MASKS ON USETD.        
C        
      J = J + 1        
      M = Z(J+1) - Z(J)        
      CALL READ (*2002,*2003,USET,BUF,M,0,FLAG)        
      DO 1121 K = 1,M        
      KSW = ORF(BUF(K),MSKUP)        
      IF (ANDF(KSW,MSKUA) .NE. 0) KSW = ORF(KSW,MSKUD )        
      IF (ANDF(KSW,MSKUN) .NE. 0) KSW = ORF(KSW,MSKUNE)        
      IF (ANDF(KSW,MSKUF) .NE. 0) KSW = ORF(KSW,MSKUFE)        
      MCB(5) = ORF(MCB(5),KSW)        
 1121 BUF(K) = KSW        
      CALL WRITE (USETD,BUF,M,0)        
      GO TO 1140        
C        
C     POINT IS AN EXTRA POINT - WRITE MASK ON USETD.        
C        
 1130 CALL WRITE (USETD,MUSETD,1,0)        
      MCB(5) = ORF(MCB(5),MUSETD)        
      M = 1        
C        
C     REPLACE INTERNAL DYNAMICS NO. WITH SILD NO. WRITE SILD ENTRY.     
C     REPLACE INTERNAL STATICS NO. WITH SIL NO.        
C        
 1140 Z(I+1) = BUF(10)        
      CALL WRITE (SILD,Z(I+1),1,0)        
      IF (Z(I+2) .EQ. 0) GO TO 1141        
      Z(I+2) = Z(J)        
      GO TO 1150        
 1141 NBREP = NBREP + 1        
C        
C     TEST FOR COMPLETION.        
C        
 1150 BUF(10) = BUF(10) + M        
      I = I + 3        
      IF (I .LE. NGPL) GO TO 1110        
C        
C     WRITE SECOND RECORD OF SILD (PAIRS OF SIL NO., SILD NO.)        
C        
      CALL WRITE (SILD,0,0,1)        
      CALL WRITE (USETD,0,0,1)        
      DO 1088 I = IGPL,NGPL,3        
      IF (Z(I+2) .EQ. 0) GO TO 1088        
      BUF(1) = Z(I+2)        
      BUF(2) = Z(I+1)        
      CALL WRITE (SILD,BUF,2,0)        
 1088 CONTINUE        
C        
C     CLOSE FILES AND WRITE TRAILERS.        
C        
      CALL CLOSE (SILD ,CLSREW)        
      CALL CLOSE (USETD,CLSREW)        
      MCB(1) = SILD        
      LUSETD = LUSET + NBREP        
      MCB(2) = LUSETD        
      MCB(3) = NBREP        
      CALL WRTTRL (MCB)        
      MCB(1) = USETD        
      CALL WRTTRL (MCB)        
      MCB(5) = 0        
      CALL CLOSE (USET,CLSREW)        
C        
C     REPLACE SIL NO. IN TABLE WITH CODED SILD NO.        
C     THEN SORT TABLE ON EXTERNAL GRID NO.        
C        
      Z(NGPL+4) = LUSETD + 1        
      DO 1091 I = IGPL,NGPL,3        
      J = 1        
      IF (Z(I+4)-Z(I+1) .NE. 1) GO TO 1091        
      J = 2        
      IF (Z(I+2) .EQ. 0) J = 3        
 1091 Z(I+2) = 10*Z(I+1) + J        
      CALL SORT (0,0,3,1,Z(IGPL),NGPL-IGPL+3)        
C        
C     WRITE EQDYN DATA BLOCK. FIRST RECORD IS PAIRS OF EXTERNAL GRID NO,
C     SILD NO. SECOND RECORD IS PAIRS OF EXTERNAL GRID NO., CODED SILD  
C     NO.        
C        
      FILE = EQDYN        
      CALL OPEN  (*2001,EQDYN,Z(BUF1),WRTREW)        
      CALL FNAME (EQDYN,BUF)        
      CALL WRITE (EQDYN,BUF,2,1)        
      DO 1094 I = IGPL,NGPL,3        
 1094 CALL WRITE (EQDYN,Z(I),2,0)        
      CALL WRITE (EQDYN,0,0,1)        
      DO 1095 I = IGPL,NGPL,3        
      BUF(1) = Z(I  )        
      BUF(2) = Z(I+2)        
 1095 CALL WRITE (EQDYN,BUF,2,0)        
      CALL WRITE (EQDYN,0,0,1)        
      CALL CLOSE (EQDYN,CLSREW)        
      MCB(1) = EQDYN        
      MCB(2) = KN        
      CALL WRTTRL (MCB)        
      NEQDYN = 2*KN - 1        
      IF (NBREP .EQ. 0) NBREP = -1        
      RETURN        
C        
C     FATAL FILE ERRORS        
C        
 2001 N = -1        
      GO TO 2005        
 2002 N = -2        
      GO TO 2005        
 2003 N = -3        
      GO TO 2005        
 2004 N = -30        
      FILE = 109        
 2005 CALL MESAGE (N,FILE,NAM)        
      RETURN        
      END        
