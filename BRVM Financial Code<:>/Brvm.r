library(BRVM)
library(tidyverse)
library(tibble)
library(repr)
library(dplyr)
library(formattable)
library(scales)
library(readr)
library(rvest)
library(openxlsx)
library(janitor)

# Extract BRVM Info with BRVM_ticker_desc
brvm_info <- BRVM_ticker_desc()

# Extract tickers from ticker_info
tickers <- brvm_info$Ticker

# Retrieve BRVM information for the BRVM tickers
brvm_info_list <- BRVM_get(.symbol = tickers, .from = "2020-01-01", .to = Sys.Date())

# Merge the BRVM information retrieved for the specified tickers
# with additional BRVM information based on the common column "Ticker"
BRVM_frame <- merge(brvm_info_list, brvm_info, by = "Ticker")

# Display a message indicating the process of loading BRVM Market Cap information
cat("Loading BRVM Market Cap Info\n")

# Load BRVM market cap data
B_Market <- BRVM_cap()

# Rename the columns
B_Market <- B_Market %>%
  rename(Ticker = Symbol,
         `Market Cap` = `Global capitalization`,
         `Market Percentage` = `Global capitalization (%)`) %>%
  select(Ticker, `Market Cap`, `Market Percentage`)

# Format the "Market Cap" column as currency
B_Market$`Market Cap` <- currency(B_Market$`Market Cap`)

# Sort the data frame by "Market Cap" column in descending order
B_Market <- arrange(B_Market, desc(`Market Cap`))

# Convert Market Percentage column to numeric
B_Market <- B_Market %>%
mutate(`Market Percentage` = as.numeric(`Market Percentage`))

# Print the modified data
print(B_Market)

# Merge BRVM dataframes by Ticker
BRVM_columns <- merge(BRVM_frame, B_Market, by = "Ticker") %>%

# Rename Company name column to Company
rename(Company = `Company name`) %>%

# Select relevant columns for BRVM analysis
select(Ticker,Sector, Company, Country, Date, Open, High, Low, Close, Volume, `Market Cap`, `Market Percentage`) %>%

# Arrange data by Market Cap in descending order
arrange(desc(`Market Cap`))

glimpse(BRVM_columns)

# Calculates the percentage difference between the "Open" and "Close" prices for each row in your dataframe

BRVM_columns <- BRVM_columns %>%
  mutate(Difference = round(((Close - Open) / Open) * 100, 2)) %>%
  select(Ticker, Sector, Company, Country, Date, Open, High, Low, Close, Difference, Volume, `Market Cap`, `Market Percentage`)

glimpse(BRVM_columns)


# Sort dataframe in ascending order by a specific column
BRVM_columns_asc <- arrange(BRVM_columns, Date)

# Sort dataframe in descending order by a specific column
BRVM_columns_desc <- arrange(BRVM_columns, desc(Date))

# Sort dataframe in descending 
glimpse(BRVM_columns_desc)

# Select the first 40 rows of BRVM_columns_desc to create Realtime_BRVM
Realtime_BRVM <- head(BRVM_columns_desc, 40)

cat('Realtime BRVM Data Columns')

Realtime_BRVM

# Retrieve BRVM index data and store it in brvm_sector
brvm_sector <- BRVM_index()

# Rename the column "Indexes" to "Sector" in the brvm_sector dataframe
brvm_sector <- brvm_sector %>%
  rename(Sector = Indexes)

# Print a message indicating that BRVM Indexes are being loaded
print("Loading BRVM Indexes")

# Print the brvm_sector dataframe
brvm_sector

BRVM_columns_desc$`Market Cap` <- as.numeric(gsub(",", "", BRVM_columns_desc$`Market Cap`))


glimpse(BRVM_columns_desc)

# Exporting DataFrame into an Excel file for BRVM Sectors

# Write the DataFrame to an Excel file

write.xlsx(brvm_sector, "/Users/quantumsphere/Desktop/BRVM Project/BRVM-Analyzer/BRVM Excel R files/BRVM_Sectors.xlsx", overwrite = TRUE)

cat("New Excel file written successfully.\n")

# Convert the Date column to character type
Realtime_BRVM$Date <- as.character(Realtime_BRVM$Date)

# Export the DataFrame to an Excel file
write.xlsx(Realtime_BRVM, "/Users/quantumsphere/Desktop/BRVM Project/BRVM-Analyzer/BRVM Excel R files/Realtime_BRVM.xlsx", overwrite = TRUE)

cat("New Excel file written successfully.\n")

# Define the file path for the CSV file
file_path <- "/Users/quantumsphere/Desktop/BRVM Project/BRVM-Analyzer/BRVM Tableau R files/BRVM_Historical_TL.csv"

# Check if the file already exists
if (file.exists(file_path)) {
  # If the file exists, remove it
  file.remove(file_path)

  # Display message indicating the existing file is removed
  cat("Existing file removed.\n")
}

# Write the new CSV file
write.csv(BRVM_columns_desc, file = file_path, row.names = FALSE)

# Display message indicating the new CSV file is written
cat("New CSV file written successfully.\n")
