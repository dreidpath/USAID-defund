import pdfplumber
import pandas as pd

with pdfplumber.open("defunded.pdf") as pdf:
    all_rows = []
    for page in pdf.pages:
        table = page.extract_table()
        if table:
            all_rows.extend(table)

# Save to spreadsheet
df = pd.DataFrame(all_rows[1:], columns=all_rows[0])  # First row as header
df.to_csv("usaid_defunded.csv", index=False)
df.to_excel("usaid_defunded.xlsx", index=False)
