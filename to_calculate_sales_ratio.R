library(rprojroot)
library(tidyverse)
library(lubridate)

setwd(find_root_file(criterion = is_git_root, path = "."))

countyFiles <- list.files(file.path("~", "inputs", "tidy_county"))

for(i in countyFiles){
  # county name:
  coName <- paste(str_extract(i, "^[a-z]+"))
  # read_csv:
  tidied <- read_csv(file.path("~", "inputs", "tidy_county", i))
  
  ###### NAIVE OUTLIERS #############
  
  # Create naive sales ratio (assessment/price) with which to identify outliers:
  tidied <- tidied %>%
    mutate(naiveSR = assmnt / price) %>%
    # Group by township, property type
    group_by(twp, class) %>%
    nest() %>%
    # sapply takes each element of tidied$data and performs a summary stat function on it
    mutate(  AVG = sapply(data, function (x) mean(x$naiveSR)),
             SD = sapply(data, function (x) sd(x$naiveSR)),
             Q1 = sapply(data, function (x) quantile(x$naiveSR, probs = 0.25)),
             Q3 = sapply(data, function (x) quantile(x$naiveSR, probs = 0.75)),
             IQR = (Q3 - Q1),
             N = sapply(data, nrow)
    )
  # Assign each group an integer value, to re-group the same way later:
  tidied$nestIndex <- 1:nrow(tidied)
  
  # Identify outliers
  tidied <- tidied %>%
    unnest(cols = c(data)) %>%
    mutate (outlier = naiveSR < (Q1 - 1.5*IQR) | naiveSR > (Q3 + 1.5*IQR))

  ###### MARKET TRENDS #############
  
  inliers <- tidied %>%
    # for each row, count the number of months since the start of the study
    filter(outlier == FALSE) %>%
    mutate(studyMonth = ifelse(year(date) == 2019, month(date), month(date) + 12)) %>%
    # Only use large enough groups (>= 30 inliers)
    group_by(nestIndex, N) %>%
    nest() %>%
    filter (N >= 30)
  
  # Define the function that produces the market trend line:
  marketTrendFunc <- function(df){
    lm(log(price / assmnt) ~ studyMonth, data = df) 
  }
  
  # Apply the market trend function to the outer data frame:
  inliers <- inliers %>%
    mutate(marketTrend = map(data, marketTrendFunc),
           # return the slope of marketTrend:
           monthlyGrowth = sapply(marketTrend, function(x) x$coefficients[2]),
           # significant = TRUE at 90% conf level if p <= 0.1:
           significant = sapply(marketTrend, function(x) {
             (summary(x)$coefficients[2,4]) <= 0.1}),
           # If slope is significant, use Annual Market Condition Trend Equation. 
           # Else annualGrowth = 0.
           annualGrowth = ifelse(significant == TRUE, (1 + monthlyGrowth)^12 - 1, 0))
  
  ###### PRICE ADJUSTMENTS ###############
  
  # Join inliers and tidied to include groups with N < 30:
  tidied <- left_join(tidied, inliers[,c("nestIndex", "monthlyGrowth", "significant", "annualGrowth")], by = "nestIndex") 
  
  tidied <- tidied %>%
    mutate(adjPrice = if_else(significant, 
                              # adjPrice = Price * [(1 + monthlyGrowth)^adj_months],
                              # where adj_months = months until assessment date
                              # (negative, in this case, to Jan 1 of the given year)
                              price * (1 + monthlyGrowth)^((-1)*(month(date) - 1)),
                              price,
                              missing = price))
  
 # Calculate the Final Sales Ratio for each property: 
  tidied <- tidied %>%
    mutate(adjSR = assmnt / adjPrice,
           county = coName)
  
  write_csv(homes, file.path("~", "inputs", "transformed_county", 
                             paste(coName, "_transformed.csv", sep="")))

}

###### SUMMARY STATISTICS: ###################

# get mean and aggregate sales ratios per group
ratioSummary <- tidied %>%
  group_by(nestIndex) %>%
  summarize(meanRatio = mean(adjSR), 
            aggRatio = sum(adjSR), 
            medianRatio = median(adjSR))
# Generally, a median ratio between 90% and 105% is considered in compliance

