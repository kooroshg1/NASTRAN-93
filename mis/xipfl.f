      SUBROUTINE XIPFL        
C        
C     THE PURPOSE OF XIOFL IS TO GENERATE THE INPUT AND OUTPUT FILE     
C     SECTIONS FOR AN OSCAR ENTRY.        
C        
      EXTERNAL        ANDF,ORF        
      INTEGER         DMPCNT,DMPPNT,BCDCNT,DMAP,OSPRC,OSBOT,OSPNT,      
     1                OSCAR(1),OS(5),ANDF,ORF        
      COMMON /XGPIC / ICOLD,ISLSH,IEQUL,NBLANK,NXEQUI,        
C                  ** CONTROL CARD NAMES **        
     1                NDIAG,NSOL,NDMAP,NESTM1,NESTM2,NEXIT,        
C                  ** DMAP CARD NAMES **        
     2                NBEGIN,NEND,NJUMP,NCOND,NREPT,NTIME,NSAVE,NOUTPT, 
     3                NCHKPT,NPURGE,NEQUIV,NCPW,NBPC,NWPC,        
     4                MASKHI,MASKLO,ISGNON,NOSGN,IALLON,MASKS(1)        
CZZ   COMMON /ZZXGPI/ CORE(1)        
      COMMON /ZZZZZZ/ CORE(1)        
      COMMON /XGPI2 / LMPL,MPLPNT,MPL(1)        
      COMMON /XGPI4 / IRTURN,INSERT,ISEQN,DMPCNT,        
     1                IDMPNT,DMPPNT,BCDCNT,LENGTH,ICRDTP,ICHAR,NEWCRD,  
     2                MODIDX,LDMAP,ISAVDW,DMAP(1)        
      COMMON /PASSER/ ISTOPF,MODNAM,ICOMON        
      EQUIVALENCE     (CORE(1),OS(1),LOSCAR),(OS(2),OSPRC),        
     1                (OS(3),OSBOT),(OS(4),OSPNT),(OS(5),OSCAR(1))      
C        
C        
C     SET INPUT FILE FLAG        
C        
      IOFL = 1        
      K3   = 0        
      ISTOPF = 0        
      J = MPL(MPLPNT)        
      MPLPNT = MPLPNT + 1        
      IF (J .NE. 0) GO TO 8        
C        
C     NO INPUT FILES - MAKE ONE NULL ENTRY IN OSCAR        
C        
      OSCAR(OSPNT+6) = 1        
      OSCAR(OSPNT+7) = 0        
      OSCAR(OSPNT+8) = 0        
      OSCAR(OSPNT+9) = 0        
      OSCAR(OSPNT) = OSCAR(OSPNT) + 4        
      GO TO 7        
C        
C        
      ENTRY XOPFL        
C     ===========        
C        
C     SET O/P FLAG        
C        
      IOFL = 0        
      K3   = 0        
      ISTOPF = 0        
      J = MPL(MPLPNT)        
      MPLPNT = MPLPNT + 1        
      IF (J .NE. 0) GO TO 8        
C        
C     THERE ARE NO O/P FILES - CHANGE OSCAR ENTRY TYPE CODE TO O FORMAT 
C        
      OSCAR(OSPNT+2) = ORF(2,ANDF(MASKLO,OSCAR(OSPNT+2)))        
      GO TO 7        
C        
C        
C     SCAN INPUT OR OUTPUT SECTION        
C        
    8 I = OSPNT + OSCAR(OSPNT)        
      ISTOPF   = I        
      OSCAR(I) = J        
      OSCAR(OSPNT) = 1 + OSCAR(OSPNT)        
      I = I + 1        
      J = I + 3*(J-1)        
      OSCAR(OSPNT) = J + 3 - OSPNT        
C        
C     ZERO I/O SECTION        
C        
      L = J + 2        
      DO 1 K = I,L        
    1 OSCAR(K) = 0        
C        
C     ENTER FILE NAME IN OSCAR FROM DMAP        
C        
      DO 10 K = I,J,3        
      CALL XSCNDM        
      GO TO (30,2,20,30,20), IRTURN        
C        
C     OK IF NAME RETURNED FROM XSCNDM        
C        
    2 IF (DMAP(DMPPNT) .EQ. NBLANK) GO TO 10        
C        
C     ENTER NAME IN OSCAR AND INITIALIZE ORDNAL        
C        
      OSCAR(K  ) = DMAP(DMPPNT  )        
      OSCAR(K+1) = DMAP(DMPPNT+1)        
      OSCAR(K+2) = 0        
   10 CONTINUE        
    7 CALL XSCNDM        
      GO TO (15,20,20,22,20), IRTURN        
   15 IF (DMAP(DMPPNT+1) .EQ. ISLSH) GO TO 22        
C        
C     NORMAL EXIT IF DMAP OPERATOR IS /        
C        
C     ERROR EXIT        
C     BLANK ITEM IN O/P SECTION OF TYPE O FORMAT IS OKAY        
C        
   20 IF (J.EQ.0 .AND. IOFL.EQ.0 .AND. DMAP(DMPPNT).EQ.NBLANK)        
     1    GO TO 7        
      K1 = 1 + (K-I)/3        
      K2 = 1 + (J-I)/3        
      IF (K1  .LE. K2) GO TO 21        
      IF (K3  .EQ.  1) GO TO 7        
      IF (IOFL .EQ. 1) CALL XGPIDG (62,OSPNT,0,0)        
      IF (IOFL .EQ. 0) CALL XGPIDG (63,OSPNT,0,0)        
      K3 = 1        
      GO TO 7        
   21 IRTURN = 2        
      GO TO 25        
   22 IRTURN = 1        
   25 RETURN        
C        
C        
C     DELIMITER OR END OF INSTRUCTION ENCOUNTERED BEFORE ANTICIPATED -  
C     CHECK FOR ILLEGAL INPUT FORMAT        
C        
   30 IF (IOFL.NE.1 .OR. DMAP(DMPPNT+1).NE.ISLSH) GO TO 20        
      IF (ICOMON .EQ. 0) GO TO 21        
      ITYP = ANDF(OSCAR(OSPNT+2),7)        
      IF (ITYP .EQ. 2) GO TO 22        
C        
C     FIRST INPUT FILE WAS NULL - SHIFT I/P SECTION BY ONE ENTRY AND    
C     ZERO FIRST ENTRY        
C     ISSUE WARNING MESSAGE        
C        
      CALL XGPIDG (-1,OSPNT,0,0)        
      IF (I .EQ. J) GO TO 22        
      I = I + 3        
      J = J + 2        
      DO 32 K = I,J        
      L = J - K + I        
   32 OSCAR(L  ) = OSCAR(L-3)        
      OSCAR(I-3) = 0        
      OSCAR(I-2) = 0        
      OSCAR(I-1) = 0        
      GO TO 22        
      END        
