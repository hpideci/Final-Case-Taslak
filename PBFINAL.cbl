       IDENTIFICATION DIVISION.
       PROGRAM-ID. PBFINAL.
       AUTHOR HUSNU CAN PIDECI
      *MADE AS A FINALWORK.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT OUT-FILE   ASSIGN TO OUTFILE
                             STATUS ST-OUT.
           SELECT INP-FILE   ASSIGN TO INPFILE
                             STATUS ST-INP.
       DATA DIVISION.
       FILE SECTION.
       FD  OUT-FILE RECORDING MODE F.
         01  OUT-REC.
           05 OUT-PROCESS-TYPE-O PIC X(04).
           05 OUT-1              PIC X(01).
           05 OUT-ID-O           PIC X(05).
           05 OUT-2              PIC X(01).
           05 OUT-DVZ-O          PIC X(03).
           05 OUT-3              PIC X(04).
           05 OUT-RETURN-CODE-O  PIC X(02).
           05 OUT-4              PIC X(01).
           05 EXPLANATION-O      PIC X(30).
           05 OUT-5              PIC X(01).
           05 OUT-FNAME-FROM     PIC X(15).
           05 OUT-6              PIC X(01).
           05 OUT-FNAME-TO       PIC X(15).
           05 OUT-7              PIC X(01).
           05 OUT-LNAME-FROM     PIC X(15).
           05 OUT-8              PIC X(01).
           05 OUT-LNAME-TO       PIC X(15).

       FD  INP-FILE RECORDING MODE F.
         01  INP-REC.
           05 INP-PROCESS-TYPE     PIC X(01).
           05 INP-KEY.
              10 INP-ID            PIC X(05).
              10 INP-DVZ           PIC X(03).

       WORKING-STORAGE SECTION.
         01  WS-WORK-AREA.
           05 WS-PBEGIDX           PIC X(08) VALUE 'PBEGIDX'.
           05 ST-INP               PIC 9(02).
              88 INP-EOF                     VALUE 10.
              88 INP-SUCCESS                 VALUE 00 97.
           05 ST-OUT               PIC 9(02).
              88 OUT-SUCCESS                 VALUE 00 97.
      *THRU komutu ile 1,2,3 ve 4 değerlerini ws-process-type-valid
      *değişkenine atıyoruz.
           05 WS-PROCESS-TYPE     PIC 9(01).
              88 WS-PROCESS-TYPE-VALID       VALUE 1 THRU 4.
           05 WS-SUB-AREA.
      *Sub programa ne yapacağını söyleyen değişkenler.
              07 WS-SUB-FUNC       PIC 9(01).
                 88 WS-FUNC-READ             VALUE 1.
                 88 WS-FUNC-UPDATE           VALUE 2.
                 88 WS-FUNC-WRITE            VALUE 3.
                 88 WS-FUNC-DELETE           VALUE 4.
                 88 WS-FUNC-OPEN             VALUE 8.
                 88 WS-FUNC-CLOSE            VALUE 9.
              07 WS-SUB-ID         PIC 9(05) COMP-3.
              07 WS-SUB-DVZ        PIC 9(03) COMP.
              07 WS-SUB-RC         PIC 9(02).
              07 WS-SUB-DATA       PIC X(104).
      *Sub programdan aldığımız bilgiyi aktaracağımız yer WS-STRING.
         01  WS-STRING.
           05 WS-PROCES4-TYPE    PIC X(04).
           05 WS-ID              PIC X(05).
           05 WS-DVZ             PIC X(03).
           05 WS-RETURN-CODE     PIC X(02).
           05 WS-EXPLANATION     PIC X(30).
           05 WS-FNAME-FROM      PIC X(15).
           05 WS-FNAME-TO        PIC X(15).
           05 WS-LNAME-FROM      PIC X(15).
           05 WS-LNAME-TO        PIC X(15).
         01  WS-CURRENT-DATE-DATA.
           05  WS-CURRENT-DATE.
               10  WS-CURRENT-YEAR         PIC 9(04).
               10  WS-CURRENT-MONTH        PIC 9(02).
               10  WS-CURRENT-DAY          PIC 9(02).

      *--------------------
       PROCEDURE DIVISION.
       0000-MAIN.
           PERFORM H100-OPEN-FILES
           PERFORM H200-PROCESS UNTIL INP-EOF
           PERFORM H999-PROGRAM-EXIT.
       0000-END. EXIT.

       H100-OPEN-FILES.
           OPEN INPUT  INP-FILE.
           OPEN OUTPUT OUT-FILE.
           IF (NOT INP-SUCCESS)
           DISPLAY 'UNABLE TO OPEN INPFILE: ' ST-INP
           MOVE ST-INP TO RETURN-CODE
           PERFORM H999-PROGRAM-EXIT
           END-IF.
           IF (NOT OUT-SUCCESS)
           DISPLAY 'UNABLE TO OPEN OUTFILE: ' ST-OUT
           MOVE ST-OUT TO RETURN-CODE
           PERFORM H999-PROGRAM-EXIT
           END-IF.
           READ INP-FILE.
           DISPLAY INP-REC.
           IF (NOT INP-SUCCESS)
           DISPLAY 'UNABLE TO READ INPFILE: ' ST-INP
           MOVE ST-INP TO RETURN-CODE
           PERFORM H999-PROGRAM-EXIT
           END-IF.
      *Burda sub programı bir kez çalıştırarak index dosyasını
      *I-O modunda açtırıyorum.
           SET WS-FUNC-OPEN TO TRUE.
           CALL WS-PBEGIDX USING WS-SUB-AREA.
       H100-END. EXIT.

       H200-PROCESS.
      *Inputdan aldığım bilgiyi işleyip sub programını çağırıyorum.
           MOVE INP-PROCESS-TYPE TO WS-PROCESS-TYPE
           IF WS-PROCESS-TYPE-VALID
              EVALUATE WS-PROCESS-TYPE
                 WHEN 1
                   SET WS-FUNC-READ   TO TRUE
                 WHEN 2
                   SET WS-FUNC-UPDATE TO TRUE
                 WHEN 3
                   SET WS-FUNC-WRITE  TO TRUE
                 WHEN 4
                   SET WS-FUNC-DELETE TO TRUE
              END-EVALUATE
           MOVE INP-ID     TO WS-SUB-ID
           MOVE INP-DVZ    TO WS-SUB-DVZ
           MOVE ZEROES     TO WS-SUB-RC
           MOVE SPACES     TO WS-SUB-DATA
           CALL WS-PBEGIDX USING WS-SUB-AREA
           PERFORM H500-WRITE-RECORD
           ELSE
           DISPLAY 'INVALID PROCESS TYPE: ' WS-PROCESS-TYPE
           END-IF.
           READ INP-FILE.
       H200-END. EXIT.

       H500-WRITE-RECORD.
      *Sub programdan geri dönen bilgiyi output dosyasına yazıyorum.
           MOVE WS-SUB-DATA      TO  WS-STRING.
           MOVE WS-PROCES4-TYPE  TO  OUT-PROCESS-TYPE-O.
           MOVE WS-ID            TO  OUT-ID-O.
           MOVE WS-DVZ           TO  OUT-DVZ-O.
           MOVE WS-RETURN-CODE   TO  OUT-RETURN-CODE-O.
           MOVE WS-EXPLANATION   TO  EXPLANATION-O.
           MOVE WS-FNAME-FROM    TO  OUT-FNAME-FROM.
           MOVE WS-FNAME-TO      TO  OUT-FNAME-TO.
           MOVE WS-LNAME-FROM    TO  OUT-LNAME-FROM.
           MOVE WS-LNAME-TO      TO  OUT-LNAME-TO.
           MOVE '-'              TO OUT-1 OUT-2 OUT-4 OUT-5 OUT-6 OUT-7.
           MOVE '-'              TO OUT-8.
           MOVE '-rc:'           TO OUT-3.
           WRITE OUT-REC.
       H500-END. EXIT.

       H999-PROGRAM-EXIT.
           CLOSE INP-FILE
           CLOSE OUT-FILE.
      *Programı kapatırken sub programdaki output dosyasınıda
      *kapatıyorum.
           SET WS-FUNC-CLOSE TO TRUE.
           CALL WS-PBEGIDX USING WS-SUB-AREA.
           STOP RUN.
       H999-END. EXIT.
