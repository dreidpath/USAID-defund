# Load required packages
library(tidyverse)
library(scales)  # for label_number()

#----- Step 0: Load the USAID contracts data

# Load pre-processed USAID funding dataframe
load("usaidDF.RData")


#----- Step 1: Define vendor keyword aliases

# Each named element corresponds to a "Vendor", and each contains a vector of keywords/aliases
keyword_aliases <- list(
  "FAO"    = c("FOOD AND AGRICULTURE ORGANIZATION"),
  "WFP"     = c("WORLD FOOD"),
  "UNFPA"     = c("UNFPA"),
  "UNICEF"   = c("UNICEF"),
  "WHO"  = c("WHO", "WORLD HEALTH")
)


#----- Step 2: Detect presence of any alias for each vendor in the 'vendor' text

# For each vendor's keyword list, check if any alias is present in the contract description
# Use `map_dfc` to return a dataframe (one column per vendor)

keyword_presence_df <- map_dfc(keyword_aliases, function(aliases) {
  pattern <- str_c(aliases, collapse = "|") %>% tolower()  # combine aliases into one regex pattern
  str_detect(tolower(usaidDF$vendor), pattern)           # case-insensitive matching
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


#----- Step 5: Define function to calculate vendor-level impact

vendor_impact <- function(df, vendor) {
  vendor <- enquo(vendor)  # capture the column (as a quosure) passed to the function
  
  df %>%
    filter(!!vendor == TRUE) %>%  # filter rows where the vendor column is TRUE
    summarise(
      total_value     = sum(value, na.rm = TRUE),
      total_loss      = sum(loss, na.rm = TRUE),
      total_contract  = sum(estimated_cost, na.rm = TRUE)
    )
}


#----- Step 6: Apply vendor_impact across all vendors and combine results

# Loop over keyword_aliases list: for each vendor, compute summary stats
# Then bind all results into one dataframe

vendorDF <- imap_dfr(keyword_aliases, function(keywords, vendor_col) {
  
  # Apply vendor impact function to the appropriate column in the dataframe
  vendorDF <- vendor_impact(usaidDF_key, !!sym(vendor_col))
  
  # Add vendor name and keywords used to detect it
  vendorDF$vendor <- vendor_col

  vendorDF  # return one-row tibble
})


#----- Final Result

# `results` now contains total value, total loss, total contract value,
# vendor name, and associated keywords per vendor

print(vendorDF)


#--------- Plot the Loss

# Plot total_loss only, scaled to millions
ggplot(vendorDF, aes(x = vendor, y = total_loss / 1e6)) +
  geom_bar(stat = "identity", fill = "firebrick") +
  scale_y_continuous(
    labels = label_number(suffix = "M", accuracy = 1),
    name = "Total Loss (Millions USD)"
  ) +
  labs(
    title = "USAID Contract Loss by UN Agency",
    x = "UN Agency"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(size = 12),
    plot.title = element_text(face = "bold", hjust = 0.5)
  )
