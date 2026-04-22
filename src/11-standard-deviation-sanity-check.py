import statistics
import csv

amounts = []
with open("Transaktioner.txt", encoding="latin-1") as f:
    for line in f:
        beloeb = float(line[126:141].strip())
        valuta = line[141:145].strip()
        if valuta == "USD":
            beloeb *= 6.8
        elif valuta == "EUR":
            beloeb *= 7.5
        amounts.append(beloeb)
print(statistics.mean(amounts))
print(statistics.stdev(amounts))