identification division.
       program-id. ReadWriteFile.

environment division.
input-output section.
file-control.
       select input-file assign to "7-KundeData.csv"
           organization is line sequential.
       select output-file assign to "7-KundeOutput.txt"
           organization line sequential.

data division.
file section.
FD input-file.
       01 csv-lines pic x(100).

FD output-file. 
       01 OUTPUT-RECORD pic u(100). 


 WORKING-STORAGE SECTION. 
       01 END-OF-FILE   PIC X VALUE "N". 
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
       OPEN INPUT input-file 
       OPEN OUTPUT output-file 
         
       perform UNTIL END-OF-FILE = "Y" 
           read input-file INTO csv-lines
               At end 
                 
                   move "Y" to END-OF-FILE
               not at end
                   unstring csv-lines delimited by ","
                       into WS_CUSTOMER_ID, WS_FIRST_NAME, WS_LAST_NAME, WS_STREET, WS_STREET_NUMBER, WS_FLOOR, WS_SIDE, WS_POSTNR, WS_CITY, WS_PHONE, WS_EMAIL

                   

                   MOVE SPACES TO OUTPUT-RECORD

                   string "ID: " delimited by size 
                   function trim(WS_CUSTOMER_ID) delimited by size
                   into OUTPUT-RECORD
                   
                   write OUTPUT-RECORD
                   
                   MOVE SPACES TO OUTPUT-RECORD
                   
                   string "NAVN: " delimited by size
                   function trim(WS_FIRST_NAME) delimited by size   
                   " " delimited by size
                   function trim(WS_LAST_NAME) delimited by size
                   into OUTPUT-RECORD
                   
                   write OUTPUT-RECORD
                   
                   MOVE SPACES TO OUTPUT-RECORD
                   
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
                   
                   write OUTPUT-RECORD
                   
                   MOVE SPACES TO OUTPUT-RECORD
                   
                   string "LOKATION: " delimited by size
                   function trim(WS_POSTNR) delimited by size  
                   ", " delimited by size 
                   function trim(WS_CITY) delimited by size
                   into OUTPUT-RECORD
                   
                   write OUTPUT-RECORD
                   
                   MOVE SPACES TO OUTPUT-RECORD
                   
                   string "TELEFON: " delimited by size
                   function trim(WS_PHONE) delimited by size
                   into OUTPUT-RECORD
                   
                   write OUTPUT-RECORD
                   
                   MOVE SPACES TO OUTPUT-RECORD
                   
                   string "EMAIL: " delimited by size
                   function trim(WS_EMAIL) delimited by size
                   into OUTPUT-RECORD
                   
                   write OUTPUT-RECORD

                   MOVE SPACES TO OUTPUT-RECORD
                   write OUTPUT-RECORD

           end-read
       end-perform
        
       close input-file
       close output-file
stop run.
