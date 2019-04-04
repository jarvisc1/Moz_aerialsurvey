# An-General characteristics
library(sf)
survey <- readRDS('data/survey.Rds') %>% st_utm()
grid <- read_sf('data/raw/grid.geojson') %>% st_utm()

nrow(survey)
survey_grid <- st_join(survey, grid, join = st_within)
length(unique(survey_grid$index))
