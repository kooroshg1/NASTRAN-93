      SUBROUTINE DUPART        
C        
C     DRIVER FOR DMAP MODULE UPARTN        
C        
C     DMAP CALLING SEQUENCE IS        
C     UPARTN    USET,KNN/KFF,KSF,KFS,KSS/C,N,N/C,N,F/C,N,S $        
C        
      INTEGER         USET,SCR1,SUB0,SUB1,IABIT(16),NAME(2),IB(3)       
      COMMON /BLANK / MAJOR(2),SUB0(2),SUB1(2)        
      COMMON /BITPOS/ IBIT(32),IABIT        
      DATA    NAME  / 4HUPAR  ,4HTN   /        
      DATA    USET  , KNN, KFF, KSF, KFS, KSS, SCR1 /        
     1        101   , 102, 201, 202, 203, 204, 301  /        
C        
C        
      NOGO = 0        
C        
C     DECIDE IF CHARACTERS ARE LEGAL BIT NUMBERS        
C        
      IB(1) = MAJOR(1)        
      IB(2) = SUB0(1)        
      IB(3) = SUB1(1)        
C        
      DO 30 J = 1,3        
      DO 20 I = 1,32        
      IF (IB(J) .NE. IABIT(I)) GO TO 20        
      IB(J) = IBIT(I)        
      GO TO 30        
   20 CONTINUE        
C        
C     INVALID        
      CALL MESAGE (59,IB(J),NAME)        
      NOGO = 1        
   30 CONTINUE        
C        
      IF (NOGO .EQ. 1) CALL MESAGE (-7,0,NAME)        
C        
      CALL UPART (USET,SCR1,IB(1),IB(2),IB(3))        
      CALL MPART (KNN,KFF,KSF,KFS,KSS)        
      RETURN        
      END        
