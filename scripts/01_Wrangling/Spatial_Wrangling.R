# clear our environment and load libraries
rm(list = ls())
gc()

library(tidyverse)

# reading in raw spatial dataset
df <- read_csv(config::get("raw_spatial_data"), guess_max = 150000)

landcover_codes <- tribble(
  ~code, ~landcover_type,
  0, "Background",
  1, "Unclassified (Cloud, Shadow, etc)",
  2, "Impervious Developed",
  5, "Open Space Developed",
  8, "Grassland",
  11, "Upland Trees",
  12, "Scrub/Shrub",
  13, "Palustrine Forested Wetland",
  14, "Palustrine Scrub/Shrub Wetland",
  15, "Palustrine Emergent Wetland",
  16, "Estuarine Forested Wetland",
  17, "Estuarine Scrub/Shrub Wetland",
  18, "Estuarine Emergent Wetland",
  19, "Unconsolidated Shore",
  20, "Bare Land",
  21, "Water",
  22, "Palustrine Aquatic Bed",
  23, "Estuarine Aquatic Bed"
)


df %>%
  # replace merged variables with binaries
  mutate(is_road = as.numeric(!is.na(MAP_LBL))) %>%
  mutate(is_building = as.numeric(Building_Existence %in% c("Existing", "New", "Changed", "PossiblyChanged"))) %>%
  mutate(is_park = as.numeric(!is.na(Park_ID))) %>%
  mutate(is_fireCall = as.numeric(!is.na(sr_type))) %>%
  rename(fireCall_overdue = overdue) %>%
  # remove landcover 17 (n=1), 22 (n=26), and 18 (n=80) since the number of observation is too small
  filter(landcover != 17 & landcover != 22 & landcover != 18) %>%
  # add the landcover types in English
  left_join(landcover_codes, by = c("landcover" = "code")) %>%
  # select useful columns for exploration and visualization
  select(-OID_, -MAP_LBL, -Park_ID, -Building_Existence, -sr_type) %>%
  # output final dataset as a csv
  write_csv(config::get("clean_spatial_data"))