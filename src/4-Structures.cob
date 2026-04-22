identification division.
       program-id. Structures.

data division.
working-storage section.

       01 USER-INFO.
           02 USER-ID pic X(10).
           02 FIRST-NAME pic X(20).
           02 LAST-NAME pic X(20).
       01 ACCOUNT-INFO.
           02 ACCOUNT-NO pic X(20).
           02 BALANCE PIC 9(7)v99. 
           02 CURRENCY-CODE pic X(3).
     

procedure division.
       move 1234567890 to USER-ID.
       move "Lars" to FIRST-NAME.
       move "Hansen" to LAST-NAME.
       move "DK12345678912345" to ACCOUNT-NO.
       move 5.05 to BALANCE.
       move "DKK" to CURRENCY-CODE.


       DISPLAY "----------------------------------------" 
       DISPLAY "Kunde ID       : " USER-ID 
       DISPLAY "Navn (renset)  : " function trim(FIRST-NAME) " " function trim(LAST-NAME)
       DISPLAY "Kontonummer    : " ACCOUNT-NO 
       DISPLAY "Balance        : " BALANCE " " CURRENCY-CODE 
       DISPLAY "----------------------------------------" 



       display USER-INFO
stop run.
