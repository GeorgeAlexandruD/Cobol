identification division.
       program-id. Kontoudskrift.

environment division.
input-output section.
file-control.
       select banks-file assign to "10-Banker.txt"
           organization is line sequential.

       select transactions-file assign to "10-Transaktioner.txt"
           organization is line sequential.

       select output-file assign to "10-Kontoudskrifter.txt"
           organization line sequential.

data division.
file section.
FD banks-file.
01 banks-in.
       copy "10-BANKER.cpy".
FD transactions-file.
01 transactions-in.
       copy "10-TRANSAKTIONER.cpy".

FD output-file. 
       01 OUTPUT-RECORD pic x(100). 

WORKING-STORAGE SECTION.
       01 END-OF-BANKS-FILE  PIC X VALUE "N". 
       01 END-OF-TRANSACTIONS-FILE   PIC X VALUE "N". 
       01 WS-CPR pic x(15) value spaces. 
       01 WS-TOTAL-INDBETALT pic S9(13)v99 value 0.
       01 WS-TOTAL-UDBETALT pic S9(13)v99 value 0.
       01 WS-TOTAL-BALANCE pic S9(13)v99 value 0.
       01 WS-TOTAL-DISPLAY PIC -Z(11).99.
       01 WS-BELOEB-NUM PIC S9(13)v99.

PROCEDURE DIVISION. 
       OPEN INPUT banks-file
       OPEN INPUT transactions-file
       OPEN OUTPUT output-file 

       perform UNTIL END-OF-TRANSACTIONS-FILE = "Y" 
           read transactions-file
               At end 
                   move "Y" to END-OF-TRANSACTIONS-FILE
               not at end
                   
                   MOVE SPACES TO OUTPUT-RECORD
                   *> for "optimal" functionality, make sure the Transaktioner file is ordered by cpr numbers
                   if WS-CPR <> CPR
                   *> since code is linear, the total of the previous person gets calculated at the beginning of a new person (cpr)
                       if WS-CPR <> spaces
                           perform WRITE-LINE
                           perform PREVIOUS-TOTAL-POSITIVE-LINE
                           perform WRITE-LINE
                           perform PREVIOUS-TOTAL-NEGATIVE-LINE
                           perform WRITE-LINE
                           perform PREVIOUS-TOTAL-BALANCE-LINE
                           perform WRITE-LINE
                           perform GREETING-LINE1
                           perform WRITE-LINE
                           perform GREETING-LINE2
                           perform WRITE-LINE
    
                           MOVE SPACES TO OUTPUT-RECORD
                           perform WRITE-LINE
                           perform WRITE-LINE
                       end-if
                       
                       move CPR to WS-CPR
                       move 0 to WS-TOTAL-INDBETALT
                       move 0 to WS-TOTAL-UDBETALT
                       perform USERNAME-LINE
                       perform WRITE-LINE
    
                       perform ADDRESS-LINE
                       perform WRITE-LINE
    
                       IF END-OF-TRANSACTIONS-FILE = "N"
                             MOVE "N" TO END-OF-BANKS-FILE
                       end-if

                       CLOSE banks-file
                       OPEN INPUT banks-file
        
                       PERFORM UNTIL END-OF-BANKS-FILE = "Y"
                           READ banks-file
        
                               AT END 
                                   MOVE "Y" TO END-OF-BANKS-FILE
                               NOT AT END
                                   if REG-NR in transactions-in = REG-NR in banks-in
    
                                       perform BANK-REGNR-LINE
                                       perform WRITE-LINE
    
                                       perform BANK-NAME-LINE
                                       perform WRITE-LINE
    
                                       perform BANK-ADRESSE-LINE
                                       perform WRITE-LINE
    
                                       perform BANK-TELEFON-LINE
                                       perform WRITE-LINE
    
                                       perform BANK-EMAIL-LINE
                                       perform WRITE-LINE

                                   end-if

                           end-read
                       end-perform

                       perform KONTO-LINE
                       perform WRITE-LINE
                   end-if

               perform TRANSACTION-LINE
               perform WRITE-LINE

               perform TOTAL-INDBETALT
               perform TOTAL-UDBETALT
           end-read
       end-perform
       *> last person needs his totals too. 
       perform WRITE-LINE
       perform PREVIOUS-TOTAL-POSITIVE-LINE
       perform WRITE-LINE
       perform PREVIOUS-TOTAL-NEGATIVE-LINE
       perform WRITE-LINE
       perform PREVIOUS-TOTAL-BALANCE-LINE
       perform WRITE-LINE
       perform GREETING-LINE1
       perform WRITE-LINE
       perform GREETING-LINE2
       perform WRITE-LINE

       close banks-file
       close transactions-file
       close output-file
stop run.

       GREETING-LINE2.
           string " -G(angsta)-Bank"
               into OUTPUT-RECORD
       exit.

       GREETING-LINE1.
           string "Med veling hilsen"
               into OUTPUT-RECORD
       exit.

       PREVIOUS-TOTAL-BALANCE-LINE.
           MOVE ZERO TO WS-TOTAL-BALANCE
           add 50000 to WS-TOTAL-BALANCE
           add WS-TOTAL-UDBETALT to WS-TOTAL-BALANCE
           add WS-TOTAL-INDBETALT to WS-TOTAL-BALANCE

           move WS-TOTAL-BALANCE to WS-TOTAL-DISPLAY
           STRING "SALDO: " DELIMITED BY SIZE
                      FUNCTION TRIM(WS-TOTAL-DISPLAY) DELIMITED BY SIZE
                      INTO OUTPUT-RECORD
       exit.

       PREVIOUS-TOTAL-POSITIVE-LINE.
           MOVE WS-TOTAL-INDBETALT TO WS-TOTAL-DISPLAY
               STRING "Total indbetalt: " DELIMITED BY SIZE
                      FUNCTION TRIM(WS-TOTAL-DISPLAY) DELIMITED BY SIZE
                      INTO OUTPUT-RECORD
       exit.

       PREVIOUS-TOTAL-NEGATIVE-LINE.
           MOVE WS-TOTAL-UDBETALT TO WS-TOTAL-DISPLAY
               STRING "Total udbetalt: " DELIMITED BY SIZE
                      FUNCTION TRIM(WS-TOTAL-DISPLAY) DELIMITED BY SIZE
                      INTO OUTPUT-RECORD
       exit.

       TOTAL-UDBETALT.
           MOVE FUNCTION NUMVAL(BELOEB) TO WS-BELOEB-NUM

           if function trim(VALUTA) = "USD"
               MULTIPLY 6.8 BY WS-BELOEB-NUM
           end-if
           if function trim(VALUTA) = "EUR"
               multiply 7.5 by WS-BELOEB-NUM  
           end-if 
           if WS-BELOEB-NUM < 0
               add WS-BELOEB-NUM to WS-TOTAL-UDBETALT
 
       exit.

       TOTAL-INDBETALT.
           MOVE FUNCTION NUMVAL(BELOEB) TO WS-BELOEB-NUM

           if function trim(VALUTA) = "USD"
               MULTIPLY 6.8 BY WS-BELOEB-NUM
           end-if
           if function trim(VALUTA) = "EUR"
               multiply 7.5 by WS-BELOEB-NUM    
           end-if
           if WS-BELOEB-NUM > 0
               add WS-BELOEB-NUM to WS-TOTAL-INDBETALT
       exit.
       
       TRANSACTION-LINE.
           string TIDSPUNKT(1:10)  delimited by size
               " " delimited by size
               TIDSPUNKT(12:8) delimited by size
               " " delimited by size
               function trim(TRANSAKTIONSTYPE) delimited by size
               " " delimited by size
               function trim(BELOEB) delimited by size
               " " delimited by size
               function trim(VALUTA) delimited by size
               " " delimited by size
               function trim(BUTIK) delimited by size
               " " delimited by size
               into OUTPUT-RECORD
       exit.

       KONTO-LINE.
           string "Kontoudskrift for kontonr.: " delimited by size
               function trim(KONTO-ID) delimited by size
               into OUTPUT-RECORD
       exit.

       BANK-TELEFON-LINE.
           string "                                            Telefon: " delimited by size
               function trim(TELEFON) delimited by size
               into OUTPUT-RECORD
       exit.

       BANK-EMAIL-LINE.
           string "                                            Email: " delimited by size
               function trim(EMAIL) delimited by size
               into OUTPUT-RECORD
       exit.

       BANK-ADRESSE-LINE.
           string "                                            Bankadresse: " delimited by size
               function  trim(BANKADRESSE) delimited by size
               into OUTPUT-RECORD
       exit.


       BANK-NAME-LINE.
           string "                                            Bank: " delimited by size
               function trim(BANKNAVN) delimited by size
               into OUTPUT-RECORD
       exit.

       BANK-REGNR-LINE.
           STRING "                                            Registreringsnummer: " DELIMITED BY SIZE
               FUNCTION TRIM(REG-NR in banks-in) DELIMITED BY SIZE
               INTO OUTPUT-RECORD.
       exit.
 
       USERNAME-LINE.        
           STRING "Kunde: " DELIMITED BY SIZE
               FUNCTION TRIM(NAVN) DELIMITED BY SIZE
               INTO OUTPUT-RECORD.
       exit.
       
       ADDRESS-LINE.        
           STRING "Adresse: " DELIMITED BY SIZE
               FUNCTION TRIM(ADRESSE) DELIMITED BY SIZE
               INTO OUTPUT-RECORD.
       exit.
       
       WRITE-LINE.
               WRITE OUTPUT-RECORD
               MOVE SPACES TO OUTPUT-RECORD.
       exit.
