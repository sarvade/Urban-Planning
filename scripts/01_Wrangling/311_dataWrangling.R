rm(list=ls())
gc()

library(tidyverse)

setwd(config::get("working_path"))

# read in all of the 311 public data extract files in .txt format (the default export from their website)
files <- list.files(pattern = "311-Public-Data-Extract.*?.txt", recursive=TRUE)

# read each dataset in, filter to only fire-related calls and relevant columns
# then export as a combined file
files %>% 
  map_dfr(read_delim, delim = "|") %>% 
  clean_names() %>% 
  filter(department %in% c("HFD Houston Fire Department", "HPD Houston Police Department")) %>% 
  filter(division != "Customer Escalation" & division != "Mental Health") %>% 
  select(latitude, longitude, overdue) %>% 
  write_csv("data/311_cleaned.csv")