identification division.
       program-id. Loops.

data division.
working-storage section.

       01 USER-ID pic X(10).
       01 FIRST-NAME pic X(20).
       01 LAST-NAME pic u(20).
       01 ACCOUNT-NO pic X(20).
       01 BALANCE PIC 9(7)v99. 
       01 CURRENCY-CODE pic X(3).
       01 FULL-NAME pic X(41).
       01 MANUAL-NAME pic X(41).
       01 COPYING-INDEXES.
           02 COPY-FROM pic 9(2).
           02 COPY-TO pic 9(2) value 1.


procedure division.
       move 1234567890 to USER-ID.
       move "Lars" to FIRST-NAME.
       move "Hansøn" to LAST-NAME.
       move "DK12345678912345" to ACCOUNT-NO.
       move 5.05 to BALANCE.
       move "DKK" to CURRENCY-CODE.

       perform varying COPY-FROM in COPYING-INDEXES from 1 by 1
           until FIRST-NAME(COPY-FROM in COPYING-INDEXES: 1) = SPACE or COPY-FROM in COPYING-INDEXES > function length(FIRST-NAME) 
           move FIRST-NAME(COPY-FROM in COPYING-INDEXES: 1) to MANUAL-NAME(COPY-TO in COPYING-INDEXES:1)
           add 1 to COPY-TO in COPYING-INDEXES
       end-perform.

       move " " to MANUAL-NAME(COPY-TO in COPYING-INDEXES:1).
       add 1 to COPY-TO in COPYING-INDEXES.

       perform varying COPY-FROM in COPYING-INDEXES from 1 by 1
           until LAST-NAME(COPY-FROM in COPYING-INDEXES: 1) = SPACE or COPY-FROM in COPYING-INDEXES > function length(LAST-NAME) 
           move LAST-NAME(COPY-FROM in COPYING-INDEXES: 1) to MANUAL-NAME(COPY-TO in COPYING-INDEXES:1)
           add 1 to COPY-TO in COPYING-INDEXES
       end-perform.

       display MANUAL-NAME.
       
       string  function trim(FIRST-NAME) delimited by size
               " " delimited by size    
               function trim(LAST-NAME) delimited by size
               into FULL-NAME
       display FULL-NAME.

       display function concatenate(function trim(FIRST-NAME) " " function trim(LAST-NAME)).





       DISPLAY "----------------------------------------" 
       DISPLAY "Kunde ID       : " USER-ID 
       DISPLAY "Navn (renset)  : " MANUAL-NAME 
       DISPLAY "Kontonummer    : " ACCOUNT-NO 
       DISPLAY "Balance        : " BALANCE " " CURRENCY-CODE 
       DISPLAY "----------------------------------------" 
stop run.
