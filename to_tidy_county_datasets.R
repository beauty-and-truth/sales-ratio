library(rprojroot)
library(tidyverse)
library(lubridate)

setwd(find_root_file(criterion = is_git_root, path = "."))

# list all CSVs in the directory:
countyFiles <- list.files(file.path(".", "inputs", "raw_county"))

for (i in countyFiles){
  # county name:
  coName <- paste(str_extract(i, "^[a-z]+"))
  # read counties:
  homes <- read_csv(file.path(".", "inputs", "raw_county", 
                               paste(coName, "_all.csv", sep = "")),
                     col_types = cols(
                       "Municipality" = col_character(), 
                       "Grantor's Name (Seller)" = col_character(), 
                       "Grantor's Mailing Address" = col_character(), 
                       "Grantor's City/State/Zip" = col_character(), 
                       "Grantee's Name (Buyer)"= col_character(), 
                       "Grantee's Mailing Address" = col_character(), 
                       "Grantee's City/State/Zip" = col_character(), 
                       "Property Location" = col_character(), 
                       "Block" = col_character(),
                       "Lot" = col_character(), 
                       "Qual" = col_character(), 
                       "Property Class" = col_character(), 
                       "Land Assmnt" = col_double(), 
                       "Building Assmnt" = col_double(), 
                       "Total Assmnt" = col_double(), 
                       "Recorded Date" = col_date(format = "%Y-%m-%d"), 
                       "Deed Date" = col_date(format = "%Y-%m-%d"), 
                       "Book" = col_character(), 
                       "Page" = col_character(), 
                       "Sale Price" = col_double(),
                       "NU Code" = col_character(), 
                       "Sq. Ft." = col_double(), 
                       "Cl. 4 Use" = col_character(), 
                       "SR1A #"  = col_character(), 
                       "Yr. Built" = col_double(), 
                       "StyDesc" = col_character(), 
                       "Style" = col_character(), 
                       "Latitude" = col_double(), 
                       "Longitude" = col_double())
                     )
  
  }
  # remove empty, header-less columns from CSVs, avoid future parsing errors:
  homes <- homes[, 1:29]
  
  # Filter useful data:
  # select appropriate date range and relevant columns
  homes <- homes %>%
    filter(is.na(`NU Code`),      # Non-Usable properties have NU code
           `Sale Price` > 500,    # Low sale price indicates NU that lacks a code
           `Property Class` == 2,     # Residential only
           `Deed Date` >= ymd(20190101), 
           `Deed Date` <= ymd(20200930)) %>%
    dplyr::select(Municipality, `Land Assmnt`, `Building Assmnt`,
                  `Total Assmnt`, `Deed Date`, `Sale Price`) %>%
    rename(twp = Municipality, assmnt = `Total Assmnt`, date = `Deed Date`, 
           price = `Sale Price`) 
  
  # Error correction: in some counties, many rows show total and building assessment are flipped
  if(coName %in% c("capemay", "essex", "hunterdon", "mercer", "somerset", "warren")){
    # Flag the error (exclude condos: `Land Assmnt` > 0):
    y <- tidied$`Land Assmnt` > 0 & 
      tidied$`Land Assmnt` + tidied$assmnt == tidied$`Building Assmnt`
    
    # Correct the Total Assessment value
    for (j in seq_len(nrow(tidied))) {if(y[j]){tidied$assmnt[j] <- tidied$`Building Assmnt`[j]}}
    
    # remove building assmnt and land assmnt columns, and any rows with missing information.
    tidied <- tidied %>% 
      select(twp, assmnt, date, price) %>%
      na.omit()
  
  write_csv(homes, file.path(".", "inputs", "tidy_county", 
                              paste(coName, "_tidied.csv", sep="")))
}
