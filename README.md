# COBOL Exercise Series

A hands-on introduction to COBOL covering the full progression from syntax basics through
file I/O, data structures, statistical analysis, and fraud detection. All exercises target
GnuCOBOL and use a consistent banking/customer dataset across the later tasks, so each
program builds naturally on the last.

---

## Exercise 1 – Your First COBOL Program
**Topics:** Program skeleton, `DISPLAY`, `PIC` clauses, variable declaration

The classic entry point. Part 1 is Hello World, establishing the four-division structure
(`IDENTIFICATION`, `ENVIRONMENT`, `DATA`, `PROCEDURE`) that every COBOL program follows.
Part 2 introduces the first variable with a `PIC` clause and a `MOVE`/`DISPLAY` pair.

The column-based structure of COBOL is one of the first surprises here — code must start
in column 8 (Area A) or column 12 (Area B) depending on what it is, a direct legacy of
80-column punch cards.

---

## Exercise 2 – Variables and MOVE
**Topics:** Multiple variables, `MOVE`, numeric vs alphanumeric `PIC` clauses, `DISPLAY`

Expands on Exercise 1 by working with several variables at once and moving data between
them. Covers the distinction between alphanumeric (`PIC X`) and numeric (`PIC 9`) fields,
and what happens when you move data between incompatible types.

---

## Exercise 3 – Loops and String Handling
**Topics:** `PERFORM`, `STRING`, `FUNCTION TRIM`, space padding

Introduces loops and the basics of string manipulation in COBOL. The main task is
combining a first and last name into a single field, which immediately surfaces one of
COBOL's quirks: all `PIC X` fields are fixed-width and space-padded, so trimming and
concatenating requires explicit handling rather than anything automatic.

Part 2 deals with stripping the excess spaces that result, and Part 3 brings it together
by printing formatted customer info — a pattern that recurs in every subsequent exercise.

---

## Exercise 4 – Structures in COBOL
**Topics:** Level numbers (`01`, `02`), group items, hierarchical data layout

Covers how COBOL organises data into structures using level numbers instead of something
like a `struct`. A level `01` item is the top of the hierarchy; `02` and below are its
fields. The whole group can be moved or written as a unit, which becomes important once
files are involved.

---

## Exercise 5 – Copybooks
**Topics:** `COPY` statement, `.cpy` files, reusable record definitions

Introduces copybooks — COBOL's equivalent of a shared header file. A record layout
defined once in a `.cpy` file can be included into any program with a single `COPY`
statement. From this point on, the shared customer and transaction layouts are defined as
copybooks and reused across all remaining exercises.

---

## Exercise 6 – Reading a File
**Topics:** `FD`, `SELECT`, `LINE SEQUENTIAL`, `READ`, `AT END`

The first file I/O exercise. Sets up a file descriptor (`FD`) and a `SELECT` clause to
bind a logical name to a physical file, then reads records in a loop using `AT END` to
detect when the file is exhausted. The record layout from the copybook slots directly into
the `FD`.

---

## Exercise 7 – Writing to a File
**Topics:** `OPEN OUTPUT`, `WRITE`, paragraphs, output formatting

Pairs with Exercise 6 — reads the same customer file and writes an output file. Part 2
introduces reformatting the data on the way out (restructuring fields, building output
lines with `STRING`). Part 3 introduces paragraphs as a way to break procedure logic into
named, callable sections, replacing the flat top-to-bottom style used so far.

---

## Exercise 8 – Reading Multiple Files
**Topics:** Multiple `FD` entries, correlated file reads, rewinding via close/reopen

Joins two files: a customer file and an account file. For each customer record, the
account file is rewound (closed and reopened) and scanned for matching records by
customer ID. This is the exercise where the "last record bug" is easy to introduce —
placing the file2 lookup outside the `NOT AT END` block causes the final customer to skip
their account lookup, though it only manifests if that customer actually has accounts.

---

## Exercise 9 – Arrays
**Topics:** `OCCURS`, indexed access, loading file data into memory

Introduces `OCCURS` to define tables (arrays) in `WORKING-STORAGE`. Rather than
processing records one at a time as they come off the file, data is loaded into an
in-memory table first and then processed. This sets up the pattern used heavily in
Exercises 11 and 12.

---

## Exercise 10 – Bank Statement Generator
**Topics:** Multi-file correlation, formatted output, running totals, currency fields

Produces a per-customer bank statement by correlating the customer file, account file,
and transaction file. Introduces signed numeric fields (`PIC S9(13)V99`) for balances and
edited display pictures (`PIC -Z(11).99`) for formatted monetary output. The `V`
(implied decimal) vs actual decimal distinction is worth paying attention to here.

---

## Exercise 11 – Statistics and Analysis
**Topics:** Aggregation, sorting, standard deviation, monthly breakdowns

Reads the full transaction dataset and produces several layers of analysis:

- **Top 20 customers by balance** — requires sorting, implemented as a bubble sort over
  the in-memory customer table. The sort uses the last slot of the `OCCURS` table as a
  scratch buffer for swapping, since COBOL has no native swap syntax.

- **Monthly cashflow** — incoming and outgoing totals bucketed by month, extracted from
  the timestamp field using a substring reference (`TIDSPUNKT(6:2)`).

- **Payment type breakdown** — counts of deposits, withdrawals, and transfers per month,
  stored in a two-dimensional `OCCURS` table.

- **Top 5 shops by turnover** — shops are discovered dynamically as transactions are read,
  then sorted by turnover in a second bubble sort pass.

- **Standard deviation** — requires two full passes over the file. The first pass
  computes the mean; the file is then closed, reopened, and read again to accumulate the
  squared deviations. COBOL's `FUNCTION SQRT` handles the final step.

---

## Exercise 12 – Fraud Detection and AML
**Topics:** Fuzzy string matching, Levenshtein distance, sanctions list screening

The capstone exercise. Implements a basic Anti-Money Laundering (AML) screening system
that checks customer names against a sanctions watchlist — not with exact matching, but
with fuzzy matching using **Levenshtein edit distance**.

Levenshtein distance counts the minimum number of single-character edits (insertions,
deletions, substitutions) needed to turn one string into another. It is computed using
dynamic programming with a two-dimensional `OCCURS` table in `WORKING-STORAGE`, filled
row by row using a tabulation approach (bottom-up DP) rather than recursion, which COBOL
does not support in any practical sense.

A configurable threshold determines how close a name needs to be to a watchlist entry to
trigger a flag. This makes the matcher tolerant of typos, transliterations, and
deliberate obfuscation — the core challenge in real AML systems.

Part 2 extends the exercise with additional detection scenarios.

---

## Notes

- All programs target **GnuCOBOL** and compile with `cobc`.
- Shared record layouts live in `.cpy` copybooks and are referenced via `COPY`.
- Numeric currency fields use `PIC S9(13)V99` throughout; display formatting uses edited
  pictures like `PIC -Z(11).99`.
- The bubble sort implementations use the last allocated slot of each `OCCURS` table as
  a swap buffer — a common COBOL pattern given the absence of a native temp-variable swap.
- The full exercise list and set up can be found in the .pdf files.
- Example compile instructions `./cobbuild.bat -x .\12-Antimoneylaudering.cob -o opgave12.exe -lcob`
