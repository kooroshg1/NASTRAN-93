      SUBROUTINE GRIDIP (GRID,SEQSS,LEN,IPSET,CSET,NO,Z,LLOC)        
C        
C     THIS SUBROUTINE FINDS SETS OF IP NUMBERS AND DEGREE OF FREEDOM    
C     COMPONENT NUMBERS FOR GRID POINTS DEFINED IN A BASIC        
C     SUBSTRUCTURE THAT IS A COMPONENT OF A PSEUDO-STRUCTURE.        
C        
C     ARGUMENTS        
C               GRID   - GRID POINT ID NUMBER        
C               SEQSS  - THE STARTING ADDRESS IN OPEN CORE OF THE       
C                        PSEUDO-STRUCTURE EQSS RECORD        
C               LEN    - LENGTH OF THE EQSS        
C               IPSET  - THE SET OF IP NUMBERS FOR GRID        
C               CSET   - COMPONENTS OF GIVEN IP NUMBER        
C               NO     - THE NUMBER OF IP DEFINED BY GRID        
C        
C        
      EXTERNAL ORF,RSHIFT        
      INTEGER  ORF,RSHIFT,GRID,SEQSS,IPSET(6),CSET(6),POSNO,Z(1)        
      COMMON  /CMBFND/ INAM(2),IERR        
C        
      IERR = 0        
      NENT = LEN/3        
C        
C     SEARCH FOR THE GRID ID IN THE EQSS        
C        
C     NOTE --- FOR RAPID LOCATION OF ALL IP FOR A GIVEN GRID,        
C              THE COMPONENT WORD OF THE EQSS HAS HAD ITS FIRST        
C              SIX BITS PACKED WITH A CODE-  THE FIRST THREE        
C              BITS GIVE THE NUMBER OF THE IP AND THE SECOND        
C              THREE THE TOTAL NO. OF IP.  E.G. 011101 MEANS        
C              THE CURRENT IP IS THE THIRD OF FIVE FOR THIS        
C              GRID ID.        
C        
C        
      CALL BISLOC (*30,GRID,Z(SEQSS),3,NENT,LOC)        
      K = SEQSS + LOC - 1        
      ICODE = RSHIFT(Z(K+2),26)        
C        
C     ICODE CONTAINS SIX BIT CODE        
C        
      POSNO = ICODE/8        
      NOAPP = ICODE - 8*POSNO        
C        
C     POSNO IS THE POSITION NUMBER OF THE GRID WE HAVE FOUND,        
C     NOAPP IS THE TOTAL NUMBER OF APPEARANCES OF THAT GRID.        
C        
      IF (NOAPP .EQ. 0) POSNO = 1        
      IF (NOAPP .EQ. 0) NOAPP = 1        
      ISTART = K - 3*(POSNO-1)        
      LLOC = ISTART        
C        
C     PICK UP RIGHT 26 BITS BY MASK26 FOR CSET(I), INSTEAD OF R/LSHIFT  
C        
      MASK26 = MASKN(26,0)        
C        
      DO 20 I = 1,NOAPP        
      KK = ISTART + 3*(I-1)        
      IPSET(I) = Z(KK+1)        
C     CSET(I)  = RSHIFT(LSHIFT(Z(KK+2),6),6)        
      CSET(I)  = ORF(Z(KK+2),MASK26)        
   20 CONTINUE        
C        
      NO = NOAPP        
      GO TO 40        
   30 IERR = 1        
   40 RETURN        
      END        
