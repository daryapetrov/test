rm(list = ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(XLConnect)
library(magrittr)
library(tidyverse)
library(reshape2)
library(lubridate)
library(plyr)

importWorksheets <- function(filename) {
  # filename: name of Excel file
  workbook <- loadWorkbook(filename)
  sheet_names <- getSheets(workbook)
  names(sheet_names) <- sheet_names
  sheet_list <- lapply(sheet_names, function(.sheet){
    readWorksheet(object=workbook, .sheet)})
}
Kerala_hosp = importWorksheets(filename = "KerelaHosp.xlsx")
miss = unique(sapply(1:length(Kerala_hosp), function(ind) names(Kerala_hosp[[ind]])[1]))
pos = which(sapply(1:length(Kerala_hosp), function(ind) names(Kerala_hosp[[ind]])[1]) == miss[2])
Kerala_hosp = Kerala_hosp[-pos]

Kerala_hosp_data = do.call(rbind, Kerala_hosp)
Kerala_hosp_data = Kerala_hosp_data[complete.cases(Kerala_hosp_data), ]
Kerala_hosp_data_total = Kerala_hosp_data[Kerala_hosp_data$District == "TOTAL",] 

date_seq = seq(as.Date('2020-04-01'), as.Date('2021-03-31'), by = "1 day")
date_seq = date_seq[-pos]
Kerala_hosp_data_total = Kerala_hosp_data_total[,-1]
Kerala_hosp_data_total$Date = date_seq

states_darya = read.csv("states.csv")
states_darya_kerala = states_darya[states_darya$State == "Kerala",]
states_darya_kerala$Date = as.Date(states_darya_kerala$Date)
kerala_df = inner_join(states_darya_kerala, Kerala_hosp_data_total, by = "Date")
names(kerala_df)[names(kerala_df) == 'Total'] = "Total_Hosp"
names(kerala_df)[names(kerala_df) == 'Hospital']  = "Hospitalized"
names(kerala_df)[names(kerala_df) == 'Home'] = "Home_Quarantined"
names(kerala_df)[names(kerala_df) == 'Hosp..Today']  = "Hospitalized_Today"
str(kerala_df)


save(kerala_df, file="./kerala_df.Rda")


