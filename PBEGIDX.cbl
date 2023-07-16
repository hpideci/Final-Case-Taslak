       IDENTIFICATION DIVISION.
       PROGRAM-ID. PBEGIDX.
       AUTHOR HUSNU CAN PIDECI
      *MADE AS A FINALWORK.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT IDX-FILE   ASSIGN IDXFILE
                             ORGANIZATION INDEXED
                             ACCESS RANDOM
                             RECORD KEY IDX-KEY
                             STATUS ST-IDX.
       DATA DIVISION.
       FILE SECTION.
       FD  IDX-FILE.
         01  IDX-REC.
           05 IDX-KEY.
              10 IDX-ID         PIC S9(05) COMP-3.
              10 IDX-DVZ        PIC S9(03) COMP.
           05 IDX-NAME          PIC X(15).
           05 IDX-SURNAME       PIC X(15).
           05 IDX-ODATE         PIC S9(07) COMP-3.
           05 IDX-BALANCE       PIC S9(15) COMP-3.

       WORKING-STORAGE SECTION.
         01  WS-WORK-AREA.
           05 ST-IDX               PIC 9(02).
              88 IDX-SUCCESS                 VALUE 00 97.

         01  WS-REC.
           05 WS-PROCESS-TYPE   PIC X(04).
           05 WS-ID             PIC 9(05).
           05 WS-DVZ            PIC 9(03).
           05 WS-RETURN-CODE    PIC 9(02).
           05 WS-EXPLANATION    PIC X(30).
           05 WS-FNAME-FROM     PIC X(15).
           05 WS-FNAME-TO       PIC X(15).
           05 WS-LNAME-FROM     PIC X(15).
           05 WS-LNAME-TO       PIC X(15).

         01 WS-FUNCTION         PIC 9(01).
            88 WS-FUNC-READ             VALUE 1.
            88 WS-FUNC-UPDATE           VALUE 2.
            88 WS-FUNC-WRITE            VALUE 3.
            88 WS-FUNC-DELETE           VALUE 4.
            88 WS-FUNC-OPEN             VALUE 8.
            88 WS-FUNC-CLOSE            VALUE 9.

         01 WS-CALC.
           05 WS-IND1  PIC 99 VALUE 1.
           05 WS-IND2  PIC 99 VALUE 1.

       LINKAGE SECTION.
         01  LD-AREA.
           05 LD-FUNCTION        PIC 9(01).
           05 LD-KEY.
              10 LD-ID           PIC S9(05) COMP-3.
              10 LD-DVZ          PIC S9(03) COMP.
           05 LD-RETURNCODE      PIC 9(02).
           05 LD-DATA            PIC X(104).

      *--------------------
       PROCEDURE DIVISION USING LD-AREA.
       0000-MAIN.
           PERFORM H100-PROCESS-SELECTION.
       0000-END. EXIT.

       H100-PROCESS-SELECTION.
      *Ana programdan gelen bilgiye göre işlem seçimi yapılıyor.
           MOVE LD-FUNCTION TO WS-FUNCTION
           EVALUATE TRUE
              WHEN WS-FUNC-OPEN
                  PERFORM H300-OPEN-FILES
                  GOBACK
              WHEN WS-FUNC-READ
                  PERFORM H320-READ-FOR-INFO
                  GOBACK
              WHEN WS-FUNC-UPDATE
                  PERFORM H330-UPDATE
                  GOBACK
              WHEN WS-FUNC-WRITE
                  PERFORM H340-WRITE
                  GOBACK
              WHEN WS-FUNC-DELETE
                  PERFORM H350-DELETE
                  GOBACK
      *Eğer işlem seçimi 9 ise paragrafa gerek duymadım ve close yaptım.
              WHEN WS-FUNC-CLOSE
                  CLOSE IDX-FILE
                  GOBACK
           END-EVALUATE.
       H100-END. EXIT.

       H200-READ.
      *Idx file'ı okuduğum yer.
           MOVE LD-ID   TO IDX-ID
           MOVE LD-DVZ  TO IDX-DVZ
           READ IDX-FILE KEY IDX-KEY
           INVALID KEY PERFORM H220-INVALID-KEY GOBACK
           END-READ.
       H200-END. EXIT.

       H220-INVALID-KEY.
      *Idx file'da aranan kayıt yoksa program buraya düşüyor.
           MOVE SPACES TO WS-REC.
           MOVE IDX-ID  TO WS-ID.
           MOVE IDX-DVZ TO WS-DVZ.
           MOVE ST-IDX TO LD-RETURNCODE.
           MOVE ST-IDX TO WS-RETURN-CODE.
           MOVE "There is no account.          " TO WS-EXPLANATION.
           PERFORM H500-DATA-HANDLING.
       H220-END. EXIT.

       H300-OPEN-FILES.
           OPEN I-O  IDX-FILE.
           IF (NOT IDX-SUCCESS)
           DISPLAY 'UNABLE TO OPEN IDXILE: ' ST-IDX
           MOVE ST-IDX TO RETURN-CODE
           MOVE ST-IDX TO LD-RETURNCODE
           GOBACK
           END-IF.
       H300-END. EXIT.

      *Read işlemi burada yapılıyor. 
       H320-READ-FOR-INFO.
           PERFORM H200-READ
           MOVE LD-ID       TO WS-ID.
           MOVE LD-DVZ      TO WS-DVZ.
           MOVE 'The data read successfully.   ' TO WS-EXPLANATION.
           MOVE IDX-NAME    TO WS-FNAME-FROM.
           MOVE IDX-NAME    TO WS-FNAME-TO.
           MOVE IDX-SURNAME TO WS-LNAME-FROM.
           MOVE IDX-SURNAME TO WS-LNAME-TO.
           MOVE ST-IDX      TO WS-RETURN-CODE.
           PERFORM H500-DATA-HANDLING.
       H320-END. EXIT.

      *Update işlemi burada yapılıyor. 
       H330-UPDATE.
           PERFORM H200-READ
           MOVE LD-ID       TO WS-ID.
           MOVE LD-DVZ      TO WS-DVZ.
           MOVE 'The data updated successfully.' TO WS-EXPLANATION.
           MOVE IDX-NAME    TO WS-FNAME-FROM.
           PERFORM UNTIL WS-IND1 > 14
           IF IDX-NAME(WS-IND1:1) = ' '
           MOVE WS-IND1 TO WS-IND2
           PERFORM UNTIL WS-IND1 > 14
           MOVE IDX-NAME(WS-IND1 + 1:1) TO IDX-NAME(WS-IND1:1)
           ADD 1 TO WS-IND1
           END-PERFORM
           MOVE WS-IND2 TO WS-IND1
           END-IF
           ADD 1 TO WS-IND1
           END-PERFORM.
           MOVE 1 TO WS-IND1.
           MOVE IDX-NAME    TO WS-FNAME-TO.
           MOVE IDX-SURNAME TO WS-LNAME-FROM.
           INSPECT IDX-SURNAME REPLACING ALL 'E' BY 'I'.
           INSPECT IDX-SURNAME REPLACING ALL 'A' BY 'E'.
           MOVE IDX-SURNAME TO WS-LNAME-TO.
           REWRITE IDX-REC.
           MOVE ST-IDX      TO WS-RETURN-CODE.
           PERFORM H500-DATA-HANDLING.
       H330-END. EXIT.

      *Write işlemi burada yapılıyor. 
       H340-WRITE.
           MOVE SPACES TO WS-REC.
           MOVE LD-ID       TO IDX-ID.
           MOVE LD-DVZ      TO IDX-DVZ.
           MOVE 'H U S N U      ' TO IDX-NAME.
           MOVE 'PIDECI         ' TO IDX-SURNAME.
           MOVE 1998322           TO IDX-ODATE.
           MOVE ZEROES            TO IDX-BALANCE.
           MOVE LD-ID       TO WS-ID.
           MOVE LD-DVZ      TO WS-DVZ.
           MOVE IDX-NAME    TO WS-FNAME-TO.
           MOVE IDX-SURNAME TO WS-LNAME-TO.
           WRITE IDX-REC.
           IF ST-IDX NOT = 0
           MOVE 'New acc could not add.        ' TO WS-EXPLANATION
           ELSE
           MOVE 'Added new acc successfully.   ' TO WS-EXPLANATION
           END-IF.
           MOVE ST-IDX      TO WS-RETURN-CODE.
           PERFORM H500-DATA-HANDLING.
       H340-END. EXIT.

      *Delete işlemi burada yapılıyor.
       H350-DELETE.
           PERFORM H200-READ
           MOVE SPACES TO WS-REC.
           MOVE LD-ID        TO WS-ID.
           MOVE LD-DVZ       TO WS-DVZ.
           MOVE IDX-NAME     TO WS-FNAME-FROM.
           MOVE IDX-SURNAME  TO WS-LNAME-FROM.
           MOVE 'The acc deleted successfully. ' TO WS-EXPLANATION.
           DELETE IDX-FILE.
           MOVE ST-IDX       TO WS-RETURN-CODE.
           PERFORM H500-DATA-HANDLING.
       H350-END. EXIT.

       H500-DATA-HANDLING.
      *Process type'ın 1-2-3-4 gibi değilde READ,UPDT şeklinde görünmesi
      *için işlem yapıyorum.
           EVALUATE TRUE
              WHEN WS-FUNC-READ
                  MOVE 'READ' TO WS-PROCESS-TYPE
              WHEN WS-FUNC-UPDATE
                  MOVE 'UPDT' TO WS-PROCESS-TYPE
              WHEN WS-FUNC-WRITE
                  MOVE 'WRIT' TO WS-PROCESS-TYPE
              WHEN WS-FUNC-DELETE
                  MOVE 'DELT' TO WS-PROCESS-TYPE
           END-EVALUATE.
      *String komutuyla bilgileri birleştiriyorum ki tek data olarak
      *ana programa gönderebileyim.
           STRING WS-PROCESS-TYPE  DELIMITED BY  SIZE
                  WS-ID            DELIMITED BY  SIZE
                  WS-DVZ           DELIMITED BY  SIZE
                  WS-RETURN-CODE   DELIMITED BY  SIZE
                  WS-EXPLANATION   DELIMITED BY  SIZE
                  WS-FNAME-FROM    DELIMITED BY  SIZE
                  WS-FNAME-TO      DELIMITED BY  SIZE
                  WS-LNAME-FROM    DELIMITED BY  SIZE
                  WS-LNAME-TO      DELIMITED BY  SIZE
              INTO LD-DATA
           END-STRING.
       H500-END. EXIT.
