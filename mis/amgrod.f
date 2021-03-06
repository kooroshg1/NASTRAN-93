      SUBROUTINE AMGROD(D,BETA)        
      INTEGER NAME(2),SYSBUF        
      INTEGER SCR1,SCR2,ECORE        
C  D IS REALLY A 2-D ARRAY D(2,NTZS)        
      DIMENSION D(1)        
      COMMON /DLBDY/ NJ1,NK1,NP,NB,NTP,NBZ,NBY,NTZ,NTY,NT0,NTZS,NTYS,   
     *   INC,INS,INB,INAS,IZIN,IYIN,INBEA1,INBEA2,INSBEA,IZB,IYB,       
     *   IAVR,IARB,INFL,IXLE,IXTE,INT121,INT122,IZS,IYS,ICS,IEE,ISG,    
     *   ICG,IXIJ,IX,IDELX,IXIC,IXLAM,IA0,IXIS1,IXIS2,IA0P,IRIA        
     *  ,INASB,IFLA1,IFLA2,ITH1A,ITH2A,        
     *   ECORE,NEXT,SCR1,SCR2,SCR3,SCR4,SCR5        
CZZ   COMMON /ZZDAMB / Z(1)        
      COMMON /ZZZZZZ / Z(1)        
      COMMON /SYSTEM/ SYSBUF        
      DATA NAME /4HAMGR,4HOD  /        
      CALL SSWTCH(30,IPRNT)        
      NFZB = 1        
      NLZB = NBZ        
      NFYB = NB+1-NBY        
      NLYB = NB        
      IBUF1 = ECORE - SYSBUF        
C        
C     CALCULATE DZ ON SCR1        
C        
      IF(NTZS.EQ.0) GO TO 100        
      IF(NEXT+2*NTZS.GT.IBUF1) CALL MESAGE(-8,0,NAME)        
      CALL GOPEN(SCR1,Z(IBUF1),1)        
      IDZDY = 0        
      CALL DZYMAT(D,NFZB,NLZB,NTZS,IDZDY,SCR1,Z(IX),BETA,IPRNT,Z(INB),  
     * Z(INC),Z(IYS),Z(IZS),Z(ISG),Z(ICG),Z(IYB),Z(IZB),Z(INBEA1))      
      CALL CLOSE(SCR1,1)        
  100 IF(NTYS.EQ.0) GO TO 200        
      IF(NEXT+2*NTYS.GT.IBUF1) CALL MESAGE(-8,0,NAME)        
      CALL GOPEN(SCR2,Z(IBUF1),1)        
      IDZDY = 1        
      CALL DZYMAT(D,NFYB,NLYB,NTYS,IDZDY,SCR2,Z(IX),BETA,IPRNT ,Z(INB), 
     * Z(INC),Z(IYS),Z(IZS),Z(ISG),Z(ICG),Z(IYB),Z(IZB),Z(INBEA1))      
      CALL CLOSE(SCR2,1)        
  200 RETURN        
      END        
