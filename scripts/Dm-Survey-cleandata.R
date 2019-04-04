## Load the survey data

# Read in survey, river, and road data 
# convert to utm
survey <- read_sf('data/raw/survey.geojson') %>% st_utm()
rivers <- read_sf('data/raw/rivers.geojson') %>% st_utm()
roads <- read_sf('data/raw/roads.geojson') %>% st_utm()
flood <- read_sf('data/raw/flood_20190320.geojson') %>% st_utm()
grid <- read_sf('data/raw/grid.geojson') %>% st_utm()

survey

# Create factors for character variables
# convert character sting to factors
survey$estpop_f <- factor(survey$estpop)
survey$sev_f <- factor(survey$severity)
survey$alt_f <- cut(survey$altitude, breaks = c(0, 500,1000, 2500),
                    labels = c("<500", "501 to 1000", "1000+"))


# Change the levels to correct order
survey$estpop_f <- fct_relevel(survey$estpop_f, "None", 
                               "Less than 100",
                               "Between 101 and 1,000",
                               "Between 1,001 and 5,000",
                               "More than 5,000") 
survey$sev_f <- fct_relevel(survey$sev_f, "No / Minor", 
                            "Of concern",
                            "Serious",
                            "Severe",
                            "Critical")

# Store a numeric variable for ordered categoricals
survey$estpop_n <- as.numeric(survey$estpop_f)
survey$sev_n <- as.numeric(survey$sev_f)

## Add coordinates
survey$x_utm <- st_coordinates(survey)[,1] 
survey$y_utm <- st_coordinates(survey)[,2]

# Calculate if within 1km of river or roads

within_1km_road <- st_is_within_distance(survey, roads,  dist = 1000)
within_1km_river <- st_is_within_distance(survey, rivers,  dist = 1000)

survey$within_1km_road <-  ifelse(apply(within_1km_road, 1, sum)>0, "Within 1km road", "Further than 1km of road")
survey$within_1km_river <-  ifelse(apply(within_1km_river, 1, sum)>0, "Within 1km river", "Further than 1km of river")
survey$within_1km_river_road <-  survey$within_1km_river + survey$within_1km_road
survey$within_1km_river_road_bin <-  ifelse((apply(within_1km_road, 1, sum)+apply(within_1km_river, 1, sum))>0,
                                            "Within 1km road or river", "Further than 1km of road or river")
table(survey$within_1km_river_road_bin)

# Join the grids onto the survey points
survey_grid <- st_join(survey, grid, join = st_within)

# Pick grids surveyed within the flood extent
floodindex <- c("F5", "F6", "E5", "E6", "D5", "D6", "C5", "C6", "B5", "B6", "A5", "A6")

survey$flood <- ifelse(survey_grid$index %in% floodindex, "Flood", "Not visibly flooded")
survey$worldpop <- survey_grid$worldpop
survey$worldpopcats <- cut(survey$worldpop, breaks = c(0, 10000, 50000, 75000, 1e6), 
                           labels = c("<10,000", "10,001 to 50,000", "50,001 to 75,000", "75,000+"))
head(survey)
head(survey_grid)
# Put population data onto survey points



saveRDS(survey, "data/survey.Rds")




