      SUBROUTINE CMRD2D (ITER)        
C        
C     THIS SUBROUTINE CALCULATES THE MODAL TRANSFORMATION MATRIX FOR THE
C     CMRED2 MODULE.        
C        
C     INPUT  DATA        
C     GINO - LAMAMR - EIGENVALUE TABLE FOR SUBSTRUCTURE BEING REDUCED   
C            PHISSR - RIGHT EIGENVECTOR MATRIX FOR SUBSTRUCTURE BEING   
C                     REDUCED        
C            PHISSL - LEFT EIGENVECTOR MATRIX FOR SUBSTRUCTURE BEING    
C                     REDUCED        
C     SOF  - GIMS   - G TRANSFORMATION MATRIX FOR ORIGINAL SUBSTRUCTURE 
C        
C     OUTPUT DATA        
C     GINO - HIM    - MODAL TRANSFORMATION MATRIX        
C        
C     PARAMETERS        
C     INPUT- GBUF   - GINO BUFFERS        
C            INFILE - INPUT FILE NUMBERS        
C            OTFILE - OUTPUT FILE NUMBERS        
C            ISCR   - SCRATCH FILE NUMBERS        
C            KORLEN - LENGTH OF OPEN CORE        
C            KORBGN - BEGINNING ADDRESS OF OPEN CORE        
C            OLDNAM - NAME OF SUBSTRUCTURE BEING REDUCED        
C            NMAX   - MAXIMUM NUMBER OF FREQUENCIES TO BE USED        
C     OUTPUT-MODUSE - BEGINNING ADDRESS OF MODE USE DESCRIPTION ARRAY   
C            NFOUND - NUMBER OF MODAL POINTS FOUND        
C            MODLEN - LENGTH OF MODE USE ARRAY        
C     OTHERS-HIMPRT - HIM PARTITION VECTOR        
C            PPRTN  - PHISS MATRIX PARTITION VECTOR        
C            PHIAM  - PHIAM MATRIX PARTITION        
C            PHIBM  - PHIBM MATRIX PARTITION        
C            PHIIM  - PHIIM MATRIX PARTITION        
C            IPARTN - BEGINNING ADDRESS OF PHISS PARTITION VECTOR       
C            LAMAMR - LAMAMR INPUT FILE NUMBER        
C            PHISS  - PHISS INPUT FILE NUMBER        
C            PPRTN  - PARTITION VECTOR FILE NUMBER        
C            HIMPRT - HIM PARTITION VECTOR FILE NUMBER        
C            GIB    - GIB INPUT FILE NUMBER        
C            PHIAM  - PHIAM PARTITION MATRIX FILE NUMBER        
C            PHIBM  - PHIBM PARTITION MATRIX FILE NUMBER        
C            PHIIM  - PHIIM PARTITION MATRIX FILE NUMBER        
C            HIM    - HIM INPUT FILE NUMBER        
C            HIMSCR - HIM SCRATCH INPUT FILE NUMBER        
C        
      LOGICAL         MODES        
      INTEGER         DRY,GBUF1,GBUF2,GBUF3,SBUF1,SBUF2,SBUF3,OTFILE,   
     1                OLDNAM,Z,TYPIN,TYPEP,FUSET,T,SIGNAB,SIGNC,PREC,   
     2                SCR,UN,UB,UI,RULE,TYPEU,        
     3                PHISS,PPRTN,GIB,PHIAM,PHIBM,PHIIM,HIM,HIMPRT,     
     4                PHISSR,PHISSL,GIBBAR,HIMBAR,HIMSCR,USETMR,HIMTYP, 
     5                DBLKOR,SGLKOR,DICORE        
      DOUBLE PRECISION DZ,DHIMSM,DHIMAG,DPHIM,DHIMG        
      DIMENSION       MODNAM(2),RZ(1),ITRLR(7),DZ(1)        
      CHARACTER       UFM*23        
      COMMON /XMSSG / UFM        
      COMMON /BLANK / IDUM1,DRY,IDUM6,GBUF1,GBUF2,GBUF3,SBUF1,SBUF2,    
     1                SBUF3,INFILE(11),OTFILE(6),ISCR(11),KORLEN,KORBGN,
     2                OLDNAM(2),IDUM4(3),RANGE(2),NMAX,IDUM5,MODES,     
     3                IDUM8,MODUSE,NFOUND,MODLEN,IDUM9,LSTZWD        
CZZ   COMMON /ZZCMRD/ Z(1)        
      COMMON /ZZZZZZ/ Z(1)        
      COMMON /PACKX / TYPIN,TYPEP,IROWP,NROWP,INCRP        
      COMMON /PATX  / LCORE,NSUB(3),FUSET        
      COMMON /MPYADX/ ITRLRA(7),ITRLRB(7),ITRLRC(7),ITRLRD(7),NZ,T,     
     1                SIGNAB,SIGNC,PREC,SCR        
      COMMON /BITPOS/ IDUM3(9),UN,IDUM7(10),UB,UI        
      COMMON /PARMEG/ IA(7),IA11(7),IA21(7),IA12(7),IA22(7),LCR,RULE    
      COMMON /UNPAKX/ TYPEU,IROWU,NROWU,INCRU        
      COMMON /SYSTEM/ IDUM2,IPRNTR        
      EQUIVALENCE     (LAMAMR,INFILE(2)),(PHISSR,INFILE(3)),        
     1                (PHISSL,INFILE(4)),(USETMR,INFILE(6)),        
     2                (PHIAM,ISCR(8)),(HIMSCR,ISCR(7)),(PHIBM,ISCR(9)), 
     3                (GIB,ISCR(8)),(GIBBAR,ISCR(11)),(PHIIM,ISCR(6)),  
     4                (HIMPRT,ISCR(7)),(HIMBAR,ISCR(8)),(PPRTN,ISCR(7)),
     5                (HIM,ISCR(10)),(RZ(1),Z(1)),(DZ(1),Z(1))        
      DATA    MODNAM/ 4HCMRD,4H2D  /        
      DATA    EPSLON/ 1.0E-03/        
      DATA    ITEM  / 4HGIMS /        
      DATA    ISCR7 / 307    /        
C        
C     READ LAMA FILE        
C        
      IF (DRY .EQ. -2) RETURN        
      KORE  = KORBGN        
      IFILE = LAMAMR        
      CALL GOPEN (LAMAMR,Z(GBUF1),0)        
      CALL FWDREC (*170,LAMAMR)        
      LAMWDS = 6        
      IF (MODES) LAMWDS = 7        
      IT = 0        
    2 CALL READ (*160,*4,LAMAMR,Z(KORBGN),LAMWDS,0,NWDS)        
      KORBGN = KORBGN + 6        
      IF (KORBGN .GE. KORLEN) GO TO 180        
      IT = IT + 1        
      GO TO 2        
    4 CALL CLOSE (LAMAMR,1)        
C        
C     ZERO OUT PARTITIONING VECTOR AND SET UP MODE USE DESCRIPTION      
C     RECORD        
C        
      MODEXT   = KORBGN        
      ITRLR(1) = PHISSR        
      IF (ITER .EQ. 2) ITRLR(1) = PHISSL        
      CALL RDTRL (ITRLR)        
      ITPHIS = ITRLR(2)        
      IF (3*ITPHIS+MODEXT .GE. KORLEN) GO TO 180        
      LAMLEN = LAMWDS*ITPHIS        
      NNMAX  = MIN0(NMAX,ITPHIS)        
      MODUSE = MODEXT + ITPHIS        
      IPARTN = MODEXT + 2*ITPHIS        
      MODLEN = ITPHIS        
      DO 10 I = 1,ITPHIS        
      Z(MODUSE+I-1) = 3        
      Z(MODEXT+I-1) = 0        
   10 RZ(IPARTN+I-1) = 0.0        
C        
C     SELECT DESIRED MODES        
C        
      KORBGN = MODEXT + 3*ITPHIS        
      NFOUND = 0        
      DO 20 I = 1,ITPHIS        
      IF (NFOUND .EQ. NNMAX) GO TO 30        
      J = 3 + LAMWDS*(I-1)        
      IF (RZ(KORE+J).LE.RANGE(1) .OR. RZ(KORE+J).GE.RANGE(2)) GO TO 20  
      Z(MODEXT+NFOUND) = I        
      NFOUND = NFOUND + 1        
      Z(MODUSE+I-1)  = 1        
      RZ(IPARTN+I-1) = 1.0        
   20 CONTINUE        
C        
C     PACK OUT PARTITIONING VECTOR        
C        
   30 TYPIN = 1        
      TYPEP = 1        
      IROWP = 1        
      NROWP = ITRLR(2)        
      INCRP = 1        
      IFORM = 2        
      CALL MAKMCB (ITRLR,PPRTN,NROWP,IFORM,TYPIN)        
      CALL GOPEN (PPRTN,Z(GBUF1),1)        
      CALL PACK (RZ(IPARTN),PPRTN,ITRLR)        
      CALL CLOSE (PPRTN,1)        
      CALL WRTTRL (ITRLR)        
      KORBGN = KORBGN - ITPHIS        
C        
C     PARTITION PHISS(R,L) MATRICES        
C        
C        **     **   **         **        
C        *       *   *   .       *        
C        * PHISS * = * 0 . PHIAM *        
C        *       *   *   .       *        
C        **     **   **         **        
C        
      NSUB(1) = ITPHIS - NFOUND        
      NSUB(2) = NFOUND        
      NSUB(3) = 0        
      LCORE   = KORLEN - KORBGN        
      ICORE   = LCORE        
      PHISS   = PHISSR        
      IF (ITER .EQ. 2) PHISS = PHISSL        
      CALL GMPRTN (PHISS,0,0,PHIAM,0,PPRTN,0,NSUB(1),NSUB(2),Z(KORBGN), 
     1             ICORE)        
C        
C     PARTITION PHIAM MATRIX        
C        
C                    **     **        
C                    *       *        
C        **     **   * PHIBM *        
C        *       *   *       *        
C        * PHIAM * = *.......*        
C        *       *   *       *        
C        **     **   * PHIIM *        
C                    *       *        
C                    **     **        
C        
      FUSET = USETMR        
      CALL CALCV (PPRTN,UN,UI,UB,Z(KORBGN))        
      CALL GMPRTN (PHIAM,PHIIM,PHIBM,0,0,0,PPRTN,NSUB(1),NSUB(2),       
     1             Z(KORBGN),ICORE)        
      KHIM = 0        
      IF (IA21(6) .EQ. 0) GO TO 55        
C        
C     COMPUTE MODAL TRANSFORMATION MATRIX        
C        
C        **   **   **     **   **   ** **     **        
C        *     *   *       *   *     * *       *        
C        * HIM * = * PHIIM * - * GIB * * PHIBM *        
C        *     *   *       *   *     * *       *        
C        **   **   **     **   **   ** **     **        
C        
      IF (ITER .EQ. 2) GO TO 40        
      CALL SOFTRL (OLDNAM,ITEM,ITRLR)        
      ITEST = ITRLR(1)        
      IF (ITEST .NE. 1) GO TO 200        
      CALL MTRXI (GIB,OLDNAM,ITEM,0,ITEST)        
      IF (ITEST .NE. 1) GO TO 200        
      ITRLR(1) = GIB        
      GO TO 45        
   40 ITRLR(1) = GIBBAR        
      CALL RDTRL (ITRLR)        
   45 DO 50 I = 1, 7        
      ITRLRA(I) = ITRLR(I)        
      ITRLRB(I) = IA21(I)        
   50 ITRLRC(I) = IA11(I)        
      IFORM = 2        
      IPRC  = 1        
      ITYP  = 0        
      IF (ITRLRA(5).EQ.2 .OR. ITRLRA(5).EQ.4) IPRC = 2        
      IF (ITRLRB(5).EQ.2 .OR. ITRLRB(5).EQ.4) IPRC = 2        
      IF (ITRLRC(5).EQ.2 .OR. ITRLRC(5).EQ.4) IPRC = 2        
      IF (ITRLRA(5) .GE. 3) ITYP = 2        
      IF (ITRLRB(5) .GE. 3) ITYP = 2        
      IF (ITRLRC(5) .GE. 3) ITYP = 2        
      ITYPE = IPRC + ITYP        
      CALL MAKMCB (ITRLRD,HIMSCR,ITRLR(3),IFORM,ITYPE)        
      CALL SOFCLS        
      T      = 0        
      SIGNAB =-1        
      SIGNC  = 1        
      PREC   = 0        
      SCR    = ISCR(7)        
      DBLKOR = KORBGN/2 + 1        
      NZ     = LSTZWD - 2*DBLKOR - 1        
      CALL MPYAD  (DZ(DBLKOR),DZ(DBLKOR),DZ(DBLKOR))        
      CALL WRTTRL (ITRLRD)        
      CALL SOFOPN (Z(SBUF1),Z(SBUF2),Z(SBUF3))        
      I      = ITRLRD(2)        
      II     = ITRLRD(3)        
      IFORM  = ITRLRD(4)        
      HIMTYP = ITRLRD(5)        
      GO TO 60        
C        
C     PHIBM IS NULL, HIM = PHIIM        
C        
   55 HIMSCR = PHIIM        
      I      = IA11(2)        
      II     = IA11(3)        
      IFORM  = IA11(4)        
      HIMTYP = IA11(5)        
      KHIM   = 1        
      DBLKOR = KORBGN/2 + 1        
C        
C     TEST SELECTED MODES        
C        
   60 NCORE = 4*II        
      IF (KHIM .EQ. 0) NCORE = NCORE + 4*IA11(3)        
      IF (KORBGN+NCORE .GE. KORLEN) GO TO 180        
      TYPIN = HIMTYP        
      TYPEP = HIMTYP        
      IROWP = 1        
      NROWP = II        
      INCRP = 1        
      IROWU = 1        
      JHIM  = HIM        
      IF (ITER .EQ. 2) JHIM = HIMBAR        
      CALL GOPEN (HIMSCR,Z(GBUF1),0)        
      IF (KHIM .EQ. 0) CALL GOPEN (PHIIM,Z(GBUF2),0)        
      CALL MAKMCB (ITRLR,JHIM,II,IFORM,HIMTYP)        
      CALL GOPEN  (JHIM,Z(GBUF3),1)        
      NFOUND = 0        
      IT     = I        
      DBLKOR = KORBGN/2 + 1        
      SGLKOR = 2*DBLKOR - 1        
      IF (HIMTYP .EQ. 3) DICORE = ((SGLKOR + 2*II)/2) + 1        
      IF (HIMTYP .EQ. 4) DICORE = DBLKOR + 2*II        
      ICORE = 2*DICORE - 1        
C        
C     UNPACK HIM AND PHIIM COLUMNS        
C        
      DO 140 I = 1,IT        
      TYPEU = HIMTYP        
      INCRU = 1        
      NROWU = II        
      IHIM  = NROWU        
      CALL UNPACK (*110,HIMSCR,DZ(DBLKOR))        
      IF (KHIM .EQ. 1) GO TO 70        
      TYPEU = IA11(5)        
      INCRU = 1        
      NROWU = IA11(3)        
      IPHIM = NROWU        
      CALL UNPACK (*90,PHIIM,DZ(DICORE))        
C        
C     SAVE LARGEST HIM COLUMN VALUE AND CALCULATE MAGNITUDE OF HIM,     
C     PHIIM COLUMNS        
C        
   70 IF (HIMTYP .EQ. 4) GO TO 74        
      ITYPE  = 0        
      HIMSUM = 0.0        
      HIMMAG = 0.0        
      DO 72 J = 1,IHIM        
      K = 1 + 2*(J-1)        
      HIMAG = SQRT((RZ(SGLKOR+K-1)**2) + (RZ(SGLKOR+K)**2))        
      IF (HIMAG .GE. HIMMAG) HIMMAG = HIMAG        
   72 HIMSUM = HIMSUM + (RZ(SGLKOR+K-1)**2) + (RZ(SGLKOR+K)**2)        
      GO TO 78        
   74 ITYPE  = 1        
      DHIMSM = 0.0D0        
      DHIMAG = 0.0D0        
      DO 76 J = 1,IHIM        
      K = 1 + 2*(J-1)        
      DHIMG = DSQRT((DZ(DBLKOR+K-1)**2) + (DZ(DBLKOR+K)**2))        
      IF (DHIMG .GE. DHIMAG) DHIMAG = DHIMG        
   76 DHIMSM = DHIMSM + (DZ(DBLKOR+K-1)**2) + (DZ(DBLKOR+K)**2)        
   78 IF (KHIM    .EQ. 1) GO TO 95        
      IF (IA11(5) .EQ. 4) GO TO 82        
      ITYPE  = ITYPE + 1        
      PHIMSM = 0.0        
      DO 80 J = 1,IPHIM        
      K = 1 + 2*(J-1)        
   80 PHIMSM = PHIMSM + (RZ(ICORE+K-1)**2) + (RZ(ICORE+K)**2)        
      GO TO 85        
   82 ITYPE = ITYPE + 2        
      DPHIM = 0.0D0        
      DO 84 J = 1,IPHIM        
      K = 1 + 2*(J-1)        
   84 DPHIM = DPHIM + (DZ(DICORE+K-1)**2) + (DZ(DICORE+K)**2)        
C        
C     TEST FOR INCLUSION        
C        
   85 GO TO (86,87,88,89), ITYPE        
   86 IF (PHIMSM .EQ. 0.0) GO TO 90        
      IF (SQRT(HIMSUM)/SQRT(PHIMSM) .GE. EPSLON) GO TO 95        
      GO TO 90        
   87 IF (DPHIM .EQ. 0.0) GO TO 90        
      IF (SQRT(HIMSUM)/DSQRT(DPHIM) .GE. EPSLON) GO TO 95        
      GO TO 90        
   88 IF (PHIMSM .EQ. 0.0) GO TO 90        
      IF (DSQRT(DHIMSM)/SQRT(PHIMSM) .GE. EPSLON) GO TO 95        
      GO TO 90        
   89 IF (DPHIM .EQ. 0.0D0) GO TO 90        
      IF (DSQRT(DHIMSM)/DSQRT(DPHIM) .GE. EPSLON) GO TO 95        
C        
C     REJECT MODE        
C        
   90 J = Z(MODEXT+I-1)        
      Z(MODUSE+J-1) = 2        
      GO TO 140        
C        
C     USE MODE        
C        
   95 NFOUND = NFOUND + 1        
C        
C     SCALE HIM COLUMN        
C        
      IHIM = 2*IHIM        
      IF (HIMTYP .EQ. 4) GO TO 104        
      DO 102 J = 1,IHIM        
  102 RZ(SGLKOR+J-1) = RZ(SGLKOR+J-1)/HIMMAG        
      GO TO 130        
  104 DO 106 J = 1,IHIM        
  106 DZ(DBLKOR+J-1) = DZ(DBLKOR+J-1)/DHIMAG        
      GO TO 130        
C        
C     NULL COLUMN        
C        
  110 IHIM = 2*IHIM        
      IF (HIMTYP .EQ. 4) GO TO 114        
      DO 112 J = 1,IHIM        
  112 RZ(SGLKOR+J-1) = 0.0        
      GO TO 130        
  114 DO 116 J = 1,IHIM        
  116 DZ(DBLKOR+J-1) = 0.0D0        
C        
C     PACK HIM COLUMN        
C        
  130 NROWP = NROWU        
      CALL PACK (DZ(DBLKOR),JHIM,ITRLR)        
  140 CONTINUE        
      CALL CLOSE (JHIM,1)        
      IF (KHIM .EQ. 0) CALL CLOSE (PHIIM,1)        
      CALL CLOSE (HIMSCR,1)        
      CALL WRTTRL (ITRLR)        
      KORBGN = KORE        
      IF (KHIM .EQ. 1) HIMSCR = ISCR7        
      RETURN        
C        
C     PROCESS SYSTEM FATAL ERRORS        
C        
  160 IMSG = -2        
      GO TO 190        
  170 IMSG = -3        
      GO TO 190        
  180 IMSG = -8        
      IFILE = 0        
  190 CALL SOFCLS        
      CALL MESAGE (IMSG,IFILE,MODNAM)        
      RETURN        
C        
C     PROCESS MODULE FATAL ERRORS        
C        
  200 GO TO (210,210,220,230,240,260), ITEST        
  210 WRITE (IPRNTR,900) UFM,MODNAM,ITEM,OLDNAM        
      DRY = -2        
      RETURN        
C        
  220 IMSG = -1        
      GO TO 250        
  230 IMSG = -2        
      GO TO 250        
  240 IMSG = -3        
  250 CALL SMSG (IMSG,ITEM,OLDNAM)        
      RETURN        
C        
  260 WRITE (IPRNTR,901) UFM,MODNAM,ITEM,OLDNAM        
      DRY = -2        
      RETURN        
C        
  900 FORMAT (A23,' 6215, MODULE ',2A4,' - ITEM ',A4,        
     1       ' OF SUBSTRUCTURE ',2A4,' PSEUDO-EXISTS ONLY.')        
  901 FORMAT (A23,' 6632, MODULE ',2A4,' - NASTRAN MATRIX FILE FOR I/O',
     1       ' OF SOF ITEM ',A4,', SUBSTRUCRURE ',2A4,', IS PURGED.')   
C        
      END        
