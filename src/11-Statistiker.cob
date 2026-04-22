IDENTIFICATION DIVISION.
       PROGRAM-ID. Statistiker.
 
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT transactions-file ASSIGN TO "10-Transaktioner.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT output-file ASSIGN TO "11-Statistik.txt"
               ORGANIZATION LINE SEQUENTIAL.
 
       DATA DIVISION.
       FILE SECTION.
       FD transactions-file.
       01 transactions-in.
           COPY "10-TRANSAKTIONER.cpy".
 
       FD output-file.
       01 OUTPUT-RECORD                    PIC X(100).
 
       WORKING-STORAGE SECTION.
      *> --- Control Flags ---
       01 END-OF-TRANSACTIONS-FILE         PIC X           VALUE "N".
       01 WS-SWAP                          PIC X           VALUE "Y".
       01 WS-SHOP-FOUND                    PIC X           VALUE "N".
       01 WS-CPR                           PIC X(15)       VALUE SPACES.
 
      *> --- Indexes & Counters ---
       01 WS-IX                            PIC 9(5)        VALUE 1.
       01 WS-JX                            PIC 9(5)        VALUE 1.
       01 WS-NEXT                          PIC 9(5).
       01 WS-MONTH-IX                      PIC 99.
       01 WS-LENGTH                        PIC 9(5)        VALUE 10001.
       01 WS-CUSTOMER-INFO-IX              PIC 9(5)        VALUE 0.
       01 WS-SHOP-INFO-IX                  PIC 9(5)        VALUE 1.
 
      *> --- Running Totals ---
       01 WS-TOTAL-INDBETALT               PIC S9(13)V99   VALUE 0.
       01 WS-TOTAL                         PIC S9(13)V99   VALUE 0.
       01 WS-BELOEB-NUM                    PIC S9(13)V99.
 
      *> --- Display Formatters ---
       01 WS-TOTAL-DISPLAY                 PIC -Z(11).99.
       01 WS-TOTAL-DISPLAY-NEGATIVE        PIC -Z(11).99.
 
      *> --- Average & Standard Deviation ---
       01 AVERAGE-TOTAL                    PIC S9(15)V99.
       01 AVERAGE-DIV                      PIC 9(6).
       01 AVERAGE                          PIC S9(13)V99.
       01 WS-STANDARD-DEVIATION-TOTAL      PIC S9(20)V99.
       01 WS-STANDARD-DEVIATION            PIC S9(13)V99.
       01 WS-STD-SQUARED                   PIC S9(20)V99.
       01 WS-STANDARD-DEVIATION-SQUARED    PIC S9(20)V99.
 
      *> --- Customer Table (max 10001, last slot used as swap buffer) ---
       01 WS-CUSTOMER-INFO OCCURS 10001 TIMES.
           02 T-KONTO-ID                   PIC X(15).
           02 TOTAL                        PIC S9(13)V99.
           02 T-NAVN                       PIC X(50).
           02 T-NUMBER                     PIC 99.
           02 AVG                          PIC S9(13)V99.
 
      *> --- Shop Table (max 500, last slot used as swap buffer) ---
       01 WS-SHOP-INFO OCCURS 500 TIMES.
           02 SHOP-NAME                    PIC X(15).
           02 SHOP-TRANSACTION-COUNTER     PIC 9(5).
           02 SHOP-TURNOVER                PIC S9(13)V99.
 
      *> --- Monthly Cashflow & Payment Type Breakdown ---
       01 WS-MONTHLY-CASHFLOW OCCURS 12 TIMES.
           02 WS-TOTAL-MONTHLY-OUTGOING    PIC S9(13)V99.
           02 WS-TOTAL-MONTHLY-INCOMING    PIC S9(13)V99.
 
       01 WS-MONTHLY-PAYMENT-TYPES OCCURS 12 TIMES.
           02 MONTH-TYPE OCCURS 3 TIMES.
               03 TYPE-NAME                PIC X(15).
               03 TYPE-NUMBER              PIC 9(5).
 
       PROCEDURE DIVISION.
           PERFORM INITIALIZE-PROGRAM
           PERFORM PROCESS-TRANSACTIONS
           PERFORM BUBBLE-SORT-CUSTOMERS
           PERFORM WRITE-REPORT
           PERFORM CALCULATE-STANDARD-DEVIATION
           CLOSE transactions-file
           CLOSE output-file
           STOP RUN.
 
      *> ============================================================
      *> INITIALIZATION
      *> ============================================================
       INITIALIZE-PROGRAM.
           OPEN INPUT transactions-file
 
           PERFORM VARYING WS-IX FROM 1 BY 1 UNTIL WS-IX > 12
               MOVE 0 TO SHOP-TURNOVER OF WS-SHOP-INFO(WS-IX)
               MOVE 0 TO WS-TOTAL-MONTHLY-INCOMING OF WS-MONTHLY-CASHFLOW(WS-IX)
               MOVE 0 TO WS-TOTAL-MONTHLY-OUTGOING OF WS-MONTHLY-CASHFLOW(WS-IX)
               MOVE 0 TO TYPE-NUMBER OF WS-MONTHLY-PAYMENT-TYPES(WS-IX, 1)
               MOVE 0 TO TYPE-NUMBER OF WS-MONTHLY-PAYMENT-TYPES(WS-IX, 2)
               MOVE 0 TO TYPE-NUMBER OF WS-MONTHLY-PAYMENT-TYPES(WS-IX, 3)
           END-PERFORM
 
           MOVE 1 TO WS-IX
           MOVE 0 TO AVERAGE-TOTAL
           MOVE 0 TO AVERAGE-DIV
           MOVE 0 TO AVERAGE
           MOVE 0 TO WS-STANDARD-DEVIATION-TOTAL
           MOVE 0 TO WS-STANDARD-DEVIATION
           MOVE 0 TO WS-STD-SQUARED
           MOVE 0 TO WS-STANDARD-DEVIATION-SQUARED
       EXIT.
 
      *> ============================================================
      *> MAIN PROCESSING LOOP — reads all transactions
      *> ============================================================
       PROCESS-TRANSACTIONS.
           PERFORM UNTIL END-OF-TRANSACTIONS-FILE = "Y"
               READ transactions-file
                   AT END
                      *> calculates average at end of loop
                       DIVIDE AVERAGE-TOTAL BY AVERAGE-DIV GIVING AVERAGE
                       MOVE AVERAGE TO WS-TOTAL-DISPLAY
                       MOVE AVERAGE-TOTAL TO WS-TOTAL-DISPLAY
                       MOVE "Y" TO END-OF-TRANSACTIONS-FILE
 
                   NOT AT END
                       MOVE SPACES TO OUTPUT-RECORD
 
                       PERFORM HANDLE-NEW-CUSTOMER
                       PERFORM ACCUMULATE-CUSTOMER-TOTAL
                       PERFORM ACCUMULATE-MONTHLY-CASHFLOW
                       PERFORM ACCUMULATE-PAYMENT-TYPES
                       PERFORM ACCUMULATE-SHOP-TURNOVER
 
                       ADD 1 TO WS-IX
               END-READ
           END-PERFORM
       EXIT.
 
      *> --- New customer detection and registration ---
       HANDLE-NEW-CUSTOMER.
           IF WS-CPR <> CPR
               ADD 1 TO WS-CUSTOMER-INFO-IX
               MOVE KONTO-ID TO T-KONTO-ID OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX)
               MOVE 0 TO TOTAL OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX)
               ADD 50000 TO TOTAL OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX)
               MOVE NAVN TO T-NAVN OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX)
               MOVE CPR TO WS-CPR
               MOVE 0 TO WS-TOTAL-INDBETALT
               MOVE 0 TO WS-TOTAL
               MOVE 0 TO T-NUMBER OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX)
           END-IF
       EXIT.
 
      *> --- Add transaction amount to current customer's running total ---
       ACCUMULATE-CUSTOMER-TOTAL.
           PERFORM CONVERT-BELOEB-W-TOTAL
           ADD WS-TOTAL  TO TOTAL    OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX)
           ADD 1         TO T-NUMBER OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX)
           MOVE 0 TO WS-TOTAL
       EXIT.
 
      *> --- Bucket transaction into the correct month's cashflow ---
       ACCUMULATE-MONTHLY-CASHFLOW.
           MOVE TIDSPUNKT(6:2) TO WS-MONTH-IX
           PERFORM CONVERT-BELOEB
           *> standard deviation first loop through
           ADD WS-BELOEB-NUM TO AVERAGE-TOTAL
           ADD 1 TO AVERAGE-DIV
 
           IF WS-BELOEB-NUM > 0
               ADD WS-BELOEB-NUM TO WS-TOTAL-MONTHLY-INCOMING OF WS-MONTHLY-CASHFLOW(WS-MONTH-IX)
           END-IF
           IF WS-BELOEB-NUM < 0
               ADD WS-BELOEB-NUM TO WS-TOTAL-MONTHLY-OUTGOING OF WS-MONTHLY-CASHFLOW(WS-MONTH-IX)
           END-IF
       EXIT.
 
      *> --- Count transaction types per month ---
       ACCUMULATE-PAYMENT-TYPES.
           IF TRANSAKTIONSTYPE = "Indbetaling"
               MOVE "Indbetaling" TO TYPE-NAME OF WS-MONTHLY-PAYMENT-TYPES(WS-MONTH-IX, 1)
               ADD 1 TO TYPE-NUMBER OF WS-MONTHLY-PAYMENT-TYPES(WS-MONTH-IX, 1)
           END-IF
           IF TRANSAKTIONSTYPE = "Udbetaling"
               MOVE "Udbetaling" TO TYPE-NAME OF WS-MONTHLY-PAYMENT-TYPES(WS-MONTH-IX, 2)
               ADD 1 TO TYPE-NUMBER OF WS-MONTHLY-PAYMENT-TYPES(WS-MONTH-IX, 2)
           END-IF
           IF TRANSAKTIONSTYPE(1:4) = "Over"
               MOVE "Overf๘rsel" TO TYPE-NAME OF WS-MONTHLY-PAYMENT-TYPES(WS-MONTH-IX, 3)
               ADD 1 TO TYPE-NUMBER OF WS-MONTHLY-PAYMENT-TYPES(WS-MONTH-IX, 3)
           END-IF
       EXIT.
 
      *> --- Find or register shop, then add to its turnover ---
       ACCUMULATE-SHOP-TURNOVER.
           MOVE "N" TO WS-SHOP-FOUND
           PERFORM VARYING WS-JX FROM 1 BY 1 UNTIL WS-JX > WS-SHOP-INFO-IX
               IF BUTIK = SHOP-NAME OF WS-SHOP-INFO(WS-JX)
                   ADD 1 TO SHOP-TRANSACTION-COUNTER OF WS-SHOP-INFO(WS-JX)
                   ADD FUNCTION ABS(WS-BELOEB-NUM) TO SHOP-TURNOVER OF WS-SHOP-INFO(WS-JX)
                   MOVE "Y" TO WS-SHOP-FOUND
               END-IF
           END-PERFORM
 
           IF WS-SHOP-FOUND = "N"
               IF WS-IX <> 1
                   ADD 1 TO WS-SHOP-INFO-IX
               END-IF
               MOVE BUTIK TO SHOP-NAME OF WS-SHOP-INFO(WS-SHOP-INFO-IX)
               ADD FUNCTION ABS(WS-BELOEB-NUM) TO SHOP-TURNOVER  OF WS-SHOP-INFO(WS-SHOP-INFO-IX)
               MOVE 1 TO SHOP-TRANSACTION-COUNTER OF WS-SHOP-INFO(WS-SHOP-INFO-IX)
           END-IF
       EXIT.
 

       WRITE-REPORT.
           OPEN OUTPUT output-file
           MOVE SPACES TO OUTPUT-RECORD
           MOVE 1 TO WS-CUSTOMER-INFO-IX
 
           PERFORM WRITE-CUSTOMER-SECTION
           PERFORM WRITE-MONTHLY-CASHFLOW-SECTION
           PERFORM WRITE-ALL-SHOPS-SECTION
           PERFORM WRITE-TOP5-SHOPS-SECTION
           PERFORM WRITE-PAYMENT-TYPES-SECTION
       EXIT.
 
       WRITE-CUSTOMER-SECTION.
           PERFORM UNTIL WS-CUSTOMER-INFO-IX > 20
               DISPLAY TOTAL    OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX) "by " T-NUMBER OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX)
               DIVIDE TOTAL    OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX) BY T-NUMBER OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX) GIVING AVG  OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX)
               MOVE TOTAL OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX) TO WS-TOTAL-DISPLAY
               STRING "Kunde-ID:" FUNCTION TRIM(T-KONTO-ID OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX)) ", Navn: " FUNCTION TRIM(T-NAVN     OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX))
                   ", Saldo: " FUNCTION TRIM(WS-TOTAL-DISPLAY) " DKK, Avg: " AVG OF WS-CUSTOMER-INFO(WS-CUSTOMER-INFO-IX)
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               PERFORM WRITE-LINE
               ADD 1 TO WS-CUSTOMER-INFO-IX
           END-PERFORM
       EXIT.
 
       WRITE-MONTHLY-CASHFLOW-SECTION.
           MOVE SPACES TO OUTPUT-RECORD
           PERFORM WRITE-LINE
           STRING "Måned      Indbetalinger(dkk)    Udbetalinger(dkk)"
               DELIMITED BY SIZE INTO OUTPUT-RECORD
           PERFORM WRITE-LINE
 
           PERFORM VARYING WS-IX FROM 1 BY 1 UNTIL WS-IX > 12
               MOVE WS-TOTAL-MONTHLY-INCOMING OF WS-MONTHLY-CASHFLOW(WS-IX) TO WS-TOTAL-DISPLAY
               MOVE WS-TOTAL-MONTHLY-OUTGOING OF WS-MONTHLY-CASHFLOW(WS-IX) TO WS-TOTAL-DISPLAY-NEGATIVE
               STRING WS-IX " "
                   FUNCTION TRIM(WS-TOTAL-DISPLAY) " "
                   FUNCTION TRIM(WS-TOTAL-DISPLAY-NEGATIVE)
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               PERFORM WRITE-LINE
           END-PERFORM
       EXIT.
 
       WRITE-ALL-SHOPS-SECTION.
           MOVE SPACES TO OUTPUT-RECORD
           PERFORM WRITE-LINE
           STRING "Butik         Antal transactioner"
               DELIMITED BY SIZE INTO OUTPUT-RECORD
           PERFORM WRITE-LINE
 
           PERFORM VARYING WS-IX FROM 1 BY 1 UNTIL WS-IX > WS-SHOP-INFO-IX
               STRING SHOP-NAME OF WS-SHOP-INFO(WS-IX) "    " SHOP-TRANSACTION-COUNTER    OF WS-SHOP-INFO(WS-IX)
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               PERFORM WRITE-LINE
           END-PERFORM
       EXIT.
 
       WRITE-TOP5-SHOPS-SECTION.
           MOVE SPACES TO OUTPUT-RECORD
           PERFORM WRITE-LINE
           STRING "top 5 butiker"
               DELIMITED BY SIZE INTO OUTPUT-RECORD
           PERFORM WRITE-LINE
 
           MOVE "Y" TO WS-SWAP
           MOVE 14  TO WS-LENGTH
           PERFORM BUBBLE-SORT-SHOPS
 
           MOVE SPACES TO OUTPUT-RECORD
           MOVE 1      TO WS-SHOP-INFO-IX
 
           PERFORM UNTIL WS-SHOP-INFO-IX > 5
               MOVE SHOP-TURNOVER OF WS-SHOP-INFO(WS-SHOP-INFO-IX) TO WS-TOTAL-DISPLAY
               STRING "Butik navn:" FUNCTION TRIM(SHOP-NAME OF WS-SHOP-INFO(WS-SHOP-INFO-IX)) ", Omsætning: " FUNCTION TRIM(WS-TOTAL-DISPLAY) " DKK"
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               PERFORM WRITE-LINE
               ADD 1 TO WS-SHOP-INFO-IX
           END-PERFORM
       EXIT.
 
       WRITE-PAYMENT-TYPES-SECTION.
           MOVE SPACES TO OUTPUT-RECORD
           PERFORM WRITE-LINE
           MOVE 1 TO WS-IX
 
           PERFORM VARYING WS-IX FROM 1 BY 1 UNTIL WS-IX > 12
               STRING WS-IX " " TYPE-NAME OF WS-MONTHLY-PAYMENT-TYPES(WS-IX, 1) " : " TYPE-NUMBER OF WS-MONTHLY-PAYMENT-TYPES(WS-IX, 1)
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               PERFORM WRITE-LINE
 
               STRING WS-IX " " TYPE-NAME OF WS-MONTHLY-PAYMENT-TYPES(WS-IX, 2) " : " TYPE-NUMBER OF WS-MONTHLY-PAYMENT-TYPES(WS-IX, 2)
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               PERFORM WRITE-LINE
 
               STRING WS-IX " " TYPE-NAME OF WS-MONTHLY-PAYMENT-TYPES(WS-IX, 3) " : " TYPE-NUMBER OF WS-MONTHLY-PAYMENT-TYPES(WS-IX, 3)
                   DELIMITED BY SIZE INTO OUTPUT-RECORD
               PERFORM WRITE-LINE
           END-PERFORM
       EXIT.
 
      *> ============================================================
      *> STANDARD DEVIATION — second pass over file
      *> ============================================================
       CALCULATE-STANDARD-DEVIATION.
           CLOSE transactions-file
           OPEN INPUT transactions-file
           MOVE "N" TO END-OF-TRANSACTIONS-FILE
 
           PERFORM UNTIL END-OF-TRANSACTIONS-FILE = "Y"
               READ transactions-file
                   AT END
                       SUBTRACT 1 FROM AVERAGE-DIV
                       DIVIDE WS-STANDARD-DEVIATION-TOTAL BY AVERAGE-DIV GIVING WS-STANDARD-DEVIATION-SQUARED
                       MOVE FUNCTION SQRT(WS-STANDARD-DEVIATION-SQUARED) TO WS-STANDARD-DEVIATION
                       MOVE SPACES TO OUTPUT-RECORD
                       MOVE WS-STANDARD-DEVIATION TO WS-TOTAL-DISPLAY
                       STRING "STD DEV: " WS-TOTAL-DISPLAY
                           DELIMITED BY SIZE INTO OUTPUT-RECORD
                       PERFORM WRITE-LINE
                       MOVE "Y" TO END-OF-TRANSACTIONS-FILE
 
                   NOT AT END
                       PERFORM CONVERT-BELOEB
                       SUBTRACT AVERAGE    FROM WS-BELOEB-NUM
                       MULTIPLY WS-BELOEB-NUM BY WS-BELOEB-NUM GIVING WS-STD-SQUARED
                       ADD WS-STD-SQUARED TO WS-STANDARD-DEVIATION-TOTAL
               END-READ
           END-PERFORM
       EXIT.
 
       CONVERT-BELOEB.
           MOVE FUNCTION NUMVAL(BELOEB) TO WS-BELOEB-NUM
           IF FUNCTION TRIM(VALUTA) = "USD"
               MULTIPLY 6.8 BY WS-BELOEB-NUM
           END-IF
           IF FUNCTION TRIM(VALUTA) = "EUR"
               MULTIPLY 7.5 BY WS-BELOEB-NUM
           END-IF
       EXIT.
 
       CONVERT-BELOEB-W-TOTAL.
           MOVE FUNCTION NUMVAL(BELOEB) TO WS-BELOEB-NUM
           IF FUNCTION TRIM(VALUTA) = "USD"
               MULTIPLY 6.8 BY WS-BELOEB-NUM
           END-IF
           IF FUNCTION TRIM(VALUTA) = "EUR"
               MULTIPLY 7.5 BY WS-BELOEB-NUM
           END-IF
           ADD WS-BELOEB-NUM TO WS-TOTAL
       EXIT.
 

       BUBBLE-SORT-CUSTOMERS.
           MOVE 1 TO WS-IX
           PERFORM UNTIL WS-SWAP = "N"
               MOVE "N" TO WS-SWAP
               PERFORM UNTIL WS-IX = WS-LENGTH
                   MOVE 1 TO WS-JX
                   PERFORM UNTIL WS-JX = WS-LENGTH - WS-IX
                       MOVE WS-JX TO WS-NEXT
                       ADD 1      TO WS-NEXT
                       IF TOTAL OF WS-CUSTOMER-INFO(WS-JX) < TOTAL OF WS-CUSTOMER-INFO(WS-NEXT)
                           MOVE WS-CUSTOMER-INFO(WS-JX)   TO WS-CUSTOMER-INFO(10001)
                           MOVE WS-CUSTOMER-INFO(WS-NEXT) TO WS-CUSTOMER-INFO(WS-JX)
                           MOVE WS-CUSTOMER-INFO(10001)   TO WS-CUSTOMER-INFO(WS-NEXT)
                           MOVE "Y" TO WS-SWAP
                       END-IF
                       ADD 1 TO WS-JX
                   END-PERFORM
                   ADD 1 TO WS-IX
               END-PERFORM
           END-PERFORM
       EXIT.
 
       BUBBLE-SORT-SHOPS.
           MOVE 1 TO WS-IX
           PERFORM UNTIL WS-SWAP = "N"
               MOVE "N" TO WS-SWAP
               PERFORM UNTIL WS-IX = WS-LENGTH
                   MOVE 1 TO WS-JX
                   PERFORM UNTIL WS-JX = WS-LENGTH - WS-IX
                       MOVE WS-JX TO WS-NEXT
                       ADD 1      TO WS-NEXT
                       IF SHOP-TURNOVER OF WS-SHOP-INFO(WS-JX) < SHOP-TURNOVER OF WS-SHOP-INFO(WS-NEXT)
                           MOVE WS-SHOP-INFO(WS-JX)   TO WS-SHOP-INFO(500)
                           MOVE WS-SHOP-INFO(WS-NEXT) TO WS-SHOP-INFO(WS-JX)
                           MOVE WS-SHOP-INFO(500)     TO WS-SHOP-INFO(WS-NEXT)
                           MOVE "Y" TO WS-SWAP
                       END-IF
                       ADD 1 TO WS-JX
                   END-PERFORM
                   ADD 1 TO WS-IX
               END-PERFORM
           END-PERFORM
       EXIT.

       WRITE-LINE.
           WRITE OUTPUT-RECORD
           MOVE SPACES TO OUTPUT-RECORD
       EXIT.
       