      SUBROUTINE AMPD (QJHUA,QHHO,SKJ,GKI,QHH,SCR1,SCR2,SCR3,SCR4)      
C        
C     THE PURPOSE OF THIS ROUTINE IS TO COMPUTE(OR RETRIEVE) QHH        
C        
C     QHH EITHER EXISTS ON QHHO (AS COLUMN QCOL) OR MUST BE COMPUTED    
C     AS FOLLOWS        
C        
C     1. QKH = SKJ*QJH        
C     2. QIH = GKI(T)*QKH        
C     3. QHH = 1 QIH 1        
C              1-----1        
C              1 0   1        
C              1     1        
C        
      INTEGER         QJHUA,QHHO,SKJ,GKI,QHH,AJJCOL,QHHCOL,SYSBUF,FILE, 
     1                SCR1,SCR2,SCR3,NAME(2),MCB(7),SCR4,QKH        
      COMMON /AMPCOM/ NCOL,NSUB,XM,XK,AJJCOL,QHHCOL,NGP,NGPD(2,30),     
     1                MCBQHH(7),MCBQJH(7),NOH        
CZZ   COMMON /ZZAMPD/ IZ(1)        
      COMMON /ZZZZZZ/ IZ(1)        
      COMMON /SYSTEM/ SYSBUF,NOUT,SKP(52),IPREC        
      COMMON /UNPAKX/ ITC,II,JJ,INCR        
      COMMON /BLANK / NOUE        
      DATA    NAME  / 4HAMPD,4H    /        
C        
      IBUF1 = KORSZ(IZ) - SYSBUF + 1        
      IBUF2 = IBUF1 - SYSBUF        
      INCR  = 1        
      ITC   = MCBQHH(5)        
C        
C     DETERMINE IF QHH EXISTS ON QHHO        
C        
      IF (QHHCOL .EQ. 0) GO TO 100        
C        
C     COPY FROM QHHO TO QHH        
C        
      CALL GOPEN (QHH,IZ(IBUF1),3)        
      CALL GOPEN (QHHO,IZ(IBUF2),0)        
      K = QHHCOL - 1        
      IF (K .EQ. 0) GO TO 20        
      FILE = QHHO        
      DO 10 I = 1,K        
      CALL FWDREC (*910,QHHO)        
   10 CONTINUE        
   20 CONTINUE        
      CALL CYCT2B (QHHO,QHH,NOH,IZ,MCBQHH)        
      CALL CLOSE  (QHHO,1)        
      CALL CLOSE  (QHH,3)        
      RETURN        
C        
C     QHH MUST BE COMPUTED        
C        
  100 CONTINUE        
C        
C     COPY SKJ TO SCR4 FOR PROPER M-K PAIR        
C        
      CALL GOPEN (SKJ,IZ(IBUF1),0)        
      CALL GOPEN (SCR4,IZ(IBUF2),1)        
      K = AJJCOL - 1        
      CALL SKPREC (SKJ,K)        
      MCB(1) = QJHUA        
      CALL RDTRL (MCB)        
      NCOLJ  = MCB(3)        
      MCB(1) = SKJ        
      CALL RDTRL (MCB)        
      MCBQJH(3) = MCB(3)        
      MCB(1) = SCR4        
      MCB(2) = 0        
      MCB(6) = 0        
      MCB(7) = 0        
      ITC = MCB(5)        
      CALL CYCT2B (SKJ,SCR4,NCOLJ,IZ,MCB)        
      CALL CLOSE  (SKJ,1)        
      CALL CLOSE  (SCR4,1)        
      CALL WRTTRL (MCB)        
      CALL SSG2B  (SCR4,QJHUA,0,SCR1,0,IPREC,1,SCR2)        
C        
C     COPY SCR1(QKH) TO OUTPUT        
C        
      QKH = MCBQJH(1)        
      IF (QKH .LE. 0) GO TO 200        
      ITC  = MCBQJH(5)        
      INCR = 1        
      CALL GOPEN  (SCR1,IZ(IBUF1),0)        
      CALL GOPEN  (QKH,IZ(IBUF2),3)        
      CALL CYCT2B (SCR1,QKH,NOH,IZ,MCBQJH)        
      CALL CLOSE  (QKH,3)        
      CALL CLOSE  (SCR1,1)        
  200 CONTINUE        
      CALL SSG2B (GKI,SCR1,0,SCR3,1,IPREC,1,SCR2)        
C        
C     COPY TO QHH        
C        
      CALL GOPEN (QHH,IZ(IBUF1),3)        
      CALL GOPEN (SCR3,IZ(IBUF2),0)        
      ITC  = MCBQHH(5)        
      INCR = 1        
      CALL CYCT2B (SCR3,QHH,NOH,IZ,MCBQHH)        
      CALL CLOSE  (SCR3,1)        
      CALL CLOSE  (QHH,3)        
      RETURN        
C        
C     ERRORS        
C        
  910 IP1 = -2        
      CALL MESAGE (IP1,FILE,NAME)        
      GO TO 910        
      END        
