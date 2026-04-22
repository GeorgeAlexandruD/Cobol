identification division.
       program-id. ReadWriteFile.

environment division.
input-output section.
file-control.
       select input-file assign to "6-KundeData.csv"
           organization is line sequential.
       select output-file assign to "6-KundeOutput.txt"
           organization line sequential.

data division.
file section.
FD input-file.
       01 csv-lines pic x(50).

FD OUTPUT-FILE. 
       01 OUTPUT-RECORD. 
           05 FIRST-NAME    PIC X(6).
           05 AGE     PIC 99.

 WORKING-STORAGE SECTION. 
       01 END-OF-FILE   PIC X VALUE "N". 
       01 persons-datafile-name pic x(6).
       01 persons-datafile-age pic 99.



PROCEDURE DIVISION. 
        OPEN INPUT input-file 
        OPEN OUTPUT output-file 
         
        perform UNTIL END-OF-FILE = "Y" 
            read input-file INTO csv-lines
               At end 
                   move "Y" to END-OF-FILE
               not at end
                   unstring csv-lines delimited by ","
                       into persons-datafile-name, persons-datafile-age
                   move persons-datafile-name to FIRST-NAME
                   move persons-datafile-age to AGE
                   write OUTPUT-RECORD
                   display "NAME: " FIRST-NAME ", Age: " AGE
            end-read
        end-perform
        
        close input-file
        close output-file
stop run.
