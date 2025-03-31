# ------------------------------------------------------------------------------
# Script: clean_usaid_contracts.R
#
# Description:
# This script loads two USAID contract datasets ("funded" and "defunded"),
# standardizes and cleans the data, merges them into a single dataframe (`usaidDF`),
# removes newline characters and extra spaces in text fields,
# and exports the cleaned data in three formats: .RData, .tsv, and .xlsx.
#
# Column Mapping (Original CSV -> Standardized Variable Name):
#   "Vendor Name"              -> vendor
#   "Contract Description"     -> contract
#   "Total Estimated Cost"     -> estimated_cost
#   "Obligated Amount"         -> obligated_amount
#   "Contract State Date"      -> start_date
#   "Contract End Date"        -> end_date
#   "Issuing Office"           -> issuing_office
#   "type"                     -> type (no change): funded or defunded
#
# Dependencies:
#   - readr
#   - tidyverse (dplyr, magrittr, etc.)
#   - openxlsx2
#
# Output Files:
#   - usaidDF.RData   : R binary format
#   - usaidDF.tsv     : tab-delimited text
#   - usaidDF.xlsx    : Excel file
# ------------------------------------------------------------------------------


# Load libraries
library(readr)
library(dplyr)
library(stringr)

# Step 1: Read CSV with currency columns as character so we can clean them
defundDF <- read_csv("usaid_defunded.csv", 
                     col_types = cols(
                       `Total Estimated\nCost` = col_character(),       # Must match exact name with newline
                       `Oblibated\nAmount` = col_character(),           # Typo preserved if this is the actual name
                       `Contract State\nDate` = col_date(format = "%m/%d/%Y"),
                       `Contract End Date` = col_date(format = "%m/%d/%Y"),
                       ...11 = col_skip()
                     ))

# Step 2: Clean currency fields by removing $ and , then converting to numeric
defundDF <- defundDF %>%
  mutate(
    `Total Estimated\nCost` = as.numeric(gsub("[$,]", "", `Total Estimated\nCost`)),
    `Oblibated\nAmount` = as.numeric(gsub("[$,]", "", `Oblibated\nAmount`))  # Match the exact column name here
  )

# Step 3: Rename and select the columns you want to keep
defundDF <- defundDF %>%
  select(
    award_id = `Award ID`,
    contract_id = `Contract PIID`,
    vendor = `Vendor Name`,
    contract = `Contract Description`,
    estimated_cost = `Total Estimated\nCost`,
    obligated_amount = `Oblibated\nAmount`,   # Rename typo'd name here
    start_date = `Contract State\nDate`,
    end_date = `Contract End Date`,
    issuing_office = `Issuing Office`,
    type
  )


# === Clean up read errors of the spreadsheet ===

defundDF$end_date[defundDF$award_id == "72061524F00003"] <- as.Date("12/17/2028", format = "%m/%d/%Y")
defundDF$type[defundDF$award_id == "72061524F00003"] <- "defund"

defundDF$estimated_cost[defundDF$award_id == "7200AA23N00001"]<- 62884816.00

defundDF$contract[defundDF$award_id == "72061524F00008"] <- "USAID|KEA / Kenya Primary Education Evaluation & Assessment Program (KPEEAP)"
defundDF$estimated_cost[defundDF$award_id == "72061524F00008"] <- 7499678.00
defundDF$obligated_amount[defundDF$award_id == "72061524F00008"] <- 3326718.00
defundDF$start_date[defundDF$award_id == "72061524F00008"] <- as.Date("10/1/2024", format = "%m/%d/%Y")
defundDF$end_date[defundDF$award_id == "72061524F00008"] <- as.Date("9/30/2028", format = "%m/%d/%Y")
defundDF$issuing_office[defundDF$award_id == "72061524F00008"] <- "American Embassy Nairobi"

defundDF$contract[defundDF$award_id == "72062323D00006"] <- "USAID|Kenya and East Africa Reading for East African's Development (READ) IDIQ."
defundDF$estimated_cost[defundDF$award_id == "72062323D00006"] <- 10000
defundDF$obligated_amount[defundDF$award_id == "72062323D00006"] <- 10000
defundDF$start_date[defundDF$award_id == "72062323D00006"] <- as.Date("1/31/2023", format = "%m/%d/%Y")
defundDF$end_date[defundDF$award_id == "72062323D00006"] <- as.Date("1/30/2028", format = "%m/%d/%Y")
defundDF$issuing_office[defundDF$award_id == "72062323D00006"] <- "American Embassy Nairobi"

defundDF$contract[defundDF$award_id == "72062323D00008"] <- "USAID|Kenya and East Africa Reading for East African's Development (READ) IDIQ."
defundDF$estimated_cost[defundDF$award_id == "72062323D00008"] <- 10000
defundDF$obligated_amount[defundDF$award_id == "72062323D00008"] <- 10000
defundDF$start_date[defundDF$award_id == "72062323D00008"] <- as.Date("1/31/2023", format = "%m/%d/%Y")
defundDF$end_date[defundDF$award_id == "72062323D00008"] <- as.Date("1/30/2028", format = "%m/%d/%Y")
defundDF$issuing_office[defundDF$award_id == "72062323D00008"] <- "American Embassy Nairobi"

defundDF$contract[defundDF$award_id == "72062323D00009"] <- "USAID|Kenya and East Africa Reading for East African's Development (READ) IDIQ."
defundDF$estimated_cost[defundDF$award_id == "72062323D00009"] <- 10000
defundDF$obligated_amount[defundDF$award_id == "72062323D00009"] <- 10000
defundDF$start_date[defundDF$award_id == "72062323D00009"] <- as.Date("1/31/2023", format = "%m/%d/%Y")
defundDF$end_date[defundDF$award_id == "72062323D00009"] <- as.Date("1/30/2028", format = "%m/%d/%Y")
defundDF$issuing_office[defundDF$award_id == "72062323D00009"] <- "American Embassy Nairobi"

defundDF$contract[defundDF$award_id == "72062323D00010"] <- "USAID|Kenya and East Africa Reading for East African's Development (READ) IDIQ."
defundDF$estimated_cost[defundDF$award_id == "72062323D00010"] <- 10000
defundDF$obligated_amount[defundDF$award_id == "72062323D00010"] <- 10000
defundDF$start_date[defundDF$award_id == "72062323D00010"] <- as.Date("1/31/2023", format = "%m/%d/%Y")
defundDF$end_date[defundDF$award_id == "72062323D00010"] <- as.Date("1/30/2028", format = "%m/%d/%Y")
defundDF$issuing_office[defundDF$award_id == "72062323D00010"] <- "American Embassy Nairobi"

defundDF$contract[defundDF$award_id == "72062323D00011"] <- "USAID|Kenya and East Africa Reading for East African's Development (READ) IDIQ."
defundDF$estimated_cost[defundDF$award_id == "72062323D00011"] <- 10000
defundDF$obligated_amount[defundDF$award_id == "72062323D00011"] <- 10000
defundDF$start_date[defundDF$award_id == "72062323D00011"] <- as.Date("1/31/2023", format = "%m/%d/%Y")
defundDF$end_date[defundDF$award_id == "72062323D00011"] <- as.Date("1/30/2028", format = "%m/%d/%Y")
defundDF$issuing_office[defundDF$award_id == "72062323D00011"] <- "American Embassy Nairobi"

defundDF$contract[defundDF$award_id == "72062323D00012"] <- "USAID|Kenya and East Africa Reading for East African's Development (READ) IDIQ."
defundDF$estimated_cost[defundDF$award_id == "72062323D00012"] <- 10000
defundDF$obligated_amount[defundDF$award_id == "72062323D00012"] <- 10000
defundDF$start_date[defundDF$award_id == "72062323D00012"] <- as.Date("1/31/2023", format = "%m/%d/%Y")
defundDF$end_date[defundDF$award_id == "72062323D00012"] <- as.Date("1/30/2028", format = "%m/%d/%Y")
defundDF$issuing_office[defundDF$award_id == "72062323D00012"] <- "American Embassy Nairobi"

defundDF$contract[defundDF$award_id == "72062323D00013"] <- "USAID|Kenya and East Africa Reading for East African's Development (READ) IDIQ."
defundDF$estimated_cost[defundDF$award_id == "72062323D00013"] <- 10000
defundDF$obligated_amount[defundDF$award_id == "72062323D00013"] <- 10000
defundDF$start_date[defundDF$award_id == "72062323D00013"] <- as.Date("1/31/2023", format = "%m/%d/%Y")
defundDF$end_date[defundDF$award_id == "72062323D00013"] <- as.Date("1/30/2028", format = "%m/%d/%Y")
defundDF$issuing_office[defundDF$award_id == "72062323D00013"] <- "American Embassy Nairobi"

defundDF$contract[defundDF$award_id == "72052224P00051"] <- "Pest control services for the USAID|Honduras office building and external areas."
defundDF$estimated_cost[defundDF$award_id == "72052224P00051"] <- 3954.00
defundDF$obligated_amount[defundDF$award_id == "72052224P00051"] <- 3954.00
defundDF$start_date[defundDF$award_id == "72052224P00051"] <- as.Date("6/21/2024", format = "%m/%d/%Y")
defundDF$end_date[defundDF$award_id == "72052224P00051"] <- as.Date("6/30/2025", format = "%m/%d/%Y")
defundDF$issuing_office[defundDF$award_id == "72052224P00051"] <- "USAID/Honduras"

defundDF$contract[defundDF$award_id == "72036724P00012"] <- "To procure 10 units USB D-Link 4G LTE USB Adapter | DWM-222 to be used in Google Meet kits."
defundDF$estimated_cost[defundDF$award_id == "72036724P00012"] <- 2150.00
defundDF$obligated_amount[defundDF$award_id == "72036724P00012"] <- 2150.00
defundDF$start_date[defundDF$award_id == "72036724P00012"] <- as.Date("5/1/2024", format = "%m/%d/%Y")
defundDF$end_date[defundDF$award_id == "72036724P00012"] <- as.Date("4/30/2025", format = "%m/%d/%Y")
defundDF$issuing_office[defundDF$award_id == "72036724P00012"] <- "USAID/Nepal"

defundDF$contract[defundDF$award_id == "72062025P00022"] <- "Ankara padded boxed tissue box w/USAID|Nigeria logo"
defundDF$estimated_cost[defundDF$award_id == "72062025P00022"] <- 1451
defundDF$obligated_amount[defundDF$award_id == "72062025P00022"] <- 1451
defundDF$start_date[defundDF$award_id == "72062025P00022"] <- as.Date("12/11/2024", format = "%m/%d/%Y")
defundDF$end_date[defundDF$award_id == "72062025P00022"] <- as.Date("3/28/2025", format = "%m/%d/%Y")
defundDF$issuing_office[defundDF$award_id == "72062025P00022"] <- "USAID/Nigeria"

defundDF$contract[defundDF$award_id == "72062025P00023"] <- "Laptop bags w/USAID|Nigeria logo"
defundDF$estimated_cost[defundDF$award_id == "72062025P00023"] <- 843
defundDF$obligated_amount[defundDF$award_id == "72062025P00023"] <- 843
defundDF$start_date[defundDF$award_id == "72062025P00023"] <- as.Date("12/11/2024", format = "%m/%d/%Y")
defundDF$end_date[defundDF$award_id == "72062025P00023"] <- as.Date("3/28/2025", format = "%m/%d/%Y")
defundDF$issuing_office[defundDF$award_id == "72062025P00023"] <- "USAID/Nigeria"

defundDF$contract[defundDF$award_id == "72061521A00002"] <- "This is a BPA set up for mobile telephony services for USAID|KEA"
defundDF$estimated_cost[defundDF$award_id == "72061521A00002"] <- 0
defundDF$obligated_amount[defundDF$award_id == "72061521A00002"] <- 0
defundDF$start_date[defundDF$award_id == "72061521A00002"] <- as.Date("10/01/2021", format = "%m/%d/%Y")
defundDF$end_date[defundDF$award_id == "72061521A00002"] <- as.Date("9/30/2025", format = "%m/%d/%Y")
defundDF$issuing_office[defundDF$award_id == "72061521A00002"] <- "American Embassy Nairobi"

# The spreadsheet has two hard to read entries: Award ID 72011424PC00006 and 72044025P00010
# It looks like these are ach a single row, but they are each actually two entries and need
# to be manually fixed

# Fix 72011424PC00006 first, on row 5253
row1 <- which(nchar(defundDF$award_id)==337)
defundDF[row1, ] <-
  list(
    award_id =  "72011424PC00006",
    contract_id ="72011424PC00006",
    vendor =  "Facebook Global Holdings II, LLC",
    contract = "Boosting USAID Ads on Facebook",
    estimated_cost =  7600.00,
    obligated_amount =  7600.00,
    start_date = as.Date("5/1/2024", format = "%m/%d/%Y"), 
    end_date = as.Date("4/30/2025", format = "%m/%d/%Y"),
    issuing_office = "USAID/Georgia", 
    type = "defund" 
  )

new_row <-   list(
  award_id =  "72044224F50003",
  contract_id = "72044224F50003"  ,
  vendor = "COUNTERTRADE PRODUCTS INC" ,
  contract = "To Purchase CLIN 0011B 220V HP Color LaserJet Ent 5700dn(220V) includes 3JN69A (OLM)",
  estimated_cost =  7543.00,
  obligated_amount =  7543,
  start_date = as.Date("2/4/2019", format = "%m/%d/%Y"), 
  end_date = as.Date("9/30/2025", format = "%m/%d/%Y"),
  issuing_office = "USAID/Cambodia", 
  type = "defund" 
)

defundDF <- rbind(defundDF[1:row1, ],
                  new_row,
                  defundDF[(row1+1):nrow(defundDF), ])


# Fix 72044025P00010 first, on row 4633
row1 <- which(nchar(defundDF$award_id)==352)
defundDF[row1, ] <-
  list(
    award_id =  "72044025P00010",
    contract_id ="72044025P00010",
    vendor =  "COUNTERTRADE PRODUCTS INC",
    contract = "Procurement of 02 Curved Monitors for USAID/VIETNAM",
    estimated_cost =  2795,
    obligated_amount =  2795.00,
    start_date = as.Date("1/22/2025", format = "%m/%d/%Y"), 
    end_date = as.Date("9/30/2025", format = "%m/%d/%Y"),
    issuing_office = "USAID/Vietnam", 
    type = "defund" 
  )

new_row <-   list(
  award_id =  "72061324P00062",
  contract_id = "72061324P00062"  ,
  vendor = "Chibanguza Motor Car Spares and Repairs T/A Christmas Pass Hotel" ,
  contract = "Venue for Inclusive Opportunity Career Fairs - IOCF in Mutare",
  estimated_cost =  2783.00,
  obligated_amount =  2783.00,
  start_date = as.Date("10/1/2024", format = "%m/%d/%Y"), 
  end_date = as.Date("1/28/2025", format = "%m/%d/%Y"),
  issuing_office = "", 
  type = "defund" 
)

defundDF <- rbind(defundDF[1:row1, ],
                  new_row,
                  defundDF[(row1+1):nrow(defundDF), ])

rm(row1)
rm(new_row)


# === Read and clean funded contracts ===
# Step 1: Read in the CSV file with currency fields as character for cleanup
fundDF <- read_csv("usaid_funded.csv", 
                   col_types = cols(
                     `Total Estimated Cost` = col_character(),     # Read as text first
                     `Obligated Amount` = col_character(),         # Same here
                     `Contract State Date` = col_date(format = "%m/%d/%Y"),
                     `Contract End Date` = col_date(format = "%m/%d/%Y")
                   )) %>%
  
  # Step 2: Clean and convert currency columns to numeric
  mutate(
    `Total Estimated Cost` = as.numeric(gsub("[$,]", "", `Total Estimated Cost`)),
    `Obligated Amount` = as.numeric(gsub("[$,]", "", `Obligated Amount`))
  ) %>%
  
  # Step 3: Select and rename relevant columns
  select(
    award_id = `Award ID`,
    contract_id = `Contract PIID`,
    vendor = `Vendor Name`, 
    contract = `Contract Description`,
    estimated_cost = `Total Estimated Cost`,
    obligated_amount = `Obligated Amount`,
    start_date = `Contract State Date`,
    end_date = `Contract End Date`,
    issuing_office = `Issuing Office`,
    type
  )

# === Combine the two dataframes ===
usaidDF <- rbind(fundDF, defundDF)

# Remove intermediate dataframes to clean up workspace
rm(defundDF)
rm(fundDF)

# === Clean up text fields: remove newlines, collapse spaces ===
usaidDF[] <- lapply(usaidDF, function(col) {
  if (is.character(col)) {
    col <- gsub("\n", " ", col)        # Replace newline characters with space
    col <- gsub("\\s+", " ", col)      # Replace multiple whitespace with single space
    col <- trimws(col)                 # Trim leading and trailing whitespace
  }
  col
})


# === Export data ===
save(usaidDF, file = "usaidDF.RData")                     # Save as .RData
write.table(usaidDF, file = "usaidDF.tsv", sep = "\t", row.names = FALSE)  # Tab-delimited text
writexl::write_xlsx(usaidDF, path = "usaidDF.xlsx")               # Excel format
