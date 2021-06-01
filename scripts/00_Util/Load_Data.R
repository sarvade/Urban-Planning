library(tidyverse)

get_spatial_grouped <- function(spatial_path, rect_snb_path, group_var) {
  spatial_rects <- read_csv(spatial_path, col_types = cols(fireCall_overdue = "c")) %>%
    fastDummies::dummy_cols(select_columns = "landcover_type") %>%
    janitor::clean_names() %>%
    group_by({{ group_var }}) %>%
    summarise(
      x = mean(x, na.rm = TRUE),
      y = mean(y, na.rm = TRUE),
      af_t = mean(af_t, na.rm = TRUE),
      sum_pop100 = mean(sum_pop100, na.rm = TRUE),
      is_road = mean(is_road, na.rm = TRUE),
      is_building = mean(is_building, na.rm = TRUE),
      is_park = mean(is_park, na.rm = TRUE),
      landcover_type_impervious_developed = mean(landcover_type_impervious_developed, na.rm = TRUE),
      landcover_type_bare_land = mean(landcover_type_bare_land, na.rm = TRUE),
      landcover_type_grassland = mean(landcover_type_grassland, na.rm = TRUE),
      landcover_type_palustrine_emergent_wetland = mean(landcover_type_palustrine_emergent_wetland, na.rm = TRUE),
      landcover_type_palustrine_forested_wetland = mean(landcover_type_palustrine_forested_wetland, na.rm = TRUE),
      landcover_type_palustrine_scrub_shrub_wetland = mean(landcover_type_palustrine_scrub_shrub_wetland, na.rm = TRUE),
      landcover_type_scrub_shrub = mean(landcover_type_scrub_shrub, na.rm = TRUE),
      landcover_type_unconsolidated_shore = mean(landcover_type_unconsolidated_shore, na.rm = TRUE),
      landcover_type_upland_trees = mean(landcover_type_upland_trees, na.rm = TRUE),
      landcover_type_water = mean(landcover_type_water, na.rm = TRUE)
    )
  
  read_csv(rect_snb_path) %>%
    rename(SN_rect = SNBNAME) %>%
    select(-OID_) %>% 
    right_join(spatial_rects, by = "rectangle_id_250") %>% 
    filter(!is.na(SN_rect))
}
