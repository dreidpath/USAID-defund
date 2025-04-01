# Load required packages
library(tidyverse)
library(scales)  # for label_number()

#----- Step 0: Load the USAID contracts data

# Load pre-processed USAID funding dataframe
load("usaidDF.RData")


#----- Step 1: Define sector keyword aliases

# Each named element corresponds to a "sector", and each contains a vector of keywords/aliases
keyword_aliases <- list(
  "HIV"    = c("hiv", "aids"),
  "TB"     = c("tb", "tuberculosis"),
  "FP"     = c("family planning", "fp", "reproductive", "srhr", "srh"),
  "WASH"   = c("wash", "water", "sanitation", "hygiene"),
  "Child"  = c("child", "children", "infant", "infants", "adolescent", "adolescents")
)


#----- Step 2: Detect presence of any alias for each sector in the 'contract' text

# For each sector's keyword list, check if any alias is present in the contract description
# Use `map_dfc` to return a dataframe (one column per sector)

keyword_presence_df <- map_dfc(keyword_aliases, function(aliases) {
  pattern <- str_c(aliases, collapse = "|") %>% tolower()  # combine aliases into one regex pattern
  str_detect(tolower(usaidDF$contract), pattern)           # case-insensitive matching
})

# Assign proper column names to the presence indicators (e.g., 'hiv', 'tb', etc.)
names(keyword_presence_df) <- names(keyword_aliases)


#----- Step 3: Merge keyword presence with original dataframe

# Bind the new logical columns indicating keyword presence to the original data
usaidDF_key <- bind_cols(usaidDF, keyword_presence_df)

# Optional: remove temporary variable to clean up workspace
rm(keyword_presence_df)


#----- Step 4: Calculate value and loss per contract

# Add 'value' and 'loss' columns depending on the contract type
usaidDF_key <- usaidDF_key %>%
  mutate(
    value = if_else(type == "funded", estimated_cost, obligated_amount, missing = NA_real_),
    loss = if_else(
      type == "funded",
      0,  # no loss if funded
      obligated_amount - estimated_cost,  # difference is loss
      missing = NA_real_
    )
  )


#----- Step 5: Define function to calculate sector-level impact

sector_impact <- function(df, sector) {
  sector <- enquo(sector)  # capture the column (as a quosure) passed to the function
  
  df %>%
    filter(!!sector == TRUE) %>%  # filter rows where the sector column is TRUE
    summarise(
      total_value     = sum(value, na.rm = TRUE),
      total_loss      = sum(loss, na.rm = TRUE),
      total_contract  = sum(estimated_cost, na.rm = TRUE)
    )
}


#----- Step 6: Apply sector_impact across all sectors and combine results

# Loop over keyword_aliases list: for each sector, compute summary stats
# Then bind all results into one dataframe

sectorDF <- imap_dfr(keyword_aliases, function(keywords, sector_col) {
  
  # Apply sector impact function to the appropriate column in the dataframe
  sectorDF <- sector_impact(usaidDF_key, !!sym(sector_col))
  
  # Add sector name and keywords used to detect it
  sectorDF$sector <- sector_col

  sectorDF  # return one-row tibble
})


#----- Final Result

# `results` now contains total value, total loss, total contract value,
# sector name, and associated keywords per sector

print(sectorDF)


#--------- Plot the Loss

# Plot total_loss only, scaled to millions
ggplot(sectorDF, aes(x = sector, y = total_loss / 1e6)) +
  geom_bar(stat = "identity", fill = "firebrick") +
  scale_y_continuous(
    labels = label_number(suffix = "M", accuracy = 1),
    name = "Total Loss (Millions USD)"
  ) +
  labs(
    title = "USAID Contract Loss by Sector",
    x = "Sector"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(size = 12),
    plot.title = element_text(face = "bold", hjust = 0.5)
  )
