//PBFINALJ JOB 1,NOTIFY=&SYSUID.
//***************************************************/
//* Copyright Contributors to the COBOL Programming Course
//* SPDX-License-Identifier: CC-BY-4.0
//***************************************************/
//*Burda sub programımızı derliyoruz.
//COBRUN   EXEC IGYWCL
//COBOL.SYSIN  DD DSN=&SYSUID..CBL(PBEGIDX),DISP=SHR
//LKED.SYSLMOD DD DSN=&SYSUID..LOAD(PBEGIDX),DISP=SHR
//*Burda ana programımızı derliyoruz.
//COBRUN   EXEC IGYWCL
//COBOL.SYSIN  DD DSN=&SYSUID..CBL(PBFINAL),DISP=SHR
//LKED.SYSLMOD DD DSN=&SYSUID..LOAD(PBFINAL),DISP=SHR
//***************************************************/
// IF RC < 5 THEN
//***************************************************/
//*Burda ana programımızın çıkış dosyasıyla aynı isimde bir dosya var ise onu 
//*siliyoruz.
//DELETFO  EXEC PGM=IEFBR14
//FILE01    DD DSN=Z95638.QSAM.FINALO,
//             DISP=(MOD,DELETE,DELETE),SPACE=(TRK,0)
//*Burda ana programımızı çalıştırıyoruz ve o kendi içinde sub programa 
//*zaten erişiyor.
//RUN      EXEC PGM=PBFINAL
//STEPLIB   DD DSN=&SYSUID..LOAD,DISP=SHR
//INPFILE   DD DSN=&SYSUID..QSAM.INP,DISP=SHR
//IDXFILE   DD DSN=&SYSUID..VSAM.FINAL,DISP=SHR
//OUTFILE   DD DSN=&SYSUID..QSAM.FINALO,DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(20,20),RLSE),
//             DCB=(RECFM=FB,LRECL=115,BLKSIZE=0),UNIT=3390
//SYSOUT    DD SYSOUT=*,OUTLIM=15000
//CEEDUMP   DD DUMMY
//SYSUDUMP  DD DUMMY
//***************************************************/
// ELSE
// ENDIF
