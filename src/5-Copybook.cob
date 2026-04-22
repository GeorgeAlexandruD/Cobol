identification division.
       program-id. Copybook.

data division.
working-storage section.

       01 USER-INFO.
           copy "5-Client.cpy".


procedure division.
       move 1234567890 to VEJNAVN.
       move "Lars" to HUSNR.
    *>    move "Hansen" to LAST-NAME.
       move "DK12345678912345" to CITY.
    *>    move 5.05 to BALANCE.
    *>    move "DKK" to CURRENCY-CODE.

    display USER-INFO
stop run.
