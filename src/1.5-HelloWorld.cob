identification division.
       program-id. HelloWorldWVar.

data division.
working-storage section.
           01 HELLO-WORLD        PIC X(20) value "Hello world".
           01 MY-AGE         PIC 9(2) value 99.
           01 MY-SALARY      PIC 9(7)V9(3) value 1234567.123.


procedure division.
       display HELLO-WORLD " " MY-AGE
       
stop run.
