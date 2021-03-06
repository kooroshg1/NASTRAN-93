      SUBROUTINE TLDRS (OFFSET,II,TRANS,TRANS1)
C        
C     &    ENTRY TLDRD (DFFSET,II,TRAND,TRAND1)        
C        
C     MODIFIED TO INCLUDE THE EFFECTS OF OFFSET        
C        
      REAL             TRANS(1),TRANS1(36),OFFSET        
      DOUBLE PRECISION TRAND(1),TRAND1(36),DFFSET        
C        
C     SINGLE PRECISION -        
C        
      DO 10 I = 1,36        
   10 TRANS1(I) = 0.0        
C        
      IPOINT = 9*(II-1)        
C        
      DO 30 I = 1,3        
      JPOINT = 6*(I-1)        
      KPOINT = JPOINT  + 21        
      LPOINT = 3*(I-1) + IPOINT        
C        
      DO 20 J = 1,3        
      TRANS1(JPOINT+J) = TRANS(LPOINT+J)        
      TRANS1(KPOINT+J) = TRANS(LPOINT+J)        
   20 CONTINUE        
   30 CONTINUE        
C        
      IF (OFFSET .EQ. 0.0) GO TO 100        
      TRANS1(4) = OFFSET*TRANS(IPOINT+4)        
      TRANS1(5) = OFFSET*TRANS(IPOINT+5)        
      TRANS1(6) = OFFSET*TRANS(IPOINT+6)        
      TRANS1(10)=-OFFSET*TRANS(IPOINT+1)        
      TRANS1(11)=-OFFSET*TRANS(IPOINT+2)        
      TRANS1(12)=-OFFSET*TRANS(IPOINT+3)        
      GO TO 100        
C        
      ENTRY TLDRD (DFFSET,II,TRAND,TRAND1)        
C     ====================================        
C        
C     DOUBLE PRECISION -        
C        
      DO 60 I = 1,36        
   60 TRAND1(I) = 0.0D0        
C        
      IPOINT = 9*(II-1)        
C        
      DO 80 I = 1,3        
      JPOINT = 6*(I-1)        
      KPOINT = JPOINT  + 21        
      LPOINT = 3*(I-1) + IPOINT        
C        
      DO 70 J = 1,3        
      TRAND1(JPOINT+J) = TRAND(LPOINT+J)        
      TRAND1(KPOINT+J) = TRAND(LPOINT+J)        
   70 CONTINUE        
   80 CONTINUE        
C        
      IF (DFFSET .EQ. 0.0D0) GO TO 100        
      TRAND1(4) = DFFSET*TRAND(IPOINT+4)        
      TRAND1(5) = DFFSET*TRAND(IPOINT+5)        
      TRAND1(6) = DFFSET*TRAND(IPOINT+6)        
      TRAND1(10)=-DFFSET*TRAND(IPOINT+1)        
      TRAND1(11)=-DFFSET*TRAND(IPOINT+2)        
      TRAND1(12)=-DFFSET*TRAND(IPOINT+3)        
  100 RETURN        
      END        
