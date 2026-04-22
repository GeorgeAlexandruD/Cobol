identification division.
       program-id. ReadFromMultipleFiles.

environment division.
input-output section.
file-control.
       select input-file1 assign to "8-KontoOpl.txt"
           organization is line sequential.

        select input-file2 assign to "8-KontoData.txt"
           organization is line sequential.
       select output-file assign to "8-KundeKonto.txt"
           organization line sequential.

data division.
file section.
FD input-file1.
       01 csv-lines pic x(100).

FD input-file2.
       01 csv-lines2 pic x(100).

FD output-file. 
       01 OUTPUT-RECORD pic u(100). 

 WORKING-STORAGE SECTION. 

       01 WS-KONTO.
           copy "8-KONTOOPL.cpy".
       01 END-OF-FILE1   PIC X VALUE "N". 
       01 END-OF-FILE2   PIC X VALUE "N". 
       01 WS_CUSTOMER_ID pic x(10).
       01 WS_FIRST_NAME pic u(15).
       01 WS_LAST_NAME pic x(15).
       01 WS_STREET pic u(20).
       01 WS_STREET_NUMBER pic ZZZ.
       01 WS_FLOOR pic ZZ.
       01 WS_SIDE pic x(3).
       01 WS_POSTNR pic 9999.
       01 WS_CITY pic x(20).
       01 WS_PHONE pic x(15).
       01 WS_EMAIL pic x(30).


PROCEDURE DIVISION. 
       OPEN INPUT input-file1
       OPEN INPUT input-file2
       OPEN OUTPUT output-file 
         
       perform UNTIL END-OF-FILE1 = "Y" 
           read input-file1 INTO csv-lines
               At end 
                   move "Y" to END-OF-FILE1
               not at end
                   unstring csv-lines delimited by ","
                       into WS_CUSTOMER_ID, WS_FIRST_NAME, WS_LAST_NAME, WS_STREET, WS_STREET_NUMBER, WS_FLOOR, WS_SIDE, WS_POSTNR, WS_CITY, WS_PHONE, WS_EMAIL
                          
                   MOVE SPACES TO OUTPUT-RECORD
                   
                   perform BUILD-ID-LINE
                   perform WRITE-LINE
                   
                   perform BUILD-NAME-LINE
                   perform WRITE-LINE

                   perform BUILD-ADDRESS-LINE
                   perform WRITE-LINE
                   
                   perform BUILD-LOCATION-LINE
                   perform WRITE-LINE
                   
                   perform BUILD-PHONE-LINE
                   perform WRITE-LINE
                   
                   perform BUILD-EMAIL-LINE
                   perform WRITE-LINE

                   write OUTPUT-RECORD

           end-read

               IF END-OF-FILE1 = "N"
                  MOVE "N" TO END-OF-FILE2

        *> rewind file2 back to start for each file1 record
                   CLOSE input-file2
                   OPEN INPUT input-file2
    
                   PERFORM UNTIL END-OF-FILE2 = "Y"
                       READ input-file2 INTO csv-lines2
    
                           AT END MOVE "Y" TO END-OF-FILE2
                           NOT AT END
                               UNSTRING csv-lines2 DELIMITED BY "," INTO KUNDE-ID, KONTO-ID, KONTO-TYPE, BALANCE, VALUTA-KD
                               IF WS_CUSTOMER_ID = KUNDE-ID

                                   perform BUILD-ACCOUNT-ID-LINE
                                   perform WRITE-LINE

                                   perform BUILD-ACCOUNT-TYPE-LINE
                                   perform WRITE-LINE

                                   perform BUILD-ACCOUNT-BALANCE-LINE
                                   perform WRITE-LINE

                                   perform BUILD-ACCOUNT-VALUTA-LINE
                                   perform WRITE-LINE
                                   
                                   write OUTPUT-RECORD
                               END-IF
                       END-READ
                   END-PERFORM
               END-IF
       end-perform
        
       close input-file1
       close input-file2
       close output-file
stop run.

       BUILD-ID-LINE.        
           STRING "ID: " DELIMITED BY SIZE
               FUNCTION TRIM(WS_CUSTOMER_ID) DELIMITED BY SIZE
               INTO OUTPUT-RECORD.

       exit.

       BUILD-NAME-LINE.
           string "NAVN: " delimited by size
                function trim(WS_FIRST_NAME) delimited by size   
                " " delimited by size
                function trim(WS_LAST_NAME) delimited by size
                into OUTPUT-RECORD
       EXIT.

       BUILD-ADDRESS-LINE.
           STRING "ADRESSE: VEJNAVN: " DELIMITED BY SIZE
               FUNCTION TRIM(WS_STREET) DELIMITED BY SIZE
               ", HUSNR: " DELIMITED BY SIZE
               FUNCTION TRIM(WS_STREET_NUMBER) DELIMITED BY SIZE
               INTO OUTPUT-RECORD
                       
               IF FUNCTION TRIM(WS_FLOOR) <> SPACES
                   STRING FUNCTION TRIM(OUTPUT-RECORD) DELIMITED BY SIZE
                          ", ETAGE: " DELIMITED BY SIZE
                          FUNCTION TRIM(WS_FLOOR) DELIMITED BY SIZE
                          INTO OUTPUT-RECORD
               END-IF
               
               IF FUNCTION TRIM(WS_SIDE) <> SPACES
                   STRING FUNCTION TRIM(OUTPUT-RECORD) DELIMITED BY SIZE
                          ", SIDE: " DELIMITED BY SIZE
                          FUNCTION TRIM(WS_SIDE) DELIMITED BY SIZE
                          INTO OUTPUT-RECORD
               END-IF
       EXIT.

       BUILD-LOCATION-LINE.
           string "LOKATION: " delimited by size
               function trim(WS_POSTNR) delimited by size  
               ", " delimited by size 
               function trim(WS_CITY) delimited by size
               into OUTPUT-RECORD
       EXIT.

       BUILD-PHONE-LINE.
           string "TELEFON: " delimited by size
               function trim(WS_PHONE) delimited by size
               into OUTPUT-RECORD
       EXIT.

       BUILD-EMAIL-LINE.
           string "EMAIL: " delimited by size
               function trim(WS_EMAIL) delimited by size
               into OUTPUT-RECORD
       EXIT.

       WRITE-LINE.
           WRITE OUTPUT-RECORD
           MOVE SPACES TO OUTPUT-RECORD.
       exit.

       BUILD-ACCOUNT-ID-LINE.
           string "KONTO-ID: " delimited by size
               function  trim(KONTO-ID) delimited by size
               into OUTPUT-RECORD
       exit.

       BUILD-ACCOUNT-TYPE-LINE.
           string "KONTO-TYPE: " delimited by size
               function  trim(KONTO-TYPE) delimited by size
               into OUTPUT-RECORD
       exit.


       BUILD-ACCOUNT-BALANCE-LINE.
           string "KONTO-BALANCE: " delimited by size
               function  trim(BALANCE) delimited by size
               into OUTPUT-RECORD
       exit.


       BUILD-ACCOUNT-VALUTA-LINE.
           string "KONTO-VALUTA: " delimited by size
               function  trim(VALUTA-KD) delimited by size
               into OUTPUT-RECORD
       exit.
