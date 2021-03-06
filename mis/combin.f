      SUBROUTINE COMBIN (PG,ILIST,NLIST)        
C        
      INTEGER         SYSBUF,PG,NAME(2),HCFLDS,HCFLD,HCCENS,HCCEN,OTPE, 
     1                REMFLS,REMFL,MCB(7)        
      DIMENSION       ARY(1),ILIST(1),ALPHA(360),LOADN(360),LOADNN(360),
     1                IARY(1),ALPHA1(360),LODC1(7),HEAD(2)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /LOADX / LC,N(13),LODC,MASS        
      COMMON /BLANK / NROWSP        
      COMMON /SYSTEM/ SYSBUF,OTPE,DUM52(52),IPREC        
CZZ   COMMON /ZZSSA1/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /LOADS / NLOAD,IPTR        
      COMMON /ZNTPKX/ A(4),LL,IEOL,IEOR        
      COMMON /PACKX / ITA,ITB,II,JJ,INCUR        
      EQUIVALENCE     (CORE(1),IARY(1),ARY(1))        
C        
C     ALSO COMBINE HCFLD AND REMFL IN MAGNETOSTATIC PROBLEMS        
C        
      DATA    HCFLDS, HCFLD /304,202/        
      DATA    REMFLS, REMFL /305,203/        
      DATA    HCCENS, HCCEN /307,204/        
      DATA    NAME  / 4HCOMB,4HIN   /        
C        
C        
      ITA = 1        
      ITB = IPREC        
      II  = 1        
C        
C     PERFORM CHECKS IN E AND M PROBLEM        
C     IN E AND M PROBLEM, REMFLS AND HCFLDS MUST HAVE THE SAME NUMBER   
C     OF COLUMNS AS PG        
C        
      MCB(1) = REMFLS        
      CALL RDTRL (MCB)        
      NPERMS = 0        
      IF (MCB(1) .LE. 0) GO TO 1        
      NPERMS = MCB(2)        
    1 MCB(1) = HCFLDS        
      CALL RDTRL (MCB)        
      NHC = 0        
      IF (MCB(1) .LE. 0) GO TO 2        
      NHC = MCB(2)        
    2 IF (NHC .NE. NPERMS) GO TO 300        
      IF (NHC .EQ. 0) GO TO 5        
      MCB(1) = PG        
      CALL RDTRL (MCB)        
      IF (NHC .NE. MCB(2)) GO TO 300        
    5 CONTINUE        
      MCB(1) = HCCENS        
      CALL RDTRL (MCB)        
      NS = 0        
      IF (MCB(1) .LE. 0) GO TO 6        
      NS = MCB(2)        
    6 IF (NS .NE. NHC) GO TO 300        
      JJ    = NROWSP        
      INCUR = 1        
      LCORE = LC        
      IBUF1 = LCORE        
      LCORE = LCORE - SYSBUF        
      CALL OPEN (*200,LODC,CORE(LCORE+1),1)        
      CALL FNAME (LODC,HEAD)        
      CALL WRITE (LODC,HEAD,2,1)        
      LCORE = LCORE - SYSBUF        
      CALL OPEN (*190,PG,CORE(LCORE+1),0)        
      CALL MAKMCB (LODC1,LODC,NROWSP,2,IPREC)        
      NLJ = IPTR        
      NL1 = 0        
      DO 160 I = 1,NLOAD        
      DO 10  J = 1,NROWSP        
   10 CORE(J) = 0.0        
      NLJ = NLJ + NL1*2 + 1        
      NL1 = IARY(NLJ)        
      DO 20 K = 1,NL1        
      KK  = NLJ + (K-1)*2 + 1        
      LOADN(K) = IARY(KK)        
      IF (LOADN(K) .LT. 0) GO TO 150        
   20 ALPHA(K) = ARY(KK+1)        
      KK = 1        
      KL = 0        
      DO 60 K = 1,NLIST        
      IF (ILIST(K)) 30,60,30        
   30 KL = KL + 1        
      DO 40 J = 1,NL1        
      IF (LOADN(J)-ILIST(K)) 40,50,40        
   40 CONTINUE        
      GO TO 60        
   50 LOADNN(KK) = KL        
      ALPHA1(KK) = ALPHA(J)        
      KK = KK + 1        
   60 CONTINUE        
      KK = 1        
      DO 140 J = 1,NL1        
      INULL = 0        
      IF (J .NE. 1) GO TO 70        
      CALL SKPREC (PG,1)        
   70 CALL INTPK (*120,PG,0,1,0)        
   80 IF (LOADNN(J)-KK) 90,100,90        
   90 IF (INULL .EQ. 1) GO TO 91        
      IF (IEOR  .EQ. 0) CALL SKPREC (PG,1)        
   91 CONTINUE        
      KK = KK + 1        
      INULL = 0        
      GO TO 70        
  100 IF (INULL .EQ. 1) GO TO 130        
      IF (IEOL) 130,110,130        
  110 CALL ZNTPKI        
      CORE(LL) = CORE(LL) + A(1)*ALPHA1(J)        
      GO TO 100        
  120 INULL = 1        
      GO TO 80        
  130 KK = KK + 1        
  140 CONTINUE        
  150 CALL PACK (CORE,LODC1(1),LODC1)        
      CALL REWIND (PG)        
  160 CONTINUE        
      CALL WRTTRL (LODC1(1))        
      CALL CLOSE  (LODC1(1),1)        
      CALL CLOSE  (PG,1)        
      IF (PG .EQ. HCFLDS) GO TO 170        
      IF (PG .EQ. REMFLS) GO TO 180        
      IF (PG .EQ. HCCENS) RETURN        
C        
C     DO MAGNETOSTATIC FIELDS FOR USE IN EMFLD        
C        
      LODC1(1) = HCFLDS        
      CALL RDTRL (LODC1)        
C        
C     IF HCFLD IS PURGED, SO MUST REMFLS        
C        
      IF (LODC1(2) .LE. 0) RETURN        
      PG   = HCFLDS        
      LODC = HCFLD        
      NROWSP = 3*NROWSP        
      GO TO 5        
C        
C     DO REMFLS        
C        
  170 LODC1(1) = REMFLS        
      CALL RDTRL (LODC1)        
      IF (LODC1(2) .LE. 0) RETURN        
      PG   = REMFLS        
      LODC = REMFL        
      NROWSP = LODC1(3)        
      GO TO 5        
C        
C     HCCENS        
C        
  180 LODC1(1) = HCCENS        
      CALL RDTRL (LODC1)        
      IF (LODC1(2).LE.0) RETURN        
      PG   = HCCENS        
      LODC = HCCEN        
      NROWSP = LODC1(3)        
      GO TO 5        
  190 IP1 = PG        
  195 CALL MESAGE (-1,IP1,NAME)        
  200 IF (LODC .EQ. HCFLD) RETURN        
      IP1 = LODC        
      GO TO 195        
  300 WRITE  (OTPE,350) UFM        
  350 FORMAT (A23,', IN AN E AND M PROBLEM, SCRATCH DATA BLOCKS HCFLDS',
     1       ' AND REMFLS HAVE DIFFERENT NUMBERS OF COLUMNS.', /10X,    
     2       ' THIS MAY RESULT FROM SPCFLD AND REMFLU CARDS HAVING THE',
     3       ' SAME LOAD SET ID')        
      CALL MESAGE (-61,0,0)        
      RETURN        
      END        
