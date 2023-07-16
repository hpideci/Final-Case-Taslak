//VSAMFINJ JOB ' ',CLASS=A,MSGLEVEL=(1,1),MSGCLASS=X,NOTIFY=&SYSUID
//*Oluşturacağımız qsamla aynı isimde bir dosya varsa onu siliyoruz.
//DELET100 EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
  DELETE Z95638.QSAM.QTOQ NONVSAM
  IF LASTCC LE 08 THEN SET MAXCC = 00
//SORT0200 EXEC PGM=SORT
//*Burda aşağıdaki bilgileri içeren bir qsam dosyası oluşturuyoruz.
//SYSOUT   DD SYSOUT=*
//SORTIN   DD *
10002949MUSTAFA        YILMAZ         20230502
10002840MUSTAFA        YILMAZ         20230625
10002978MUSTAFA        YILMAZ         20190301
10001949MEHMET         YILMAZ         20230401
10001840MEHMET         YILMAZ         20230520
10001978M E H M E T    YILMAZ         20230601
10003949A H M E T      COPCU          20230701
10003840AHMET          COPCU          20230615
10003978AHMET          COPCU          20230415
10004949YASAR          OKTEN          20230701
10004840YASAR          OKTEN          20230625
10004978YASAR          OKTEN          20230414
41377949SINA EREN      OZBAYRAM       20230515
41377840SINA EREN      OZBAYRAM       20230630
41377978SINA EREN      OZBAYRAM       20230701
20004949BERZAN         KEMAL          20210715
20004840B E R Z A N    KEMAL          20180913
20004978BERZAN         KEMAL          20230707
//SORTOUT  DD DSN=Z95638.QSAM.QTOQ,
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(5,5),RLSE),
//            DCB=(RECFM=FB,LRECL=60)
//*Burda oluşturacağımız qsam dosyasını sıralıyor,tarihi julian
//*cinsine çeviriyor ve sonuna 15 tane 0 ekliyoruz.
//SYSIN    DD *
  SORT FIELDS=(1,7,CH,A)
  OUTREC FIELDS=(1,38,39,8,Y4T,TOJUL=Y4T,15C'0')
//*
//*Oluşturacağımız qsamla aynı isimde bir dosya varsa onu siliyoruz.
//DELET300 EXEC PGM=IEFBR14
//FILE01    DD DSN=&SYSUID..QSAM.QTOV,
//             DISP=(MOD,DELETE,DELETE),SPACE=(TRK,0)
//*Yukarıda oluşturduğumuz qsam dosyasındaki comp,comp-3 dönüşümlerini yapıyor,
//*yeni dosyamızı farklı bir isimle oluşturuyoruz.
//SORT0400 EXEC PGM=SORT
//SYSOUT   DD SYSOUT=*
//SORTIN   DD DSN=Z95638.QSAM.QTOQ,DISP=SHR
//SORTOUT  DD DSN=Z95638.QSAM.QTOV,
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(5,5),RLSE),
//            DCB=(RECFM=FB,LRECL=47)
//SYSIN DD *
  SORT FIELDS=COPY
    OUTREC FIELDS=(1,5,ZD,TO=PD,LENGTH=3,
                   6,3,ZD,TO=BI,LENGTH=2,
                   9,30,
                   39,7,ZD,TO=PD,LENGTH=4,
                   46,15,ZD,TO=PD,LENGTH=8)
//DELET500 EXEC PGM=IDCAMS
//*Oluşturacağımız vsamla aynı isimde bir dosya varsa onu siliyoruz.
//SYSPRINT DD SYSOUT=*
//SYSIN DD *
  DELETE Z95638.VSAM.FINAL CLUSTER PURGE
  IF LASTCC LE 08 THEN SET MAXCC = 00
  DEF CL ( NAME(Z95638.VSAM.FINAL)      -
           FREESPACE( 20 20 )        -
           SHR( 2,3 )                -
           KEYS(5 0)                 -
           INDEXED SPEED             -
           RECSZ(47 47)              -
           TRK (10 10)               -
           LOG(NONE)                 -
           VOLUME (VPWRKB)           -
           UNIQUE )                  -
   DATA (NAME(Z95638.VSAM.FINAL.DATA))  -
   INDEX ( NAME(Z95638.VSAM.FINAL.INDEX))
//REPRO600 EXEC PGM=IDCAMS
//*Qsam dosyasındaki verileri sınıflandırarak vsam dosyamıza aktarıyoruz.
//SYSPRINT DD SYSOUT=*
//INN001   DD DSN=Z95638.QSAM.QTOV,DISP=SHR
//OUT001   DD DSN=Z95638.VSAM.FINAL,DISP=SHR
//SYSIN    DD *
  REPRO INFILE(INN001) OUTFILE(OUT001)
