setwd("C:/Users/keost/Documents/Datasets")

# libraries
library(tidyverse)
library(RODBC)

# creating the sql connection
db_conn = odbcConnect("NewDSN", rows_at_time=1)

if(db_conn==-1) {
  quit("no", 1)
}

db_conn==-1

# 2020 data (DONE)
df1 = read_csv("2020_hotel_data.csv")
janitor::clean_names(df1)
glimpse(df1)

sqlSave(db_conn, df1, tablename = "2020_hotel_data", append=FALSE, rownames=FALSE)

# 2019 data (DONE)
df2 = read_csv("2019_hotel_data.csv")
janitor::clean_names(df2)
glimpse(df2)

sqlSave(db_conn, df2, tablename = "2019_hotel_data", append=FALSE, rownames=FALSE)

# 2018 data (DONE)
df3 = read_csv("2018_hotel_data.csv")
janitor::clean_names(df3)
glimpse(df3)

sqlSave(db_conn, df3, tablename = "2018_hotel_data", append=FALSE, rownames=FALSE)

# meal cost
df4 = read_csv("hotel_meal_cost.csv")
janitor::clean_names(df4)
glimpse(df4)

sqlSave(db_conn, df4, tablename = "hotel_meal_cost", append=FALSE, rownames=FALSE)


# market segment
df5 = read_csv("hotel_market_segment.csv")
janitor::clean_names(df5)
glimpse(df5)

sqlSave(db_conn, df5, tablename = "hotel_market_segment", append=FALSE, rownames=FALSE)








